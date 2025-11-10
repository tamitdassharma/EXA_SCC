CLASS /esrcc/cl_c_executioncockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /esrcc/cl_c_executioncockpit IMPLEMENTATION.


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
*
***select data
        TYPES: BEGIN OF ty_service_share,
                 stewardship        TYPE /esrcc/stewardship,
                 legalentity        TYPE /esrcc/legalentity,
                 sysid              TYPE /esrcc/sysid,
                 ccode              TYPE /esrcc/ccode_de,
                 costobject         TYPE /esrcc/costobject_de,
                 costcenter         TYPE /esrcc/costcenter,
                 chain_id           TYPE /esrcc/chain_id,
                 chain_sequence     TYPE /esrcc/chain_sequence,
                 serviceproduct     TYPE /esrcc/srvproduct,
                 costshare          TYPE /esrcc/costshare,
                 sysiddescription   TYPE /esrcc/description,
                 legalentitydesc    TYPE /esrcc/description,
                 ccodedesc          TYPE /esrcc/description,
                 costobjectdesc     TYPE /esrcc/description,
                 costcenterdesc     TYPE /esrcc/description,
                 serviceproductdesc TYPE /esrcc/description,
               END OF ty_service_share.

        DATA lt_result        TYPE STANDARD TABLE OF /esrcc/c_execution_cockpit.
        DATA ls_result        TYPE /esrcc/c_execution_cockpit.
        DATA lt_service_share TYPE STANDARD TABLE OF ty_service_share.
        DATA lt_li            TYPE TABLE OF /esrcc/cb_li.
        DATA cbli             TYPE TABLE OF /esrcc/cb_li.
        DATA _sysid           TYPE RANGE OF /esrcc/sysid.
        DATA _fplv            TYPE RANGE OF /esrcc/costdataset_de.
        DATA _ryear           TYPE RANGE OF /esrcc/ryear.
        DATA _poper           TYPE RANGE OF poper.
        DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
        DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
        DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
        DATA _costcenter      TYPE RANGE OF /esrcc/costcenter.
        DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
        DATA _billingfreq     TYPE /esrcc/billfrequency.
        DATA _billingperiod   TYPE /esrcc/billperiod.
        DATA _validon         TYPE /esrcc/validfrom.
        DATA _validfrom       TYPE /esrcc/validfrom.
        DATA _validto         TYPE /esrcc/validto.
        DATA _action          TYPE /esrcc/actions.
        DATA _oecd            TYPE RANGE OF /esrcc/oecdtpg_de.
        DATA fplv             TYPE /esrcc/costdataset_de.
        DATA _chainid         TYPE RANGE OF /esrcc/chain_id.
        DATA _tpprofile       TYPE RANGE OF /esrcc/tpprofile.
        DATA hierarchylevel   TYPE /esrcc/hierarchylevel.
        DATA trueuperformed   TYPE abap_boolean.
        DATA incompletetrueup TYPE abap_boolean.

*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.

            WHEN 'SYSID'.
              _sysid = CORRESPONDING #( <ls_filter>-range ).
*            WHEN 'FPLV'.
*              _fplv = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RYEAR'.
              _ryear = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'POPER'.
              _poper = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LEGALENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CCODE'.
              _ccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTOBJECT'.
              _costobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTCENTER'.
              _costcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'BILLINGFREQ'.
              _billingfreq = <ls_filter>-range[ 1 ]-low.
            WHEN 'BILLINGPERIOD'.
              _billingperiod = <ls_filter>-range[ 1 ]-low.
            WHEN 'SERVICEPRODUCT'.
              _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'ACTION'.
              _action = <ls_filter>-range[ 1 ]-low.
            WHEN 'OECD'.
              _oecd = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CHAIN_ID'.
              _chainid = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'TPPROFILE'.
              _tpprofile = CORRESPONDING #( <ls_filter>-range ).
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

* get master data
        DATA(lv_year) = _ryear[ 1 ]-low.
        DATA(lv_poper) = _poper[ 1 ]-low.

        CONCATENATE lv_year lv_poper+1(2) '01' INTO _validon.

*********************************************************************************************************
*        Create Data Tree
*********************************************************************************************************
        hierarchylevel = 0.

