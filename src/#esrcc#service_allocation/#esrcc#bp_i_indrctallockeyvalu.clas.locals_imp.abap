CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_allocvalue TYPE STRUCTURE FOR READ RESULT /esrcc/i_indirectallockeyvalue\\indirectallocationkeyvalues,

      BEGIN OF ts_control,
        value TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_allocvalue
        IMPORTING
          entity  TYPE ts_allocvalue
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_allocvalue.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-value = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALUE' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_indirectallocationkeyvalue DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR indirectallocationkeyvalues RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE indirectallocationkeyvalues.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE indirectallocationkeyvalues.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE indirectallocationkeyvalues.

ENDCLASS.

CLASS lhc_indirectallocationkeyvalue IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.
    DATA(entity) = entities[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
      CHANGING
        reported_entity    = reported-indirectallocationkeyvalues
        failed_entity      = failed-indirectallocationkeyvalues
    )->check_authorization(
      EXPORTING
        entity     = entity
        auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
        activity   = /esrcc/cl_authorization=>c_authorization_activity-create
    ).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-indirectallocationkeyvalues
        failed_entity      = failed-indirectallocationkeyvalues
    ).

*   Check duplicates
    SELECT SINGLE @abap_true
        FROM /esrcc/indtalloc
        WHERE cost_object_uuid = @entity-costobjectuuid
          AND allocation_key   = @entity-allocationkey
          AND fplv             = @entity-fplv
          AND ryear            = @entity-ryear
          AND poper            = @entity-poper
        INTO @DATA(is_duplicate).
    IF sy-subrc = 0.
      lo_config_util->set_duplicate_error( entity = entity ).
    ENDIF.

    NEW lcl_custom_validation( config_util_ref = lo_config_util )->validate_allocvalue(
      entity  = CORRESPONDING #( entity )
      control = VALUE #( value = if_abap_behv=>mk-on )
    ).

  ENDMETHOD.

  METHOD precheck_update.
    READ ENTITIES OF /esrcc/i_indirectallockeyvalue IN LOCAL MODE
        ENTITY indirectallocationkeyvalues
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(indirect).

    DATA(entity) = indirect[ 1 ].

*   Check Authorization
    /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
      CHANGING
        reported_entity    = reported-indirectallocationkeyvalues
        failed_entity      = failed-indirectallocationkeyvalues
    )->check_authorization(
        EXPORTING
          entity     = entity
          auth_value = CORRESPONDING #( entity MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-change
      ).

*   Validate mandatory field
    DATA(entity_in) = entities[ 1 ].
    NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
      CHANGING
        reported_entity    = reported-indirectallocationkeyvalues
        failed_entity      = failed-indirectallocationkeyvalues
    ) )->validate_allocvalue(
      entity  = CORRESPONDING #( entity_in )
      control = CORRESPONDING #( entity_in-%control )
    ).
  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF /esrcc/i_indirectallockeyvalue IN LOCAL MODE
          ENTITY indirectallocationkeyvalues
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(entities).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
      CHANGING
        reported_entity    = reported-indirectallocationkeyvalues
        failed_entity      = failed-indirectallocationkeyvalues
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
