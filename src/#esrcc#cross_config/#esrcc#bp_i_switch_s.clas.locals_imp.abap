CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_switch        TYPE STRUCTURE FOR READ RESULT /esrcc/i_switch_s\\switch,
      tt_switch_create TYPE TABLE FOR CREATE /esrcc/i_switch_s\\switchall\_switch,
      BEGIN OF ts_control,
        switchname TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_switch
        IMPORTING
          entity  TYPE ts_switch
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_switch
        IMPORTING
          entities TYPE tt_switch_create
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

  METHOD validate_switch.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-switchname = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SWITCHNAME' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_switch.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'SwitchAll' ) )
        source_entity_name = '/ESRCC/C_SWITCH'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_switch(
          entity  = CORRESPONDING #( target )
          control = VALUE #( switchname = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/SWITCH'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Switch' table = '/ESRCC/SWITCH' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_switch_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR switchall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION switchall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR switchall
        RESULT result,
      precheck_cba_switch FOR PRECHECK
        IMPORTING entities FOR CREATE switchall\_switch.
ENDCLASS.

CLASS lhc_/esrcc/i_switch_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_switch_s IN LOCAL MODE
    ENTITY switchall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_switch = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_switch_s IN LOCAL MODE
      ENTITY switchall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_switch_s IN LOCAL MODE
      ENTITY switchall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_SWITCH' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_switch.
    lcl_custom_validation=>precheck_cba_switch(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-switch
        reported = reported-switch ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_switch_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_switch_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-switchall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_switch DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR switch~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR switch
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION switch~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR switch
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR switch
        RESULT    result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR switch~validatedata.
ENDCLASS.

CLASS lhc_/esrcc/i_switch IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_switch_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_switc_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/SWITCH'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-switch ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_switch TYPE TABLE FOR CREATE /esrcc/i_switch_s\_switch.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-switch = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_switch_s IN LOCAL MODE
      ENTITY switch
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_switch)
      FAILED DATA(read_failed).

    LOOP AT ref_switch ASSIGNING FIELD-SYMBOL(<ref_switch>).
      DATA(key) = keys[ KEY draft %tky = <ref_switch>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_switch>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_switch>-%is_draft
          %data = CORRESPONDING #( <ref_switch> EXCEPT
            application
            createdat
            createdby
            lastchangedat
            lastchangedby
            locallastchangedat
            singletonid
            switchname
        ) ) )
      ) TO new_switch ASSIGNING FIELD-SYMBOL(<new_switch>).
      <new_switch>-%target[ 1 ]-application = key-%param-application.
      <new_switch>-%target[ 1 ]-switchname = key-%param-switchname.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_switch(
      EXPORTING
        entities = new_switch
      CHANGING
        failed   = failed-switch
        reported = reported-switch ).

    IF failed-switch IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_switch_s IN LOCAL MODE
        ENTITY switchall CREATE BY \_switch
        FIELDS (
                 application
                 switchname
                 active
               ) WITH new_switch
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-switch = mapped_create-switch.
    INSERT LINES OF read_failed-switch INTO TABLE failed-switch.

    IF failed-switch IS INITIAL.
      reported-switch = VALUE #( FOR created IN mapped-switch (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-switchall-%is_draft = created-%is_draft
                                                 %path-switchall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_SWITCH' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
  METHOD validatedata.
  ENDMETHOD.

ENDCLASS.
