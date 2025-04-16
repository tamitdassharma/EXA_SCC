CLASS /esrcc/cl_c_bpa_integration DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_C_BPA_INTEGRATION IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range into DATA(cx_query).
            DATA(_error) = cx_query->get_longtext(  ).
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


          TYPES: BEGIN OF ty_result,
                   fplv                        TYPE /esrcc/costdataset_de,
                   ryear                       TYPE /esrcc/ryear,
                   billfrequency               TYPE /esrcc/billfrequency,
                   billingperiod               TYPE /esrcc/billperiod,
                   legalentity                 TYPE /esrcc/legalentity,
                   ccode                       TYPE /esrcc/ccode_de,
                   sysid                       TYPE /esrcc/sysid,
                   costobject                  TYPE /esrcc/costobject_de,
                   costnumber                  TYPE /esrcc/costcenter,
                   serviceproduct              TYPE /esrcc/srvproduct,
                   receivingentity             TYPE /esrcc/receivingntity,
                   approval_level              TYPE /esrcc/approvallevel,
                   costdatasetdescription      TYPE /esrcc/description,
                   billingfrequencydescription TYPE /esrcc/description,
                   billingperioddescription    TYPE /esrcc/description,
                   legalentitydescription      TYPE /esrcc/description,
                   ccodedescription            TYPE /esrcc/description,
                   costobjectdescription       TYPE /esrcc/description,
                   costcenterdescription       TYPE /esrcc/description,
                   Serviceproductdescription   TYPE /esrcc/description,
                   receivingentitydescription  TYPE /esrcc/description,
                   currency                    TYPE waers,
                   totalcost                   TYPE /esrcc/value,
                   excludedcost                TYPE /esrcc/value,
                   includedcost                TYPE /esrcc/value,
                   origtotalcost               TYPE /esrcc/value,
                   passtotalcost               TYPE /esrcc/value,
                   stewardship                 TYPE /esrcc/value,
                   remainingcostbase           TYPE /esrcc/value,
                   srvcostshare                TYPE /esrcc/value,
                   valueaddshare               TYPE /esrcc/value,
                   passthroughshare            TYPE /esrcc/value,
                   valueaddmarkupabs           TYPE /esrcc/value,
                   passthrumarkupabs           TYPE /esrcc/value,
                   totalsrvmarkupabs           TYPE /esrcc/value,
                   totalchargeoutamount        TYPE /esrcc/value,
                   chargeoutforservice         TYPE /esrcc/value,
                   totaludmarkupabs            TYPE /esrcc/value,
                   totalcostbaseabs            TYPE /esrcc/value,
                   valuaddabs                  TYPE /esrcc/value,
                   passthruabs                 TYPE /esrcc/value,
                   amountlc                    TYPE /esrcc/value,
                   amountgc                    TYPE /esrcc/value,
                   Groupcurr                   TYPE /esrcc/groupcurr,
                   Localcurr                   TYPE /esrcc/localcurr,
                 END OF ty_result.

          DATA lt_data TYPE TABLE OF ty_result.
          DATA ls_data TYPE ty_result.
          DATA lt_result TYPE STANDARD TABLE OF /esrcc/c_bpa_integration.
          DATA ls_result TYPE /esrcc/c_bpa_integration.
          DATA _sysid           TYPE RANGE OF /esrcc/sysid.
          DATA _fplv            TYPE RANGE OF /esrcc/costdataset_de.
          DATA _ryear           TYPE /esrcc/ryear.
          DATA _poper           TYPE RANGE OF poper.
          DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
          DATA _receivingentity TYPE RANGE OF /esrcc/legalentity.
          DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
          DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
          DATA _costnumber      TYPE RANGE OF /esrcc/costcenter.
          DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
          DATA _billingfreq     TYPE RANGE OF /esrcc/billfrequency.
          DATA _billingperiod   TYPE RANGE OF /esrcc/billperiod.
          DATA _application     TYPE /esrcc/application_type_de.
          DATA _workflowid      TYPE RANGE OF /esrcc/sww_wiid.


