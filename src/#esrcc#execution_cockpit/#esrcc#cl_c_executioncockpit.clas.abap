CLASS /esrcc/cl_c_executioncockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS determine_costbase_status.
    METHODS determine_stewardship_status.
    METHODS determine_chargeout_status.
    METHODS costbase_authority_check
      IMPORTING
        action TYPE /esrcc/actions
      CHANGING
        result TYPE /esrcc/c_execution_cockpit.
    METHODS serviceproduct_authority_check
      IMPORTING
        action TYPE /esrcc/actions
      CHANGING
        result TYPE /esrcc/c_execution_cockpit.
    METHODS chargeout_authority_check
      IMPORTING
        action TYPE /esrcc/actions
      CHANGING
        result TYPE /esrcc/c_execution_cockpit.
ENDCLASS.



CLASS /ESRCC/CL_C_EXECUTIONCOCKPIT IMPLEMENTATION.


  METHOD determine_chargeout_status.

  ENDMETHOD.


  METHOD determine_costbase_status.


  ENDMETHOD.


  METHOD determine_stewardship_status.

  ENDMETHOD.


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
        DATA hierarchylevel   TYPE /esrcc/hierarchylevel.

*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.

            WHEN 'SYSID'.
              _sysid = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'FPLV'.
              _fplv = CORRESPONDING #( <ls_filter>-range ).
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
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

*Derive poper from billing frequency customizing
        SELECT 'I'  AS sign,
              'EQ'  AS option,
              poper AS low
              FROM /esrcc/billfreq
              WHERE billingfreq = @_billingfreq
                AND billingvalue = @_billingperiod
              ORDER BY low ASCENDING
              INTO CORRESPONDING FIELDS OF TABLE @_poper.

* get master data
        DATA(lv_year) = _ryear[ 1 ]-low.

        READ TABLE _poper ASSIGNING FIELD-SYMBOL(<ls_poper>) INDEX 1.
        IF sy-subrc = 0.
          CONCATENATE lv_year <ls_poper>-low+1(2) '01' INTO _validon.
        ENDIF.

