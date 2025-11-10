CLASS /esrcc/write_back DEFINITION PUBLIC FINAL CREATE PRIVATE .

  PUBLIC SECTION.
    INTERFACES:
      /esrcc/if_write_back .

    CLASS-METHODS:
      create RETURNING VALUE(instance) TYPE REF TO /esrcc/if_write_back.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      _instance        TYPE REF TO /esrcc/write_back,
      _write_back_badi TYPE REF TO /esrcc/badi_write_back,
      _logger          TYPE REF TO /esrcc/if_application_logs.

    CLASS-METHODS:
      _initialize RETURNING VALUE(instantiated) TYPE abap_boolean,
      _logging RETURNING VALUE(instantiated) TYPE abap_boolean,
      _exit_handler RETURNING VALUE(instantiated) TYPE abap_boolean.

    DATA:
      _filters TYPE /esrcc/if_write_back=>filters_type.
ENDCLASS.



CLASS /esrcc/write_back IMPLEMENTATION.


  METHOD /esrcc/if_write_back~filter.
    _filters = filters.

    TRY.

        CALL BADI _write_back_badi->adapt_filters
          CHANGING
            filters = _filters.
      CATCH cx_badi_context_error cx_badi_initial_context cx_badi_initial_reference cx_badi_not_implemented INTO DATA(exception).
        " Handle exceptions
    ENDTRY.
    result = _instance.
  ENDMETHOD.


  METHOD /esrcc/if_write_back~write_back.
    TRY.

        CALL BADI _write_back_badi->pre_exit.
      CATCH cx_badi_context_error cx_badi_initial_context cx_badi_initial_reference cx_badi_not_implemented INTO DATA(exception).
        " Handle exceptions
    ENDTRY.

    TRY.

        CALL BADI _write_back_badi->post_exit.
      CATCH cx_badi_context_error cx_badi_initial_context cx_badi_initial_reference cx_badi_not_implemented INTO exception.
        " Handle exceptions
    ENDTRY.
    result = _instance.
  ENDMETHOD.

  METHOD create.
    IF _initialize( ).
      _instance = NEW /esrcc/write_back( ).
    ENDIF.

    instance = _instance.
  ENDMETHOD.

  METHOD _initialize.
    instantiated = COND #( WHEN _logging(  ) THEN _exit_handler(  ) ).
  ENDMETHOD.

  METHOD _exit_handler.
    TRY.
        GET BADI _write_back_badi.
        instantiated = abap_true.
      CATCH cx_badi_unknown_error INTO DATA(exception).
        " Log the error
    ENDTRY.
  ENDMETHOD.

  METHOD _logging.
    _logger = NEW /esrcc/cl_application_logs( ).
    IF _logger IS NOT INITIAL.
      instantiated = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