*   filters
          LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

            CASE <ls_filter>-name.

              WHEN 'SYSID'.
                _sysid = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'FPLV'.
                _fplv = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'RYEAR'.
                _ryear = <ls_filter>-range[ 1 ]-low.
              WHEN 'LEGALENTITY'.
                _legalentity = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'CCODE'.
                _ccode = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'COSTOBJECT'.
                _costobject = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'COSTNUMBER'.
                _costnumber = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'BILLFREQUENCY'.
                _billingfreq = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'BILLINGPERIOD'.
                _billingperiod = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'SERVICEPRODUCT'.
                _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'RECEIVINGENTITY'.
                _receivingentity = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'APPLICATION'.
                _application = <ls_filter>-range[ 1 ]-low.
              WHEN 'WORKFLOW_ID'.
                _workflowid = CORRESPONDING #( <ls_filter>-range ).
              WHEN OTHERS.
            ENDCASE.

          ENDLOOP.

          CASE _application.

            WHEN 'CBS'.

              SELECT fplv,
                     ryear,
                     Billingfrequqncy AS Billfrequency,
                     Billingperiod,
                     sysid,
                     Ccode,
                     Legalentity,
                     Costobject,
                     Costcenter AS costnumber,
                     currency,
                     SUM( totalcost ) AS totalcost,
                     SUM( excludedtotalcost ) AS excludedcost,
                     SUM( Includetotalcost ) AS includedcost,
                     SUM( Origtotalcost ) AS Origtotalcost,
                     SUM( Passtotalcost ) AS Passtotalcost,
                     SUM( Remainingcostbase ) AS Remainingcostbase,
                     costdatasetdescription,
                     ccodedescription,
                     legalentitydescription,
                     costobjectdescription,
                     costcenterdescription,
                     billingfrequencydescription,
                     billingperioddescription
                      FROM /esrcc/c_cc_cost_workflow
                        WHERE Workflowid IN @_workflowid
                          AND Currencytype = 'L'
                          GROUP BY
                          fplv,
                          Ryear,
                          Billingfrequqncy,
                          Billingperiod,
                          Sysid,
                          ccode,
                          Legalentity,
                          Costobject,
                          Costcenter,
                          currency,
                          costdatasetdescription,
                          ccodedescription,
                          legalentitydescription,
                          costobjectdescription,
                          costcenterdescription,
                          billingfrequencydescription,
                          billingperioddescription
                          INTO CORRESPONDING FIELDS OF TABLE @lt_data.

            WHEN 'SCM'.

              SELECT fplv,
                      ryear,
                      poper,
                      sysid,
                      Ccode,
                      Legalentity,
                      Costobject,
                      Costcenter AS costnumber,
                      Serviceproduct,
                      currency,
                      SUM( Srvcostshare ) AS srvcostshare,
                      SUM( Valueaddshare ) AS valueaddshare,
                      SUM( Passthroughshare ) AS passthroughshare,
                      costdatasetdescription,
                      ccodedescription,
                      legalentitydescription,
                      costobjectdescription,
                      costcenterdescription,
                      serviceproductdescription
                       FROM /esrcc/i_srv_workflow
                         WHERE Workflowid IN @_workflowid
                           AND Currencytype = 'L'
                           GROUP BY
                           fplv,
                           Ryear,
                           poper,
                           Sysid,
                           ccode,
                           Legalentity,
                           Costobject,
                           Costcenter,
                           serviceproduct,
                           currency,
                           costdatasetdescription,
                           ccodedescription,
                           legalentitydescription,
                           costobjectdescription,
                           costcenterdescription,
                           serviceproductdescription
                           INTO CORRESPONDING FIELDS OF TABLE @lt_data.
            WHEN 'CHR'.

              SELECT fplv,
                   ryear,
                   poper,
                   sysid,
                   Ccode,
                   Legalentity,
                   Costobject,
                   Serviceproduct,
                   Receivingentity,
                   currency,
                   SUM( TotalChargeout ) AS chargeoutforservice,
                   SUM( TotalRecMarkup ) AS totaludmarkupabs,
                   SUM( RecCostShare ) AS totalcostbaseabs,
                   SUM( RecValueadded ) AS valuaddabs,
                   SUM( RecPassthrough ) AS passthruabs,
                   costdatasetdescription,
                   ccodedescription,
                   legalentitydescription,
                   costobjectdescription,
                   serviceproductdescription,
                   receivingentitydescription
                    FROM /esrcc/i_reccost_workflow
                      WHERE Workflowid IN @_workflowid
                        AND Currencytype = 'L'
                        GROUP BY
                        fplv,
                        Ryear,
                        poper,
                        Sysid,
                        ccode,
                        Legalentity,
                        Costobject,
*                          Costcenter,
                        serviceproduct,
                        Receivingentity,
                        currency,
                        costdatasetdescription,
                        ccodedescription,
                        legalentitydescription,
                        costobjectdescription,
