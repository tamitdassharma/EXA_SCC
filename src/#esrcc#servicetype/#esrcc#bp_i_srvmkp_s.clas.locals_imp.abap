CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_markup TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvmkp_s\\servicemarkup,
      BEGIN OF ts_control,
        origcost      TYPE if_abap_behv=>t_xflag,
        passcost      TYPE if_abap_behv=>t_xflag,
        intraorigcost TYPE if_abap_behv=>t_xflag,
        intrapasscost TYPE if_abap_behv=>t_xflag,
        validfrom     TYPE if_abap_behv=>t_xflag,
        validto       TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_service_markup
        IMPORTING
          entity  TYPE ts_markup
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_service_markup.
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

    IF control-origcost      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ORIGCOST' ) TO fields. ENDIF.
    IF control-passcost      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PASSCOST' ) TO fields. ENDIF.
    IF control-intraorigcost = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'INTRAORIGCOST' ) TO fields. ENDIF.
    IF control-intrapasscost = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'INTRAPASSCOST' ) TO fields. ENDIF.

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
ENDCLASS.


CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_table_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(
                                         ( entity = 'ServiceMarkup' table = '/ESRCC/SRVMKP' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvmkp_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR servicemarkupall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR servicemarkupall
        RESULT result,
      precheck_cba_servicemarkup FOR PRECHECK
        IMPORTING entities FOR CREATE servicemarkupall\_servicemarkup.
ENDCLASS.

CLASS lhc_/esrcc/i_srvmkp_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/SRVMKP'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/SRVMKP'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
    ENTITY servicemarkupall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_servicemarkup = edit_flag ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_SRVMKP' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_servicemarkup.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceMarkupAll' ) )
        source_entity_name = '/ESRCC/C_SRVMKP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-servicemarkup
        failed_entity      = failed-servicemarkup ) ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
      lo_validation->validate_service_markup(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_srvmkp_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_srvmkp_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-servicemarkupall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvmkp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: tt_service_markup TYPE TABLE FOR READ RESULT /esrcc/i_srvmkp_s\\servicemarkup.

    METHODS:
      set_workflow_status
        IMPORTING
          entities                     TYPE tt_service_markup
          for_workflow_internal_status TYPE /esrcc/status_de
          to_workflow_status           TYPE /esrcc/status_de.

    METHODS:
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR servicemarkup~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE servicemarkup,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR servicemarkup RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR servicemarkup RESULT result.

    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION servicemarkup~finalize RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION servicemarkup~submit RESULT result.

    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR servicemarkup~updateinternalworkflowstatus.

    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR servicemarkup~triggerworkflow.
    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR servicemarkup~updateworkflowstatus.
    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION servicemarkup~reopen RESULT result.
    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR servicemarkup~updatecomment.
ENDCLASS.

CLASS lhc_/esrcc/i_srvmkp IMPLEMENTATION.
  METHOD set_workflow_status.
    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = to_workflow_status ).
    MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus = for_workflow_internal_status )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowstatus            = to_workflow_status
                          workflowstatuscriticality = criticality
                          %control                  = VALUE #( workflowstatus            = if_abap_behv=>mk-on
                                                               workflowstatuscriticality = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD validatedata.
    DATA draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvmkp_s\\servicemarkup.

    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
         ENTITY servicemarkup
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    " Draft version data
    SELECT mkp~*
      FROM /esrcc/d_srvmkp AS mkp
      INNER JOIN @keys AS key
          ON key~serviceproduct = mkp~serviceproduct
         AND key~validfrom <> mkp~validfrom
      WHERE mkp~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entities).

    DATA(lo_service_markup) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceMarkupAll' ) )
        source_entity_name = '/ESRCC/C_SRVMKP'
      CHANGING
        reported_entity    = reported-servicemarkup
        failed_entity      = failed-servicemarkup ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_service_markup ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_markup(
        entity  = entity
        control = VALUE #( origcost      = if_abap_behv=>mk-on
                           passcost      = if_abap_behv=>mk-on
                           intraorigcost = if_abap_behv=>mk-on
                           intrapasscost = if_abap_behv=>mk-on
                           validto       = if_abap_behv=>mk-on )
      ).

      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     serviceproduct  = entity-serviceproduct
                 AND validfrom      <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).

        lo_service_markup->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
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
        paths              = VALUE #( ( path = 'ServiceMarkupAll' ) )
        source_entity_name = '/ESRCC/C_SRVMKP'
      CHANGING
        reported_entity    = reported-servicemarkup
        failed_entity      = failed-servicemarkup ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-origcost      = if_abap_behv=>mk-on
                                          OR %control-passcost      = if_abap_behv=>mk-on
                                          OR %control-intraorigcost = if_abap_behv=>mk-on
                                          OR %control-intrapasscost = if_abap_behv=>mk-on
                                          OR %control-validfrom     = if_abap_behv=>mk-on
                                          OR %control-validto       = if_abap_behv=>mk-on.
      lo_validation->validate_service_markup(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( origcost      = entity-%control-origcost
                             passcost      = entity-%control-passcost
                             intraorigcost = entity-%control-intraorigcost
                             intrapasscost = entity-%control-intrapasscost
                             validfrom     = entity-%control-validfrom
                             validto       = entity-%control-validto )
      ).
    ENDLOOP.
  ENDMETHOD.
  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities
                      LET submit   = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                          finalize = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                          reopen   = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                          update   = lo_auth->regulate_action_update( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                          delete   = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                      IN ( %tky             = wa-%tky
                           %action-submit   = submit
                           %action-finalize = finalize
                           %action-reopen   = reopen
                           %update          = update
                           %delete          = delete ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
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
    reported-%other = VALUE #( ( /esrcc/cl_config_util=>message_on_action( ) ) ).
  ENDMETHOD.

  METHOD submit.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
            ENTITY servicemarkup
            UPDATE FIELDS ( commentid comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
            WITH VALUE #( FOR entity IN entities
                            ( %tky                      = entity-%tky
                              workflowid                = ''
                              commentid                 = COND #( WHEN entity-commentid IS INITIAL THEN cl_uuid_factory=>create_system_uuid( )->create_uuid_c32( ) ELSE entity-commentid )
                              comments                  = VALUE #( keys[ %tky = entity-%tky ]-%param-comments OPTIONAL )
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

    reported-%other = VALUE #( ( /esrcc/cl_config_util=>message_on_action( ) ) ).
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set internal status to "Draft" for modified entries
    MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        UPDATE FIELDS ( workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-draft )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-draft
                          %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD updateworkflowstatus.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
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

  METHOD triggerworkflow.
    DATA:
      failed_leading_objects TYPE /esrcc/tt_wf_leadingobject,
      messages               TYPE /esrcc/tt_message.

    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(workflow_internal_status) = ''.
    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = /esrcc/cl_wf_utility=>app-bc_product_markup
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).

    IF wf_active = abap_true.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object        = CORRESPONDING /esrcc/tt_wf_leadingobject( entities MAPPING serviceproduct = serviceproduct valid_from = validfrom EXCEPT * )
          iv_apptype               = /esrcc/cl_wf_utility=>app-bc_product_markup
        IMPORTING
          et_failed_leading_object = failed_leading_objects
          et_message               = messages.

      " Set status to error for failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-failed ).
      LOOP AT failed_leading_objects INTO DATA(leading_object).
        MODIFY entities
            FROM VALUE #( workflowstatus = /esrcc/cl_wf_utility=>wf_status-failed
                          workflowstatuscriticality = criticality )
            TRANSPORTING workflowstatus workflowstatuscriticality
            WHERE serviceproduct = leading_object-serviceproduct.
      ENDLOOP.

      MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
          ENTITY servicemarkup
          UPDATE FIELDS ( workflowinternalstatus workflowstatus workflowstatuscriticality )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                      = entity-%tky
                            workflowstatus            = entity-workflowstatus
                            workflowstatuscriticality = entity-workflowstatuscriticality
                            workflowinternalstatus    = workflow_internal_status ) )
          FAILED DATA(failed_mod)
          MAPPED DATA(mapped_mod).
    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
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


  METHOD reopen.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
    ENTITY servicemarkup
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
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

    reported-%other = VALUE #( ( /esrcc/cl_config_util=>message_on_action( ) ) ).
  ENDMETHOD.

  METHOD updatecomment.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
        ENTITY servicemarkup
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity) WHERE commentid IS NOT INITIAL.
      /esrcc/cl_comments_util=>modify_comments(
        comments    = VALUE #( instanceid = entity-commentid )
        iv_comments = entity-comments
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
