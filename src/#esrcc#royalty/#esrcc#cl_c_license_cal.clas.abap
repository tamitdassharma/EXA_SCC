CLASS /esrcc/cl_c_license_cal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /esrcc/cl_c_license_cal IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
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
*        DATA(lv_search_string) = io_request->get_search_expression( ).
*        DATA(lv_search_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

*        IF lv_sql_filter IS INITIAL.
*          lv_sql_filter = lv_search_sql.
*        ELSE.
*          lv_sql_filter = |( { lv_sql_filter } AND { lv_search_sql } )|.
*        ENDIF.
**request data

*        IF io_request->is_data_requested( ).
***paging
        DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
        DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
        DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                    THEN 0 ELSE lv_page_size ).

**sorting
        DATA(sort_elements) = io_request->get_sort_elements( ).
        DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                   ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` DESCENDING`
                                                                                                                                   ELSE ` ASCENDING` ) ) ).
        DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
                                                                         ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
**requested elements
        DATA(lt_req_elements) = io_request->get_requested_elements( ).


****grouping
        DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
        DATA(lv_grouping) = concat_lines_of( table = lt_grouped_element sep = `, ` ).

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

*
***select data
        DATA lt_result        TYPE STANDARD TABLE OF /esrcc/c_licencse_cal.
        DATA lt_db_result     TYPE STANDARD TABLE OF /esrcc/c_licencse_cal.
        DATA lt_fin_result    TYPE STANDARD TABLE OF /esrcc/c_licencse_cal.
        DATA ls_result        TYPE /esrcc/c_licencse_cal.
        DATA _sysid           TYPE RANGE OF /esrcc/sysid.
        DATA _fplv            TYPE RANGE OF /esrcc/royaltybase_version.
        DATA _ryear           TYPE RANGE OF /esrcc/ryear.
        DATA _poper           TYPE RANGE OF poper.
        DATA _refpoper        TYPE RANGE OF poper.
        DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
        DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
        DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
        DATA _costcenter      TYPE RANGE OF /esrcc/costcenter.
        DATA _licenseelegalentity TYPE RANGE OF /esrcc/legalentity.
        DATA _licenseeccode        TYPE RANGE OF /esrcc/ccode_de.
        DATA _licenseecostobject   TYPE RANGE OF /esrcc/costobject_de.
        DATA _licenseecostcenter   TYPE RANGE OF /esrcc/costcenter.
        DATA _license         TYPE RANGE OF /esrcc/licenseid.
        DATA _currencytype    TYPE RANGE OF /esrcc/sendercurr.
        DATA trueupamount     TYPE /esrcc/amount.
        DATA _workflowid      TYPE RANGE OF /esrcc/workflowid.


*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.

            WHEN 'RYEAR'.
              _ryear = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'FPLV'.
              _fplv  = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'POPER'.
              _poper = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSOR_LEGALENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSOR_CCODE'.
              _ccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSOR_COSTOBJECT'.
              _costobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSOR_COSTCENTER'.
              _costcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSE'.
              _license = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSEE_LEGALENTITY'.
              _licenseelegalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSEE_CCODE'.
              _licenseeccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSEE_COSTOBJECT'.
              _licenseecostobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSEE_COSTCENTER'.
              _licenseecostcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LICENSEtyp'.
              _licenseecostcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

        SELECT DISTINCT
           *
          FROM /esrcc/i_read_royalty AS royalcal
*              WHERE royalcal~LicensorCCode IN @_ccode
*                AND royalcal~LicensorLegalEntity IN @_legalentity
*                AND royalcal~LicensorCostObject  IN @_costobject
*                AND royalcal~LicensorCostCenter  IN @_costcenter
*                AND royalcal~License             IN @_license
*                AND royalcal~LicenseeCCode IN @_licenseeccode
*                AND royalcal~LicenseeLegalEntity IN @_licenseelegalentity
*                AND royalcal~LicenseeCostObject  IN @_licenseecostobject
*                AND royalcal~LicenseeCostCenter  IN @_licenseecostcenter
*                AND royalcal~Ryear     IN @_ryear
*                AND royalcal~poper     IN @_poper
*                AND royalcal~fplv      IN @_fplv
            WHERE (lv_sql_filter)
            INTO CORRESPONDING FIELDS OF TABLE @lt_db_result.

        SELECT basevalue~*,
               0 AS chargeoutamount
               FROM /esrcc/i_determine_royalty AS basevalue
