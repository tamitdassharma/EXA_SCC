CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_element TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelements_s\\costelement,

      BEGIN OF ts_control,
        sysid       TYPE if_abap_behv=>t_xflag,
        legalentity TYPE if_abap_behv=>t_xflag,
        companycode TYPE if_abap_behv=>t_xflag,
        costelement TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_cost_element
        IMPORTING
          entity  TYPE ts_cost_element
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_cost_element.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-sysid       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-legalentity = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.
    IF control-companycode = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COMPANYCODE' ) TO fields. ENDIF.
    IF control-costelement = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTELEMENT' ) TO fields. ENDIF.

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
                                         ( entity = 'CostElements' table = '/ESRCC/CST_ELMNT' )
                                         ( entity = 'CostElementsText' table = '/ESRCC/CST_ELMTT' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_costelements_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_source_entity TYPE sxco_cds_object_name VALUE '/ESRCC/C_COSTELEMENTS',
      c_path          TYPE sxco_cds_association_name VALUE 'CostElementsAll'.

    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costelementsall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costelementsall
        RESULT result,
      precheck_cba_costelements FOR PRECHECK
        IMPORTING entities FOR CREATE costelementsall\_costelements.
ENDCLASS.

CLASS lhc_/esrcc/i_costelements_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CST_ELMNT'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CST_ELMNT'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_costelements_s IN LOCAL MODE
    ENTITY costelementsall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_costelements = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_COSTELEMENTS' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_costelements.
    TYPES ts_cost_element TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelements_s\\costelement.

    DATA(lo_cost_element) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = c_path ) )
        source_entity_name = c_source_entity
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costelement
        failed_entity      = failed-costelement
    ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    SELECT DISTINCT
           celem~sysid,
           celem~legalentity,
           celem~companycode,
           celem~costelement
        FROM /esrcc/d_cst_elm AS celem
        INNER JOIN @target_entities AS tent
            ON  tent~sysid       = celem~sysid
            AND tent~legalentity = celem~legalentity
            AND tent~companycode = celem~companycode
            AND tent~costelement = celem~costelement
        WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( sysid       = entity-sysid
                                                         legalentity = entity-legalentity
                                                         companycode = entity-companycode
                                                         costelement = entity-costelement
                                                         size        = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      IF line_exists( duplicate_entities[ sysid       = group_ref->sysid
                                          legalentity = group_ref->legalentity
                                          companycode = group_ref->companycode
                                          costelement = group_ref->costelement ] ) OR
         group_ref->size > 1.
        lo_cost_element->set_duplicate_error( entity = CORRESPONDING ts_cost_element( group_ref->* ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_costelements_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_costelements_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costelementsall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_costelements DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_source_entity TYPE sxco_cds_object_name VALUE '/ESRCC/C_COSTELEMENTS',
      c_path          TYPE sxco_cds_association_name VALUE 'CostElementsAll'.

    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR costelement
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costelement~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costelement.
ENDCLASS.

CLASS lhc_/esrcc/i_costelements IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CST_ELMNT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_costelementstext = edit_flag.
  ENDMETHOD.
  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_costelements_s IN LOCAL MODE
        ENTITY costelement
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = c_path ) )
        source_entity_name = c_source_entity
      CHANGING
        reported_entity    = reported-costelement
        failed_entity      = failed-costelement ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE sysid IS INITIAL
                                                         OR legalentity IS INITIAL
                                                         OR companycode IS INITIAL
                                                         OR costelement IS INITIAL.
      lo_validation->validate_cost_element(
        entity  = <entity>
        control = VALUE #( sysid         = if_abap_behv=>mk-on
                           legalentity   = if_abap_behv=>mk-on
                           companycode   = if_abap_behv=>mk-on
                           costelement   = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = c_path ) )
          source_entity_name = c_source_entity
        CHANGING
          reported_entity    = reported-costelement
          failed_entity      = failed-costelement ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-sysid       = if_abap_behv=>mk-on
                                          OR %control-legalentity = if_abap_behv=>mk-on
                                          OR %control-companycode = if_abap_behv=>mk-on
                                          OR %control-costelement = if_abap_behv=>mk-on.
      lo_validation->validate_cost_element(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid         = entity-%control-sysid
                           legalentity   = entity-%control-legalentity
                           companycode   = entity-%control-companycode
                           costelement   = entity-%control-costelement )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_/esrcc/i_costelementstext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR costelementstext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_costelementstext IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CST_ELMTT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