*********************************************************************************************************
*        Create Data Tree
*********************************************************************************************************

        fplv = _fplv[ 1 ]-low.
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
               @_billingfreq AS billingfreq,
               @_billingperiod AS billingperiod,
               concat( srv~legalentity, companycode ) AS nodeid,
               '08' AS Costbase_status,
               '05' AS Stewardship_status,
               '05' AS chargeout_status,
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
         AND srv~BillingFrequency = @_billingfreq
         AND srv~validfrom <= @_validon
         AND srv~validto >= @_validon
         AND srvpro~OecdTpg IN @_oecd
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
               @_billingfreq AS billingfreq,
               @_billingperiod AS billingperiod,
               concat( srv~legalentity, companycode ) AS parentnodeid,
               concat( concat( concat( srv~legalentity, companycode ), srv~costobject ), srv~costcenter ) AS nodeid,
               procctrl~status AS Costbase_status,
               procctrl~log_header_uuid AS costbaselogid,
               '05' AS Stewardship_status,
               '05' AS chargeout_status,
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

            LEFT OUTER JOIN /esrcc/procctrl AS procctrl
            ON  procctrl~sysid       = srv~sysid
            AND procctrl~ryear       = @lv_year
            AND procctrl~fplv        = @fplv
            AND procctrl~legalentity = srv~legalentity
            AND procctrl~ccode       = srv~CompanyCode
            AND procctrl~costobject  = srv~costobject
            AND procctrl~costcenter  = srv~costcenter
            AND procctrl~billingfreq = @_billingfreq
            AND procctrl~billingperiod = @_billingperiod
            AND procctrl~process    = 'CBS'

       WHERE srv~legalentity IN @_legalentity
         AND srv~sysid IN @_sysid
         AND srv~CompanyCode IN @_ccode
         AND srv~costobject IN @_costobject
         AND srv~costcenter IN @_costcenter
         AND srv~serviceproduct IN @_serviceproduct
         AND srv~BillingFrequency = @_billingfreq
         AND srv~validfrom <= @_validon
         AND srv~validto >= @_validon
         AND srvpro~OecdTpg IN @_oecd
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
               @_billingfreq AS billingfreq,
               @_billingperiod AS billingperiod,
               concat( concat( concat( srv~legalentity, companycode ), srv~costobject ), srv~costcenter ) AS parentnodeid,
               concat( concat( concat( concat( srv~legalentity, companycode ), srv~costobject ), srv~costcenter ), srv~serviceproduct ) AS nodeid,
               procctrlscm~status AS Stewardship_status,
               procctrlscm~log_header_uuid AS serviceproductlogid,
               procctrlchr~status AS chargeout_status,
               procctrlchr~log_header_uuid AS chargeoutlogid,
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
            LEFT OUTER JOIN /esrcc/procctrl AS procctrlscm
            ON  procctrlscm~sysid       = srv~sysid
            AND procctrlscm~ryear       = @lv_year
            AND procctrlscm~fplv        = @fplv
            AND procctrlscm~legalentity = srv~legalentity
            AND procctrlscm~ccode       = srv~CompanyCode
            AND procctrlscm~costobject  = srv~costobject
            AND procctrlscm~costcenter  = srv~costcenter
            AND procctrlscm~serviceproduct = srv~ServiceProduct
            AND procctrlscm~billingfreq = @_billingfreq
            AND procctrlscm~billingperiod = @_billingperiod
            AND procctrlscm~process    = 'SCM'
            LEFT OUTER JOIN /esrcc/procctrl AS procctrlchr
            ON  procctrlchr~sysid       = srv~sysid
            AND procctrlchr~ryear       = @lv_year
            AND procctrlchr~fplv        = @fplv
            AND procctrlchr~legalentity = srv~legalentity
            AND procctrlchr~ccode       = srv~CompanyCode
            AND procctrlchr~costobject  = srv~costobject
            AND procctrlchr~costcenter  = srv~costcenter
            AND procctrlchr~serviceproduct = srv~ServiceProduct
            AND procctrlchr~billingfreq = @_billingfreq
            AND procctrlchr~billingperiod = @_billingperiod
            AND procctrlchr~process    = 'CHR'

            LEFT OUTER JOIN /esrcc/srvprot AS srvprodt
             ON srv~serviceproduct = srvprodt~serviceproduct
            AND srvprodt~spras = @sy-langu
       WHERE srv~legalentity IN @_legalentity
         AND srv~sysid IN @_sysid
         AND srv~CompanyCode IN @_ccode
         AND srv~costobject IN @_costobject
         AND srv~costcenter IN @_costcenter
         AND srv~serviceproduct IN @_serviceproduct
         AND srv~BillingFrequency = @_billingfreq
         AND srv~validfrom <= @_validon
         AND srv~validto >= @_validon
         AND srvpro~OecdTpg IN @_oecd
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
        AND Costobject IS NOT INITIAL
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
       WHERE Costbase_status = @/esrcc/cl_calculate_chargeout=>costbase_finalized
        AND  ServiceProduct IS INITIAL
        AND  Costcenter IS NOT INITIAL
        AND Costobject IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode
         ORDER BY sysid,
                  ccode,
                  legalentity
         INTO TABLE @DATA(lt_finalcostcenters).

*   get the count of total service products per legal enity and costcenter for status display
        SELECT DISTINCT
               legalentity,
               sysid,
               ccode,
               costobject,
               costcenter,
               CAST( COUNT( serviceproduct ) AS CHAR ) AS totalserviceproducts
       FROM  @lt_result AS result
       WHERE ServiceProduct IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode,
                  costobject,
                  costcenter
         ORDER BY sysid,
                  ccode,
                  legalentity,
                  costobject,
                  costcenter
         INTO TABLE @DATA(lt_totalserviceproducts).

*get the number of serviceproduct finalized per legal entity per costobject
        SELECT DISTINCT
               legalentity,
               sysid,
               ccode,
               costobject,
               costcenter,
               CAST( COUNT( serviceproduct ) AS CHAR ) AS finalserviceproduct
            FROM  @lt_result AS result
       WHERE Stewardship_status = @/esrcc/cl_calculate_chargeout=>serviceshare_finalized
        AND  ServiceProduct IS NOT INITIAL
        AND  Costcenter IS NOT INITIAL
        AND Costobject IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode,
                  costobject,
                  costcenter
         ORDER BY sysid,
                  ccode,
                  legalentity,
                  costobject,
                  costcenter
         INTO TABLE @DATA(lt_finalserviceproductscm).