*        Read legal entity & Company Code from stewardship customizing as root node
        SELECT DISTINCT
               srv~legalentity,
               srv~sysid,
               srv~companycode AS ccode,
               srv~chain_id,
               srv~chain_sequence,
               srv~LegalEntityDescription AS legalentitydescription,
               srv~CompanyCodeDescription AS ccodedescription,
               @fplv AS fplv,
               le~country AS legalcountry,
               @hierarchylevel AS hierarchylevel,
               @lv_year AS ryear,
               @lv_poper AS poper,
               concat( srv~legalentity, companycode ) AS nodeid,
               @/esrcc/if_calculate_chargeout=>stdchargeout_finalized AS StdChargeout_Status,
               @/esrcc/if_calculate_chargeout=>recalculation_finalized AS Recalculation_Status,
               @/esrcc/if_calculate_chargeout=>chargeout_finalized AS chargeout_status,
               @abap_false AS selectionallowed
        FROM  /esrcc/i_stw_serviceproduct AS srv
               INNER JOIN /esrcc/le AS le
               ON le~legalentity = srv~legalentity
               INNER JOIN /esrcc/le_ccode AS leccode
               ON leccode~active = @abap_true
               AND leccode~legalentity = srv~legalentity
               AND leccode~ccode = srv~CompanyCode
               INNER JOIN /esrcc/srvpro AS srvpro
               ON srvpro~Serviceproduct = srv~Serviceproduct
       WHERE srv~legalentity IN @_legalentity
         AND srv~sysid IN @_sysid
         AND srv~CompanyCode IN @_ccode
         AND srv~costobject IN @_costobject
         AND srv~costcenter IN @_costcenter
         AND srv~serviceproduct IN @_serviceproduct
         AND srv~validfrom <= @_validon
         AND srv~validto >= @_validon
         AND srvpro~OecdTpg IN @_oecd
         AND srv~chain_id IN @_chainid
         AND le~tpprofile IN @_tpprofile
         APPENDING CORRESPONDING FIELDS OF TABLE @lt_result.


        hierarchylevel = 1.
*        Read legal entity & Company Code, Cost Object & Cost Center from stewardship customizing as child node
        SELECT DISTINCT
               srv~legalentity,
               srv~sysid,
               srv~companycode AS ccode,
               srv~costobject,
               srv~costcenter,
               srv~chain_id,
               srv~chain_sequence,
               srv~LegalEntityDescription AS legalentitydescription,
               srv~CompanyCodeDescription AS ccodedescription,
               srv~CostObjectDescription AS costobjectdescription,
               srv~CostCenterDescription AS costcenterdescription,
               @fplv AS fplv,
               le~country AS legalcountry,
               @hierarchylevel AS hierarchylevel,
               @lv_year AS ryear,
               @lv_poper AS poper,
               concat( srv~legalentity, companycode ) AS parentnodeid,
               concat( concat( concat( srv~legalentity, companycode ), srv~costobject ), srv~costcenter ) AS nodeid,
               procctrl~status AS StdChargeout_Status,
               CASE WHEN procctrltru~log_header_uuid IS NOT INITIAL THEN
               procctrltru~log_header_uuid
               ELSE
               procctrl~log_header_uuid
               END AS logid,
               CASE WHEN procctrltru~log_header_uuid IS NOT INITIAL THEN
               @/esrcc/if_calculate_chargeout=>trueuprecal
               ELSE
               @/esrcc/if_calculate_chargeout=>stdchargeout
               END AS logapp,
               procctrltru~status AS Recalculation_Status,
*               procctrlchr~status AS chargeout_status,
               @abap_false AS selectionallowed,
               procctrl~fplv AS stdchargeoutfplv,
               procctrltru~fplv AS Recalculationfplv
        FROM  /esrcc/i_stw_serviceproduct AS srv
            INNER JOIN /esrcc/le AS le
            ON le~legalentity = srv~legalentity

            INNER JOIN /esrcc/le_ccode AS leccode
            ON leccode~active = @abap_true
            AND leccode~legalentity = srv~legalentity
            AND leccode~ccode = srv~CompanyCode

            INNER JOIN /esrcc/srvpro AS srvpro
            ON srvpro~Serviceproduct = srv~Serviceproduct

            LEFT OUTER JOIN /esrcc/procctrl AS procctrl
            ON  procctrl~sysid       = srv~sysid
            AND procctrl~ryear       = @lv_year
*            AND procctrl~fplv        = @fplv
            AND procctrl~legalentity = srv~legalentity
            AND procctrl~ccode       = srv~CompanyCode
            AND procctrl~costobject  = srv~costobject
            AND procctrl~costcenter  = srv~costcenter
            AND procctrl~poper       = @lv_poper
            AND procctrl~process    = @/esrcc/if_calculate_chargeout=>stdchargeout

            LEFT OUTER JOIN /esrcc/procctrl AS procctrltru
            ON  procctrltru~sysid       = srv~sysid
            AND procctrltru~ryear       = @lv_year
*            AND procctrlscm~fplv        = @fplv
            AND procctrltru~legalentity = srv~legalentity
            AND procctrltru~ccode       = srv~CompanyCode
            AND procctrltru~costobject  = srv~costobject
            AND procctrltru~costcenter  = srv~costcenter
            AND procctrltru~poper       = @lv_poper
            AND procctrltru~process    = @/esrcc/if_calculate_chargeout=>trueuprecal

