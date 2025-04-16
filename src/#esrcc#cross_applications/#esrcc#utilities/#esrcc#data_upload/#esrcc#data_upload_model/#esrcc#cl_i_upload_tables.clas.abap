CLASS /esrcc/cl_i_upload_tables DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_i_upload_tables IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA:
      results TYPE STANDARD TABLE OF /esrcc/i_uploadtables WITH EMPTY KEY.

    TRY.
        DATA(sql_filter_string) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            " TODO: variable is assigned but never used (ABAP cleaner)
            FINAL(filters) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(ex_rap_filter_no_range).
            " handle exception
            DATA(text) = ex_rap_filter_no_range->get_text( ).
        ENDTRY.
*
*        FINAL(search_expression) = io_request->get_search_expression( ).
        FINAL(search_expression_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( io_request->get_search_expression( ) ) }%'|.

        IF sql_filter_string IS INITIAL.
          sql_filter_string = search_expression_sql.
        ELSE.
          sql_filter_string = |( { sql_filter_string } AND { search_expression_sql } )|.
        ENDIF.
        " request data
        IF io_request->is_data_requested( ) = abap_false.
          RETURN.
        ENDIF.

        " paging
        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(offset) = io_request->get_paging( )->get_offset( ).
        FINAL(page_size) = io_request->get_paging( )->get_page_size( ).
        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(max_rows) = COND #( WHEN page_size = if_rap_query_paging=>page_size_unlimited
                                  THEN 0
                                  ELSE page_size ).
        "
        " sorting
        FINAL(sort_elements) = io_request->get_sort_elements( ).
        FINAL(sort_criterias) = VALUE string_table(
            FOR sort_element IN sort_elements
            ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true
                                                   THEN ` descending`
                                                   ELSE ` ascending` ) ) ).
        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(sort_string) = COND #( WHEN sort_criterias IS INITIAL
                                     THEN `primary key`
                                     ELSE concat_lines_of( table = sort_criterias
                                                           sep   = `, ` ) ).
        " requested elements
        DATA(requested_elements) = io_request->get_requested_elements( ).
        " aggregate
        FINAL(aggregated_elements) = io_request->get_aggregation( )->get_aggregated_elements( ).
        "
        IF aggregated_elements IS NOT INITIAL.
          LOOP AT aggregated_elements ASSIGNING FIELD-SYMBOL(<aggregated_element>).
            DELETE requested_elements WHERE table_line = <aggregated_element>-result_element.
            FINAL(aggregation) = |{ <aggregated_element>-aggregation_method }( { <aggregated_element>-input_element } ) as { <aggregated_element>-result_element }|.
            APPEND aggregation TO requested_elements.
          ENDLOOP.
        ENDIF.
        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(requested_element) = concat_lines_of( table = requested_elements
                                                    sep   = `, ` ).
        " grouping
        FINAL(grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(grouping) = concat_lines_of( table = grouped_element
                                           sep   = `, ` ).

        DATA(database_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
            VALUE #(
                ( xco_cp_system=>software_component->get_filter( xco_cp_abap_sql=>constraint->equal( 'ESRCC' ) ) ) ) )->in(
                    xco_cp_abap=>repository )->get( ).

        LOOP AT database_table_readers ASSIGNING FIELD-SYMBOL(<database_table_reader>).
          IF <database_table_reader>->content( )->get_delivery_class( )->value = 'C'.
            APPEND VALUE #( tablename   = <database_table_reader>->name
                            language    = sy-langu
                            description = <database_table_reader>->content( )->get_short_description( ) ) TO results.
          ENDIF.
        ENDLOOP.
            APPEND VALUE #( tablename   = 'NA'
                            language    = sy-langu
                            description = 'Use with other scenarios except Business Configuration.'(001) ) TO results.
        io_response->set_data( results ).
        " request count
        IF io_request->is_total_numb_of_rec_requested( ).
          " fill response
          io_response->set_total_number_of_records( lines( results ) ).
        ENDIF.

      CATCH cx_xco_runtime_exception INTO DATA(ex_runtime_exception).
        DATA(text_new) = ex_runtime_exception->get_text( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