*get the number of serviceproduct finalized per legal entity per costobject
        SELECT DISTINCT
               legalentity,
               sysid,
               ccode,
               costobject,
               costcenter,
               CAST( COUNT( serviceproduct ) AS CHAR ) AS finalserviceproduct
            FROM  @lt_result AS result
       WHERE chargeout_status = @/esrcc/cl_calculate_chargeout=>chargeout_finalized
        AND  ServiceProduct IS NOT INITIAL
        AND  Costcenter IS NOT INITIAL
        AND Costobject IS NOT INITIAL
         GROUP BY legalentity,
                  sysid,
                  ccode,
                  costobject,
                  costcenter
          ORDER BY sysid,
                  ccode,
                  legalentity,
                  costobject,
                  costcenter
         INTO TABLE @DATA(lt_finalserviceproductchr).

*********************************************************************************************************
*        End Data Tree
*********************************************************************************************************
        SELECT DISTINCT
               result~sysid,
               result~legalentity,
               result~ccode,
               result~costobject,
               result~costcenter,
               result~serviceproduct
            FROM @lt_result AS result
            WHERE ServiceProduct IS NOT INITIAL
            ORDER BY sysid,
                     legalentity,
                     ccode,
                     costobject,
                     costcenter,
                     serviceproduct
            INTO CORRESPONDING FIELDS OF TABLE @lt_service_share.

* Determine Status-----------------------------------------------------------
        SELECT DISTINCT
                proc~sysid,
                ryear,
                fplv,
                proc~legalentity,
                proc~ccode,
                proc~costobject,
                proc~costcenter,
                proc~serviceproduct,
                billingfreq,
                billingperiod,
                process,
                status,
                log_header_uuid
                FROM /esrcc/procctrl AS proc
                INNER JOIN @lt_service_share AS srvshare
                  ON proc~legalentity = srvshare~legalentity
                  AND proc~sysid = srvshare~sysid
                  AND proc~ccode = srvshare~ccode
                  AND proc~costobject = srvshare~costobject
                  AND proc~costcenter = srvshare~costcenter
                 WHERE fplv IN @_fplv
                  AND ryear IN @_ryear
                  AND billingfreq = @_billingfreq
                  AND billingperiod = @_billingperiod
                  ORDER BY proc~sysid, ryear, fplv, proc~legalentity,
                           proc~ccode, proc~costobject, proc~costcenter,
                           billingfreq, billingperiod,
                           process, proc~serviceproduct
                 INTO TABLE @DATA(lt_procctrl).


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
              INNER JOIN @lt_service_share AS srvshare
                  ON cbli~legalentity = srvshare~legalentity
                  AND cbli~sysid = srvshare~sysid
                  AND cbli~ccode = srvshare~ccode
                  AND cbli~costobject = srvshare~costobject
                  AND cbli~costcenter = srvshare~costcenter
              WHERE ryear IN @_ryear
                AND fplv  IN @_fplv
                AND poper IN @_poper
                AND ( status = 'D' OR status = 'A' OR status = 'W' )
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
                       cbli~fplv,
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
                                                                AND Costcenter IS NOT INITIAL.