*            LEFT OUTER JOIN /esrcc/procctrl AS procctrlchr
*            ON  procctrlchr~sysid       = srv~sysid
*            AND procctrlchr~ryear       = @lv_year
**            AND procctrlscm~fplv        = @fplv
*            AND procctrlchr~legalentity = srv~legalentity
*            AND procctrlchr~ccode       = srv~CompanyCode
*            AND procctrlchr~costobject  = srv~costobject
*            AND procctrlchr~costcenter  = srv~costcenter
*            AND procctrlchr~poper       = @lv_poper
*            AND procctrlchr~process    = @/esrcc/if_calculate_chargeout=>chargeout

       WHERE srv~legalentity IN @_legalentity
         AND srv~sysid IN @_sysid
         AND srv~CompanyCode IN @_ccode
         AND srv~costobject IN @_costobject
         AND srv~costcenter IN @_costcenter
         AND srv~serviceproduct IN @_serviceproduct
         AND srv~validfrom  <= @_validon
         AND srv~validto    >= @_validon
         AND srvpro~OecdTpg IN @_oecd
         AND srv~chain_id   IN @_chainid
         AND le~tpprofile   IN @_tpprofile
         APPENDING CORRESPONDING FIELDS OF TABLE @lt_result.

        hierarchylevel = 2.
*        Read legal entity & Company Code, Cost Object & Cost Center from stewardship customizing as child node
        SELECT DISTINCT
               srv~legalentity,
               srv~sysid,
               srv~companycode AS ccode,
               srv~costobject,
               srv~costcenter,
               srv~serviceproduct,
               srv~chain_id,
               srv~chain_sequence,
               srv~LegalEntityDescription AS legalentitydescription,
               srv~CompanyCodeDescription AS ccodedescription,
               srv~CostObjectDescription AS costobjectdescription,
               srv~CostCenterDescription AS costcenterdescription,
               srvprodt~description AS serviceproductdescr,
               @fplv AS fplv,
               le~country AS legalcountry,
               @hierarchylevel AS hierarchylevel,
               @lv_year AS ryear,
               @lv_poper AS poper,
               concat( concat( concat( srv~legalentity, companycode ), srv~costobject ), srv~costcenter ) AS parentnodeid,
               concat( concat( concat( concat( srv~legalentity, companycode ), srv~costobject ), srv~costcenter ), srv~serviceproduct ) AS nodeid,
               @abap_false AS selectionallowed
        FROM  /esrcc/i_stw_serviceproduct AS srv
            INNER JOIN /esrcc/le AS le
            ON le~legalentity = srv~legalentity
            INNER JOIN /esrcc/le_ccode AS leccode
            ON leccode~active = @abap_true
            AND leccode~legalentity = srv~legalentity
            AND leccode~ccode = srv~CompanyCode
            INNER JOIN /esrcc/srvpro AS srvpro
            ON srvpro~Serviceproduct = srv~Serviceproduct

            LEFT OUTER JOIN /esrcc/srvprot AS srvprodt
             ON srv~serviceproduct = srvprodt~serviceproduct
            AND srvprodt~spras = @sy-langu
       WHERE srv~legalentity IN @_legalentity
         AND srv~sysid IN @_sysid
         AND srv~CompanyCode IN @_ccode
         AND srv~costobject IN @_costobject
         AND srv~costcenter IN @_costcenter
         AND srv~serviceproduct IN @_serviceproduct
         AND srv~validfrom <= @_validon
         AND srv~validto >= @_validon
         AND srvpro~OecdTpg IN @_oecd
         AND srv~chain_id IN @_chainid
         AND le~tpprofile        IN @_tpprofile
         APPENDING CORRESPONDING FIELDS OF TABLE @lt_result.

*   get the count of total objects per legal entity for status display
        SELECT DISTINCT
               legalentity,
               sysid,
               ccode,
               CAST( COUNT( costcenter ) AS CHAR ) AS totalcostcenter
            FROM  @lt_result AS result
       WHERE ServiceProduct IS INITIAL
        AND  Costcenter IS NOT INITIAL
        AND  Costobject IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode
         ORDER BY sysid,
                  ccode,
                  legalentity
         INTO TABLE @DATA(lt_totalcostcenters).

*get the number of costobjects finalized per legal entity
        SELECT DISTINCT
               legalentity,
               sysid,
               ccode,
               CAST( COUNT( costcenter ) AS CHAR ) AS finalcostcenter
            FROM  @lt_result AS result
       WHERE StdChargeout_Status = @/esrcc/if_calculate_chargeout=>stdchargeout_finalized
        AND  ServiceProduct IS INITIAL
        AND  Costcenter IS NOT INITIAL
        AND  Costobject IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode
         ORDER BY sysid,
                  ccode,
                  legalentity
         INTO TABLE @DATA(lt_finalcostcenters).


*get the number of costobjects finalized per legal entity for trueups
        SELECT DISTINCT
               legalentity,
               sysid,
               ccode,
               CAST( COUNT( costcenter ) AS CHAR ) AS finalcostcenter
            FROM  @lt_result AS result
       WHERE Recalculation_Status = @/esrcc/if_calculate_chargeout=>recalculation_finalized
        AND  ServiceProduct IS INITIAL
        AND  Costcenter IS NOT INITIAL
        AND  Costobject IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode
         ORDER BY sysid,
                  ccode,
                  legalentity
         INTO TABLE @DATA(lt_finalcostcentersscm).

