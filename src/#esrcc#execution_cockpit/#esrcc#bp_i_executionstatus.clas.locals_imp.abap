CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_exec_status        TYPE STRUCTURE FOR READ RESULT /esrcc/i_executionstatus_s\\executionstatus,
      tt_exec_status_create TYPE TABLE FOR CREATE /esrcc/i_executionstatus_s\\executionstatusall\_executionstatus,
      BEGIN OF ts_control,
        status TYPE if_abap_behv=>t_xflag,
        color  TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_execution_status
        IMPORTING
          entity  TYPE ts_exec_status
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_execution_status
        IMPORTING
          entities TYPE tt_exec_status_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_execution_status.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-status = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'STATUS' ) TO fields. ENDIF.
    IF control-color  = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COLOR' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_execution_status.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ExecutionStatusAll' ) )
        source_entity_name = '/ESRCC/C_EXECUTIONSTATUS'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_execution_status(
          entity  = CORRESPONDING #( target )
          control = VALUE #( status = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/EXECSTATUS'
                                       table_entity_relations = VALUE #( ( entity = 'ExecutionStatus' table = '/ESRCC/EXEC_ST' )
                                                                         ( entity = 'ExecutionStatusText' table = '/ESRCC/EXECST_T' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_executionstatus_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR executionstatusall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION executionstatusall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR executionstatusall
        RESULT result,
      precheck_cba_executionstatus FOR PRECHECK
        IMPORTING entities FOR CREATE executionstatusall\_executionstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_executionstatus_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
    ENTITY executionstatusall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_executionstatus = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
      ENTITY executionstatusall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
      ENTITY executionstatusall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_EXECUTIONSTATUS' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_executionstatus.
    lcl_custom_validation=>precheck_cba_execution_status(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-executionstatus
        reported = reported-executionstatus ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_executionstatus_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_executionstatus_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-executionstatusall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_executionstatus DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR executionstatus~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR executionstatus
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR executionstatus~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE executionstatus,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR executionstatus RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR executionstatus RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION executionstatus~copy.
ENDCLASS.

CLASS lhc_/esrcc/i_executionstatus IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_executionstatus_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_execs_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/EXEC_ST'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-executionstatus ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_executionstatustext = edit_flag.
  ENDMETHOD.
  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
         ENTITY executionstatus
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ExecutionStatusAll' ) )
        source_entity_name = '/ESRCC/C_EXECUTIONSTATUS'
      CHANGING
        reported_entity    = reported-executionstatus
        failed_entity      = failed-executionstatus ) ).

    LOOP AT entities INTO DATA(entity) WHERE color IS INITIAL.
      lo_validation->validate_execution_status(
        entity  = entity
        control = VALUE #( color = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ExecutionStatusAll' ) )
        source_entity_name = '/ESRCC/C_EXECUTIONSTATUS'
      CHANGING
        reported_entity    = reported-executionstatus
        failed_entity      = failed-executionstatus ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-color = if_abap_behv=>mk-on.
      lo_validation->validate_execution_status(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( color = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_EXECUTIONSTATUS' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_executionstatus_s\_executionstatus,
      new_text TYPE TABLE FOR CREATE /esrcc/i_executionstatus_s\\executionstatus\_executionstatustext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-executionstatus = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
      ENTITY executionstatus
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
      ENTITY executionstatus BY \_executionstatustext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid        = key_cid
                             %is_draft   = <ref_main>-%is_draft
                             %data       = CORRESPONDING #( <ref_main> EXCEPT application status singletonid )
                             application = key-%param-application
                             status      = key-%param-status ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft   = key-%tky-%is_draft
                                                                            AND %tky-application = key-%tky-application
                                                                            AND %tky-status      = key-%tky-status.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid        = key_cid && <ref_text>-spras
                        %is_draft   = key-%is_draft
                        %data       = CORRESPONDING #( <ref_text> EXCEPT application status singletonid )
                        application = key-%param-application
                        status      = key-%param-status ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_execution_status(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-executionstatus
        reported = reported-executionstatus ).

    IF failed-executionstatus IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_executionstatus_s IN LOCAL MODE
        ENTITY executionstatusall CREATE BY \_executionstatus
        FIELDS (
                 application
                 status
                 color
               ) WITH new_main
        ENTITY executionstatus CREATE BY \_executionstatustext
        FIELDS (
                 spras
                 application
                 status
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-executionstatus = mapped_create-executionstatus.
    INSERT LINES OF read_failed-executionstatus INTO TABLE failed-executionstatus.

    IF failed-executionstatus IS INITIAL AND failed-executionstatustext IS INITIAL.
      reported-executionstatus = VALUE #( FOR created IN mapped-executionstatus (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-executionstatusall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_executionstatuste DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR executionstatustext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR executionstatustext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_executionstatuste IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_executionstatus_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_execs_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/EXECST_T'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-executionstatustext ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
