CLASS /esrcc/cl_dyn_table_generator DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES:
      /esrcc/if_dyn_table_generator.

    CLASS-METHODS:
      get RETURNING VALUE(instance) TYPE REF TO /esrcc/if_dyn_table_generator.

  PRIVATE SECTION.
    CLASS-DATA:
      _dynamic_generator TYPE REF TO /esrcc/cl_dyn_table_generator.

    DATA:
      _table_name         TYPE tabname,
      _dynamic_table      TYPE REF TO data,
      _dynamic_table_line TYPE REF TO data,
      _field_list         TYPE /esrcc/if_dyn_table_generator=>ddic_field_info_list,
      _components         TYPE cl_abap_structdescr=>component_table.
ENDCLASS.


CLASS /esrcc/cl_dyn_table_generator IMPLEMENTATION.
  METHOD /esrcc/if_dyn_table_generator~destroy.
    FREE _dynamic_generator.
  ENDMETHOD.

  METHOD /esrcc/if_dyn_table_generator~generate.
    DATA:
      structure_descriptor TYPE REF TO cl_abap_typedescr,
      enrichment_exit      TYPE REF TO /esrcc/dynamic_table_generator.

    IF table_name IS INITIAL.
      RAISE EXCEPTION NEW cx_sy_ref_is_initial( ).
    ENDIF.

    _table_name = table_name.

    " Form or generate the basic list of components of the provided table
    cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = _table_name
                                           RECEIVING  p_descr_ref    = structure_descriptor
                                           EXCEPTIONS type_not_found = 1
                                                      OTHERS         = 2 ).
    IF sy-subrc <> 0.
      is_exception_raised = abap_true.
      RETURN.
    ENDIF.

    _components = CAST cl_abap_structdescr( structure_descriptor )->get_components( ).
    DELETE _components WHERE name IS INITIAL.

    _field_list = CORRESPONDING #( CAST cl_abap_structdescr( structure_descriptor )->get_ddic_field_list( ) ).

    TRY.
        GET BADI enrichment_exit FILTERS table_name = _table_name.

        CALL BADI enrichment_exit->enrich_table_components
          CHANGING components = _components.
      CATCH cx_badi_not_implemented cx_badi_unknown_error cx_badi_initial_reference cx_sy_dyn_call_illegal_method
        INTO FINAL(raised_badi_exception). " TODO: variable is assigned but never used (ABAP cleaner)
    ENDTRY.

    FINAL(line_handler) = cl_abap_structdescr=>get( _components ).
    CREATE DATA _dynamic_table_line TYPE HANDLE line_handler.
    IF _dynamic_table_line IS INITIAL.
      RAISE EXCEPTION NEW cx_sy_create_data_error( ).
    ENDIF.

    FINAL(table_handler) = cl_abap_tabledescr=>create( line_handler ).
    CREATE DATA _dynamic_table TYPE HANDLE table_handler.
    IF _dynamic_table IS INITIAL.
      RAISE EXCEPTION NEW cx_sy_create_data_error( ).
    ENDIF.
  ENDMETHOD.

  METHOD /esrcc/if_dyn_table_generator~get_dynamic_table.
    dynamic_table = _dynamic_table.
  ENDMETHOD.

  METHOD /esrcc/if_dyn_table_generator~get_dynamic_table_line.
    dynamic_table_line = _dynamic_table_line.
  ENDMETHOD.

  METHOD /esrcc/if_dyn_table_generator~get_table_components.
    components = _components.
  ENDMETHOD.

  METHOD /esrcc/if_dyn_table_generator~override_table_components.
    CLEAR:
     _dynamic_table_line,
     _dynamic_table.

    FINAL(line_handler) = cl_abap_structdescr=>get( components ).
    CREATE DATA _dynamic_table_line TYPE HANDLE line_handler.
    IF _dynamic_table_line IS INITIAL.
      RAISE EXCEPTION NEW cx_sy_create_data_error( ).
    ENDIF.

    FINAL(table_handler) = cl_abap_tabledescr=>create( line_handler ).
    CREATE DATA _dynamic_table TYPE HANDLE table_handler.
    IF _dynamic_table IS INITIAL.
      RAISE EXCEPTION NEW cx_sy_create_data_error( ).
    ENDIF.
  ENDMETHOD.

  METHOD get.
    IF _dynamic_generator IS NOT BOUND.
      _dynamic_generator = NEW /esrcc/cl_dyn_table_generator( ).
    ENDIF.
    instance = _dynamic_generator.
  ENDMETHOD.

  METHOD /esrcc/if_dyn_table_generator~get_field_list.
    field_list = VALUE #( _field_list[ tabname   = table_name
                                       fieldname = field_name
                                       langu     = sy-langu ] OPTIONAL ).
  ENDMETHOD.
ENDCLASS.
