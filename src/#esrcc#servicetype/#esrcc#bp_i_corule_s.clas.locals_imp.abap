CLASS lcl_custom_validation DEFINITION INHERITING FROM cl_abap_behv.
  PUBLIC SECTION.
    TYPES:
      ts_rule        TYPE STRUCTURE FOR READ RESULT /esrcc/i_corule_s\\rule,
      ts_weightage   TYPE STRUCTURE FOR READ RESULT /esrcc/i_corule_s\\weightage,
      tt_rule_create TYPE TABLE FOR CREATE /esrcc/i_corule_s\\ruleall\_rule,

      BEGIN OF ts_control_rule,
        ruleid             TYPE if_abap_behv=>t_xflag,
        costversion        TYPE if_abap_behv=>t_xflag,
        chargeoutmethod    TYPE if_abap_behv=>t_xflag,
        capacityversion    TYPE if_abap_behv=>t_xflag,
        consumptionversion TYPE if_abap_behv=>t_xflag,
        keyversion         TYPE if_abap_behv=>t_xflag,
        adhocallocationkey TYPE if_abap_behv=>t_xflag,
      END OF ts_control_rule,

      BEGIN OF ts_control_weightage,
        allocationkey    TYPE if_abap_behv=>t_xflag,
        allocationperiod TYPE if_abap_behv=>t_xflag,
        refperiod        TYPE if_abap_behv=>t_xflag,
        weightage        TYPE if_abap_behv=>t_xflag,
      END OF ts_control_weightage.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_rule
        IMPORTING
          entity  TYPE ts_rule
          control TYPE ts_control_rule,
      validate_weightage
        IMPORTING
          entity  TYPE ts_weightage
          control TYPE ts_control_weightage.
    CLASS-METHODS:
      create
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util
        RETURNING
          VALUE(instance) TYPE REF TO lcl_custom_validation,

      precheck_cba_rule
        IMPORTING
          entities TYPE tt_rule_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util,
      gt_ref_period   TYPE TABLE OF /esrcc/i_allocationperiod.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD create.
    instance = NEW lcl_custom_validation( config_util_ref = config_util_ref ).
  ENDMETHOD.

  METHOD validate_rule.
    DATA:
      fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-ruleid          = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RULEID' ) TO fields. ENDIF.
    IF control-chargeoutmethod = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHARGEOUTMETHOD' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    CLEAR fields.

    DATA(co_rule_relevances) = /esrcc/cl_config_util=>get_co_rule_config( ).
    DATA(co_rule_relevance) = VALUE #( co_rule_relevances[ chargeout_method = entity-chargeoutmethod ] OPTIONAL ).

    IF control-costversion = if_abap_behv=>mk-on AND co_rule_relevance-cost_version = abap_true.
      APPEND VALUE #( fieldname = 'COSTVERSION' ) TO fields.
    ENDIF.

    IF control-capacityversion = if_abap_behv=>mk-on AND co_rule_relevance-capacity_version = abap_true.
      APPEND VALUE #( fieldname = 'CAPACITYVERSION' ) TO fields.
    ENDIF.

    IF control-consumptionversion = if_abap_behv=>mk-on AND co_rule_relevance-consumption_version = abap_true.
      APPEND VALUE #( fieldname = 'CONSUMPTIONVERSION' ) TO fields.
    ENDIF.

    IF control-keyversion = if_abap_behv=>mk-on AND co_rule_relevance-key_version = abap_true.
      APPEND VALUE #( fieldname = 'KEYVERSION' ) TO fields.
    ENDIF.

    IF control-adhocallocationkey = if_abap_behv=>mk-on AND co_rule_relevance-adhoc_allocation_key = abap_true.
      APPEND VALUE #( fieldname = 'ADHOCALLOCATIONKEY' ) TO fields.
    ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD validate_weightage.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF gt_ref_period IS INITIAL.
      SELECT DISTINCT *
        FROM /esrcc/i_allocationperiod
        INTO TABLE @gt_ref_period.                      "#EC CI_NOWHERE
    ENDIF.

    IF control-allocationkey    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONKEY' ) TO fields. ENDIF.
    IF control-allocationperiod = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONPERIOD' ) TO fields. ENDIF.

    IF control-refperiod = if_abap_behv=>mk-on.
      IF entity-allocationperiod = '03' OR entity-allocationperiod = '04' OR entity-allocationperiod = '06'.
        APPEND VALUE #( fieldname = 'REFPERIOD' ) TO fields.
      ELSEIF entity-refperiod IS NOT INITIAL.
        config_util_ref->set_state_message(
          fieldname = 'REFPERIOD'
          entity    = entity
          msg       = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                   number   = '010'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = VALUE #( gt_ref_period[ allocationperiod = entity-allocationperiod ]-text OPTIONAL ) )
         state_area = CONV #( /esrcc/cl_config_util=>non_mandatory )
        ).
      ENDIF.
    ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-weightage = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'WEIGHTAGE' ) )
        entity = entity
      ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_rule.
    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_CORULE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_rule(
          entity  = CORRESPONDING #( target )
          control = VALUE #( ruleid = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/CORULE'
                                       table_entity_relations = VALUE #( ( entity = 'Rule' table = '/ESRCC/CO_RULE' )
                                                                         ( entity = 'RuleText' table = '/ESRCC/CO_RULET' )
                                                                         ( entity = 'Weightage' table = '/ESRCC/ALOC_WGT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_corule_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ruleall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ruleall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ruleall
        RESULT result,
      precheck_cba_rule FOR PRECHECK
        IMPORTING entities FOR CREATE ruleall\_rule.
ENDCLASS.

CLASS lhc_/esrcc/i_corule_s IMPLEMENTATION.
  METHOD get_instance_features.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ).
      DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    ELSE.
      edit_flag = if_abap_behv=>fc-o-enabled.
    ENDIF.

    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
    ENTITY ruleall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_rule = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
      ENTITY ruleall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
      ENTITY ruleall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CORULE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_rule.
    lcl_custom_validation=>precheck_cba_rule(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-rule
        reported = reported-rule ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_corule_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_corule_s IMPLEMENTATION.
  METHOD save_modified.
    DATA:
      co_rules TYPE TABLE OF /esrcc/co_rule,
      rule_ids TYPE RANGE OF /esrcc/chargeout_rule_id.

    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-ruleall INDEX 1 INTO DATA(all).
      IF all-transportrequestid IS NOT INITIAL.
        lhc_rap_tdat_cts=>get( )->record_changes(
                                    transport_request = all-transportrequestid
                                    create            = REF #( create )
                                    update            = REF #( update )
                                    delete            = REF #( delete ) ).
      ENDIF.
    ENDIF.

    IF update-rule IS INITIAL.
      RETURN.
    ENDIF.

    DATA(co_rule_relevances) = /esrcc/cl_config_util=>get_co_rule_config( ).

    LOOP AT update-rule ASSIGNING FIELD-SYMBOL(<chargeout>) WHERE %control-chargeoutmethod = if_abap_behv=>mk-on.
      DATA(co_rule_relevance) = VALUE #( co_rule_relevances[ chargeout_method = <chargeout>-chargeoutmethod ] OPTIONAL ).

      APPEND VALUE /esrcc/co_rule( rule_id = <chargeout>-ruleid
                                   chargeout_method      = <chargeout>-chargeoutmethod
*                                   cost_version          = COND #( WHEN co_rule_relevance-cost_version         = abap_true THEN <chargeout>-costversion )
                                   capacity_version      = COND #( WHEN co_rule_relevance-capacity_version     = abap_true THEN <chargeout>-capacityversion )
                                   consumption_version   = COND #( WHEN co_rule_relevance-consumption_version  = abap_true THEN <chargeout>-consumptionversion )
                                   key_version           = COND #( WHEN co_rule_relevance-key_version          = abap_true THEN <chargeout>-keyversion )
                                   adhoc_allocation_key  = COND #( WHEN co_rule_relevance-adhoc_allocation_key = abap_true THEN <chargeout>-adhocallocationkey )
                                   created_by            = <chargeout>-createdby
                                   created_at            = <chargeout>-createdat
                                   last_changed_by       = <chargeout>-lastchangedby
                                   last_changed_at       = <chargeout>-lastchangedat
                                   local_last_changed_at = <chargeout>-locallastchangedat ) TO co_rules.

      IF co_rule_relevance-weightage_tab = abap_false.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <chargeout>-ruleid ) TO rule_ids.
      ENDIF.
    ENDLOOP.

    IF co_rules IS NOT INITIAL.
      UPDATE /esrcc/co_rule FROM TABLE @co_rules.
    ENDIF.

    IF rule_ids IS NOT INITIAL.
      DELETE FROM /esrcc/aloc_wgt WHERE rule_id IN @rule_ids.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_corule DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_corule TYPE TABLE FOR READ RESULT /esrcc/i_corule_s\\rule.

    CLASS-METHODS set_workflow_status
      IMPORTING
        entities                     TYPE tt_corule
        for_workflow_internal_status TYPE /esrcc/status_de
        to_workflow_status           TYPE /esrcc/status_de.

    CLASS-METHODS set_workflow_internal_status
      IMPORTING
        entities           TYPE tt_corule
        to_workflow_status TYPE /esrcc/status_de.

  PRIVATE SECTION.
    METHODS:
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE rule.

    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR rule~validatedata.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR rule RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR rule RESULT result.

    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION rule~finalize RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION rule~submit RESULT result.

    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR rule~updateworkflowstatus.
    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR rule~triggerworkflow.
    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR rule~updateinternalworkflowstatus.
    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION rule~reopen RESULT result.
    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR rule~updatecomment.
    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION rule~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR rule~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_corule IMPLEMENTATION.
  METHOD precheck_update.
    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'RuleAll' ) )
          source_entity_name = '/ESRCC/C_CORULE'
        CHANGING
          reported_entity    = reported-rule
          failed_entity      = failed-rule ) ).

    SELECT ruleid, chargeoutmethod
      FROM /esrcc/d_co_rule
      FOR ALL ENTRIES IN @entities
      WHERE ruleid = @entities-ruleid
      INTO TABLE @DATA(rules).

    LOOP AT entities INTO DATA(entity) WHERE %control-chargeoutmethod    = if_abap_behv=>mk-on
