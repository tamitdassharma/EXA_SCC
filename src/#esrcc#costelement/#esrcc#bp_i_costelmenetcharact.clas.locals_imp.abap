CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_ce_char TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar,
      BEGIN OF ts_control,
        validfrom      TYPE if_abap_behv=>t_xflag,
        validto        TYPE if_abap_behv=>t_xflag,
        cost_indicator TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_ce_char
        IMPORTING
          entity  TYPE ts_ce_char
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_ce_char.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validfrom      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto        = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.
    IF control-cost_indicator = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTINDICATOR' ) TO fields. ENDIF.

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
                                         ( entity = 'CostElementChar' table = '/ESRCC/CSTELMTCH' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS c_source_entity TYPE sxco_cds_object_name VALUE '/ESRCC/C_COSTELMENETCHARACTE'.
    CONSTANTS c_path TYPE sxco_cds_association_name VALUE 'CostElementCharAll'.

    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costelementcharall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costelementcharall
        RESULT result,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR costelementchar
        RESULT result,
      precheck_cba_costelementchar FOR PRECHECK
        IMPORTING entities FOR CREATE costelementcharall\_costelementchar,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costelementchar~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costelementchar.
ENDCLASS.

CLASS lhc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CSTELMTCH'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CSTELMTCH'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
    ENTITY costelementcharall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_costelementchar = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_COSTELMENETCHARACTE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CSTELMTCH'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD precheck_cba_costelementchar.
    TYPES ts_ce_char TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar.
    CONSTANTS c_vs_virtual TYPE /esrcc/ce_value_source VALUE 'SCC'.

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = c_path ) )
        source_entity_name = c_source_entity
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costelementchar
        failed_entity      = failed-costelementchar ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).
    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).

*   Identify duplicate entries
    SELECT DISTINCT
           celem~costelementuuid
        FROM /esrcc/d_cstelmt AS celem
        INNER JOIN @target_entities AS tent
            ON  tent~costelementuuid = celem~costelementuuid
            AND tent~validfrom       = celem~validfrom
        WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

*   Identify already assigned cost element entities
    SELECT DISTINCT
           tent~cstelmntcharuuid
        FROM /esrcc/d_cstelmt AS celem
        INNER JOIN @target_entities AS tent
            ON  tent~sysid       = celem~sysid
            AND tent~legalentity = celem~legalentity
            AND tent~companycode = celem~companycode
            AND tent~valuesource = celem~valuesource
            AND tent~validfrom   BETWEEN celem~validfrom AND celem~validto
        WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
          AND tent~valuesource  = @c_vs_virtual
          AND celem~valuesource = @c_vs_virtual
        INTO TABLE @DATA(assigned_entities).

    SELECT SINGLE text
        FROM /esrcc/i_valuesource
        WHERE valuesource = @c_vs_virtual
        INTO @DATA(value_source_text).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( costelementuuid  = entity-costelementuuid
                                                         validfrom        = entity-validfrom
                                                         size             = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      READ TABLE target_entities INTO DATA(t_entity) INDEX sy-tabix.

      lo_validation->validate_ce_char(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      " Validate duplicate entries
      IF line_exists( duplicate_entities[ costelementuuid = group_ref->costelementuuid ] ) OR group_ref->size > 1.
        lo_config_util->set_state_message(
          entity     = CORRESPONDING ts_ce_char( entity )
          msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '023'
                         severity = if_abap_behv_message=>severity-error
                       )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
      ELSEIF line_exists( assigned_entities[ cstelmntcharuuid = t_entity-cstelmntcharuuid ] ).
        " Validate cost element assignment
        lo_config_util->set_state_message(
          entity     = CORRESPONDING ts_ce_char( t_entity )
          msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '030'
                         severity = if_abap_behv_message=>severity-error
                         v1       = value_source_text
                       )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/c_costelmenetcharacte_s\\costelementchar.
    CONSTANTS c_vs_virtual TYPE /esrcc/ce_value_source VALUE 'SCC'.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
         ENTITY costelementchar
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT ele~*
      FROM /esrcc/d_cstelmt AS ele
      INNER JOIN @entities AS ent
        ON  ent~sysid        = ele~sysid
        AND ent~legalentity  = ele~legalentity
        AND ent~companycode  = ele~companycode
*        AND ent~costelement  = ele~costelement
      WHERE ele~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_ce_char) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = c_path ) )
        source_entity_name = c_source_entity
      CHANGING
        reported_entity    = reported-costelementchar
        failed_entity      = failed-costelementchar ).

    SELECT SINGLE text
        FROM /esrcc/i_valuesource
        WHERE valuesource = @c_vs_virtual
        INTO @DATA(value_source_text).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_ce_char ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_ce_char(
        entity  = entity
        control = VALUE #( validto = if_abap_behv=>mk-on cost_indicator = if_abap_behv=>mk-on )
      ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date)
           WHERE     sysid            = entity-sysid
                 AND legalentity      = entity-legalentity
                 AND companycode      = entity-companycode
                 AND costelement      = entity-costelement
                 AND cstelmntcharuuid <> entity-cstelmntcharuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_ce_char->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                             src_to      = draft-validto
                                                             src_entity  = draft
                                                             curr_from   = entity-validfrom
                                                             curr_to     = entity-validto
                                                             curr_entity = entity ).
      ENDLOOP.

      IF entity-valuesource = c_vs_virtual.
        LOOP AT overlapping_dates INTO date WHERE cstelmntcharuuid <> entity-cstelmntcharuuid
                                              AND sysid            = entity-sysid
                                              AND legalentity      = entity-legalentity
                                              AND companycode      = entity-companycode
                                              AND valuesource      = c_vs_virtual
                                              AND ( validfrom      BETWEEN entity-validfrom AND entity-validto
                                                OR  validto        BETWEEN entity-validfrom AND entity-validto ).
          lo_ce_char->set_state_message(
            entity     = entity
            msg        = new_message(
                           id       = /esrcc/cl_config_util=>c_config_msg
                           number   = '030'
                           severity = if_abap_behv_message=>severity-error
                           v1       = value_source_text )
            state_area = CONV #( /esrcc/cl_config_util=>duplicate )
          ).
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = c_path ) )
          source_entity_name = c_source_entity
        CHANGING
          reported_entity    = reported-costelementchar
          failed_entity      = failed-costelementchar ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-costindicator = if_abap_behv=>mk-on
                                          OR %control-validto = if_abap_behv=>mk-on.
      lo_validation->validate_ce_char(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto = entity-%control-validto cost_indicator = entity-%control-costindicator )
      ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costelementcharall INDEX 1 INTO DATA(all).
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
