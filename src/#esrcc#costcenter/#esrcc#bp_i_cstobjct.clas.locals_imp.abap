CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_object TYPE STRUCTURE FOR READ RESULT /esrcc/i_cstobjct_s\\costobject,

      BEGIN OF ts_control,
        billfrequency TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_cost_object
        IMPORTING
          entity  TYPE ts_cost_object
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_cost_object.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-billfrequency = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'BILLINGFREQUENCY' ) TO fields. ENDIF.

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
                                         ( entity = 'CostObject' table = '/ESRCC/CST_OBJCT' )
                                         ( entity = 'CostObjectText' table = '/ESRCC/CST_OBJTT' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_cstobjct_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costobjectall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costobjectall
        RESULT result,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION costobjectall~edit,
      precheck_cba_costobject FOR PRECHECK
        IMPORTING entities FOR CREATE costobjectall\_costobject.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjct_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CST_OBJCT'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CST_OBJCT'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
    ENTITY costobjectall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_costobject = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_CSTOBJCT' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.

  METHOD edit.
    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    SELECT DISTINCT legalentity, costobject FROM /esrcc/i_cstobjct INTO TABLE @DATA(cost_objects). "#EC CI_NOWHERE

    LOOP AT cost_objects INTO DATA(cost_object).
      DATA(is_unauthorized) = lo_auth->is_unauthorized(
        EXPORTING
          auth_value = CORRESPONDING #( cost_object MAPPING legal_entity = legalentity cost_object = costobject )
          create     = abap_true
          update     = abap_true
          delete     = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_true.
      reported-costobjectall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                              number   = '019'
                                                              severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_costobject.
    TYPES ts_cost_object TYPE STRUCTURE FOR READ RESULT /esrcc/i_cstobjct_s\\costobject.

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostObjectAll' ) )
        source_entity_name = '/ESRCC/C_CSTOBJCT'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costobject
        failed_entity      = failed-costobject
    ).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostObjectAll' ) )
        source_entity_name = '/ESRCC/C_CSTOBJCT'
      CHANGING
        reported_entity    = reported-costobject
        failed_entity      = failed-costobject
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    SELECT DISTINCT
           cobj~sysid,
           cobj~legalentity,
           cobj~companycode,
           cobj~costobject,
           cobj~costcenter
        FROM /esrcc/d_cstobj AS cobj
        INNER JOIN @target_entities AS tent
            ON  tent~sysid       = cobj~sysid
            AND tent~legalentity = cobj~legalentity
            AND tent~companycode = cobj~companycode
            AND tent~costobject  = cobj~costobject
            AND tent~costcenter  = cobj~costcenter
        WHERE cobj~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( sysid       = entity-sysid
                                                         legalentity = entity-legalentity
                                                         companycode = entity-companycode
                                                         costobject  = entity-costobject
                                                         costcenter  = entity-costcenter
                                                         size        = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      lo_auth->check_authorization(
        EXPORTING
          entity     = CORRESPONDING ts_cost_object( group_ref->* )
          auth_value = VALUE #( cost_object = group_ref->costobject )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-create
      ).

      IF line_exists( duplicate_entities[ sysid       = group_ref->sysid
                                          legalentity = group_ref->legalentity
                                          companycode = group_ref->companycode
                                          costobject  = group_ref->costobject
                                          costcenter  = group_ref->costcenter ] ) OR group_ref->size > 1.
        lo_cost_object->set_duplicate_error( entity = CORRESPONDING ts_cost_object( group_ref->* ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_cstobjct_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_cstobjct_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costobjectall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_cstobjct DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costobject,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR costobject RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR costobject~validatedata.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE costobject.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjct IMPLEMENTATION.
  METHOD precheck_update.
    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'CostObjectAll' ) )
          assoc_paths        = VALUE #( ( path = '_CostObjectAll' ) )
          source_entity_name = '/ESRCC/C_CSTOBJCT'
        CHANGING
          reported_entity    = reported-costobject
          failed_entity      = failed-costobject ).

*    IF lo_cost_object->foreign_check_cost_object(
*      EXPORTING
*        entities          = entities
*        uuid_fieldname    = 'COSTOBJECTUUID'
*        error_fieldname   = 'LEGALENTITY'
*        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = costobjectuuid )
*        action            = VALUE #( update = abap_true )
*        foreign_check     = VALUE #( serv_consumption = abap_true serv_capacity = abap_true alloc_key = abap_true )
*    ) = abap_true.
*      RETURN.
*    ENDIF.

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    LOOP AT entities INTO DATA(entity) WHERE %control-billingfrequency = if_abap_behv=>mk-on.
      lo_validation->validate_cost_object(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( billfrequency = entity-%control-billingfrequency )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
        ENTITY costobject
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( paths = VALUE #( ( path = '_CostObjectText' ) ) ).

    LOOP AT keys INTO DATA(key).
      DATA(entity) = VALUE #( entities[ %tky = key-%tky ] OPTIONAL ).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true create_by_assoc = abap_true )
          auth_value            = VALUE #( legal_entity = entity-legalentity cost_object = entity-costobject )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
        ENTITY costobject
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
                             EXPORTING
                               paths              = VALUE #( ( path = 'CostObjectAll' ) )
                               assoc_paths        = VALUE #( ( path = '_CostObjectAll' ) )
                               source_entity_name = '/ESRCC/C_CSTOBJCT'
                             CHANGING
                               reported_entity    = reported-costobject
                               failed_entity      = failed-costobject
                           ).

*    lo_cost_object->foreign_check_cost_object(
*      EXPORTING
*        entities          = entities
*        uuid_fieldname    = 'COSTOBJECTUUID'
*        error_fieldname   = 'LEGALENTITY'
*        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = costobjectuuid )
*        action            = VALUE #( update = abap_true )
*        foreign_check     = VALUE #( serv_consumption = abap_true serv_capacity = abap_true alloc_key = abap_true )
*    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE billingfrequency IS INITIAL.
      lo_validation->validate_cost_object(
        entity  = <entity>
        control = VALUE #( billfrequency = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
*    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
*        ENTITY costobject
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*
*    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
*                         EXPORTING
*                           paths              = VALUE #( ( path = 'CostObjectAll' )
*                                                         ( path = 'CostObject' ) )
*                           assoc_paths        = VALUE #( ( path = '_CostObjectAll' ) )
*                           source_entity_name = '/ESRCC/C_CSTOBJCT'
*                         CHANGING
*                           reported_entity    = reported-costobject
*                           failed_entity      = failed-costobject
*                       ).
*
*    lo_cost_object->foreign_check_cost_object(
*      EXPORTING
*        entities          = entities
*        uuid_fieldname    = 'COSTOBJECTUUID'
*        error_fieldname   = 'LEGALENTITY'
*        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = costobjectuuid )
*        action            = VALUE #( delete = abap_true )
*        foreign_check     = VALUE #( serv_consumption = abap_true serv_capacity = abap_true alloc_key = abap_true )
*    ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_cstobjcttext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR costobjecttext RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjcttext IMPLEMENTATION.
  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
            ENTITY costobjecttext
            BY \_costobject
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    LOOP AT keys INTO DATA(key).
      DATA(entity) = VALUE #( entities[ %tky = CORRESPONDING #( key-%tky ) ] OPTIONAL ).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true )
          auth_value            = VALUE #( legal_entity = entity-legalentity cost_object = entity-costobject )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