**get the number of costobjects finalized per legal entity for writebacks
*        SELECT DISTINCT
*               legalentity,
*               sysid,
*               ccode,
*               CAST( COUNT( costcenter ) AS CHAR ) AS finalcostcenter
*            FROM  @lt_result AS result
*       WHERE Chargeout_status = @/esrcc/if_calculate_chargeout=>chargeout_finalized
*        AND  ServiceProduct IS INITIAL
*        AND  Costcenter IS NOT INITIAL
*        AND  Costobject IS NOT INITIAL
*         GROUP BY legalentity,
*                  sysid,
*                  ccode
*         ORDER BY sysid,
*                  ccode,
*                  legalentity
*         INTO TABLE @DATA(lt_finalcostcenterschr).

*********************************************************************************************************
*        End Data Tree
*********************************************************************************************************

* Determine Status-----------------------------------------------------------
        SELECT DISTINCT
                proc~sysid,
                ryear,
                poper,
                fplv,
                proc~legalentity,
                proc~ccode,
                proc~costobject,
                proc~costcenter,
                process,
                status,
                log_header_uuid,
                errorflag
                FROM /esrcc/procctrl AS proc
                 WHERE
                  ryear IN @_ryear
                  AND poper IN @_poper
                  AND legalentity IN @_legalentity
                  AND ccode IN @_ccode
                  AND costobject IN @_costobject
                  AND costcenter IN @_costcenter
                  AND process = @/esrcc/if_calculate_chargeout=>stdchargeout
                  ORDER BY proc~sysid, ryear, poper, proc~legalentity,
                           proc~ccode, proc~costobject, proc~costcenter,
                           process
                 INTO TABLE @DATA(lt_procctrl).

        SELECT DISTINCT
               proc~sysid,
               ryear,
               poper,
               fplv,
               proc~legalentity,
               proc~ccode,
               proc~costobject,
               proc~costcenter,
               process,
               status,
               log_header_uuid,
               errorflag
               FROM /esrcc/procctrl AS proc
                WHERE
                 ryear IN @_ryear
                 AND legalentity IN @_legalentity
                 AND ccode IN @_ccode
                 AND costobject IN @_costobject
                 AND costcenter IN @_costcenter
                 AND process = @/esrcc/if_calculate_chargeout=>trueuprecal
                 ORDER BY proc~sysid, ryear, poper, proc~legalentity,
                          proc~ccode, proc~costobject, proc~costcenter,
                          process
                APPENDING TABLE @lt_procctrl.

        SORT lt_procctrl BY sysid ryear poper legalentity ccode costobject costcenter process.


*Read line items for cost base status
        SELECT DISTINCT fplv,
              ryear,
              cbli~sysid,
              cbli~legalentity,
              cbli~ccode,
              cbli~costobject,
              cbli~costcenter,
              status,
              SUM( hsl ) AS totalcost ,
              localcurr
              FROM /esrcc/cb_li AS cbli
              WHERE ryear IN @_ryear
                AND fplv  IN @_fplv
                AND poper IN @_poper
                AND ( status = @/esrcc/if_calculate_chargeout=>draft OR
                      status = @/esrcc/if_calculate_chargeout=>approved OR
                      status = @/esrcc/if_calculate_chargeout=>approval_pending
                       )
              GROUP BY
              fplv,
              ryear,
              cbli~sysid,
              cbli~legalentity,
              cbli~ccode,
              cbli~costobject,
              cbli~costcenter,
              status,
              localcurr
              ORDER BY cbli~sysid,
                       cbli~ryear,
                       cbli~legalentity,
                       cbli~ccode,
                       cbli~costobject,
                       cbli~costcenter,
                       status
              INTO CORRESPONDING FIELDS OF TABLE @lt_li.

*Get status for business configuration
        SELECT st~application, st~status, st~color, description
            FROM /esrcc/exec_st AS st
            INNER JOIN /esrcc/execst_t AS tx
            ON st~application = tx~application
            AND st~status = tx~status
            AND tx~spras = @sy-langu
           INTO TABLE @DATA(lt_processstatus).

*  check if workflow is on for any process
        /esrcc/cl_utility_core=>check_workflow_active(
          IMPORTING
            wf_flag     = DATA(wf_flag)
        ).

*Mapping Status to outupt

        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>) WHERE Costobject IS NOT INITIAL
                                                                AND Costcenter IS NOT INITIAL
                                                                AND ServiceProduct IS INITIAL.


