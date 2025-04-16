CLASS /esrcc/cl_download_template DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.


CLASS /esrcc/cl_download_template IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA original_data TYPE STANDARD TABLE OF /esrcc/c_uploadstaging WITH DEFAULT KEY.

    DATA:
      dynamic_table TYPE REF TO data,
      dynamic_line  TYPE REF TO data.

    FIELD-SYMBOLS:
      <table> TYPE STANDARD TABLE,
      <line>  TYPE any.

    original_data = CORRESPONDING #( it_original_data ).


    FINAL(template_helper) = /esrcc/template_helper=>create( ).

    LOOP AT original_data ASSIGNING FIELD-SYMBOL(<original_data>).
    IF template_helper->check_table_registered( SWITCH tabname( <original_data>-SubApplication
                                                  WHEN 'FLI' THEN '/ESRCC/CB_LI_TMP'
                                                  WHEN 'FCD' THEN '/ESRCC/CONSUMPTN'
                                                  WHEN 'FAB' THEN '/ESRCC/INDTALLOC'
                                                  WHEN 'FPD' THEN '/ESRCC/SRV_CPCTY'
                                                  WHEN 'FBC' THEN <original_data>-TableName
                                                  ELSE            <original_data>-TableName ) ).
       <original_data>-TableName = template_helper->get_table_alias( ).
    ENDIF.

      DATA(components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                       to_upper( <original_data>-TableName ) ) )->get_components( ).
      DELETE components WHERE name = 'CLIENT' OR name = 'CREATED_BY' OR name = 'CREATED_AT' OR name = 'LAST_CHANGED_BY' OR name = 'LAST_CHANGED_AT' OR name = 'LOCAL_LAST_CHANGED_AT'.

      DATA(dynamic_line_handler) = cl_abap_structdescr=>get(
                                       VALUE #( FOR <component> IN components
                                                ( VALUE #( BASE CORRESPONDING #( <component> )
                                                           type = cl_abap_elemdescr=>get_string( ) ) ) ) ).
      FINAL(dynamic_table_handler) = cl_abap_tabledescr=>create( dynamic_line_handler ).

      CREATE DATA dynamic_table TYPE HANDLE dynamic_table_handler.
      ASSIGN dynamic_table->* TO <table>.

      CREATE DATA dynamic_line TYPE HANDLE dynamic_line_handler.
      ASSIGN dynamic_line->* TO <line>.

      DATA(database_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
                                         VALUE #(
                                             ( xco_cp_abap_repository=>object_name->get_filter(
                                                   xco_cp_abap_sql=>constraint->equal( <original_data>-TableName ) ) ) ) )->in(
                                                       xco_cp_abap=>repository )->get( ).

      IF lines( database_table_readers ) = 0.
        RETURN.
      ENDIF.

      DATA(table_fields_information) = database_table_readers[ 1 ]->fields->all->get( ).
      LOOP AT components ASSIGNING FIELD-SYMBOL(<component_read>).
        ASSIGN COMPONENT sy-tabix OF STRUCTURE <line> TO FIELD-SYMBOL(<cell>).
        IF <cell> IS ASSIGNED.
          FINAL(description) = table_fields_information[
                                   table_line->name = <component_read>-name ]->content( )->get_short_description( ).
          <cell> = description.
          UNASSIGN <cell>.
        ENDIF.
      ENDLOOP.

      APPEND <line> TO <table>.

      IF <table> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      FINAL(access_writer) = xco_cp_xlsx=>document->empty( )->write_access( ).
      FINAL(worksheet) = access_writer->get_workbook( )->worksheet->at_position( 1 ).

      " TODO: variable is assigned but never used (ABAP cleaner)
      FINAL(result) = worksheet->select( xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( )
       )->row_stream( )->operation->write_from( REF #( <table> ) )->execute( ).

      <original_data>-TemporaryDataStream = access_writer->get_file_content( ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( original_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = '/ESRCC/C_UPLOADSTAGING'.
      APPEND LINES OF VALUE if_sadl_exit_calc_element_read=>tt_elements( ( CONV #( 'APPLICATION' ) )
                                                                         ( CONV #( 'SUBAPPLICATION' ) )
                                                                         ( CONV #( 'TABLENAME' ) ) ) TO et_requested_orig_elements.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
