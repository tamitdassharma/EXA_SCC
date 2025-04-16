CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_le_ccode TYPE STRUCTURE FOR READ RESULT /esrcc/i_leccode_s\\letocompanycode,
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
                                         ( entity = 'LeToCompanyCode' table = '/ESRCC/LE_CCODE' )
                                         ( entity = 'CompanyCodeText' table = '/ESRCC/CCODET' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_/esrcc/i_leccode DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR letocompanycode~validaterecordchanges,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR letocompanycode~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE letocompanycode,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR letocompanycode RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_leccode IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_leccode_s.
*    SELECT SINGLE transportrequestid FROM /esrcc/d_lecco_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = transportrequestid
*                                table             = '/ESRCC/LE_CCODE'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-letocompanycode ) ).
*  ENDMETHOD.

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
      RETURN.
    ENDIF.

    SELECT sysid, ccode, legalentity FROM /esrcc/d_le_ccod
        FOR ALL ENTRIES IN @keys
        WHERE sysid = @keys-sysid
          AND ccode = @keys-ccode
          AND draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO CORRESPONDING FIELDS OF TABLE @lt_keys.

    MODIFY lt_keys FROM VALUE #( %is_draft = keys[ 1 ]-%is_draft ) TRANSPORTING %is_draft WHERE %is_draft <> keys[ 1 ]-%is_draft.

*    /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
*    NEW /esrcc/cl_authorization( )->set_instance_authorization(
*        EXPORTING
*          keys            = lt_keys
*          update          = abap_true
*          delete          = abap_true
*          create_by_assoc = abap_true
*          field_mapping   = VALUE #( legal_entity = 'LEGALENTITY' )
*          assoc_path      = VALUE #( ( path = '_CompanyCodeText' ) )
*        CHANGING
*          result          = result
*      ).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( paths = VALUE #( ( path = '_CompanyCodeText' ) ) ).
    LOOP AT lt_keys INTO DATA(key).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true create_by_assoc = abap_true )
          auth_value            = VALUE #( legal_entity = key-legalentity )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_ccodetext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR companycodetext~validaterecordchanges,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR companycodetext RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_ccodetext IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_leccode_s.
*    SELECT SINGLE transportrequestid FROM /esrcc/d_lecco_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = transportrequestid
*                                table             = '/ESRCC/CCODET'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-companycodetext ) ).
*  ENDMETHOD.
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

*    /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
*    NEW /esrcc/cl_authorization( )->set_instance_authorization(
*        EXPORTING
*          keys            = lt_keys
*          update          = abap_true
*          delete          = abap_true
*          field_mapping   = VALUE #( legal_entity = 'LEGALENTITY' )
*        CHANGING
*          result          = result
*      ).

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
*      selectcustomizingtransptreq FOR MODIFY
*        IMPORTING
*                  keys   FOR ACTION letocompanycodeall~selectcustomizingtransptreq
*        RESULT    result,
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
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/LE_CCODE'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/LE_CCODE'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
    ENTITY letocompanycodeall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_letocompanycode = edit_flag ) ).
*               %action-selectcustomizingtransptreq = selecttransport_flag ) ).
  ENDMETHOD.
*  METHOD selectcustomizingtransptreq.
*    MODIFY ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
*      ENTITY letocompanycodeall
*        UPDATE FIELDS ( transportrequestid hidetransport )
*        WITH VALUE #( FOR key IN keys
*                        ( %tky               = key-%tky
*                          transportrequestid = key-%param-transportrequestid
*                          hidetransport      = abap_false ) ).
*
*    READ ENTITIES OF /esrcc/i_leccode_s IN LOCAL MODE
*      ENTITY letocompanycodeall
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*    result = VALUE #( FOR entity IN entities
*                        ( %tky   = entity-%tky
*                          %param = entity ) ).
*  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_LECCODE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
*    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_letocompanycode.
    TYPES ts_legal_entity TYPE STRUCTURE FOR READ RESULT /esrcc/i_leccode_s\\letocompanycode.

    DATA(lo_cost_center) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCompanyCodeAll' ) )
        source_entity_name = '/ESRCC/C_LECCODE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-letocompanycode
        failed_entity      = failed-letocompanycode
    ).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCompanyCodeAll' ) )
        source_entity_name = '/ESRCC/C_LECCODE'
      CHANGING
        reported_entity    = reported-letocompanycode
        failed_entity      = failed-letocompanycode
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_center ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
      IF entity-legalentity IS NOT INITIAL.
*        CHECK lo_cost_center->check_authorization(
        CHECK lo_auth->check_authorization(
          EXPORTING
            entity     = CORRESPONDING ts_legal_entity( entity )
*            legal_entity = entity-legalentity
            auth_value = VALUE #( legal_entity = entity-legalentity )
            activity   = /esrcc/cl_authorization=>c_authorization_activity-create
        ) = abap_true.
      ENDIF.

      lo_validation->validate_le_ccode(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( ccode = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD edit.
*    DATA(lo_util) = /esrcc/cl_config_util=>create_for_authorization( ).
    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    SELECT DISTINCT legalentity FROM /esrcc/i_leccode INTO TABLE @DATA(legal_entities). "#EC CI_NOWHERE

    LOOP AT legal_entities INTO DATA(entity).
*      DATA(is_unauthorized) = lo_util->is_unauthorized(
      DATA(is_unauthorized) = lo_auth->is_unauthorized(
        EXPORTING
*          legal_entity = entity-legalentity
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