*                                          OR %control-costversion        = if_abap_behv=>mk-on
                                          OR %control-capacityversion    = if_abap_behv=>mk-on
                                          OR %control-consumptionversion = if_abap_behv=>mk-on
                                          OR %control-keyversion         = if_abap_behv=>mk-on
                                          OR %control-adhocallocationkey = if_abap_behv=>mk-on.

      IF entity-%control-chargeoutmethod = if_abap_behv=>mk-off.
        entity-chargeoutmethod = VALUE #( rules[ ruleid = entity-ruleid ]-chargeoutmethod OPTIONAL ).
      ENDIF.

      lo_validation->validate_rule(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chargeoutmethod    = entity-%control-chargeoutmethod
*                           costversion        = entity-%control-costversion
                           capacityversion    = entity-%control-capacityversion
                           consumptionversion = entity-%control-consumptionversion
                           keyversion         = entity-%control-keyversion
                           adhocallocationkey = entity-%control-adhocallocationkey ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_corule_s\\rule.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
         ENTITY rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    SELECT wgt~ruleid, SUM( wgt~weightage ) AS weightage
      FROM /esrcc/d_alocwgt AS wgt
      INNER JOIN @entities AS ent
         ON ent~ruleid = wgt~ruleid
      WHERE wgt~draftentityoperationcode NOT IN ( 'D', 'L' )
      GROUP BY wgt~ruleid
      INTO TABLE @DATA(weightages).

    DATA(lo_rule) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_CORULE'
      CHANGING
        reported_entity    = reported-rule
        failed_entity      = failed-rule ).

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = lo_rule ).
    DATA(co_rule_relevances) = /esrcc/cl_config_util=>get_co_rule_config( ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_rule(
        entity  = entity
        control = VALUE #( chargeoutmethod    = if_abap_behv=>mk-on
                           costversion        = if_abap_behv=>mk-on
                           capacityversion    = if_abap_behv=>mk-on
                           consumptionversion = if_abap_behv=>mk-on
                           keyversion         = if_abap_behv=>mk-on
                           adhocallocationkey = if_abap_behv=>mk-on )
      ).

      DATA(weightage) = VALUE #( weightages[ ruleid = entity-ruleid ] OPTIONAL ).

      IF VALUE #( co_rule_relevances[ chargeout_method = entity-chargeoutmethod ]-weightage_tab OPTIONAL ) = abap_true.
        " Validate Weightage %
        IF weightage IS INITIAL.
          lo_rule->set_state_message(
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '011' severity = if_abap_behv_message=>severity-error )
            state_area = CONV #( /esrcc/cl_config_util=>child_mandatory )
          ).
        ELSEIF weightage-weightage <> 100.
          lo_rule->set_state_message(
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_rule->get_field_text( fieldname = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
            state_area = CONV #( /esrcc/cl_config_util=>percentage )
          ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities
                      LET update = lo_auth->regulate_action_update( wf_status = wa-workflowstatus )
                      IN ( %tky              = wa-%tky
                           %action-copy      = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-submit    = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-finalize  = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-reopen    = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %update           = update
                           %delete           = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %assoc-_ruletext  = update
                           %assoc-_weightage = update ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CORULE' ).
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-finalize_in_process
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-finalize_in_process
                          workflowstatuscriticality = criticality ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky %param = entity ) ).
    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD submit.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
            ENTITY rule
            UPDATE FIELDS ( commentid comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
            WITH VALUE #( FOR entity IN entities
                            ( %tky                      = entity-%tky
                              workflowid                = ''
                              commentid                 = COND #( WHEN entity-commentid IS INITIAL THEN
                                                                  cl_uuid_factory=>create_system_uuid( )->create_uuid_c32( )
                                                                  ELSE entity-commentid )
                              comments                  = VALUE #( keys[ KEY draft %tky = entity-%tky ]-%param-comments OPTIONAL )
                              workflowstatus            = /esrcc/cl_wf_utility=>wf_status-in_process
                              workflowstatuscriticality = criticality
                              workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-in_process ) )
            FAILED failed
            REPORTED reported
            MAPPED mapped.
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param-comments = entity-comments ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD updateworkflowstatus.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set workflow status to "Draft"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>wf_status-draft
      to_workflow_status           = /esrcc/cl_wf_utility=>wf_status-draft
    ).

    " Set workflow status to "Finalized"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>wf_status-finalize_in_process
      to_workflow_status           = /esrcc/cl_wf_utility=>wf_status-finalized
    ).

    " Set workflow status to "Approved"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>wf_status-reopen_in_process
      to_workflow_status           = /esrcc/cl_wf_utility=>wf_status-approved
    ).
  ENDMETHOD.

  METHOD set_workflow_status.
    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = to_workflow_status ).
    MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus = for_workflow_internal_status )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowstatus            = to_workflow_status
                          workflowstatuscriticality = criticality
                          %control                  = VALUE #( workflowstatus            = if_abap_behv=>mk-on
                                                               workflowstatuscriticality = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.


  METHOD set_workflow_internal_status.
    MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
          ENTITY rule
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> to_workflow_status )
                          ( %tky                      = entity-%tky
                            %is_draft                 = entity-%is_draft
                            workflowinternalstatus    = to_workflow_status
                            %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD triggerworkflow.
    DATA leading_objects_failed TYPE /esrcc/tt_wf_leadingobject_err.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>app-bc_charge_out_rule ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.

      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject( entities MAPPING rule_id = ruleid EXCEPT * )
        IMPORTING
          leading_objects_error = leading_objects_failed
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( ruleid                    = failed-leading_object-rule_id
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
          ENTITY rule
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-approved
                          workflowstatuscriticality = criticality
                          workflowinternalstatus    = workflow_internal_status ) )
        FAILED failed_mod
        MAPPED mapped_mod.
    ENDIF.
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set internal status to "Draft" for modified entries
    set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>wf_status-draft
    ).
  ENDMETHOD.

  METHOD reopen.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        UPDATE FIELDS ( comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowid                = ''
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-reopen_in_process
                          workflowstatuscriticality = criticality
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-reopen_in_process ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param-%tky = entity-%tky ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD updatecomment.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity) WHERE commentid IS NOT INITIAL.
      /esrcc/cl_comments_util=>modify_comments(
        comments    = VALUE #( instanceid = entity-commentid )
        iv_comments = entity-comments
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_corule_s\_rule,
      new_text TYPE TABLE FOR CREATE /esrcc/i_corule_s\\rule\_ruletext,
      new_wgt  TYPE TABLE FOR CREATE /esrcc/i_corule_s\\rule\_weightage.

    FIELD-SYMBOLS:
      <new_text> LIKE LINE OF new_text,
      <new_wgt>  LIKE LINE OF new_wgt.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-rule = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
      ENTITY rule
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
      ENTITY rule BY \_ruletext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text)

      ENTITY rule BY \_weightage
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_wgt).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid      = key_cid
                             %is_draft = <ref_main>-%is_draft
                             %data     = CORRESPONDING #( <ref_main> EXCEPT ruleid singletonid )
                             ruleid  = key-%param-ruleid ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
                                                                            AND %tky-ruleid    = key-%tky-ruleid.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && <ref_text>-spras
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_text> EXCEPT ruleid singletonid )
                        ruleid    = key-%param-ruleid ) INTO TABLE <new_text>-%target.
      ENDLOOP.

      UNASSIGN <new_wgt>.
      LOOP AT ref_wgt ASSIGNING FIELD-SYMBOL(<ref_wgt>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
                                                                          AND %tky-ruleid    = key-%tky-ruleid.
        IF <new_wgt> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_wgt ASSIGNING <new_wgt>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && <ref_wgt>-allocationkey
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_wgt> EXCEPT ruleid singletonid )
                        ruleid    = key-%param-ruleid ) INTO TABLE <new_wgt>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_rule(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-rule
        reported = reported-rule ).

    IF failed-rule IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY ruleall CREATE BY \_rule
        FIELDS (
                 ruleid
*                 costversion
                 chargeoutmethod
                 capacityversion
                 consumptionversion
                 keyversion
                 adhocallocationkey
               ) WITH new_main
        ENTITY rule CREATE BY \_ruletext
        FIELDS (
                 spras
                 ruleid
                 description
               ) WITH new_text
        ENTITY rule CREATE BY \_weightage
        FIELDS (
                 ruleid
                 allocationkey
                 allocationperiod
                 refperiod
                 weightage
               ) WITH new_wgt
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-rule = mapped_create-rule.
    INSERT LINES OF read_failed-rule INTO TABLE failed-rule.

    IF failed-rule IS INITIAL AND failed-ruletext IS INITIAL AND failed-weightage IS INITIAL.
      reported-rule = VALUE #( FOR created IN mapped-rule (
                                     %cid          = created-%cid
                                     %action-copy  = if_abap_behv=>mk-on
                                     %msg          = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-ruleall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_corule_s.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_co_ru_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/CO_RULE'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-rule ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_coruletext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR ruletext RESULT result,
      updateinternalworkflowstatus FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ruletext~updateinternalworkflowstatus,
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING keys FOR ruletext~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_coruletext IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY ruletext
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(text).

    SELECT SINGLE rule~workflowstatus
        FROM /esrcc/i_corule AS rule
        INNER JOIN @text AS txt
            ON txt~ruleid = rule~ruleid
        INTO @DATA(wf_status).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    DATA(regulate_update) = lo_auth->regulate_action_update( wf_status = wf_status ).
    DATA(regulate_delete) = lo_auth->regulate_action_delete( wf_status = wf_status ).

    result = VALUE #( FOR wa IN text ( %tky    = wa-%tky
                                       %update = regulate_update
                                       %delete = regulate_delete ) ).
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY ruletext
        BY \_rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT entities.
    ENDIF.

    lhc_/esrcc/i_corule=>set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>wf_status-draft
    ).
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_corule_s.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_co_ru_s INTO @DATA(transportrequestid). "#EC CI_NOORDER

      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/CO_RULET'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-ruletext ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_weightage DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE weightage.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR weightage~validatedata.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR weightage RESULT result.
    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR weightage~updateinternalworkflowstatus.
    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR weightage~validatetransportrequest.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR weightage RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION weightage~copy.