*  Costbase status----------------------------------------------------
          IF <ls_result>-Costcenter IS NOT INITIAL AND <ls_result>-serviceproduct IS INITIAL.
            IF <ls_result>-Costbase_status IS INITIAL.
              <ls_result>-costbase_status = '01'.   "Line Items not Available

              READ TABLE lt_li ASSIGNING FIELD-SYMBOL(<ls_li>) WITH KEY sysid       = <ls_result>-sysid
                                                                        ryear       = <ls_result>-ryear
                                                                        fplv        = <ls_result>-fplv
                                                                        legalentity = <ls_result>-legalentity
                                                                         ccode      = <ls_result>-ccode
                                                                         costobject = <ls_result>-costobject
                                                                         costcenter = <ls_result>-costcenter
                                                                         status     = 'D' BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_result>-costbase_status = '02'.   "Line Items In Draft
              ELSE.
                READ TABLE lt_li ASSIGNING <ls_li> WITH KEY  sysid       = <ls_result>-sysid
                                                             ryear       = <ls_result>-ryear
                                                             fplv        = <ls_result>-fplv
                                                             legalentity = <ls_result>-legalentity
                                                             ccode       = <ls_result>-ccode
                                                             costobject  = <ls_result>-costobject
                                                             costcenter  = <ls_result>-costcenter
                                                              status     = 'W' BINARY SEARCH.
                IF sy-subrc = 0.
                  <ls_result>-costbase_status = '03'.   "Line Items In Approval Pending
                ELSE.
                  READ TABLE lt_li TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                  ryear       = <ls_result>-ryear
                                                                  fplv        = <ls_result>-fplv
                                                                  legalentity = <ls_result>-legalentity
                                                                  ccode      = <ls_result>-ccode
                                                                  costobject = <ls_result>-costobject
                                                                  costcenter = <ls_result>-costcenter
                                                                  BINARY SEARCH.

                  IF sy-subrc = 0.
                    <ls_result>-costbase_status = '04'.   "Calculate Stewardship
                  ENDIF.
                ENDIF.

              ENDIF.
            ENDIF.

            IF <ls_result>-costbase_status = '11'.   "Costbase calculation failed.
              MESSAGE e026(/esrcc/execcockpit) INTO <ls_result>-messagecostbase.
              <ls_result>-messagetypecostbase = 'I'.
            ENDIF.

            costbase_authority_check(
              EXPORTING
                action = _action
              CHANGING
                result = <ls_result>
            ).
* Derive the aggregate status for service product costing
            READ TABLE lt_totalserviceproducts ASSIGNING FIELD-SYMBOL(<totalserviceproducts>)
                                               WITH KEY  sysid       = <ls_result>-sysid
                                                         ccode       = <ls_result>-ccode
                                                         legalentity = <ls_result>-legalentity
                                                         costobject  = <ls_result>-costobject
                                                         costcenter  = <ls_result>-costcenter BINARY SEARCH.
            IF sy-subrc = 0.
              READ TABLE lt_finalserviceproductscm ASSIGNING FIELD-SYMBOL(<finalserviceproducts>)
                                                 WITH KEY  sysid       = <ls_result>-sysid
                                                           ccode       = <ls_result>-ccode
                                                           legalentity = <ls_result>-legalentity
                                                           costobject  = <ls_result>-costobject
                                                           costcenter  = <ls_result>-costcenter BINARY SEARCH.
              IF sy-subrc = 0.
                DATA(finalized) = <finalserviceproducts>-finalserviceproduct.
              ELSE.
                finalized = 0.
              ENDIF.
              CONCATENATE ' (' finalized '/' <totalserviceproducts>-totalserviceproducts ' )'
              INTO <ls_result>-stewardshipstatusdescr.
*
*            map status color
              IF finalized = 0.
                <ls_result>-stewardshipcriticality = 0.
              ELSEIF finalized <> <totalserviceproducts>-totalserviceproducts.
                <ls_result>-stewardshipcriticality = 2.
              ELSEIF finalized = <totalserviceproducts>-totalserviceproducts.
                <ls_result>-stewardshipcriticality = 3.
              ENDIF.

* Derive the aggregate status for chargeout to receiver
              READ TABLE lt_finalserviceproductchr ASSIGNING <finalserviceproducts>
                                                 WITH KEY  sysid       = <ls_result>-sysid
                                                           ccode       = <ls_result>-ccode
                                                           legalentity = <ls_result>-legalentity
                                                           costobject  = <ls_result>-costobject
                                                           costcenter  = <ls_result>-costcenter BINARY SEARCH.
              IF sy-subrc = 0.
                finalized = <finalserviceproducts>-finalserviceproduct.
              ELSE.
                finalized = 0.
              ENDIF.
              CONCATENATE ' (' finalized '/' <totalserviceproducts>-totalserviceproducts ' )'
              INTO <ls_result>-chargeoutstatusdescr.
*
*            map status color
              IF finalized = 0.
                <ls_result>-chargeoutcriticality = 0.
              ELSEIF finalized <> <totalserviceproducts>-totalserviceproducts.
                <ls_result>-chargeoutcriticality = 2.
              ELSEIF finalized = <totalserviceproducts>-totalserviceproducts.
                <ls_result>-chargeoutcriticality = 3.
              ENDIF.
            ENDIF.

