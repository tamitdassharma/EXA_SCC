CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_consumption TYPE STRUCTURE FOR READ RESULT /esrcc/i_diralocconsumptn\\directallocationconsumption,
      BEGIN OF ts_control,
        consumption TYPE if_abap_behv=>t_xflag,
        uom         TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_consumption
        IMPORTING
          entity  TYPE ts_consumption
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_consumption.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-consumption = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CONSUMPTION' ) TO fields. ENDIF.
    IF control-uom         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'UOM' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_directallocationconsumptio DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR directallocationconsumption RESULT result.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE directallocationconsumption.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE directallocationconsumption.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE directallocationconsumption.

ENDCLASS.

CLASS lhc_directallocationconsumptio IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.

    DATA(entity) = entities[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
      CHANGING
        reported_entity    = reported-directallocationconsumption
        failed_entity      = failed-directallocationconsumption
    )->check_authorization(
      EXPORTING
        entity     = entity
        auth_value = CORRESPONDING #( entity MAPPING legal_entity = receivingentity cost_object = costobject cost_number = costcenter )
        activity   = /esrcc/cl_authorization=>c_authorization_activity-create
    ).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
        EXPORTING
          source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
        CHANGING
          reported_entity    = reported-directallocationconsumption
          failed_entity      = failed-directallocationconsumption
      ).

*   Check duplicates
    SELECT SINGLE @abap_true
        FROM /esrcc/consumptn
        WHERE service_product           = @entity-serviceproduct
          AND ryear                     = @entity-ryear
          AND poper                     = @entity-poper
          AND fplv                      = @entity-fplv
          AND cost_object_uuid          = @entity-costobjectuuid
          AND provider_cost_object_uuid = @entity-providercostobjectuuid
        INTO @DATA(is_duplicate).
    IF is_duplicate = abap_true.
      lo_config_util->set_duplicate_error( entity = entity ).
    ENDIF.

*   Validate if provider & receiver are same
    IF entity-costobjectuuid = entity-providercostobjectuuid.
      lo_config_util->set_state_message(
          entity     = entity
          msg        = /esrcc/cl_config_msg_handler=>same_sender_receiver( )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate )
        ).
    ENDIF.

*   Validate mandatory field
    NEW lcl_custom_validation( config_util_ref = lo_config_util )->validate_consumption(
      entity  = CORRESPONDING #( entity )
      control = VALUE #( consumption = if_abap_behv=>mk-on
                         uom         = if_abap_behv=>mk-on ) ).

  ENDMETHOD.

  METHOD precheck_update.
    READ ENTITIES OF /esrcc/i_diralocconsumptn IN LOCAL MODE
        ENTITY directallocationconsumption
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(direct).

    DATA(entity) = direct[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
      CHANGING
        reported_entity    = reported-directallocationconsumption
        failed_entity      = failed-directallocationconsumption
    )->check_authorization(
        EXPORTING
          entity     = entity
          auth_value = CORRESPONDING #( entity MAPPING legal_entity = receivingentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-change
      ).

*   Validate mandatory field
    DATA(entity_in) = entities[ 1 ].
    NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
          EXPORTING
            source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
          CHANGING
            reported_entity    = reported-directallocationconsumption
            failed_entity      = failed-directallocationconsumption
        ) )->validate_consumption(
      entity  = CORRESPONDING #( entity_in )
      control = CORRESPONDING #( entity_in-%control )
    ).
  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF /esrcc/i_diralocconsumptn IN LOCAL MODE
        ENTITY directallocationconsumption
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
      CHANGING
        reported_entity    = reported-directallocationconsumption
        failed_entity      = failed-directallocationconsumption
    ).

*   Check Authorization
    LOOP AT entities INTO DATA(entity).
      lo_auth->check_authorization(
        EXPORTING
          entity     = entity
          auth_value = CORRESPONDING #( entity MAPPING legal_entity = receivingentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-delete
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
