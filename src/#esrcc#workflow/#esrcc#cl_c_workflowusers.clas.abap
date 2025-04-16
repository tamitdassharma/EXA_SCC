CLASS /esrcc/cl_c_workflowusers DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_c_workflowusers IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(cx_query).
            DATA(error) = cx_query->get_longtext(  ).
            "handle exception
        ENDTRY.

**parameters
*            DATA(lt_parameters) = io_request->get_parameters( ).
*            DATA(lv_next_year) =  CONV /dmo/end_date( cl_abap_context_info=>get_system_date( ) + 365 )  .
*            DATA(lv_par_filter) = | BEGIN_DATE >= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_START_DATE' ]-value
*                                                                                              DEFAULT cl_abap_context_info=>get_system_date( ) ) ) }'| &&
*                                  | AND | &&
*                                  | END_DATE <= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_END_DATE' ]-value
*                                                                                            DEFAULT lv_next_year ) ) }'| .
*            IF lv_sql_filter IS INITIAL.
*              lv_sql_filter = lv_par_filter.
*            ELSE.
*              lv_sql_filter = |( { lv_sql_filter } AND { lv_par_filter } )| .
*            ENDIF.
**search
        DATA(lv_search_string) = io_request->get_search_expression( ).
        DATA(lv_search_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

        IF lv_sql_filter IS INITIAL.
          lv_sql_filter = lv_search_sql.
        ELSE.
          lv_sql_filter = |( { lv_sql_filter } AND { lv_search_sql } )|.
        ENDIF.
**request data
        IF io_request->is_data_requested( ) = abap_true.
***paging
          DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                      THEN 0 ELSE lv_page_size ).

**sorting
          DATA(sort_elements) = io_request->get_sort_elements( ).
          DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                     ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` descending`
                                                                                                                                     ELSE ` ascending` ) ) ).
          DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
                                                                           ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
**requested elements
          DATA(lt_req_elements) = io_request->get_requested_elements( ).
**aggregate
          DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).

          IF lt_aggr_element IS NOT INITIAL.
            LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
              DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
              DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
              APPEND lv_aggregation TO lt_req_elements.
            ENDLOOP.
          ENDIF.
          DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).
****grouping
          DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
          DATA(lv_grouping) = concat_lines_of( table = lt_grouped_element sep = `, ` ).


          DATA lt_result TYPE STANDARD TABLE OF /esrcc/c_workflow_users.
          DATA ls_result TYPE /esrcc/c_workflow_users.
          DATA _sysid           TYPE RANGE OF /esrcc/sysid.
          DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
          DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
          DATA _costnumber      TYPE RANGE OF /esrcc/costcenter.
          DATA _application     TYPE RANGE OF /esrcc/application_type_de.
          DATA _approvallevel   TYPE RANGE OF /esrcc/approvallevel.

*   filters
          LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

            CASE <ls_filter>-name.

              WHEN 'SYSID'.
                _sysid = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'LEGALENTITY'.
                _legalentity = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'COSTOBJECT'.
                _costobject = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'COSTCENTER'.
                _costnumber = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'APPLICATION'.
                _application = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'APPROVAL_LEVEL'.
                READ TABLE <ls_filter>-range ASSIGNING FIELD-SYMBOL(<ls_range>) INDEX 1.
                IF sy-subrc = 0.
                  _approvallevel = CORRESPONDING #( <ls_filter>-range ).
                ENDIF.
              WHEN OTHERS.
            ENDCASE.

          ENDLOOP.

          SELECT * FROM /ESRCC/C_WfCust WHERE ( Application IN @_application
                                          AND Approvallevel IN @_approvallevel )
                                          AND ( Sysid IN @_sysid
                                          OR Legalentity IN @_legalentity
                                          OR costobject IN @_costobject
                                          OR Costcenter IN @_costnumber )
                                          INTO TABLE @DATA(lt_wf_steps).
          IF lt_wf_steps IS NOT INITIAL.
            SELECT DISTINCT * FROM /ESRCC/C_WfUsrM FOR ALL ENTRIES IN @lt_wf_steps
                                          WHERE Usergroup = @lt_wf_steps-Usergroup
                                          INTO TABLE @DATA(lt_wf_users).

            IF lt_wf_users IS NOT INITIAL.
              SELECT LastName, FirstName, DefaultEmailAddress FROM I_BusinessUserBasic AS bususr
                       INNER JOIN I_WorkplaceAddress AS address
                         ON bususr~BusinessPartnerUUID = address~BusinessPartnerUUID
                       FOR ALL ENTRIES IN @lt_wf_users
                          WHERE bususr~UserID = @lt_wf_users-Userid INTO TABLE @DATA(lt_wf_email). "#EC CI_NO_TRANSFORM
            ENDIF.

            LOOP AT lt_wf_steps ASSIGNING FIELD-SYMBOL(<ls_wf_step>).
              CLEAR ls_result.
              ls_result-application = <ls_wf_step>-Application.
              ls_result-approval_level = <ls_wf_step>-Approvallevel.
              ls_result-costcenter = <ls_wf_step>-Costcenter.
              ls_result-costobject = <ls_wf_step>-Costobject.
              ls_result-sysid = <ls_wf_step>-sysid.
              ls_result-legalentity = <ls_wf_step>-Legalentity.
              LOOP AT lt_wf_email ASSIGNING FIELD-SYMBOL(<ls_wf_user>).
                IF ls_result-useremail IS INITIAL.
                  ls_result-useremail = <ls_wf_user>-DefaultEmailAddress.
                ELSE.
                  CONCATENATE ls_result-useremail <ls_wf_user>-DefaultEmailAddress INTO ls_result-useremail SEPARATED BY ','.
                ENDIF.
              ENDLOOP.
              APPEND ls_result TO lt_result.
            ENDLOOP.
          ENDIF.

*    ***fill response
          io_response->set_data( lt_result ).
*        ENDIF.
**request count
          IF io_request->is_total_numb_of_rec_requested( ).
**select count
*
**fill response
            io_response->set_total_number_of_records( lines( lt_result ) ).
          ENDIF.
        ENDIF.
      CATCH cx_rap_query_provider INTO DATA(cx_query_provider).
        error = cx_query_provider->get_longtext(  ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