*Derive the selection allowed flag
            IF <ls_result>-messagetypecostbase <> 'E'.
              CASE _action.
                WHEN /esrcc/cl_calculate_chargeout=>action_calculate_costbase.
                  IF ( <ls_result>-costbase_status = '04' OR
                       <ls_result>-costbase_status = '07' OR
                       <ls_result>-costbase_status = '10' OR
                       <ls_result>-costbase_status = '11' )
                       AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/cl_calculate_chargeout=>action_finalize_costbase.
                  IF <ls_result>-costbase_status = '07' AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/cl_calculate_chargeout=>action_reopen_costbase.
                  IF <ls_result>-costbase_status = '08' AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/cl_calculate_chargeout=>action_sequential_chargeout.
                  IF wf_flag = abap_false.
                    IF <ls_result>-chain_id IS NOT INITIAL AND
                       <ls_result>-chain_sequence = 1 AND
                              ( <ls_result>-costbase_status = '04' OR
                             <ls_result>-costbase_status = '07' OR
                             <ls_result>-costbase_status = '10' OR
                             <ls_result>-costbase_status = '11' ).
                      <ls_result>-selectionallowed = abap_true.
                    ENDIF.
                  ELSE.
                    MESSAGE e016(/esrcc/execcockpit) INTO <ls_result>-messagecostbase.
                    <ls_result>-messagetypecostbase = 'I'.
                  ENDIF.
*                  ENDIF.
                WHEN /esrcc/cl_calculate_chargeout=>action_reopenseq_chargeout.
                  IF <ls_result>-chain_id IS NOT INITIAL AND
                     <ls_result>-chain_sequence = 1 AND
                     <ls_result>-costbase_status = '08'.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING FIELD-SYMBOL(<ls_processstatus>) WITH KEY  application = 'CBS'
                                                                                             status = <ls_result>-costbase_status.
            IF sy-subrc = 0.
              <ls_result>-costbasestatusdescr = <ls_processstatus>-description.
              <ls_result>-costbasecriticallity = <ls_processstatus>-color.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'SCM'
                                                                                    status = <ls_result>-stewardship_status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-stewardshipstatusdescr INTO  <ls_result>-stewardshipstatusdescr.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'CHR'
                                                                                    status = <ls_result>-chargeout_status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-chargeoutstatusdescr INTO  <ls_result>-chargeoutstatusdescr.
            ENDIF.

          ENDIF.
****************************************************************************************************************************************************
*  Service Cost Share & Markup Status-----------------------------------------------------
          IF <ls_result>-serviceproduct IS NOT INITIAL.
            IF <ls_result>-Stewardship_status IS INITIAL.

              READ TABLE lt_procctrl ASSIGNING FIELD-SYMBOL(<ls_procctrl>) WITH KEY sysid         = <ls_result>-sysid
                                                                      ryear         = <ls_result>-ryear
                                                                      fplv          = <ls_result>-fplv
                                                                      legalentity   = <ls_result>-legalentity
                                                                      ccode         = <ls_result>-ccode
                                                                      costobject    = <ls_result>-costobject
                                                                      costcenter    = <ls_result>-costcenter
                                                                      billingfreq   = <ls_result>-billingfreq
                                                                      billingperiod = <ls_result>-billingperiod
                                                                         process    = 'CBS' BINARY SEARCH.
*                                                                           status = '08'.    "Cost base Finalized
              IF sy-subrc = 0 AND <ls_procctrl>-status = '08'.
                <ls_result>-stewardship_status = '01'.  "Calculate Stewardship & Service Cost Share
              ELSE.
                <ls_result>-stewardship_status = '00'.  "Not Possible
              ENDIF.

            ENDIF.

            IF <ls_result>-stewardship_status = '07'.   "Costbase calculation failed.
              MESSAGE e026(/esrcc/execcockpit) INTO <ls_result>-messageservice.
              <ls_result>-messagetypeservice = 'I'.
            ENDIF.

            serviceproduct_authority_check(
              EXPORTING
                action = _action
              CHANGING
                result = <ls_result>
            ).