*                          costcenterdescription,
                        serviceproductdescription,
                        receivingentitydescription
                        INTO CORRESPONDING FIELDS OF TABLE @lt_data.

            WHEN 'CBL'.
              SELECT fplv,
                     ryear,
                     sysid,
                     Ccode,
                     Legalentity,
                     Costobject,
                     Costcenter AS costnumber,
                     costdatasetdescription,
                     ccodedescription,
                     legalentitydescription,
                     costobjectdescription,
                     costcenterdescription,
                     Localcurr,
                     Groupcurr,
                     SUM( hsl ) AS amountlc,
                     SUM( ksl ) AS amountgc
                      FROM /esrcc/c_opentaskcostbase
                        WHERE Workflowid IN @_workflowid
                          GROUP BY
                          fplv,
                          Ryear,
                          Sysid,
                          ccode,
                          Legalentity,
                          Costobject,
                          Costcenter,
                          costdatasetdescription,
                          ccodedescription,
                          legalentitydescription,
                          costobjectdescription,
                          costcenterdescription,
                          Localcurr,
                          Groupcurr
                          INTO CORRESPONDING FIELDS OF TABLE @lt_data.
            WHEN OTHERS.

          ENDCASE.
          DATA(amount_external) = 1.
          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
            CLEAR ls_result.
            MOVE-CORRESPONDING <ls_data> TO ls_result.
            SELECT SINGLE decimals FROM I_Currency
            WHERE Currency = @<ls_data>-currency
            INTO @DATA(lv_decimal).
            IF sy-subrc = 0 AND lv_decimal <> 2.
              amount_external = 10 ** ( 2 - lv_decimal ).
            ENDIF.
            ls_result-totalcost = |{ ( amount_external * <ls_data>-totalcost ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-includedcost = |{ ( amount_external * <ls_data>-includedcost ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-excludedcost = |{ ( amount_external * <ls_data>-excludedcost ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-origtotalcost = |{ ( amount_external * <ls_data>-origtotalcost ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-passtotalcost = |{ ( amount_external * <ls_data>-passtotalcost ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-remainingcostbase = |{ ( amount_external * <ls_data>-remainingcostbase ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-srvcostshare = |{ ( amount_external * <ls_data>-srvcostshare ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-valueaddshare = |{ ( amount_external * <ls_data>-valueaddshare ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-passthroughshare = |{ ( amount_external * <ls_data>-passthroughshare ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-valueaddmarkupabs = |{ ( amount_external * <ls_data>-valueaddmarkupabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-passthrumarkupabs = |{ ( amount_external * <ls_data>-passthrumarkupabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-totalsrvmarkupabs = |{ ( amount_external * <ls_data>-totalsrvmarkupabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-totalchargeoutamount = |{ ( amount_external * <ls_data>-totalchargeoutamount ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-chargeoutforservice = |{ ( amount_external * <ls_data>-chargeoutforservice ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-totaludmarkupabs = |{ ( amount_external * <ls_data>-totaludmarkupabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-totalcostbaseabs = |{ ( amount_external * <ls_data>-totalcostbaseabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-valuaddabs = |{ ( amount_external * <ls_data>-valuaddabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-passthruabs = |{ ( amount_external * <ls_data>-passthruabs ) CURRENCY = <ls_data>-currency NUMBER = USER }  { <ls_data>-currency }|.
            ls_result-amountlc = |{ ( amount_external * <ls_data>-amountlc ) CURRENCY = <ls_data>-localcurr NUMBER = USER }  { <ls_data>-localcurr }|.
            ls_result-amountgc = |{ ( amount_external * <ls_data>-amountgc ) CURRENCY = <ls_data>-groupcurr NUMBER = USER }  { <ls_data>-groupcurr }|.

            CONCATENATE <ls_data>-costnumber ' (' <ls_data>-costcenterdescription ')'
            INTO ls_result-costcenterdescription.
            CONCATENATE <ls_data>-legalentity ' (' <ls_data>-legalentitydescription ')'
            INTO ls_result-legalentitydescription.
            CONCATENATE <ls_data>-serviceproduct ' (' <ls_data>-Serviceproductdescription ')'
            INTO ls_result-Serviceproductdescription.
            CONCATENATE <ls_data>-receivingentity ' (' <ls_data>-receivingentitydescription ')'
            INTO ls_result-receivingentitydescription.
            CONCATENATE <ls_data>-ccode ' (' <ls_data>-ccodedescription ')'
            INTO ls_result-ccodedescription.
            CASE _application.
              WHEN 'CBS'.
                CONCATENATE <ls_data>-ryear <ls_data>-billingfrequencydescription <ls_data>-billingperioddescription
                INTO ls_result-subject SEPARATED BY '/'.
                CONCATENATE <ls_data>-costdatasetdescription ls_result-subject ls_result-costcenterdescription ls_result-legalentitydescription
                INTO ls_result-subject SEPARATED BY ' ||'.
              WHEN 'SCM'.
                CONCATENATE <ls_data>-ryear <ls_data>-billingfrequencydescription <ls_data>-billingperioddescription
                INTO ls_result-subject SEPARATED BY '/'.
                CONCATENATE <ls_data>-costdatasetdescription ls_result-subject ls_result-serviceproductdescription ls_result-legalentitydescription
                INTO ls_result-subject SEPARATED BY ' ||'.
              WHEN 'CHR'.
                CONCATENATE <ls_data>-ryear <ls_data>-billingfrequencydescription <ls_data>-billingperioddescription
                INTO ls_result-subject SEPARATED BY '/'.
                CONCATENATE <ls_data>-costdatasetdescription ls_result-subject ls_result-costcenterdescription ls_result-legalentitydescription
                ls_result-receivingentitydescription
                INTO ls_result-subject SEPARATED BY ' ||'.
              WHEN 'CBL'.
                ls_result-subject = <ls_data>-ryear.
                CONCATENATE <ls_data>-costdatasetdescription ls_result-subject ls_result-costcenterdescription ls_result-legalentitydescription
                INTO ls_result-subject SEPARATED BY ' ||'.
              WHEN OTHERS.
            ENDCASE.

            APPEND ls_result TO lt_result.
          ENDLOOP.

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
        _error = cx_query_provider->get_longtext(  ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