*  Costbase status----------------------------------------------------
          IF <ls_result>-Costcenter IS NOT INITIAL AND <ls_result>-serviceproduct IS INITIAL.
            IF <ls_result>-StdChargeout_Status IS INITIAL.
              <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>lineitemsnot_available.   "Line Items not Available

              READ TABLE lt_li ASSIGNING FIELD-SYMBOL(<ls_li>) WITH KEY sysid       = <ls_result>-sysid
                                                                        ryear       = <ls_result>-ryear
                                                                        legalentity = <ls_result>-legalentity
                                                                         ccode      = <ls_result>-ccode
                                                                         costobject = <ls_result>-costobject
                                                                         costcenter = <ls_result>-costcenter
                                                                         status     = /esrcc/if_calculate_chargeout=>draft
                                                                         BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>lineitems_drafft.   "Line Items In Draft
              ELSE.
                READ TABLE lt_li ASSIGNING <ls_li> WITH KEY  sysid       = <ls_result>-sysid
                                                             ryear       = <ls_result>-ryear
                                                             legalentity = <ls_result>-legalentity
                                                             ccode       = <ls_result>-ccode
                                                             costobject  = <ls_result>-costobject
                                                             costcenter  = <ls_result>-costcenter
                                                             status     = /esrcc/if_calculate_chargeout=>approval_pending
                                                             BINARY SEARCH.
                IF sy-subrc = 0.
                  <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>lineitems_inapproval.   "Line Items In Approval Pending
                ELSE.
                  READ TABLE lt_li TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                   ryear       = <ls_result>-ryear
*                                                                   fplv        = <ls_result>-fplv
                                                                   legalentity = <ls_result>-legalentity
                                                                   ccode       = <ls_result>-ccode
                                                                   costobject  = <ls_result>-costobject
                                                                   costcenter  = <ls_result>-costcenter
                                                                  BINARY SEARCH.

                  IF sy-subrc = 0.
                    <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_allowed.   "Calculate Stewardship
                  ENDIF.
                ENDIF.

              ENDIF.
            ENDIF.

            IF <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_failed.   "Costbase calculation failed.
              MESSAGE e026(/esrcc/execcockpit) INTO <ls_result>-messagestdchargeout.
              <ls_result>-messagetypestdchargeout = 'I'.

            ENDIF.

*Derive the selection allowed flag

*Check if already True-ups is performed for future period
            CLEAR: trueuperformed.
            LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<ls_procctrl>)
                                   WHERE     sysid         = <ls_result>-sysid
                                     AND     ryear         = <ls_result>-ryear
                                     AND     poper         > <ls_result>-poper
                                     AND     legalentity   = <ls_result>-legalentity
                                     AND     ccode         = <ls_result>-ccode
                                     AND     costobject    = <ls_result>-costobject
                                     AND     costcenter    = <ls_result>-costcenter
                                     AND     process       = /esrcc/if_calculate_chargeout=>trueuprecal
                                     AND     ( status      = /esrcc/if_calculate_chargeout=>recalculation_finalized
                                      OR       status      = /esrcc/if_calculate_chargeout=>recalculation_fin_inproces
                                      OR       status      = /esrcc/if_calculate_chargeout=>recalculation_approved
                                      OR       status      = /esrcc/if_calculate_chargeout=>recalculation_inprocess
                                      OR       status      = /esrcc/if_calculate_chargeout=>recalculation_reopen_inprocess
                                      OR       status      = /esrcc/if_calculate_chargeout=>recalculation_rejected
                                      OR       status      = /esrcc/if_calculate_chargeout=>recalculation_pending ).

*              IF sy-subrc = 0.
              trueuperformed = abap_true.
              MESSAGE e032(/esrcc/execcockpit) WITH <ls_procctrl>-poper INTO <ls_result>-messagestdchargeout.
              <ls_result>-messagetypestdchargeout = 'I'.
              DATA(trueupeperiod) = <ls_procctrl>-poper.
              EXIT.
*              ENDIF.
            ENDLOOP.

*Check if already True-ups is performed in past but not finalized
            CLEAR: incompletetrueup.
            LOOP AT lt_procctrl ASSIGNING <ls_procctrl>
                                   WHERE     sysid         = <ls_result>-sysid
                                     AND     ryear         = <ls_result>-ryear
                                     AND     poper         < <ls_result>-poper
                                     AND     legalentity   = <ls_result>-legalentity
                                     AND     ccode         = <ls_result>-ccode
                                     AND     costobject    = <ls_result>-costobject
                                     AND     costcenter    = <ls_result>-costcenter
                                     AND     process       = /esrcc/if_calculate_chargeout=>trueuprecal
                                     AND     status        <> /esrcc/if_calculate_chargeout=>recalculation_finalized.

*              IF sy-subrc = 0.
              incompletetrueup = abap_true.
              MESSAGE e034(/esrcc/execcockpit) INTO <ls_result>-messagerecalculation.
              <ls_result>-messagetyperecalculation = 'I'.
              EXIT.
*              ENDIF.
            ENDLOOP.

*  Check if error flag is raised for any node in the sequential chains
            READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY
                                                   sysid         = <ls_result>-sysid
                                                   ryear         = <ls_result>-ryear
                                                   poper         = <ls_result>-poper
                                                   legalentity   = <ls_result>-legalentity
                                                   ccode         = <ls_result>-ccode
                                                   costobject    = <ls_result>-costobject
                                                   costcenter    = <ls_result>-costcenter
                                                   process       = /esrcc/if_calculate_chargeout=>stdchargeout
                                                   BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(errorseq) = <ls_procctrl>-errorflag.
            ELSE.
              CLEAR errorseq.
            ENDIF.
