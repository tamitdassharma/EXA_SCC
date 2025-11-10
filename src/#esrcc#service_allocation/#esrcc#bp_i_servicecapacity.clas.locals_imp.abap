CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_capacity TYPE STRUCTURE FOR READ RESULT /esrcc/i_servicecapacity\\servicecapacity,
      BEGIN OF ts_control,
        planning TYPE if_abap_behv=>t_xflag,
        uom      TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_capacity
        IMPORTING
          entity  TYPE ts_capacity
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_capacity.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-planning = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PLANNING' ) TO fields. ENDIF.
    IF control-uom      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'UOM' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_servicecapacity DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR servicecapacity RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE servicecapacity.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE servicecapacity.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE servicecapacity.

ENDCLASS.

CLASS lhc_servicecapacity IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.
    DATA(entity) = entities[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_SERVICECAPACITY'
      CHANGING
        reported_entity    = reported-servicecapacity
        failed_entity      = failed-servicecapacity
    )->check_authorization(
      EXPORTING
        entity     = entity
        auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
        activity   = /esrcc/cl_authorization=>c_authorization_activity-create
    ).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
        EXPORTING
          source_entity_name = '/ESRCC/C_SERVICECAPACITY'
        CHANGING
          reported_entity    = reported-servicecapacity
          failed_entity      = failed-servicecapacity
      ).

*   Check duplicates
    SELECT SINGLE @abap_true
        FROM /esrcc/srv_cpcty
        WHERE ryear            = @entity-ryear
          AND poper            = @entity-poper
          AND fplv             = @entity-fplv
          AND service_product  = @entity-serviceproduct
          AND cost_object_uuid = @entity-costobjectuuid
        INTO @DATA(is_duplicate).
    IF sy-subrc = 0.
      lo_config_util->set_duplicate_error( entity = entity ).
    ENDIF.

*   Validate mandatory field
    NEW lcl_custom_validation( config_util_ref = lo_config_util )->validate_capacity(
      entity  = CORRESPONDING #( entity )
      control = VALUE #( planning = if_abap_behv=>mk-on
                         uom      = if_abap_behv=>mk-on )
    ).
  ENDMETHOD.

  METHOD precheck_update.

    READ ENTITIES OF /esrcc/i_servicecapacity IN LOCAL MODE
        ENTITY servicecapacity
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(capacity).

    DATA(entity) = capacity[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_SERVICECAPACITY'
      CHANGING
        reported_entity    = reported-servicecapacity
        failed_entity      = failed-servicecapacity
    )->check_authorization(
        EXPORTING
          entity     = entity
          auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-change
      ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_SERVICECAPACITY'
      CHANGING
        reported_entity    = reported-servicecapacity
        failed_entity      = failed-servicecapacity ) ).

*   Validate mandatory field
    DATA(entity_in) = entities[ 1 ].
    lo_validation->validate_capacity(
      entity  = CORRESPONDING #( entity_in )
      control = CORRESPONDING #( entity_in-%control )
  ).
  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF /esrcc/i_servicecapacity IN LOCAL MODE
            ENTITY servicecapacity
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(entities).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
          EXPORTING
            source_entity_name = '/ESRCC/C_SERVICECAPACITY'
          CHANGING
            reported_entity    = reported-servicecapacity
            failed_entity      = failed-servicecapacity
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

ENDCLASS.
