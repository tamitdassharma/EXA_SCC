CLASS /esrcc/extract_data_bw DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES:
      /esrcc/if_extract_data.

    CLASS-METHODS:
      create RETURNING VALUE(instance) TYPE REF TO /esrcc/if_extract_data.

  PRIVATE SECTION.
    CLASS-DATA:
      _instance TYPE REF TO /esrcc/extract_data_bw.

    DATA:
      _filters TYPE /esrcc/if_extract_data=>filters_type.
ENDCLASS.


CLASS /esrcc/extract_data_bw IMPLEMENTATION.
  METHOD create.
    " Factory method to create an instance of the class
    instance = _instance = NEW /esrcc/extract_data_bw( ).
  ENDMETHOD.

  METHOD /esrcc/if_extract_data~extract.
    " Extract data based on the provided filters
    DATA:
      validity           TYPE RANGE OF poper,
      legal_entities     TYPE RANGE OF /esrcc/legalentity,
      cost_centers       TYPE RANGE OF /esrcc/costcenter,
      cost_elements      TYPE RANGE OF /esrcc/costelement,
      package_codes      TYPE RANGE OF /esrcc/package_code,
      extraction_bw_badi TYPE REF TO /esrcc/bw_extraction_badi.

    FIELD-SYMBOLS:
      <filter_value> TYPE if_apj_rt_exec_object=>tt_templ_val.


    ASSIGN _filters[ filter_name = 'REP_YEAR' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      DATA(year) = CONV /esrcc/ryear( <filter_value>[ 1 ]-low  ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'PERIOD' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      validity = CORRESPONDING #( <filter_value> ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'EXT_OBJ' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      DATA(object) = CONV /esrcc/extraction_object( <filter_value>[ 1 ]-low ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'LEDGER' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      DATA(ledger) = CONV /esrcc/ledger_de( <filter_value>[ 1 ]-low ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'ENTITY' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      legal_entities = CORRESPONDING #( <filter_value> ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'CSTCENTR' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      cost_centers = CORRESPONDING #( <filter_value> ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'CSTELEM' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      cost_elements = CORRESPONDING #( <filter_value> ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'PKG_CODE' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      package_codes = CORRESPONDING #( <filter_value> ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'PKG_SIZE' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      DATA(package_size) = CONV i( <filter_value>[ 1 ]-low ).
    ENDIF.

    ASSIGN _filters[ filter_name = 'SIMULATE' ]-filter_value->* TO <filter_value>.
    IF sy-subrc = 0.
      DATA(is_simulation) = CONV abap_bool( <filter_value>[ 1 ]-low ).
    ENDIF.

    TRY.
        GET BADI extraction_bw_badi.
      CATCH cx_badi_not_implemented cx_badi_unknown_error.
        RETURN.
    ENDTRY.

    TRY.
        CALL BADI extraction_bw_badi->extract_data
          EXPORTING
            extraction_type = object
            reporting_year  = year
            periods         = validity
            ledger          = ledger
            legal_entities  = legal_entities
            cost_centers    = cost_centers
            cost_elements   = cost_elements
            package_codes   = package_codes
            package_size    = package_size
            simulation_mode = is_simulation.
      CATCH cx_amdp_creation_error
            cx_amdp_execution_error
            cx_amdp_version_error.

    ENDTRY.
    " Handle exceptions as needed
    result = _instance.
  ENDMETHOD.

  METHOD /esrcc/if_extract_data~filter.
    _filters = filters.
    " Store the filters for later use in the extract method
    result = _instance.
  ENDMETHOD.

ENDCLASS.