*Derive the selection allowed field.
            IF <ls_result>-messagetypeservice <> 'E'.
              CASE _action.
                WHEN /esrcc/cl_calculate_chargeout=>action_calculat_serviceproduct.
                  IF ( <ls_result>-Stewardship_status = '01' OR
                       <ls_result>-Stewardship_status = '04' OR
                       <ls_result>-Stewardship_status = '06' OR
                       <ls_result>-Stewardship_status = '07' )
                       AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/cl_calculate_chargeout=>action_finalize_serviceproduct.
                  IF <ls_result>-Stewardship_status = '04' AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/cl_calculate_chargeout=>action_reopen_serviceproduct.
                  IF <ls_result>-Stewardship_status = '05' AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.
            ENDIF.
*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'SCM'
                                                                               status = <ls_result>-Stewardship_status.
            IF sy-subrc = 0.
              <ls_result>-stewardshipstatusdescr  = <ls_processstatus>-description.
              <ls_result>-stewardshipcriticality  = <ls_processstatus>-color.
            ENDIF.

**********************************************************************************************************************************************
*  Charge-out to Receiver Status----------------------------------------------------------
            IF <ls_result>-chargeout_status IS INITIAL.
              READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY    sysid       = <ls_result>-sysid
                                                                         ryear         = <ls_result>-ryear
                                                                         fplv          = <ls_result>-fplv
                                                                         legalentity = <ls_result>-legalentity
                                                                         ccode      = <ls_result>-ccode
                                                                         costobject = <ls_result>-costobject
                                                                         costcenter = <ls_result>-costcenter
                                                                         billingfreq = <ls_result>-billingfreq
                                                                         billingperiod = <ls_result>-billingperiod
                                                                         process    = 'SCM' BINARY SEARCH.
              IF sy-subrc = 0 AND <ls_procctrl>-status = '05'.  "Stewardship Finalized
                <ls_result>-chargeout_status = '01'.  "Calculate Charge-Out
              ELSE.
                <ls_result>-chargeout_status = '00'.  "Not Possible
              ENDIF.

            ENDIF.

            IF <ls_result>-chargeout_status = '07'.   "Costbase calculation failed.
              MESSAGE e026(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
              <ls_result>-messagetypechargeout = 'I'.
            ENDIF.

            chargeout_authority_check(
              EXPORTING
                action = _action
              CHANGING
                result = <ls_result>
            ).

*Derive the selection allowed field.
            IF <ls_result>-messagetypechargeout <> 'E'.
              CASE _action.
                WHEN /esrcc/cl_calculate_chargeout=>action_calculat_chargeout.
                  IF ( <ls_result>-Chargeout_status = '01' OR
                            <ls_result>-Chargeout_status = '04' OR
                            <ls_result>-Chargeout_status = '06' OR
                            <ls_result>-Chargeout_status = '07' )
                      AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.

                WHEN /esrcc/cl_calculate_chargeout=>action_finalize_chargeout.
                  IF <ls_result>-Chargeout_status = '04' AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN /esrcc/cl_calculate_chargeout=>action_reopen_chargeout.
                  IF <ls_result>-Chargeout_status = '05' AND <ls_result>-chain_id IS INITIAL.
                    <ls_result>-selectionallowed = abap_true.
                  ENDIF.
                WHEN OTHERS.
              ENDCASE.
            ENDIF.
*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'CHR'
                                                                               status = <ls_result>-chargeout_status.
            IF sy-subrc = 0.
              <ls_result>-chargeoutstatusdescr  = <ls_processstatus>-description.
              <ls_result>-chargeoutcriticality  = <ls_processstatus>-color.
            ENDIF.
          ENDIF.
        ENDLOOP.

**********************************************************************************************************************************************
*get the count of finalized cost center & service products per legal entity
        SELECT DISTINCT
                 legalentity,
                 sysid,
                 ccode,
                 CAST( COUNT( stewardshipcriticality ) AS CHAR ) AS finalcostcenterscm
              FROM  @lt_result AS result
         WHERE stewardshipcriticality = 3
          AND  ServiceProduct IS INITIAL
          AND  Costcenter IS NOT INITIAL
          AND Costobject IS NOT INITIAL
           GROUP BY legalentity,
                    sysid,
                    ccode
           ORDER BY sysid,
                    ccode,
                    legalentity
           INTO TABLE @DATA(lt_finalcostcentersscm).

*get the count of finalized cost center & service products per legal entity
        SELECT DISTINCT
                 legalentity,
                 sysid,
                 ccode,
                 CAST( COUNT( chargeoutcriticality ) AS CHAR ) AS finalcostcenterchr
              FROM  @lt_result AS result
         WHERE chargeoutcriticality = 3
          AND  ServiceProduct IS INITIAL
          AND  Costcenter IS NOT INITIAL
          AND Costobject IS NOT INITIAL
           GROUP BY legalentity,
                    sysid,
                    ccode
           ORDER BY sysid,
                    ccode,
                    legalentity
           INTO TABLE @DATA(lt_finalcostcenterschr).

**********************************************************************************************************************************************
        SORT lt_result BY sysid Legalentity  ccode costobject costcenter selectionallowed.

        IF _action = /esrcc/cl_calculate_chargeout=>action_calculat_serviceproduct OR
           _action = /esrcc/cl_calculate_chargeout=>action_finalize_serviceproduct OR
           _action = /esrcc/cl_calculate_chargeout=>action_reopen_serviceproduct OR
           _action = /esrcc/cl_calculate_chargeout=>action_calculat_chargeout OR
           _action = /esrcc/cl_calculate_chargeout=>action_finalize_chargeout OR
           _action = /esrcc/cl_calculate_chargeout=>action_reopen_chargeout.
          LOOP AT lt_result ASSIGNING <ls_result> WHERE Costobject IS NOT INITIAL AND ServiceProduct IS INITIAL.


*    Set the selection allowed field depending on child fields for legale entity
            READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<result>)
                                 WITH KEY sysid       = <ls_result>-sysid
                                          Legalentity = <ls_result>-Legalentity
                                          ccode       = <ls_result>-ccode
                                          costobject  = <ls_result>-Costobject
                                          costcenter  = <ls_result>-Costcenter
                                          selectionallowed = abap_true BINARY SEARCH.
            IF sy-subrc = 0.
              <ls_result>-selectionallowed = abap_true.
            ENDIF.

          ENDLOOP.
        ENDIF.

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
            INTO <ls_result>-costbasestatusdescr.
