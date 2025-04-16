CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_allocvalue TYPE STRUCTURE FOR READ RESULT /esrcc/i_indirectallockeyvalue\\indirectallocationkeyvalues,

      BEGIN OF ts_control,
        ryear         TYPE if_abap_behv=>t_xflag,
        poper         TYPE if_abap_behv=>t_xflag,
        allocationkey TYPE if_abap_behv=>t_xflag,
        fplv          TYPE if_abap_behv=>t_xflag,
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

    IF control-ryear         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RYEAR' ) TO fields. ENDIF.
    IF control-poper         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'POPER' ) TO fields. ENDIF.
    IF control-allocationkey = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONKEY' ) TO fields. ENDIF.
    IF control-fplv          = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'FPLV' ) TO fields. ENDIF.

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
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR indirectallocationkeyvalues~validatedata.
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

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_indirectallockeyvalue IN LOCAL MODE
          ENTITY indirectallocationkeyvalues
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
                                                                         EXPORTING
                                                                           paths              = VALUE #( ( path = 'IndirectAllocationKeyValues' ) )
                                                                           source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
                                                                         CHANGING
                                                                           reported_entity    = reported-indirectallocationkeyvalues
                                                                           failed_entity      = failed-indirectallocationkeyvalues
                                                                       ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE ryear IS INITIAL
                                                         OR poper IS INITIAL
                                                         OR allocationkey IS INITIAL
                                                         OR fplv IS INITIAL.
      lo_validation->validate_allocvalue(
        entity  = <entity>
        control = VALUE #( ryear         = if_abap_behv=>mk-on
                           poper         = if_abap_behv=>mk-on
                           allocationkey = if_abap_behv=>mk-on
                           fplv          = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
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
      /esrcc/cl_config_util=>create(
        EXPORTING
          source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
          is_transition      = abap_true
        CHANGING
          reported_entity    = reported-indirectallocationkeyvalues
          failed_entity      = failed-indirectallocationkeyvalues
      )->set_duplicate_error( entity = entity ).
    ENDIF.

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