*

            IF <ls_result>-messagetypestdchargeout <> 'E'.
              CASE _action.
                WHEN /esrcc/if_calculate_chargeout=>calculate_stdchargeout.
                  IF ( <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_allowed OR
                       <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_approved OR
                       <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_rejected OR
                       <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_failed )
                       AND <ls_result>-chain_id IS INITIAL
                       AND trueuperformed = abap_false.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/if_calculate_chargeout=>finalize_stdchargeout.
                  IF <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_approved
                     AND <ls_result>-chain_id IS INITIAL
                     AND trueuperformed = abap_false.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/if_calculate_chargeout=>reopen_stdchargeout.
                  IF <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_finalized
                     AND <ls_result>-chain_id IS INITIAL
                     AND trueuperformed = abap_false.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/if_calculate_chargeout=>calculate_stdseqchargeout.
                  IF wf_flag = abap_false.
                    IF <ls_result>-chain_id IS NOT INITIAL AND
                       <ls_result>-chain_sequence = 1 AND
                       trueuperformed = abap_false AND
                       ( <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_allowed OR
                         <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_approved OR
                         <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_rejected OR
                         <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_failed ).
                      <ls_result>-selectionallowed = abap_true.
                    ENDIF.
                  ELSE.
                    MESSAGE e016(/esrcc/execcockpit) INTO <ls_result>-messagestdchargeout.
                    <ls_result>-messagetypestdchargeout = 'I'.
                  ENDIF.
*                  ENDIF.
                WHEN /esrcc/if_calculate_chargeout=>finalize_stdseqchargeout.
                  IF <ls_result>-chain_id IS NOT INITIAL AND
                     <ls_result>-chain_sequence = 1 AND
                     errorseq = abap_false AND
                     trueuperformed = abap_false AND
                     <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_approved.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/if_calculate_chargeout=>reopen_stdseqchargeout.
                  IF <ls_result>-chain_id IS NOT INITIAL AND
                     <ls_result>-chain_sequence = 1 AND
                     trueuperformed = abap_false AND
                     <ls_result>-StdChargeout_Status = /esrcc/if_calculate_chargeout=>stdchargeout_finalized.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING FIELD-SYMBOL(<ls_processstatus>)
                                        WITH KEY  application = /esrcc/if_calculate_chargeout=>stdchargeout
                                                  status = <ls_result>-StdChargeout_Status.
            IF sy-subrc = 0.
              <ls_result>-StdChargeoutstatusdescr = <ls_processstatus>-description.
              <ls_result>-StdChargeoutcriticallity = <ls_processstatus>-color.
            ENDIF.

****************************************************************************************************************************************************
**  Service Product Costing Status-----------------------------------------------------
            IF <ls_result>-Recalculation_Status IS INITIAL.

              IF <ls_result>-Recalculation_Status <> /esrcc/if_calculate_chargeout=>recalculation_notpossible.  "Not Possible
                READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY
                                                  sysid         = <ls_result>-sysid
                                                  ryear         = <ls_result>-ryear
                                                  poper         = <ls_result>-poper
*                                                  fplv          = <ls_result>-fplv
                                                  legalentity   = <ls_result>-legalentity
                                                  ccode         = <ls_result>-ccode
                                                  costobject    = <ls_result>-costobject
                                                  costcenter    = <ls_result>-costcenter
                                                  process       = /esrcc/if_calculate_chargeout=>stdchargeout.
*                                                  BINARY SEARCH.
*
                IF sy-subrc = 0 AND <ls_procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_finalized.
                  <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_allowed.  "Calculate Stewardship & Service Cost Share
                ELSE.
                  <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_notpossible.  "Not Possible
                ENDIF.
              ENDIF.
            ENDIF.
*
            IF <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_failed.   "Costbase calculation failed.
              MESSAGE e026(/esrcc/execcockpit) INTO <ls_result>-messagerecalculation.
              <ls_result>-messagetyperecalculation = 'I'.
            ENDIF.

            IF trueuperformed = abap_true.
              MESSAGE e032(/esrcc/execcockpit) WITH trueupeperiod INTO <ls_result>-messagerecalculation.
              <ls_result>-messagetyperecalculation = 'I'.
            ENDIF.


            CLEAR errorseq.
*  Check if error flag is raised for any node in the sequential chains
            READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY
                                                           sysid         = <ls_result>-sysid
                                                           ryear         = <ls_result>-ryear
                                                           poper         = <ls_result>-poper
                                                           legalentity   = <ls_result>-legalentity
                                                           ccode         = <ls_result>-ccode
                                                           costobject    = <ls_result>-costobject
                                                           costcenter    = <ls_result>-costcenter
                                                           process       = /esrcc/if_calculate_chargeout=>trueuprecal
                                                           BINARY SEARCH.
            IF sy-subrc = 0.
              errorseq = <ls_procctrl>-errorflag.
            ELSE.
              CLEAR errorseq.
            ENDIF.

