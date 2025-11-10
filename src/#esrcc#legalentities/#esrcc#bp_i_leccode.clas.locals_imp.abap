CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_le_ccode        TYPE STRUCTURE FOR READ RESULT /esrcc/i_leccode_s\\letocompanycode,
      tt_le_ccode_create TYPE TABLE FOR CREATE /esrcc/i_leccode_s\\letocompanycodeall\_letocompanycode,
      BEGIN OF ts_control,
        ccode       TYPE if_abap_behv=>t_xflag,
        legalentity TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util.
    METHODS:
      validate_le_ccode
        IMPORTING
          entity  TYPE ts_le_ccode
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_le_ccode
        IMPORTING
          entities TYPE tt_le_ccode_create
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

  METHOD validate_le_ccode.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-ccode       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CCODE' ) TO fields. ENDIF.
    IF control-legalentity = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_le_ccode.
    TYPES ts_legal_entity TYPE STRUCTURE FOR READ RESULT /esrcc/i_leccode_s\\letocompanycode.

    DATA(lo_cost_center) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCompanyCodeAll' ) )
        source_entity_name = '/ESRCC/C_LECCODE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCompanyCodeAll' ) )
        source_entity_name = '/ESRCC/C_LECCODE'
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_center ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        IF target-legalentity IS NOT INITIAL.
          CHECK lo_auth->check_authorization(
            EXPORTING
              entity     = CORRESPONDING ts_legal_entity( target )
              auth_value = VALUE #( legal_entity = target-legalentity )
              activity   = /esrcc/cl_authorization=>c_authorization_activity-create
          ) = abap_true.
        ENDIF.

        lo_validation->validate_le_ccode(
          EXPORTING
            entity  = CORRESPONDING #( target )
            control = VALUE #( ccode = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LECCODE'
                                       table_entity_relations = VALUE #( ( entity = 'LeToCompanyCode' table = '/ESRCC/LE_CCODE' )
                                                                         ( entity = 'CompanyCodeText' table = '/ESRCC/CCODET' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_/esrcc/i_leccode DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR letocompanycode~validatetransportrequest,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR letocompanycode~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE letocompanycode,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR letocompanycode RESULT result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
            IMPORTING REQUEST requested_authorizations FOR letocompanycode RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION letocompanycode~copy.
ENDCLASS.

CLASS lhc_/esrcc/i_leccode IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_leccode_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_lecco_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LE_CCODE'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-letocompanycode ) ).
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
         ENTITY letocompanycode
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCompanyCodeAll' ) )
        source_entity_name = '/ESRCC/C_LECCODE'
      CHANGING
        reported_entity    = reported-letocompanycode
        failed_entity      = failed-letocompanycode ) ).

    LOOP AT entities INTO DATA(entity) WHERE legalentity IS INITIAL.
      lo_validation->validate_le_ccode( EXPORTING entity = entity control = VALUE #( legalentity = if_abap_behv=>mk-on ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCompanyCodeAll' ) )
        source_entity_name = '/ESRCC/C_LECCODE'
      CHANGING
        reported_entity    = reported-letocompanycode
        failed_entity      = failed-letocompanycode ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-legalentity = if_abap_behv=>mk-on.
      lo_validation->validate_le_ccode(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( legalentity = entity-%control-legalentity )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA: lt_keys TYPE TABLE FOR READ RESULT /esrcc/i_leccode_s\\letocompanycode.

    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                          %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
      RETURN.
    ENDIF.

    SELECT sysid, ccode, legalentity FROM /esrcc/d_le_ccod
        FOR ALL ENTRIES IN @keys
        WHERE sysid = @keys-sysid
          AND ccode = @keys-ccode
          AND draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO CORRESPONDING FIELDS OF TABLE @lt_keys.

    MODIFY lt_keys FROM VALUE #( %is_draft = keys[ 1 ]-%is_draft ) TRANSPORTING %is_draft WHERE %is_draft <> keys[ 1 ]-%is_draft.

    DATA(lo_auth) = NEW /esrcc/cl_authorization( paths = VALUE #( ( path = '_CompanyCodeText' ) ) ).
    LOOP AT lt_keys INTO DATA(key).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true copy = abap_true create_by_assoc = abap_true )
          auth_value            = VALUE #( legal_entity = key-legalentity )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LECCODE' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_leccode_s\_letocompanycode,
      new_text TYPE TABLE FOR CREATE /esrcc/i_leccode_s\\letocompanycode\_companycodetext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-letocompanycode = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
      ENTITY letocompanycode
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
      ENTITY letocompanycode BY \_companycodetext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid      = key_cid
                             %is_draft = <ref_main>-%is_draft
                             %data     = CORRESPONDING #( <ref_main> EXCEPT sysid ccode singletonid )
                             sysid     = key-%param-sysid
                             ccode     = key-%param-ccode ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
                                                                            AND %tky-sysid     = key-%tky-sysid
                                                                            AND %tky-ccode     = key-%tky-ccode.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && <ref_text>-spras
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_text> EXCEPT sysid ccode singletonid )
                        sysid     = key-%param-sysid
                        ccode     = key-%param-ccode ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_le_ccode(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-letocompanycode
        reported = reported-letocompanycode ).

    IF failed-letocompanycode IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
        ENTITY letocompanycodeall CREATE BY \_letocompanycode
        FIELDS (
                 sysid
                 ccode
                 legalentity
                 controllingarea
                 active
               ) WITH new_main
        ENTITY letocompanycode CREATE BY \_companycodetext
        FIELDS (
                 spras
                 sysid
                 ccode
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-letocompanycode = mapped_create-letocompanycode.
    INSERT LINES OF read_failed-letocompanycode INTO TABLE failed-letocompanycode.

    IF failed-letocompanycode IS INITIAL AND failed-companycodetext IS INITIAL.
      reported-letocompanycode = VALUE #( FOR created IN mapped-letocompanycode (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-letocompanycodeall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_ccodetext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR companycodetext~validatetransportrequest,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR companycodetext RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_ccodetext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_leccode_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_lecco_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/CCODET'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-companycodetext ) ).
  ENDMETHOD.
  METHOD get_instance_features.
    TYPES: ts_key TYPE STRUCTURE FOR READ RESULT /esrcc/i_leccode_s\\companycodetext.
    TYPES: BEGIN OF key.
             INCLUDE TYPE ts_key.
    TYPES:   legalentity TYPE /esrcc/legalentity,
           END OF key.
    TYPES: tt_key TYPE TABLE OF key.

    DATA: lt_keys TYPE tt_key.

    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    SELECT key~%is_draft, key~spras, key~sysid, key~ccode, ccode~legalentity
      FROM /esrcc/d_le_ccod AS ccode
      INNER JOIN @keys AS key
        ON key~sysid = ccode~sysid
       AND key~ccode = ccode~ccode
      WHERE ccode~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_keys.

    MODIFY lt_keys FROM VALUE #( %is_draft = keys[ 1 ]-%is_draft ) TRANSPORTING %is_draft WHERE %is_draft <> keys[ 1 ]-%is_draft.

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    LOOP AT lt_keys INTO DATA(key).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true )
          auth_value            = VALUE #( legal_entity = key-legalentity )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_/esrcc/i_leccode_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR letocompanycodeall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION letocompanycodeall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR letocompanycodeall
        RESULT result,
      precheck_cba_letocompanycode FOR PRECHECK
        IMPORTING entities FOR CREATE letocompanycodeall\_letocompanycode,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION letocompanycodeall~edit.
ENDCLASS.

CLASS lhc_/esrcc/i_leccode_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
    ENTITY letocompanycodeall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_letocompanycode = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
      ENTITY letocompanycodeall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
      ENTITY letocompanycodeall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LECCODE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_letocompanycode.
    lcl_custom_validation=>precheck_cba_le_ccode(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-letocompanycode
        reported = reported-letocompanycode ).
  ENDMETHOD.

  METHOD edit.
    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    SELECT DISTINCT legalentity FROM /esrcc/i_leccode INTO TABLE @DATA(legal_entities). "#EC CI_NOWHERE

    LOOP AT legal_entities INTO DATA(entity).
      DATA(is_unauthorized) = lo_auth->is_unauthorized(
        EXPORTING
          auth_value = VALUE #( legal_entity = entity-legalentity )
          create     = abap_true
          update     = abap_true
          delete     = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_true.
      reported-letocompanycodeall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                                   number   = '019'
                                                                   severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_leccode_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_leccode_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-letocompanycodeall INDEX 1 INTO DATA(all).
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
