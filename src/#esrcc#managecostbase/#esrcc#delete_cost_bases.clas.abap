CLASS /esrcc/delete_cost_bases DEFINITION PUBLIC FINAL CREATE PRIVATE .

  PUBLIC SECTION.

    TYPES: BEGIN OF deletion_parameters,
             reporting_years  TYPE RANGE OF /esrcc/rYEAR,
             posting_periods  TYPE RANGE OF poper,
             planning_version TYPE RANGE OF /esrcc/costdataset_de,
             system_id        TYPE RANGE OF /esrcc/sysid,
             legal_entity     TYPE RANGE OF /esrcc/legalentity,
             company_code     TYPE RANGE OF /esrcc/ccode_de,
             document_number  TYPE RANGE OF /esrcc/doc_no,
             item_number      TYPE RANGE OF /esrcc/buzei,
             cost_object_type TYPE RANGE OF /esrcc/costobject_de,
             cost_center      TYPE RANGE OF /esrcc/costcenter,
             cost_element     TYPE RANGE OF /esrcc/costelement,
             is_simulation    TYPE xsdboolean,
           END OF deletion_parameters.

    CLASS-METHODS: create RETURNING VALUE(instance) TYPE REF TO /esrcc/delete_cost_bases.

    METHODS:
      execute RETURNING VALUE(records) TYPE i
              RAISING
                cx_abap_auth_check_exception,
      set_parameters IMPORTING filters TYPE deletion_parameters.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: _reporting_years  TYPE RANGE OF /esrcc/rYEAR,
          _posting_periods  TYPE RANGE OF poper,
          _planning_version TYPE RANGE OF /esrcc/costdataset_de,
          _system_id        TYPE RANGE OF /esrcc/sysid,
          _legal_entity     TYPE RANGE OF /esrcc/legalentity,
          _company_code     TYPE RANGE OF /esrcc/ccode_de,
          _document_number  TYPE RANGE OF /esrcc/doc_no,
          _item_number      TYPE RANGE OF /esrcc/buzei,
          _cost_object_type TYPE RANGE OF /esrcc/costobject_de,
          _cost_center      TYPE RANGE OF /esrcc/costcenter,
          _cost_element     TYPE RANGE OF /esrcc/costelement,
          _is_simulation    TYPE xsdboolean.

    METHODS:
      _is_authorised RETURNING VALUE(is_authorised) TYPE abap_bool,
      _generate_where_clause RETURNING VALUE(result) TYPE string,
      _delete_cost_bases IMPORTING where_clause    TYPE string
                         RETURNING VALUE(db_count) TYPE i.

ENDCLASS.



CLASS /ESRCC/DELETE_COST_BASES IMPLEMENTATION.


  METHOD create.
    instance = NEW /esrcc/delete_cost_bases( ).
  ENDMETHOD.


  METHOD execute.
    IF NOT _is_authorised(  ).
      RAISE EXCEPTION TYPE cx_abap_auth_check_exception.
    ENDIF.

    records = _delete_cost_bases( where_clause = _generate_where_clause( ) ).
  ENDMETHOD.


  METHOD set_parameters.
    _reporting_years  = filters-reporting_years.
    _posting_periods  = filters-posting_periods.
    _planning_version = filters-planning_version.
    _system_id        = filters-system_id.
    _legal_entity     = filters-legal_entity.
    _company_code     = filters-company_code.
    _document_number  = filters-document_number.
    _item_number      = filters-item_number.
    _cost_object_type = filters-cost_object_type.
    _cost_center      = filters-cost_center.
    _cost_element     = filters-cost_element.
    _is_simulation    = filters-is_simulation.
  ENDMETHOD.


  METHOD _delete_cost_bases.
    IF where_clause IS NOT INITIAL.
      TRY.
          DELETE FROM /esrcc/cb_li WHERE (where_clause).
        CATCH cx_sy_dynamic_osql_semantics INTO DATA(lx_sql).
      ENDTRY.
      IF sy-subrc = 0.
        db_count = sy-dbcnt.
        IF _is_simulation = abap_true.
          ROLLBACK WORK.
        ELSE.
          COMMIT WORK.
        ENDIF.
      ELSE.
        db_count = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD _generate_where_clause.
    result = |RYEAR IN @_REPORTING_YEARS AND POPER IN @_POSTING_PERIODS{
                COND #( WHEN _planning_version IS NOT INITIAL
                            THEN | AND FPLV IN @_PLANNING_VERSION|
                        WHEN _system_id IS NOT INITIAL
                            THEN | AND POPER IN @_POSTING_PERIOD|
                        WHEN _legal_entity IS NOT INITIAL
                            THEN | AND LEGALENTITY IN @_LEGAL_ENTITY|
                        WHEN _company_code IS NOT INITIAL
                            THEN | AND CCODE IN @_COMPANY_CODE|
                        WHEN _document_number IS NOT INITIAL
                            THEN | AND BELNR IN @_DOCUMENT_NUMBER|
                        WHEN _item_number IS NOT INITIAL
                            THEN | AND BUZEI IN @_ITEM_NUMBER|
                        WHEN _cost_object_type IS NOT INITIAL
                            THEN | AND COSTOBJECT IN @_COST_OBJECT_TYPE|
                        WHEN _cost_center IS NOT INITIAL
                            THEN | AND COSTCENTER IN @_COST_CENTER|
                        WHEN _cost_element IS NOT INITIAL
                            THEN | AND COSTELEMENT IN @_COST_ELEMENT| ) }|.
  ENDMETHOD.


  METHOD _is_authorised.
    AUTHORITY-CHECK OBJECT '/ESRCC/ADM'
      ID 'ACTVT' FIELD '06'. " DELETE.
    is_authorised = SWITCH #( sy-subrc WHEN 0 THEN abap_true
                          ELSE abap_false ).
  ENDMETHOD.
ENDCLASS.
