CLASS /esrcc/cl_c_trueup_opentask DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /esrcc/cl_c_trueup_opentask IMPLEMENTATION.


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
        DATA(lv_search_string) = io_request->get_search_expression( ).
        DATA(lv_search_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

        IF lv_sql_filter IS INITIAL.
          lv_sql_filter = lv_search_sql.
        ELSE.
          lv_sql_filter = |( { lv_sql_filter } AND { lv_search_sql } )|.
        ENDIF.
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
        DATA lt_result        TYPE STANDARD TABLE OF /esrcc/c_trueup_opentask.
        DATA lt_fin_result    TYPE STANDARD TABLE OF /esrcc/c_trueup_opentask.
        DATA ls_result        TYPE /esrcc/c_trueup_opentask.
        DATA _sysid           TYPE RANGE OF /esrcc/sysid.
        DATA _fplv            TYPE RANGE OF /esrcc/costdataset_de.
        DATA _ryear           TYPE RANGE OF /esrcc/ryear.
        DATA _poper           TYPE RANGE OF poper.
        DATA _refpoper        TYPE RANGE OF poper.
        DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
        DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
        DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
        DATA _costcenter      TYPE RANGE OF /esrcc/costcenter.
        DATA _receivingentity TYPE RANGE OF /esrcc/legalentity.
        DATA _recccode        TYPE RANGE OF /esrcc/ccode_de.
        DATA _reccostobject   TYPE RANGE OF /esrcc/costobject_de.
        DATA _reccostcenter   TYPE RANGE OF /esrcc/costcenter.
        DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
        DATA _currencytype    TYPE RANGE OF /esrcc/sendercurr.
        DATA trueupamount     TYPE /esrcc/amount.
        DATA _workflowid      TYPE RANGE OF /esrcc/workflowid.


*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.

            WHEN 'RYEAR'.
              _ryear = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'REFPOPER'.
              _refpoper = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LEGALENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CCODE'.
              _ccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTOBJECT'.
              _costobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTCENTER'.
              _costcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'SERVICEPRODUCT'.
              _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVINGENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVERCOMPANYCODE'.
              _recccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVERCOSTOBJECT'.
              _reccostobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVERCOSTCENTER'.
              _reccostcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CURRENCYTYPE'.
              _currencytype = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'WORKFLOWID'.
              _workflowid = CORRESPONDING #( <ls_filter>-range ).
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

*check if trigger is via open task My Inbox
        IF _workflowid IS NOT INITIAL.
          SELECT DISTINCT ryear,
                          recalrefpoper,
                          sysid,
                          legalentity,
                          ccode,
                          costobject,
                          costcenter
                   FROM /esrcc/cb_stw AS cbstw
                   INNER JOIN /esrcc/rec_chg AS recchg
                   ON cbstw~cc_uuid = recchg~cc_uuid
                   WHERE recchg~workflowid IN @_workflowid
                   INTO TABLE @DATA(cbstw).

          LOOP AT cbstw ASSIGNING FIELD-SYMBOL(<cbstw>).
            APPEND VALUE #( sign = 'I' Option = 'EQ' Low = <cbstw>-legalentity high = '' )  TO _legalentity.
            APPEND VALUE #( sign = 'I' Option = 'EQ' Low = <cbstw>-ccode high = '' )  TO _ccode.
            APPEND VALUE #( sign = 'I' Option = 'EQ' Low = <cbstw>-costobject high = '' )  TO _costobject.
            APPEND VALUE #( sign = 'I' Option = 'EQ' Low = <cbstw>-costcenter high = '' )  TO _costcenter.
            APPEND VALUE #( sign = 'I' Option = 'EQ' Low = 'L' high = '' )  TO _currencytype.

           APPEND VALUE #( sign = 'I' Option = 'EQ' Low = <cbstw>-recalrefpoper high = '' )  TO _refpoper.
           APPEND VALUE #( sign = 'I' Option = 'EQ' Low = <cbstw>-ryear high = '' )  TO _ryear.
           ENDLOOP.
        ENDIF.

**Derive poper from reference poper
        DATA(poper) = 1.
        DATA(refpoper) = _refpoper[ 1 ]-low.
        WHILE ( poper <= refpoper ).
          APPEND VALUE #( sign = 'I' option = 'EQ' low = poper high = '' ) TO _poper.
          poper = poper + 1.
        ENDWHILE.

*   Get the recalculated chargeouts
        SELECT * FROM /esrcc/i_trup_analysis
           WHERE RefPoper       IN @_refpoper
            AND  ryear          IN @_ryear
            AND  Legalentity    IN @_legalentity
            AND  ccode          IN @_ccode
            AND  Costobject     IN @_costobject
            AND  Costcenter     IN @_costcenter
            AND  Serviceproduct IN @_serviceproduct
            AND  ProcessType     = @/esrcc/if_calculate_chargeout=>recalprocesstype
            AND  Currencytype   IN @_currencytype
            ORDER BY poper
            INTO TABLE @DATA(lt_recalculated).

*   Get the standard chargeouts
        SELECT * FROM /esrcc/i_trup_analysis
           WHERE poper          <= @refpoper
            AND  ryear          IN @_ryear
            AND  Legalentity    IN @_legalentity
            AND  ccode          IN @_ccode
            AND  Costobject     IN @_costobject
            AND  Costcenter     IN @_costcenter
            AND  Serviceproduct IN @_serviceproduct
            AND  ProcessType     = @/esrcc/if_calculate_chargeout=>standardprocesstype
            AND  Currencytype   IN @_currencytype
            INTO TABLE @DATA(lt_standard).

*   Get the true up amounts
        SELECT * FROM /esrcc/trueup
           WHERE recalrefpoper  < @refpoper
            AND  ryear          IN @_ryear
            AND  Legalentity    IN @_legalentity
            AND  ccode          IN @_ccode
            AND  Costobject     IN @_costobject
            AND  Costcenter     IN @_costcenter
            AND  Serviceproduct IN @_serviceproduct
            INTO TABLE @DATA(lt_trueups).

*     Get trueuptypes
        SELECT * FROM /esrcc/i_trueuptype INTO TABLE @DATA(trueuptypes).  "#EC CI_NOWHERE

        LOOP AT lt_recalculated ASSIGNING FIELD-SYMBOL(<recalculated>).
          READ TABLE lt_standard ASSIGNING FIELD-SYMBOL(<standard>)
                                   WITH KEY ryear = <recalculated>-ryear
                                            poper = <recalculated>-poper
                                            sysid       = <recalculated>-sysid
                                            Legalentity = <recalculated>-Legalentity
                                            ccode       = <recalculated>-ccode
                                            costobject  = <recalculated>-costobject
                                            costcenter  = <recalculated>-Costcenter
                                            ServiceProduct = <recalculated>-ServiceProduct
                                            ReceiverSysId = <recalculated>-ReceiverSysId
                                            ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                            Receivingentity = <recalculated>-Receivingentity
                                            ReceiverCostObject = <recalculated>-ReceiverCostObject
                                            ReceiverCostCenter = <recalculated>-ReceiverCostCenter.
          IF sy-subrc = 0.
            CLEAR trueupamount.
            LOOP AT lt_trueups INTO DATA(trueup)
                                 WHERE ryear             = <recalculated>-ryear
                                   AND poper             = <recalculated>-poper
                                   AND sysid             = <recalculated>-sysid
                                   AND Legalentity       = <recalculated>-Legalentity
                                   AND ccode             = <recalculated>-ccode
                                   AND costobject        = <recalculated>-costobject
                                   AND costcenter        = <recalculated>-Costcenter
                                   AND ServiceProduct    = <recalculated>-ServiceProduct
                                   AND ReceiverSysId     = <recalculated>-ReceiverSysId
                                   AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                   AND Receivingentity = <recalculated>-Receivingentity
                                   AND ReceiverCostObject = <recalculated>-ReceiverCostObject
                                   AND ReceiverCostCenter = <recalculated>-ReceiverCostCenter.
              IF _currencytype[ 1 ]-low = 'L'.
                trueupamount = trueup-amount_l + trueupamount.
              ELSEIF _currencytype[ 1 ]-low = 'G'.
                trueupamount = trueup-amount_g + trueupamount.
              ELSEIF _currencytype[ 1 ]-low = 'I'.
                /esrcc/cl_utility_core=>currency_conversion(
                  EXPORTING
                    amount          = trueup-amount_l
                    source_curr     = trueup-localcurr
                    target_curr     = <recalculated>-Currency
                    validon         = <recalculated>-Exchdate
                  IMPORTING
                    convertedamount = DATA(amount)
                ).
                trueupamount = amount + trueupamount.
              ENDIF.
            ENDLOOP.

            CLEAR ls_result.
            MOVE-CORRESPONDING <recalculated> TO ls_result.
            ls_result-StdTotalChargeoutAmount   = <standard>-TotalChargeoutAmount + trueupamount.
            ls_result-StdTotalMarkup            = <standard>-TotalMarkup.
            ls_result-StdTotalCostbase          = <standard>-TotalCostbase.
            ls_result-RecalTotalChargeoutAmount = <recalculated>-TotalChargeoutAmount.
            ls_result-RecalTotalMarkup          = <recalculated>-TotalMarkup.
            ls_result-RecalTotalCostbase        = <recalculated>-TotalCostbase.
            ls_result-DelTotalChargeoutAmount   = ls_result-RecalTotalChargeoutAmount - ls_result-StdTotalChargeoutAmount.
            ls_result-DelTotalMarkup            = ls_result-RecalTotalMarkup - ls_result-StdTotalMarkup.
            ls_result-DelTotalCostbase          = ls_result-RecalTotalCostbase - ls_result-StdTotalCostbase.
            IF ls_result-DelTotalChargeoutAmount > 0.
              ls_result-Trueuptype = 'D'.
            ELSEIF ls_result-DelTotalChargeoutAmount < 0.
              ls_result-Trueuptype = 'C'.
            ELSE.
              ls_result-Trueuptype = 'N'.
            ENDIF.
            READ TABLE trueuptypes ASSIGNING FIELD-SYMBOL(<trueuptype>) WITH KEY Trueuptype = ls_result-Trueuptype.
            IF sy-subrc = 0.
              ls_result-trueuptypedescription = <trueuptype>-text.
            ENDIF.
            APPEND ls_result TO lt_result.
          ENDIF.

        ENDLOOP.
        CLEAR lt_fin_result.
        IF sort_elements IS NOT INITIAL.
          SELECT (lv_req_elements)
                 FROM @lt_result AS result
                 GROUP BY (lv_grouping)
                 ORDER BY (lv_sort_string)
                 INTO CORRESPONDING FIELDS OF TABLE @lt_fin_result.
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
          io_response->set_total_number_of_records( lines( lt_fin_result ) ).
        ENDIF.

      CATCH cx_rap_query_provider.

    ENDTRY.
*    ENDIF.
  ENDMETHOD.

ENDCLASS.
