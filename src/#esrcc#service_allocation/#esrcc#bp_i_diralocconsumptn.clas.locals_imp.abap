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
      /esrcc/cl_config_util=>create(
        EXPORTING
          source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
          is_transition      = abap_true
        CHANGING
          reported_entity    = reported-directallocationconsumption
          failed_entity      = failed-directallocationconsumption
      )->set_duplicate_error( entity = entity ).
    ENDIF.

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
