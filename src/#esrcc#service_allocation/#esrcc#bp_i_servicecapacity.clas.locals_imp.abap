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
      /esrcc/cl_config_util=>create(
        EXPORTING
          source_entity_name = '/ESRCC/C_SERVICECAPACITY'
          is_transition      = abap_true
        CHANGING
          reported_entity    = reported-servicecapacity
          failed_entity      = failed-servicecapacity
      )->set_duplicate_error( entity = entity ).
    ENDIF.
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
