CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_hier_def        TYPE STRUCTURE FOR READ RESULT /esrcc/i_hierdef_s\\hierdef,
      tt_hier_def_create TYPE TABLE FOR CREATE /esrcc/i_hierdef_s\\hierdefall\_hierdef,
      BEGIN OF ts_control,
        validfrom   TYPE if_abap_behv=>t_xflag,
        validto     TYPE if_abap_behv=>t_xflag,
        stewardship TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_hierarchy_definition
        IMPORTING
          entity  TYPE ts_hier_def
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_hierarchy_def
        IMPORTING
          entities TYPE tt_hier_def_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_hierarchy_definition.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_initial(
        fields = VALUE #( ( fieldname = 'VALIDTO' ) )
        entity = entity
      ).
    ENDIF.

    IF control-validto    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
        fields = fields
        entity = entity
      ).

    CLEAR fields.
    IF control-stewardship = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'STEWARDSHIP' ) TO fields. ENDIF.
    config_util_ref->validate_percentage(
      fields = fields
      entity = entity
    ).

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_from) = entity-validfrom.
      DATA(lv_to) = entity-validto.
      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_from
          end_date   = lv_to
      ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_hierarchy_def.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'HierDefAll' ) )
        source_entity_name = '/ESRCC/C_HIERDEF'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_hierarchy_definition(
          entity  = CORRESPONDING #( target )
          control = VALUE #( validfrom  = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_rap_tdat_cts DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/HIERDEF'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'HierDef' table = '/ESRCC/HIER_DEF' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_hierdef_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR hierdefall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION hierdefall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR hierdefall
        RESULT result,
      precheck_cba_hierdef FOR PRECHECK
        IMPORTING entities FOR CREATE hierdefall\_hierdef.
ENDCLASS.

CLASS lhc_/esrcc/i_hierdef_s IMPLEMENTATION.
  METHOD get_instance_features.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ).
      DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    ELSE.
      edit_flag = if_abap_behv=>fc-o-enabled.
    ENDIF.

    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
    ENTITY hierdefall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_hierdef = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
      ENTITY hierdefall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
      ENTITY hierdefall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_HIERDEF' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_hierdef.
    lcl_custom_validation=>precheck_cba_hierarchy_def(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-hierdef
        reported = reported-hierdef ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_hierdef_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_hierdef_s IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-hierdefall INDEX 1 INTO DATA(all).
      IF all-transportrequestid IS NOT INITIAL.
        lhc_rap_tdat_cts=>get( )->record_changes(
                                    transport_request = all-transportrequestid
                                    create            = REF #( create )
                                    update            = REF #( update )
                                    delete            = REF #( delete ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_hierdef DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: tt_hier_def TYPE TABLE FOR READ RESULT /esrcc/i_hierdef_s\\hierdef.

    METHODS:
      set_workflow_status
        IMPORTING
          entities                     TYPE tt_hier_def
          for_workflow_internal_status TYPE /esrcc/status_de
          to_workflow_status           TYPE /esrcc/status_de,
      schedule_hier_def
        IMPORTING
          option  TYPE /esrcc/mass_create_option
        EXPORTING
          message TYPE csequence
          failed  TYPE abap_boolean.

    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR hierdef~validatetransportrequest,
*      get_global_features FOR GLOBAL FEATURES
*        IMPORTING
*        REQUEST requested_features FOR hierdef
*        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION hierdef~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR hierdef
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR hierdef
        RESULT    result,
      finalize FOR MODIFY
        IMPORTING keys FOR ACTION hierdef~finalize RESULT result.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION hierdef~reopen RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION hierdef~submit RESULT result.

    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR hierdef~updateinternalworkflowstatus.

    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierdef~triggerworkflow.

    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierdef~updatecomment.

    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierdef~updateworkflowstatus.
    METHODS schedulejob FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierdef~schedulejob.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR hierdef~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE hierdef.
    METHODS autogenerate FOR MODIFY
      IMPORTING keys FOR ACTION  hierdef~autogenerate.
    METHODS sync FOR MODIFY
      IMPORTING keys FOR ACTION hierdef~sync.

ENDCLASS.

CLASS lhc_/esrcc/i_hierdef IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_hierdef_s.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_hier__s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/HIER_DEF'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-hierdef ) ).
    ENDIF.
  ENDMETHOD.
*  METHOD get_global_features.
**    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
**    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
**      edit_flag = if_abap_behv=>fc-o-disabled.
**    ENDIF.
*
*    IF lhc_rap_tdat_cts=>get( )->is_editable( ).
*      DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
*    ELSE.
*      edit_flag = if_abap_behv=>fc-o-enabled.
*    ENDIF.
*    result-%update = edit_flag.
*    result-%delete = edit_flag.
*
*  ENDMETHOD.
  METHOD copy.
    DATA new_hierdef TYPE TABLE FOR CREATE /esrcc/i_hierdef_s\_hierdef.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-hierdef = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
      ENTITY hierdef
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_hierdef)
      FAILED DATA(read_failed).

    LOOP AT ref_hierdef ASSIGNING FIELD-SYMBOL(<ref_hierdef>).
      DATA(key) = keys[ KEY draft %tky = <ref_hierdef>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_hierdef>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_hierdef>-%is_draft
          %data = CORRESPONDING #( <ref_hierdef> EXCEPT
            createdat
            createdby
            hierarchy1
            hierarchy2
            hierarchy3
            hierarchy4
            lastchangedat
            lastchangedby
            locallastchangedat
            singletonid
            validfrom
        ) ) )
      ) TO new_hierdef ASSIGNING FIELD-SYMBOL(<new_hierdef>).
      <new_hierdef>-%target[ 1 ]-hierarchy1 = key-%param-hierarchy1.
      <new_hierdef>-%target[ 1 ]-hierarchy2 = key-%param-hierarchy2.
      <new_hierdef>-%target[ 1 ]-hierarchy3 = key-%param-hierarchy3.
      <new_hierdef>-%target[ 1 ]-hierarchy4 = key-%param-hierarchy4.
      <new_hierdef>-%target[ 1 ]-validfrom = key-%param-validfrom.
    ENDLOOP.

    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
      ENTITY hierdefall CREATE BY \_hierdef
      FIELDS (
               hierarchy1
               hierarchy2
               hierarchy3
               hierarchy4
               validfrom
               validto
               srvprddef
               srvrecdef
               stewardship
               chainid
               ishub
               currencyderivationtype
               workflowid
               workflowstatus
             ) WITH new_hierdef
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-hierdef = mapped_create-hierdef.
    INSERT LINES OF read_failed-hierdef INTO TABLE failed-hierdef.

    IF failed-hierdef IS INITIAL.
      reported-hierdef = VALUE #( FOR created IN mapped-hierdef (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-hierdefall-%is_draft = created-%is_draft
                                                 %path-hierdefall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_HIERDEF' ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
          ENTITY hierdef
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities ( %tky                 = wa-%tky
                                           %action-copy         = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                                           %action-submit       = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                                           %action-finalize     = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                                           %action-reopen       = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                                           %action-sync         = lo_auth->regulate_action_sync( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                                           %action-autogenerate = lo_auth->regulate_action_autogenerate( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                                           %update              = lo_auth->regulate_action_update( wf_status = wa-workflowstatus )
                                           %delete              = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus ) ) ).
  ENDMETHOD.
  METHOD finalize.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        UPDATE FIELDS ( workflowinternalstatus workflowstatus workflowstatuscriticality )
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

  METHOD reopen.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
    ENTITY hierdef
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
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

  METHOD submit.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
            ENTITY hierdef
            UPDATE FIELDS ( commentid comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
            WITH VALUE #( FOR entity IN entities
                            ( %tky                      = entity-%tky
                              workflowid                = ''
                              commentid                 = COND #( WHEN entity-commentid IS INITIAL THEN cl_uuid_factory=>create_system_uuid( )->create_uuid_c32( ) ELSE entity-commentid )
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
                                               %param-%tky = entity-%tky ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set internal status to "Draft" for modified entries
    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        UPDATE FIELDS ( workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-draft )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-draft
                          %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD triggerworkflow.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>app-bc_hierarchy_definition ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.

      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow_bc(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject_bc( entities MAPPING valid_from = validfrom )
        IMPORTING
          leading_objects_error = DATA(leading_objects_failed)
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( hierarchy1                = failed-leading_object-serviceproduct
                          hierarchy2                = failed-leading_object-serviceproduct
                          hierarchy3                = failed-leading_object-serviceproduct
                          hierarchy4                = failed-leading_object-serviceproduct
                          validfrom                 = failed-leading_object-valid_from
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
          ENTITY hierdef
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
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

  METHOD updatecomment.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity) WHERE commentid IS NOT INITIAL.
      /esrcc/cl_comments_util=>modify_comments(
        comments    = VALUE #( instanceid = entity-commentid )
        iv_comments = entity-comments
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD updateworkflowstatus.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
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
    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus = for_workflow_internal_status )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowstatus            = to_workflow_status
                          workflowstatuscriticality = criticality
                          %control                  = VALUE #( workflowstatus            = if_abap_behv=>mk-on
                                                               workflowstatuscriticality = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD schedulejob.
    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-finalize_in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(workflow_internal_status) = ''.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).
      TRY.
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = '/ESRCC/HIER_DEF_TMPL'
              iv_job_text            = 'SCC Stewardship Mass Generator'
              is_start_info          = VALUE #( start_immediately = abap_true )
              it_job_parameter_value = VALUE #( ( name = 'HIER1'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_entity>-hierarchy1 ) ) )
                                                ( name = 'HIER2'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_entity>-hierarchy2 ) ) )
                                                ( name = 'HIER3'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_entity>-hierarchy3 ) ) )
                                                ( name = 'HIER4'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_entity>-hierarchy4 ) ) )
                                                ( name = 'VALIDFR' t_value = VALUE #( ( sign = 'I' option = 'EQ' low = <fs_entity>-validfrom ) ) ) )
            IMPORTING
              ev_jobname             = DATA(job_name)
              ev_jobcount            = DATA(job_count) ).

          DATA(job_scheduled) = abap_true.
        CATCH cx_apj_rt INTO DATA(lr_apj_rt).
          DATA(error_message) = lr_apj_rt->get_text( ).
          <fs_entity>-workflowstatus = /esrcc/cl_wf_utility=>wf_status-finalize_in_error.
          <fs_entity>-workflowstatuscriticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-finalize_in_error ).

          APPEND VALUE #( %tky = <fs_entity>-%tky
                          %msg = NEW cl_abap_behv( )->new_message_with_text(
                                                     severity = if_abap_behv_message=>severity-error
                                                     text     = error_message ) ) TO reported-hierdef.
      ENDTRY.
    ENDLOOP.

    " Reset internal status
    MODIFY ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
        ENTITY hierdef
        UPDATE FIELDS ( workflowinternalstatus workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR ent IN entities
                        ( %tky                      = ent-%tky
                          workflowinternalstatus    = workflow_internal_status
                          workflowstatus            = ent-workflowstatus
                          workflowstatuscriticality = ent-workflowstatuscriticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

    IF job_scheduled = abap_true.
      APPEND NEW /esrcc/cl_config_msg_handler( )->background_job_scheduled( v1 = TEXT-000 ) TO reported-%other.
    ENDIF.
  ENDMETHOD.

  METHOD validatedata.
    DATA draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_hierdef_s\\hierdef.

    READ ENTITIES OF /esrcc/i_hierdef_s IN LOCAL MODE
         ENTITY hierdef
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    " Draft version data
    SELECT hier~*
      FROM /esrcc/d_hier_de AS hier
      INNER JOIN @keys AS key
          ON  key~hierarchy1 = hier~hierarchy1
          AND key~hierarchy2 = hier~hierarchy2
          AND key~hierarchy3 = hier~hierarchy3
          AND key~hierarchy4 = hier~hierarchy4
          AND key~validfrom <> hier~validfrom
      WHERE hier~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entities).

    DATA(lo_hier_def) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'HierDefAll' ) )
        source_entity_name = '/ESRCC/C_HIERDEF'
      CHANGING
        reported_entity    = reported-hierdef
        failed_entity      = failed-hierdef ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_hier_def ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_hierarchy_definition(
        entity  = entity
        control = VALUE #( validfrom   = if_abap_behv=>mk-on
                           validto     = if_abap_behv=>mk-on
                           stewardship = if_abap_behv=>mk-on )
      ).

      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     hierarchy1  = entity-hierarchy1
                 AND hierarchy2  = entity-hierarchy2
                 AND hierarchy3  = entity-hierarchy3
                 AND hierarchy4  = entity-hierarchy4
                 AND validfrom  <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).

        lo_hier_def->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
                                                              src_to      = <draft>-validto
                                                              src_entity  = draft
                                                              curr_from   = entity-validfrom
                                                              curr_to     = entity-validto
                                                              curr_entity = entity ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'HierDefAll' ) )
        source_entity_name = '/ESRCC/C_HIERDEF'
      CHANGING
        reported_entity    = reported-hierdef
        failed_entity      = failed-hierdef ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-validto     = if_abap_behv=>mk-on
                                          OR %control-stewardship = if_abap_behv=>mk-on.
      lo_validation->validate_hierarchy_definition(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( validto     = entity-%control-validto
                             stewardship = entity-%control-stewardship )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD autogenerate.
    LOOP AT keys INTO DATA(key).
      TRY.
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = '/ESRCC/HIER_DEF_TMPL'
              iv_job_text            = 'SCC Stewardship Mass Generator'
              is_start_info          = VALUE #( start_immediately = abap_true )
              it_job_parameter_value = VALUE #( ( name = 'HIER1'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy1 ) ) )
                                                ( name = 'HIER2'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy2 ) ) )
                                                ( name = 'HIER3'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy3 ) ) )
                                                ( name = 'HIER4'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy4 ) ) )
                                                ( name = 'VALIDFR' t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-validfrom  ) ) )
                                                ( name = 'OPTIONS' t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-%param-options ) ) ) )
            IMPORTING
              ev_jobname             = DATA(job_name)
              ev_jobcount            = DATA(job_count) ).

          DATA(job_scheduled) = abap_true.
        CATCH cx_apj_rt INTO DATA(lr_apj_rt).
          APPEND VALUE #( %tky = key-%tky
                          %msg = NEW cl_abap_behv( )->new_message_with_text(
                                                     severity = if_abap_behv_message=>severity-error
                                                     text     = lr_apj_rt->get_text( ) ) ) TO reported-hierdef.
          RETURN.
      ENDTRY.
    ENDLOOP.

    IF job_scheduled = abap_true.
      APPEND NEW /esrcc/cl_config_msg_handler( )->inform_on_sync( ) TO reported-%other.
    ENDIF.
  ENDMETHOD.

  METHOD schedule_hier_def.

  ENDMETHOD.

  METHOD sync.
    LOOP AT keys INTO DATA(key).
      TRY.
          cl_apj_rt_api=>schedule_job(
            EXPORTING
              iv_job_template_name   = '/ESRCC/HIER_DEF_TMPL'
              iv_job_text            = 'SCC Stewardship Mass Generator'
              is_start_info          = VALUE #( start_immediately = abap_true )
              it_job_parameter_value = VALUE #( ( name = 'HIER1'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy1 ) ) )
                                                ( name = 'HIER2'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy2 ) ) )
                                                ( name = 'HIER3'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy3 ) ) )
                                                ( name = 'HIER4'   t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-hierarchy4 ) ) )
                                                ( name = 'VALIDFR' t_value = VALUE #( ( sign = 'I' option = 'EQ' low = key-validfrom  ) ) )
                                                ( name = 'SYNC'    t_value = VALUE #( ( sign = 'I' option = 'EQ' low = abap_true ) ) ) )
            IMPORTING
              ev_jobname             = DATA(job_name)
              ev_jobcount            = DATA(job_count) ).

          DATA(job_scheduled) = abap_true.
        CATCH cx_apj_rt INTO DATA(lr_apj_rt).
          APPEND VALUE #( %tky = key-%tky
                          %msg = NEW cl_abap_behv( )->new_message_with_text(
                                                     severity = if_abap_behv_message=>severity-error
                                                     text     = lr_apj_rt->get_text( ) ) ) TO reported-hierdef.
      ENDTRY.
    ENDLOOP.

    IF job_scheduled = abap_true.
      APPEND NEW /esrcc/cl_config_msg_handler( )->inform_on_sync( ) TO reported-%other.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