**Derive the selection allowed field.
            IF <ls_result>-messagetyperecalculation <> 'E'.
              CASE _action.
                WHEN /esrcc/if_calculate_chargeout=>calculate_recalchargeout.
                  IF ( <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_allowed OR
                       <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_approved OR
                       <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_rejected OR
                       <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_failed )
                       AND <ls_result>-chain_id IS INITIAL
                       AND trueuperformed = abap_false
                       AND incompletetrueup = abap_false.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/if_calculate_chargeout=>finalize_recalchargeout.
                  IF <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_approved
                     AND <ls_result>-chain_id IS INITIAL AND
                     trueuperformed = abap_false.

                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/if_calculate_chargeout=>reopen_recalchargeout.
                  IF <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_finalized
                     AND <ls_result>-chain_id IS INITIAL
                     AND trueuperformed = abap_false.

                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/if_calculate_chargeout=>calculate_recalseqchargeout.
                  IF wf_flag = abap_false.
                    IF <ls_result>-chain_id IS NOT INITIAL AND
                       trueuperformed = abap_false AND
                       incompletetrueup = abap_false AND
                       <ls_result>-chain_sequence = 1 AND
                       ( <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_allowed OR
                         <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_approved OR
                         <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_rejected OR
                         <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_failed ).
                      <ls_result>-selectionallowed = abap_true.
                    ENDIF.
                  ELSE.
                    MESSAGE e016(/esrcc/execcockpit) INTO <ls_result>-messagerecalculation.
                    <ls_result>-messagetyperecalculation = 'I'.
                  ENDIF.

                WHEN /esrcc/if_calculate_chargeout=>finalize_recalseqchargeout.
                  IF <ls_result>-chain_id IS NOT INITIAL AND
                     <ls_result>-chain_sequence = 1 AND
                     trueuperformed = abap_false AND
                     errorseq = abap_false AND
                     <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_approved.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/if_calculate_chargeout=>reopen_recalseqchargeout.
                  IF <ls_result>-chain_id IS NOT INITIAL AND
                     <ls_result>-chain_sequence = 1 AND
                     trueuperformed = abap_false AND
                     <ls_result>-Recalculation_Status = /esrcc/if_calculate_chargeout=>recalculation_finalized.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.
            ENDIF.
*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = /esrcc/if_calculate_chargeout=>trueuprecal
                                                                               status = <ls_result>-Recalculation_Status.
            IF sy-subrc = 0.
              <ls_result>-Recalculationstatusdescr  = <ls_processstatus>-description.
              <ls_result>-Recalculationcriticallity  = <ls_processstatus>-color.
            ENDIF.

          ENDIF.
        ENDLOOP.