ENDCLASS.

CLASS lhc_weightage IMPLEMENTATION.
  METHOD precheck_update.
    DATA: weightage TYPE STRUCTURE FOR READ RESULT /esrcc/i_corule_s\\weightage.

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' )
                                      ( path = 'Rule' ) )
        source_entity_name = '/ESRCC/C_ALLOCWEIGHTAGE'
      CHANGING
        reported_entity    = reported-weightage
        failed_entity      = failed-weightage ) ).

    SELECT ruleid, allocationkey, allocationperiod
        FROM /esrcc/d_alocwgt
        FOR ALL ENTRIES IN @entities
        WHERE ruleid        = @entities-ruleid
          AND allocationkey = @entities-allocationkey
          AND draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(draft).

    LOOP AT entities INTO DATA(entity) WHERE %control-allocationperiod = if_abap_behv=>mk-on
                                          OR %control-refperiod        = if_abap_behv=>mk-on
                                          OR %control-weightage        = if_abap_behv=>mk-on.
      weightage = CORRESPONDING #( entity ).
*      weightage-singletonid = '1'.     " Commented to avoid dump, that occurs when removing the value of mandatory field and hitting enter without tab out.

      IF entity-%control-allocationperiod = if_abap_behv=>mk-off.
        weightage-allocationperiod = VALUE #( draft[ ruleid        = entity-ruleid
                                                     allocationkey = entity-allocationkey ]-allocationperiod OPTIONAL ).
      ENDIF.

      lo_validation->validate_weightage(
        entity  = weightage
        control = VALUE #( allocationperiod = entity-%control-allocationperiod
                           refperiod        = entity-%control-refperiod
                           weightage        = entity-%control-weightage )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA:
      fieldnames TYPE /esrcc/cl_config_util=>tt_fields,
      ls_rule    TYPE STRUCTURE FOR READ RESULT /esrcc/i_corule_s\\rule.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
         ENTITY weightage
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(unique_entities) = entities.
    SORT unique_entities BY ruleid.
    DELETE ADJACENT DUPLICATES FROM unique_entities COMPARING ruleid.

    SELECT ent~%is_draft AS is_draft, ent~singletonid, wgt~ruleid, SUM( wgt~weightage ) AS weightage
      FROM /esrcc/d_alocwgt AS wgt
      INNER JOIN @unique_entities AS ent
        ON  ent~ruleid = wgt~ruleid
      WHERE wgt~draftentityoperationcode NOT IN ( 'D', 'L' )
      GROUP BY ent~%is_draft, ent~singletonid, wgt~ruleid
      HAVING SUM( wgt~weightage ) <> 100
      INTO TABLE @DATA(weightages).

    DATA(lo_weightage) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' )
                                      ( path = 'Rule' ) )
        source_entity_name = '/ESRCC/C_ALLOCWEIGHTAGE'
      CHANGING
        reported_entity    = reported-weightage
        failed_entity      = failed-weightage ).

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = lo_weightage ).

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(rules).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_weightage(
        entity  = entity
        control = VALUE #( allocationperiod = if_abap_behv=>mk-on
                           refperiod        = if_abap_behv=>mk-on
                           weightage        = if_abap_behv=>mk-on )
      ).

      IF line_exists( weightages[ ruleid = entity-ruleid ] ).
        lo_weightage->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_weightage->get_field_text( fieldname = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
        DELETE weightages WHERE ruleid = entity-ruleid.     " Error message already displayed, delete it
      ENDIF.

      IF VALUE #( rules[ KEY entity ruleid = entity-ruleid ]-chargeoutmethod OPTIONAL ) = 'D'.
        lo_weightage->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '012' severity = if_abap_behv_message=>severity-error )
          state_area = CONV #( /esrcc/cl_config_util=>child_non_mandatory )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY weightage
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(weightage).

    SELECT SINGLE rule~workflowstatus
        FROM /esrcc/i_corule AS rule
        INNER JOIN @weightage AS wgt
            ON wgt~ruleid = rule~ruleid
        INTO @DATA(wf_status).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    DATA(regulate_update) = lo_auth->regulate_action_update( wf_status = wf_status ).
    DATA(regulate_delete) = lo_auth->regulate_action_delete( wf_status = wf_status ).

    result = VALUE #( FOR wa IN weightage ( %tky         = wa-%tky
                                            %update      = regulate_update
                                            %delete      = regulate_delete
                                            %action-copy = lo_auth->regulate_action_copy_obj_page( is_draft = wa-%is_draft wf_status = wf_status ) ) ).
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY weightage
        BY \_rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
        ENTITY rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT entities.
    ENDIF.

    lhc_/esrcc/i_corule=>set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>wf_status-draft
    ).
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_corule_s.

    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_co_ru_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/ALOC_WGT'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-weightage ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CORULE' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_corule_s\\rule\_weightage.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-weightage = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
      ENTITY weightage
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %is_draft = <ref_main>-%is_draft
        ruleid = key-ruleid
        %target = VALUE #( ( %cid          = key_cid
                             %is_draft     = <ref_main>-%is_draft
                             %data         = CORRESPONDING #( <ref_main> EXCEPT allocationkey singletonid )
                             allocationkey = key-%param-allocationkey ) ) ) TO new_main ASSIGNING FIELD-SYMBOL(<new_main>).
    ENDLOOP.

    MODIFY ENTITIES OF /esrcc/i_corule_s IN LOCAL MODE
      ENTITY rule CREATE BY \_weightage
      FIELDS (
               ruleid
               allocationkey
               allocationperiod
               refperiod
               weightage
             ) WITH new_main
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-weightage = mapped_create-weightage.
    INSERT LINES OF read_failed-weightage INTO TABLE failed-weightage.

    IF failed-weightage IS INITIAL.
      reported-weightage = VALUE #( FOR created IN mapped-weightage (
                                     %cid          = created-%cid
                                     %action-copy  = if_abap_behv=>mk-on
                                     %msg          = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-ruleall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