*
*            map status color
            IF finalcostcenters = 0.
              <ls_result>-costbasecriticallity = 0.
            ELSEIF finalcostcenters <> <totalcostcenters>-totalcostcenter.
              <ls_result>-costbasecriticallity = 2.
            ELSEIF finalcostcenters = <totalcostcenters>-totalcostcenter.
              <ls_result>-costbasecriticallity = 3.
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
            INTO <ls_result>-stewardshipstatusdescr.
*
*            map status color
            IF finalcostcenters = 0.
              <ls_result>-stewardshipcriticality = 0.
            ELSEIF finalcostcenters <> <totalcostcenters>-totalcostcenter.
              <ls_result>-stewardshipcriticality = 2.
            ELSEIF finalcostcenters = <totalcostcenters>-totalcostcenter.
              <ls_result>-stewardshipcriticality = 3.
            ENDIF.

            READ TABLE lt_finalcostcenterschr ASSIGNING <finalcostcenters>
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
            INTO <ls_result>-chargeoutstatusdescr.
*
*            map status color
            IF finalcostcenters = 0.
              <ls_result>-chargeoutcriticality = 0.
            ELSEIF finalcostcenters <> <totalcostcenters>-totalcostcenter.
              <ls_result>-chargeoutcriticality = 2.
            ELSEIF finalcostcenters = <totalcostcenters>-totalcostcenter.
              <ls_result>-chargeoutcriticality = 3.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'CBS'
                                                                                    status = <ls_result>-costbase_status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-costbasestatusdescr INTO  <ls_result>-costbasestatusdescr.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'SCM'
                                                                                    status = <ls_result>-stewardship_status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-stewardshipstatusdescr INTO  <ls_result>-stewardshipstatusdescr.
            ENDIF.

*Derive the status text and color
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'CHR'
                                                                                    status = <ls_result>-chargeout_status.
            IF sy-subrc = 0.
              CONCATENATE <ls_processstatus>-description <ls_result>-chargeoutstatusdescr INTO  <ls_result>-chargeoutstatusdescr.
            ENDIF.

          ENDIF.