*
***********************************************************************************************************************************************
***  Charge-out to Receiver Status----------------------------------------------------------
*          IF <ls_result>-chargeout_status IS INITIAL.
*            READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY    sysid       = <ls_result>-sysid
*                                                                       ryear         = <ls_result>-ryear
*                                                                       poper         = <ls_result>-poper
**                                                                       fplv          = <ls_result>-fplv
*                                                                       legalentity = <ls_result>-legalentity
*                                                                       ccode      = <ls_result>-ccode
*                                                                       costobject = <ls_result>-costobject
*                                                                       costcenter = <ls_result>-costcenter
*                                                                       process    = /esrcc/if_calculate_chargeout=>trueuprecal
*                                                                       BINARY SEARCH.
*            IF sy-subrc = 0 AND <ls_procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_finalized.  "Stewardship Finalized
*              <ls_result>-chargeout_status = /esrcc/if_calculate_chargeout=>chargeout_allowed.  "Calculate Charge-Out
*            ELSE.
*              <ls_result>-chargeout_status = /esrcc/if_calculate_chargeout=>chargeout_notpossible.  "Not Possible
*            ENDIF.
*
**        ENDIF.
**
*            IF <ls_result>-chargeout_status = /esrcc/if_calculate_chargeout=>chargeout_failed.   "Costbase calculation failed.
*              MESSAGE e026(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
*              <ls_result>-messagetypechargeout = 'I'.
*            ENDIF.
*
***Derive the status text and color
*            READ TABLE lt_processstatus ASSIGNING <ls_processstatus>
*                                        WITH KEY  application = /esrcc/if_calculate_chargeout=>chargeout
*                                                       status = <ls_result>-chargeout_status.
*            IF sy-subrc = 0.
*              <ls_result>-chargeoutstatusdescr  = <ls_processstatus>-description.
*              <ls_result>-chargeoutcriticality  = <ls_processstatus>-color.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.

        SORT lt_result BY sysid Legalentity ccode selectionallowed.

        LOOP AT lt_result ASSIGNING <ls_result> WHERE Costobject IS INITIAL AND Costcenter IS INITIAL.
*legal entity status---------------------------------------------------
* Derive the aggregate status for service product costing
          READ TABLE lt_totalcostcenters ASSIGNING FIELD-SYMBOL(<totalcostcenters>)
                                             WITH KEY  sysid       = <ls_result>-sysid
                                                       ccode       = <ls_result>-ccode
                                                       legalentity = <ls_result>-legalentity
                                                       BINARY SEARCH.
          IF sy-subrc = 0.
            READ TABLE lt_finalcostcenters ASSIGNING FIELD-SYMBOL(<finalcostcenters>)
                                               WITH KEY  sysid       = <ls_result>-sysid
                                                         ccode       = <ls_result>-ccode
                                                         legalentity = <ls_result>-legalentity
                                                         BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(finalcostcenters) = <finalcostcenters>-finalcostcenter.
            ELSE.
              finalcostcenters = 0.
            ENDIF.
            CONCATENATE ' (' finalcostcenters '/' <totalcostcenters>-totalcostcenter ' )'
            INTO <ls_result>-StdChargeoutstatusdescr.
*
*            map status color
            IF finalcostcenters = 0.
              <ls_result>-StdChargeoutcriticallity = 0.
            ELSEIF finalcostcenters <> <totalcostcenters>-totalcostcenter.
              <ls_result>-StdChargeoutcriticallity = 2.
            ELSEIF finalcostcenters = <totalcostcenters>-totalcostcenter.
              <ls_result>-StdChargeoutcriticallity = 3.
            ENDIF.


** Derive the aggregate status for chargeout to receiver
            READ TABLE lt_finalcostcentersscm ASSIGNING <finalcostcenters>
                                               WITH KEY  sysid       = <ls_result>-sysid
                                                         ccode       = <ls_result>-ccode
                                                         legalentity = <ls_result>-legalentity
                                                         BINARY SEARCH.
            IF sy-subrc = 0.
              finalcostcenters = <finalcostcenters>-finalcostcenter.
            ELSE.
              finalcostcenters = 0.
            ENDIF.
            CONCATENATE ' (' finalcostcenters '/' <totalcostcenters>-totalcostcenter ' )'
            INTO <ls_result>-Recalculationstatusdescr.
*
*            map status color
            IF finalcostcenters = 0.
              <ls_result>-Recalculationcriticallity = 0.
            ELSEIF finalcostcenters <> <totalcostcenters>-totalcostcenter.
              <ls_result>-Recalculationcriticallity = 2.
            ELSEIF finalcostcenters = <totalcostcenters>-totalcostcenter.
              <ls_result>-Recalculationcriticallity = 3.
            ENDIF.

*            READ TABLE lt_finalcostcenterschr ASSIGNING <finalcostcenters>
*                                               WITH KEY  sysid       = <ls_result>-sysid
*                                                         ccode       = <ls_result>-ccode
*                                                         legalentity = <ls_result>-legalentity
*                                                         BINARY SEARCH.
*            IF sy-subrc = 0.
*              finalcostcenters = <finalcostcenters>-finalcostcenter.
*            ELSE.
*              finalcostcenters = 0.
*            ENDIF.
*            CONCATENATE ' (' finalcostcenters '/' <totalcostcenters>-totalcostcenter ' )'
*            INTO <ls_result>-chargeoutstatusdescr.
**
**            map status color
*            IF finalcostcenters = 0.
*              <ls_result>-chargeoutcriticality = 0.
*            ELSEIF finalcostcenters <> <totalcostcenters>-totalcostcenter.
*              <ls_result>-chargeoutcriticality = 2.
*            ELSEIF finalcostcenters = <totalcostcenters>-totalcostcenter.
*              <ls_result>-chargeoutcriticality = 3.
*            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = /esrcc/if_calculate_chargeout=>stdchargeout
                                                                                    status = <ls_result>-StdChargeout_Status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-StdChargeoutstatusdescr INTO  <ls_result>-StdChargeoutstatusdescr.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = /esrcc/if_calculate_chargeout=>trueuprecal
                                                                                    status = <ls_result>-Recalculation_Status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-Recalculationstatusdescr INTO  <ls_result>-Recalculationstatusdescr.
            ENDIF.

*Derive the status text and color
*            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = /esrcc/if_calculate_chargeout=>chargeout
*                                                                                    status = <ls_result>-chargeout_status.
*            IF sy-subrc = 0.
*              CONCATENATE <ls_processstatus>-description <ls_result>-chargeoutstatusdescr INTO  <ls_result>-chargeoutstatusdescr.
*            ENDIF.

          ENDIF.

*    Set the selection allowed field depending on child fields for legale entity
          READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<result>)
                               WITH KEY sysid = <ls_result>-sysid
                                        Legalentity = <ls_result>-Legalentity
                                        ccode = <ls_result>-ccode
                                        selectionallowed = abap_true BINARY SEARCH.
          IF sy-subrc = 0.
            <ls_result>-selectionallowed = abap_true.
          ENDIF.

        ENDLOOP.
**************************************************************************************************************************************
        SORT lt_result BY sysid Legalentity ccode Costobject Costcenter ServiceProduct.
***fill response
        io_response->set_data( lt_result ).
*        ENDIF.
**request count
        IF io_request->is_total_numb_of_rec_requested( ).
**select count
**fill response
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.

      CATCH cx_rap_query_provider.

    ENDTRY.
  ENDMETHOD.

ENDCLASS.
