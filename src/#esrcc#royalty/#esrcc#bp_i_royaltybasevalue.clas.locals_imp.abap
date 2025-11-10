CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_roy_base TYPE STRUCTURE FOR READ RESULT /esrcc/i_royaltybasevalue\\royaltybasevalue,
      BEGIN OF ts_control,
        amountvalue TYPE if_abap_behv=>t_xflag,
        unitvalue   TYPE if_abap_behv=>t_xflag,
        uom         TYPE if_abap_behv=>t_xflag,
        currency    TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_royalty
        IMPORTING
          entity  TYPE ts_roy_base
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_royalty.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF entity-amountvalue IS NOT INITIAL. APPEND VALUE #( fieldname = 'CURRENCY' ) TO fields. ENDIF.
    IF entity-unitvalue IS NOT INITIAL. APPEND VALUE #( fieldname = 'UOM' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    DATA(lo_dictionary) = NEW /esrcc/cl_abap_dictionary( iv_entity_name = '/ESRCC/C_ROYALTYBASEVALUE' ).
    CLEAR fields.
    IF entity-amountvalue IS INITIAL.
      APPEND VALUE #( fieldname = 'CURRENCY' ) TO fields.
    ENDIF.

    config_util_ref->validate_non_mandatory(
      fields = fields
      value  = lo_dictionary->derive_field_label( iv_data_element = lo_dictionary->get_data_element_by_value( iv_value = entity-amountvalue ) iv_field_name = 'AMOUNTVALUE' )
      entity = entity
    ).

    CLEAR fields.
    IF entity-unitvalue IS INITIAL.
      APPEND VALUE #( fieldname = 'UOM' ) TO fields.
    ENDIF.

    config_util_ref->validate_non_mandatory(
      fields = fields
      value  = lo_dictionary->derive_field_label( iv_data_element = lo_dictionary->get_data_element_by_value( iv_value = entity-unitvalue ) iv_field_name = 'UNITVAUE' )
      entity = entity
    ).

    IF control-amountvalue = if_abap_behv=>mk-on OR control-unitvalue = if_abap_behv=>mk-on.
      config_util_ref->check_single_input(
        fields = VALUE #( ( fieldname = 'AMOUNTVALUE' )
                          ( fieldname = 'UNITVALUE' ) )
        entity = entity
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_royaltybasevalue DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR royaltybasevalue RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE royaltybasevalue.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE royaltybasevalue.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE royaltybasevalue.
    METHODS updatevalidon FOR DETERMINE ON MODIFY
      IMPORTING keys FOR royaltybasevalue~updatevalidon.

ENDCLASS.

CLASS lhc_royaltybasevalue IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD precheck_create.
    DATA(entity) = entities[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_ROYALTYBASEVALUE'
      CHANGING
        reported_entity    = reported-royaltybasevalue
        failed_entity      = failed-royaltybasevalue
    )->check_authorization(
      EXPORTING
        entity     = entity
        auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
        activity   = /esrcc/cl_authorization=>c_authorization_activity-create
    ).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_ROYALTYBASEVALUE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-royaltybasevalue
        failed_entity      = failed-royaltybasevalue
    ).

*   Check duplicates
    SELECT SINGLE @abap_true
        FROM /esrcc/roybasval
        WHERE ryear            = @entity-ryear
          AND poper            = @entity-poper
          AND fplv             = @entity-fplv
          AND royalty_base_key = @entity-royaltybasekey
          AND cost_object_uuid = @entity-costobjectuuid
          AND license          = @entity-license
        INTO @DATA(is_duplicate).
    IF sy-subrc = 0.
      lo_config_util->set_duplicate_error( entity = entity ).
    ENDIF.

*   Validate mandatory field
    NEW lcl_custom_validation( config_util_ref = lo_config_util )->validate_royalty(
      entity  = CORRESPONDING #( entity )
      control = VALUE #( amountvalue = if_abap_behv=>mk-on
                         unitvalue   = if_abap_behv=>mk-on
                         uom         = if_abap_behv=>mk-on
                         currency    = if_abap_behv=>mk-on ) ).
  ENDMETHOD.

  METHOD precheck_update.
    READ ENTITIES OF /esrcc/i_royaltybasevalue IN LOCAL MODE
        ENTITY royaltybasevalue
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(base_entities).

    DATA(entity) = base_entities[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_ROYALTYBASEVALUE'
      CHANGING
        reported_entity    = reported-royaltybasevalue
        failed_entity      = failed-royaltybasevalue
    )->check_authorization(
        EXPORTING
          entity     = entity
          auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-change
      ).

*   Validate mandatory field
    DATA(entity_in) = entities[ 1 ].

    entity_in-amountvalue = COND #( WHEN entity_in-%control-amountvalue = if_abap_behv=>mk-off THEN entity-amountvalue ELSE entity_in-amountvalue ).
    entity_in-currency    = COND #( WHEN entity_in-%control-currency = if_abap_behv=>mk-off THEN entity-currency ELSE entity_in-currency ).
    entity_in-unitvalue   = COND #( WHEN entity_in-%control-unitvalue = if_abap_behv=>mk-off THEN entity-unitvalue ELSE entity_in-unitvalue ).
    entity_in-uom         = COND #( WHEN entity_in-%control-uom = if_abap_behv=>mk-off THEN entity-uom ELSE entity_in-uom ).

    NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
          EXPORTING
            source_entity_name = '/ESRCC/C_ROYALTYBASEVALUE'
          CHANGING
            reported_entity    = reported-royaltybasevalue
            failed_entity      = failed-royaltybasevalue
        ) )->validate_royalty(
      entity  = VALUE #( BASE CORRESPONDING #( entity_in )
                         amountvalue = COND #( WHEN entity_in-%control-amountvalue = if_abap_behv=>mk-off THEN entity-amountvalue ELSE entity_in-amountvalue )
                         currency    = COND #( WHEN entity_in-%control-currency = if_abap_behv=>mk-off THEN entity-currency ELSE entity_in-currency )
                         unitvalue   = COND #( WHEN entity_in-%control-unitvalue = if_abap_behv=>mk-off THEN entity-unitvalue ELSE entity_in-unitvalue )
                         uom         = COND #( WHEN entity_in-%control-uom = if_abap_behv=>mk-off THEN entity-uom ELSE entity_in-uom ) )
      control = CORRESPONDING #( entity_in-%control )
    ).
  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF /esrcc/i_royaltybasevalue IN LOCAL MODE
        ENTITY royaltybasevalue
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_ROYALTYBASEVALUE'
      CHANGING
        reported_entity    = reported-royaltybasevalue
        failed_entity      = failed-royaltybasevalue
    ).

*   Check Authorization
    LOOP AT entities INTO DATA(entity).
      lo_auth->check_authorization(
        EXPORTING
          entity     = entity
          auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-delete
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD updatevalidon.
    READ ENTITIES OF /esrcc/i_royaltybasevalue IN LOCAL MODE
      ENTITY royaltybasevalue
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    " Update 'Valid On' date
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      <entity>-validon = |{ <entity>-ryear }{ <entity>-poper+1(2) }01|.
    ENDLOOP.

    MODIFY ENTITIES OF /esrcc/i_royaltybasevalue IN LOCAL MODE
      ENTITY royaltybasevalue
      UPDATE FIELDS ( validon )
      WITH CORRESPONDING #( entities )
      REPORTED DATA(upd_reported)
      MAPPED DATA(upd_mapped)
      FAILED DATA(upd_failed).
  ENDMETHOD.

ENDCLASS.