*    Set the selection allowed field depending on child fields for legale entity
          READ TABLE lt_result ASSIGNING <result>
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


  METHOD chargeout_authority_check.

*    Authorisation Check
    IF action = /esrcc/cl_calculate_chargeout=>action_calculat_chargeout.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '01'.
      IF sy-subrc <> 0.
        MESSAGE e008(/esrcc/execcockpit) INTO result-messagechargeout.
        result-messagetypechargeout = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '01'.
        IF sy-subrc <> 0.
          MESSAGE e008(/esrcc/execcockpit) INTO result-messagechargeout.
          result-messagetypechargeout = 'E'.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/cl_calculate_chargeout=>action_finalize_chargeout.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '02'.
      IF sy-subrc <> 0.
        MESSAGE e014(/esrcc/execcockpit) INTO result-messagechargeout.
        result-messagetypechargeout = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '02'.
        IF sy-subrc <> 0.
          MESSAGE e014(/esrcc/execcockpit) INTO result-messagechargeout.
          result-messagetypechargeout = 'E'.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/cl_calculate_chargeout=>action_reopen_chargeout.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '06'.
      IF sy-subrc <> 0.
        MESSAGE e015(/esrcc/execcockpit) INTO result-messagechargeout.
        result-messagetypechargeout = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '06'.
        IF sy-subrc <> 0.
          MESSAGE e015(/esrcc/execcockpit) INTO result-messagechargeout.
          result-messagetypechargeout = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD costbase_authority_check.

*    Authorisation Check
    IF action = /esrcc/cl_calculate_chargeout=>action_calculate_costbase.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '01'.
      IF sy-subrc <> 0.
        MESSAGE e006(/esrcc/execcockpit) INTO result-messagecostbase.
        result-messagetypecostbase = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '01'.
        IF sy-subrc <> 0.
          MESSAGE e006(/esrcc/execcockpit) INTO result-messagecostbase.
          result-messagetypecostbase = 'E'.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/cl_calculate_chargeout=>action_finalize_costbase.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '02'.
      IF sy-subrc <> 0.
        MESSAGE e010(/esrcc/execcockpit) INTO result-messagecostbase.
        result-messagetypecostbase = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '02'.
        IF sy-subrc <> 0.
          MESSAGE e010(/esrcc/execcockpit) INTO result-messagecostbase.
          result-messagetypecostbase = 'E'.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/cl_calculate_chargeout=>action_reopen_costbase.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '06'.
      IF sy-subrc <> 0.
        MESSAGE e011(/esrcc/execcockpit) INTO result-messagecostbase.
        result-messagetypecostbase = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '06'.
        IF sy-subrc <> 0.
          MESSAGE e011(/esrcc/execcockpit) INTO result-messagecostbase.
          result-messagetypecostbase = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD serviceproduct_authority_check.

*    Authorisation Check
    IF action = /esrcc/cl_calculate_chargeout=>action_calculat_serviceproduct.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '01'.
      IF sy-subrc <> 0.
        MESSAGE e007(/esrcc/execcockpit) INTO result-messageservice.
        result-messagetypeservice = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '01'.
        IF sy-subrc <> 0.
          MESSAGE e007(/esrcc/execcockpit) INTO result-messageservice.
          result-messagetypeservice = 'E'.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/cl_calculate_chargeout=>action_finalize_serviceproduct.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '02'.
      IF sy-subrc <> 0.
        MESSAGE e012(/esrcc/execcockpit) INTO result-messageservice.
        result-messagetypeservice = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '02'.
        IF sy-subrc <> 0.
          MESSAGE e012(/esrcc/execcockpit) INTO result-messageservice.
          result-messagetypeservice = 'E'.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/cl_calculate_chargeout=>action_reopen_serviceproduct.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD result-legalentity
          ID 'ACTVT'  FIELD '06'.
      IF sy-subrc <> 0.
        MESSAGE e013(/esrcc/execcockpit) INTO result-messageservice.
        result-messagetypeservice = 'E'.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD result-costobject
            ID '/ESRCC/CN'  FIELD result-costcenter
            ID 'ACTVT'  FIELD '06'.
        IF sy-subrc <> 0.
          MESSAGE e013(/esrcc/execcockpit) INTO result-messageservice.
          result-messagetypeservice = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