*                 WHERE active = @abap_true
*                   AND LicensorCCode IN @_ccode
*                   AND LicensorLegalEntity IN @_legalentity
*                   AND LicensorCostObject  IN @_costobject
*                   AND LicensorCostCenter  IN @_costcenter
*                   AND License             IN @_license
*                   AND LicenseeCCode       IN @_licenseeccode
*                   AND LicenseeLegalEntity IN @_licenseelegalentity
*                   AND LicenseeCostObject  IN @_licenseecostobject
*                   AND LicenseeCostCenter  IN @_licenseecostcenter
*                   AND Ryear            IN @_ryear
*                   AND poper            IN @_poper
*                   AND fplv             IN @_fplv
                 WHERE (lv_sql_filter)
                 ORDER BY
                 licenseesysid,
                 licenseeccode,
                 licenseelegalentity,
                 licenseecostobject,
                 licenseecostcenter,
                 license,
                 licensorsysid,
                 licensorccode,
                 licensorlegalentity,
                 licensorcostobject,
                 licensorcostcenter,
                 ryear,
                 poper,
                 fplv
                 INTO CORRESPONDING FIELDS OF TABLE @lt_result.

        LOOP AT lt_db_result ASSIGNING FIELD-SYMBOL(<db_result>).
          READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<result>)
            WITH KEY licenseesysid  = <db_result>-licenseesysid
                    licenseeccode       = <db_result>-licenseeccode
                    licenseelegalentity = <db_result>-licenseeLegalEntity
                    licenseecostobject  = <db_result>-licenseeCostObject
                    licenseecostcenter  = <db_result>-licenseeCostCenter
                    license             = <db_result>-license
                    licensorsysid       = <db_result>-licensorsysid
                    licensorccode       = <db_result>-licensorccode
                    licensorlegalentity = <db_result>-licensorLegalEntity
                    licensorcostobject  = <db_result>-licensorCostObject
                    licensorcostcenter  = <db_result>-licensorCostCenter
                    ryear               = <db_result>-ryear
                    poper               = <db_result>-poper
                    fplv                = <db_result>-fplv
                    BINARY SEARCH.
          IF sy-subrc = 0.
            DELETE lt_result WHERE licenseesysid       = <db_result>-licenseesysid
                               AND licenseeccode       = <db_result>-licenseeccode
                               AND licenseelegalentity = <db_result>-licenseeLegalEntity
                               AND licenseecostobject  = <db_result>-licenseeCostObject
                               AND licenseecostcenter  = <db_result>-licenseeCostCenter
                               AND license             = <db_result>-license
                               AND licensorsysid       = <db_result>-licensorsysid
                               AND licensorccode       = <db_result>-licensorccode
                               AND licensorlegalentity = <db_result>-licensorLegalEntity
                               AND licensorcostobject  = <db_result>-licensorCostObject
                               AND licensorcostcenter  = <db_result>-licensorCostCenter
                               AND ryear               = <db_result>-ryear
                               AND poper               = <db_result>-poper
                               AND fplv                = <db_result>-fplv.
          ENDIF.
        ENDLOOP.

        SELECT * FROM /esrcc/i_royaltystatus INTO TABLE @DATA(royaltystatus). "#EC CI_NOWHERE

        LOOP AT lt_result ASSIGNING <result> WHERE licensorsysid IS INITIAL
                                                OR licensorccode IS INITIAL
                                                OR licensorlegalentity IS INITIAL
                                                OR licenseecostobject IS INITIAL
                                                OR licenseecostcenter IS INITIAL
                                                OR license IS INITIAL
                                                OR royaltybasekey IS INITIAL
*                                                OR ( uom IS INITIAL AND currency IS INITIAL )
                                                OR royaltycomputationmethod IS INITIAL.

          <result>-status = 'E'.

          READ TABLE royaltystatus ASSIGNING FIELD-SYMBOL(<royaltystatus>)
                                   WITH KEY status = <result>-status.
          IF sy-subrc = 0.
            <result>-statusDescription = <royaltystatus>-text.
          ENDIF.

        ENDLOOP.

        APPEND LINES OF lt_db_result TO lt_result.

        CLEAR lt_fin_result.
        IF sort_elements IS NOT INITIAL.
          SELECT (lv_req_elements)
                 FROM @lt_result AS result
                 WHERE (lv_sql_filter)
                 GROUP BY (lv_grouping)
                 ORDER BY (lv_sort_string)
                 INTO CORRESPONDING FIELDS OF TABLE @lt_fin_result
                 OFFSET @LV_offset UP TO @LV_max_rows ROWS.
        ELSE.
          SELECT (lv_req_elements)
                 FROM @lt_result AS result
                 GROUP BY (lv_grouping)
                 INTO CORRESPONDING FIELDS OF TABLE @lt_fin_result.

        ENDIF.

***fill response
        io_response->set_data( lt_fin_result ).
*
**request count
        IF io_request->is_total_numb_of_rec_requested( ).
**select count
**fill response
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.

      CATCH cx_rap_query_provider.

    ENDTRY.
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
