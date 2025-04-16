CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_chargeout TYPE STRUCTURE FOR READ RESULT /esrcc/i_chargeoutbc_s\\chargeout,

      BEGIN OF ts_control_chargeout,
        chargeoutruleid TYPE if_abap_behv=>t_xflag,
        validfrom       TYPE if_abap_behv=>t_xflag,
        validto         TYPE if_abap_behv=>t_xflag,
      END OF ts_control_chargeout.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_chargeout
        IMPORTING
          entity  TYPE ts_chargeout
          control TYPE ts_control_chargeout.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_chargeout.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-chargeoutruleid = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHARGEOUTRULEID' ) TO fields. ENDIF.
    IF control-validto         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.

      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
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
                                         ( entity = 'Chargeout' table = '/ESRCC/CHARGEOUT' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_chargeoutbc_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR chargeoutall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR chargeoutall
        RESULT result,
      precheck_cba_chargeout FOR PRECHECK
        IMPORTING entities FOR CREATE chargeoutall\_chargeout.
ENDCLASS.

CLASS lhc_/esrcc/i_chargeoutbc_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CHARGEOUT'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CHARGEOUT'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
    ENTITY chargeoutall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_chargeout = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_CHARGEOUTBC' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_chargeout.
    TYPES ts_chargeout TYPE STRUCTURE FOR READ RESULT /esrcc/i_chargeoutbc_s\\chargeout.

    DATA(lo_chargeout) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ChargeoutAll' ) )
        source_entity_name = '/ESRCC/C_CHARGEOUTBC'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-chargeout
        failed_entity      = failed-chargeout
    ).
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_chargeout ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    SELECT DISTINCT
           chrg~serviceproduct
        FROM /esrcc/d_chargeo AS chrg
        INNER JOIN @target_entities AS tent
            ON  tent~serviceproduct = chrg~serviceproduct
            AND tent~validfrom      = chrg~validfrom
        WHERE chrg~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( serviceproduct = entity-serviceproduct
                                                         validfrom      = entity-validfrom
                                                         size           = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      lo_validation->validate_chargeout(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF line_exists( duplicate_entities[ serviceproduct = group_ref->serviceproduct ] ) OR group_ref->size > 1.
        lo_chargeout->set_duplicate_error( entity = CORRESPONDING ts_chargeout( group_ref->* ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_chargeoutbc_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_chargeoutbc_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-chargeoutall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_chargeoutbc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR chargeout
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR chargeout~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE chargeout.
ENDCLASS.

CLASS lhc_/esrcc/i_chargeoutbc IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CHARGEOUT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD validatedata.
    DATA:
      draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_chargeoutbc_s\\chargeout.

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
         ENTITY chargeout
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT chrg~*
      FROM /esrcc/d_chargeo AS chrg
      INNER JOIN @entities AS ent
        ON  ent~serviceproduct = chrg~serviceproduct
      WHERE chrg~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_chargeout) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ChargeoutAll' ) )
        source_entity_name = '/ESRCC/C_CHARGEOUTBC'
      CHANGING
        reported_entity    = reported-chargeout
        failed_entity      = failed-chargeout ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_chargeout ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_chargeout( entity = entity control = VALUE #( chargeoutruleid = if_abap_behv=>mk-on
                                                                            validto         = if_abap_behv=>mk-on ) ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE serviceproduct = entity-serviceproduct
                                                  AND uuid           <> entity-uuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_chargeout->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                               src_to      = draft-validto
                                                               src_entity  = draft
                                                               curr_from   = entity-validfrom
                                                               curr_to     = entity-validto
                                                               curr_entity = entity ).
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
       EXPORTING
         paths              = VALUE #( ( path = 'ChargeoutAll' ) )
         source_entity_name = '/ESRCC/C_CHARGEOUTBC'
       CHANGING
         reported_entity    = reported-chargeout
         failed_entity      = failed-chargeout ) ).

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
        ENTITY chargeout
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(chargeout).

    LOOP AT entities INTO DATA(entity) WHERE %control-chargeoutruleid = if_abap_behv=>mk-on
                                          OR %control-validto         = if_abap_behv=>mk-on.
      lo_validation->validate_chargeout(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chargeoutruleid = entity-%control-chargeoutruleid
                           validto         = entity-%control-validto )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
