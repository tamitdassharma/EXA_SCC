CLASS /esrcc/cl_calculate_chargeout DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS: calculate_costbase
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
        !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: calculate_servicecostshare
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
        !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: calculate_chargeout
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
        !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: finalize_costbase
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range OPTIONAL.

    CLASS-METHODS: finalize_servicecostshare
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range OPTIONAL.

    CLASS-METHODS: finalize_chargeout
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range OPTIONAL.

    CLASS-METHODS: reopen_costbase
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range OPTIONAL.

    CLASS-METHODS: reopen_serviceshare
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL
        !it_poper          TYPE /esrcc/tt_poper_range OPTIONAL.

    CLASS-METHODS: reopen_chargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL
        !it_poper          TYPE /esrcc/tt_poper_range OPTIONAL.

    CLASS-METHODS: calculate_adhocchargeout
      IMPORTING
        !it_cbli       TYPE /esrcc/tt_cbli
        !is_parameters TYPE /esrcc/c_adhocchargeout
        !it_receivers  TYPE /esrcc/tt_receivers.

    CLASS-METHODS: sequentialchargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: reopnesequentialchargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: create_processlogs
      IMPORTING
        !iv_action      TYPE /esrcc/actions OPTIONAL
        !it_keys        TYPE /esrcc/tt_keys
      EXPORTING
        !et_processlogs TYPE /esrcc/tt_processlogs.

    CLASS-METHODS: virtual_posting
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: delete_adhoc_chargeout
      IMPORTING
        !id TYPE sysuuid_x16.

    CLASS-METHODS: Authority_check
      IMPORTING
        !keys   TYPE /esrcc/procctrl
        !action TYPE /esrcc/actions
      EXPORTING
        !failed TYPE abap_boolean.

    CLASS-METHODS: set_process_control
      IMPORTING
        !keys    TYPE /esrcc/tt_keys
        !process TYPE /esrcc/application_type_de
        !status  TYPE /esrcc/process_status_de
        !update  TYPE abap_boolean
      EXPORTING
        !failed  TYPE abap_boolean.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS: determine_delta_chargeout
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: determine_last_day
      IMPORTING
        !iv_ryear    TYPE /esrcc/ryear
        !iv_poper    TYPE poper
      EXPORTING
        !ev_valid_on TYPE /esrcc/validfrom.

    CLASS-METHODS: delete_virtual_postings
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: trigger_workflow
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
        !iv_application    TYPE /esrcc/application_type_de.

    CLASS-METHODS: delete_chargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !it_poper          TYPE /esrcc/tt_poper_range
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: delete_servicecostshare
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !it_poper          TYPE /esrcc/tt_poper_range
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: delete_costbase
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: derive_poper
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
      EXPORTING
        !et_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: validate_costbase
      IMPORTING
        !it_poper  TYPE /esrcc/tt_poper_range
      EXPORTING
        !ev_failed TYPE abap_boolean
      CHANGING
        !ct_keys   TYPE /esrcc/tt_keys.


    CLASS-METHODS: validate_serviceproductcosting
      IMPORTING
        !it_poper  TYPE /esrcc/tt_poper_range
      EXPORTING
        !ev_failed TYPE abap_boolean
      CHANGING
        !ct_keys   TYPE /esrcc/tt_keys.

    CLASS-METHODS: validate_receiverchargeout
      IMPORTING
        !it_poper  TYPE /esrcc/tt_poper_range
      EXPORTING
        !ev_failed TYPE abap_boolean
      CHANGING
        !ct_keys   TYPE /esrcc/tt_keys.

    CLASS-METHODS: create_loginstance
      IMPORTING
                !key               TYPE /esrcc/procctrl
                !procctrl          TYPE /esrcc/tt_keys
                !process           TYPE /esrcc/process
      RETURNING VALUE(loginstance) TYPE REF TO /esrcc/if_application_logs.

    CLASS-METHODS: add_logmessages
      IMPORTING
        !logitems    TYPE /esrcc/log_items
        !loginstance TYPE REF TO /esrcc/if_application_logs.
    .

ENDCLASS.



CLASS /esrcc/cl_calculate_chargeout IMPLEMENTATION.


  METHOD add_logmessages.


  ENDMETHOD.


  METHOD authority_check.

    CLEAR failed.

*    Authorisation Check
    IF action = /esrcc/if_calculate_chargeout=>action_calculate_costbase OR
       action = /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct OR
       action = /esrcc/if_calculate_chargeout=>action_calculat_chargeout.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD keys-legalentity
          ID 'ACTVT'  FIELD '01'.
      IF sy-subrc <> 0.
        failed = abap_true.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD keys-costobject
            ID '/ESRCC/CN'  FIELD keys-costcenter
            ID 'ACTVT'  FIELD '01'.
        IF sy-subrc <> 0.
          failed = abap_true.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/if_calculate_chargeout=>action_finalize_costbase OR
           action = /esrcc/if_calculate_chargeout=>action_finalize_serviceproduct OR
           action = /esrcc/if_calculate_chargeout=>action_finalize_chargeout.

      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD keys-legalentity
          ID 'ACTVT'  FIELD '02'.
      IF sy-subrc <> 0.
        failed = abap_true.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD keys-costobject
            ID '/ESRCC/CN'  FIELD keys-costcenter
            ID 'ACTVT'  FIELD '02'.
        IF sy-subrc <> 0.
          failed = abap_true.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/if_calculate_chargeout=>action_reopen_costbase OR
           action = /esrcc/if_calculate_chargeout=>action_reopen_serviceproduct OR
           action = /esrcc/if_calculate_chargeout=>action_reopen_chargeout.
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD keys-legalentity
          ID 'ACTVT'  FIELD '06'.
      IF sy-subrc <> 0.
        failed = abap_true.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD keys-costobject
            ID '/ESRCC/CN'  FIELD keys-costcenter
            ID 'ACTVT'  FIELD '06'.
        IF sy-subrc <> 0.
          failed = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD calculate_adhocchargeout.

    DATA lt_cb_stw   TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srvshare TYPE TABLE OF /esrcc/srv_share.
    DATA lt_recchg   TYPE TABLE OF /esrcc/rec_chg.
    DATA lt_allocationshare TYPE TABLE OF /esrcc/alocshare.
    DATA lt_allocationvalue TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_proctrl         TYPE TABLE OF /esrcc/procctrl.

    SELECT fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
*           businessdivision,
*           profitcenter,
*           functionalarea,
           localcurr,
           groupcurr,
           SUM( hsl ) AS totalcost_l,
           SUM( ksl ) AS totalcost_g
           FROM @it_cbli AS cbli
           GROUP BY
           fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
*           businessdivision,
*           profitcenter,
*           functionalarea,
           localcurr,
           groupcurr
           INTO CORRESPONDING FIELDS OF TABLE @lt_cb_stw.

    SELECT fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
*           businessdivision,
*           profitcenter,
*           functionalarea,
           localcurr,
           groupcurr,
           SUM( hsl ) AS virtualcost_l,
           SUM( ksl ) AS virtualcost_g
           FROM @it_cbli AS cbli
           WHERE value_source = 'SCC'
           GROUP BY
           fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
*           businessdivision,
*           profitcenter,
*           functionalarea,
           localcurr,
           groupcurr
           INTO TABLE @DATA(lt_cb_stw_scc).

    SELECT fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
*           businessdivision,
*           profitcenter,
*           functionalarea,
           localcurr,
           groupcurr,
           SUM( hsl ) AS origtotalcost_l,
           SUM( ksl ) AS origtotalcost_g
           FROM @it_cbli AS cbli
           WHERE costind = 'ORIG'
           GROUP BY
           fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
*           businessdivision,
*           profitcenter,
*           functionalarea,
           localcurr,
           groupcurr
           INTO TABLE @DATA(lt_cb_stw_orig).

    SELECT fplv,
          ryear,
          poper,
          sysid,
          legalentity,
          ccode,
          costobject,
          costcenter,
*          businessdivision,
*          profitcenter,
*          functionalarea,
          localcurr,
          groupcurr,
          SUM( hsl ) AS passtotalcost_l,
          SUM( ksl ) AS passtotalcost_g
          FROM @it_cbli AS cbli
          WHERE costind = 'PASS'
          GROUP BY
          fplv,
          ryear,
          poper,
          sysid,
          legalentity,
          ccode,
          costobject,
          costcenter,
*          businessdivision,
*          profitcenter,
*          functionalarea,
          localcurr,
          groupcurr
          INTO TABLE @DATA(lt_cb_stw_pass).

* Derive the share % based on the share value
    SELECT SUM( sharevalue ) FROM @it_receivers AS receievers INTO @DATA(totalvalue).

    SELECT SINGLE servicetype, transactiongroup
       FROM /esrcc/srvpro WHERE serviceproduct = @is_parameters-Serviceproduct
                                INTO @DATA(ls_serviceproduct).

    SELECT SINGLE * FROM /esrcc/co_rule WHERE rule_id = @is_parameters-rule_id
                                          AND workflow_status = 'F'
                                INTO @DATA(ls_rule).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    READ TABLE it_cbli ASSIGNING FIELD-SYMBOL(<cbli>) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_cb_stw ASSIGNING FIELD-SYMBOL(<ls_cbstw>).

      READ TABLE lt_cb_stw_scc ASSIGNING FIELD-SYMBOL(<ls_cb_stw_scc>)
                                    WITH KEY fplv         = <ls_cbstw>-fplv
                                              ryear       = <ls_cbstw>-ryear
                                              poper       = <ls_cbstw>-poper
                                              sysid       = <ls_cbstw>-sysid
                                              legalentity = <ls_cbstw>-legalentity
                                              ccode       = <ls_cbstw>-ccode
                                              costobject  = <ls_cbstw>-costobject
                                              costcenter  = <ls_cbstw>-costcenter.
      IF sy-subrc = 0.
        <ls_cbstw>-virtualtotalcost_l = <ls_cb_stw_scc>-virtualcost_l.
        <ls_cbstw>-virtualtotalcost_g = <ls_cb_stw_scc>-virtualcost_g.
      ENDIF.

      READ TABLE lt_cb_stw_orig ASSIGNING FIELD-SYMBOL(<ls_cb_stw_orig>)
                                    WITH KEY fplv         = <ls_cbstw>-fplv
                                              ryear       = <ls_cbstw>-ryear
                                              poper       = <ls_cbstw>-poper
                                              sysid       = <ls_cbstw>-sysid
                                              legalentity = <ls_cbstw>-legalentity
                                              ccode       = <ls_cbstw>-ccode
                                              costobject  = <ls_cbstw>-costobject
                                              costcenter  = <ls_cbstw>-costcenter.
      IF sy-subrc = 0.
        <ls_cbstw>-origtotalcost_l = <ls_cb_stw_orig>-origtotalcost_l.
        <ls_cbstw>-origtotalcost_g = <ls_cb_stw_orig>-origtotalcost_g.
      ENDIF.

      READ TABLE lt_cb_stw_pass ASSIGNING FIELD-SYMBOL(<ls_cb_stw_pass>)
                                    WITH KEY fplv         = <ls_cbstw>-fplv
                                              ryear       = <ls_cbstw>-ryear
                                              poper       = <ls_cbstw>-poper
                                              sysid       = <ls_cbstw>-sysid
                                              legalentity = <ls_cbstw>-legalentity
                                              ccode       = <ls_cbstw>-ccode
                                              costobject  = <ls_cbstw>-costobject
                                              costcenter  = <ls_cbstw>-costcenter.
      IF sy-subrc = 0.
        <ls_cbstw>-passtotalcost_l = <ls_cb_stw_pass>-passtotalcost_l.
        <ls_cbstw>-passtotalcost_g = <ls_cb_stw_pass>-passtotalcost_g.
      ENDIF.
      <ls_cbstw>-billfrequency = 'M'.
      <ls_cbstw>-billingperiod = <ls_cbstw>-poper+1(2).
      <ls_cbstw>-profitcenter  = <cbli>-profitcenter.
      <ls_cbstw>-businessdivision  = <cbli>-businessdivision.
      <ls_cbstw>-functionalarea    = <cbli>-functionalarea.
* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_cbstw>-cc_uuid = lo_uuid->create_uuid_x16( ).
            DATA(lv_ccuuid) = <ls_cbstw>-cc_uuid.
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
      DATA(localcurr) = <ls_cbstw>-localcurr.
      DATA(groupcurr) = <ls_cbstw>-groupcurr.
      <ls_cbstw>-status = /esrcc/if_calculate_chargeout=>finalized.
      <ls_cbstw>-processtype = /esrcc/if_calculate_chargeout=>adhocprocesstype.   "adhoc chargeout process
      determine_last_day(
       EXPORTING
         iv_ryear    = <ls_cbstw>-ryear
         iv_poper    = <ls_cbstw>-poper
       IMPORTING
         ev_valid_on = DATA(exchdate)
     ).
* Admin data
      <ls_cbstw>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cbstw>-created_at
      ).
      <ls_cbstw>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cbstw>-last_changed_at
      ).

*Create process log entry
      CLEAR lt_proctrl.
      APPEND INITIAL LINE TO lt_proctrl ASSIGNING FIELD-SYMBOL(<ls_proctrl>).
      MOVE-CORRESPONDING <ls_cbstw> TO <ls_proctrl>.
      <ls_proctrl>-billingfreq = <ls_cbstw>-billfrequency.  "Adhoc
      <ls_proctrl>-process = 'ADH'.  "Adhoc
      create_processlogs(
        iv_action = '12'
        it_keys   = lt_proctrl
      ).

**************************************************************************
*Determine Service Cost Share
**************************************************************************
      APPEND INITIAL LINE TO lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).

      <ls_srvshare>-serviceproduct = is_parameters-Serviceproduct.
      <ls_srvshare>-servicetype = ls_serviceproduct-servicetype.
      <ls_srvshare>-transactiongroup = ls_serviceproduct-transactiongroup.
      <ls_srvshare>-costshare = 100.
      <ls_srvshare>-chargeout = ls_rule-chargeout_method.
      <ls_srvshare>-key_version = ls_rule-key_version.
      <ls_srvshare>-consumption_version = ls_rule-consumption_version.
      <ls_srvshare>-capacity_version = ls_rule-capacity_version.
      <ls_srvshare>-cc_uuid = lv_ccuuid.
      <ls_srvshare>-status = /esrcc/if_calculate_chargeout=>finalized.
* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_srvshare>-srv_uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
      DATA(lv_srvuuid) = <ls_srvshare>-srv_uuid.
* Admin data
      <ls_srvshare>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-created_at
      ).
      <ls_srvshare>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-last_changed_at
      ).
**************************************************************************
*Determine Receiver Charge out
**************************************************************************
      LOOP AT it_receivers ASSIGNING FIELD-SYMBOL(<ls_receivers>).

        APPEND INITIAL LINE TO lt_recchg ASSIGNING FIELD-SYMBOL(<ls_recchg>).
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          <ls_recchg>-cc_uuid  = lv_ccuuid.
          <ls_recchg>-srv_uuid = lv_srvuuid.
          TRY.
              <ls_recchg>-rec_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        <ls_recchg>-receiversysid       = <ls_receivers>-sysid.
        <ls_recchg>-receivercompanycode = <ls_receivers>-ccode.
        <ls_recchg>-receivingentity     = <ls_receivers>-legalentity.
        <ls_recchg>-receivercostobject  = <ls_receivers>-costobject.
        <ls_recchg>-receivercostcenter  = <ls_receivers>-costcenter.
        IF totalvalue > 0.
          <ls_recchg>-reckpishare =  ( <ls_receivers>-sharevalue / totalvalue ) * 100.
        ELSE.
          <ls_recchg>-reckpishare         = <ls_receivers>-sharepercent.
        ENDIF.
        <ls_recchg>-invoicingcurrency   = <ls_receivers>-invoicingcurrency.
        IF <ls_cbstw>-legalentity <> <ls_receivers>-legalentity.
          <ls_recchg>-valueaddmarkup      = is_parameters-intervalueaddmarkup.
          <ls_recchg>-passthrumarkup      = is_parameters-interpassthroughmarkup.
        ELSE.
          <ls_recchg>-valueaddmarkup      = is_parameters-intravalueaddmarkup.
          <ls_recchg>-passthrumarkup      = is_parameters-intrapassthroughmarkup.
        ENDIF.
        <ls_recchg>-exchdate            = exchdate.
        <ls_recchg>-status              = /esrcc/if_calculate_chargeout=>finalized.
        <ls_recchg>-invoicestatus       = '01'.  "not started
* Admin data
        <ls_recchg>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_recchg>-created_at
        ).
        <ls_srvshare>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_recchg>-last_changed_at
        ).

**************************************************************************
*Determine Allocation share for traceability
**************************************************************************
        APPEND INITIAL LINE TO lt_allocationshare ASSIGNING FIELD-SYMBOL(<allocationshare>).
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          <allocationshare>-parentuuid  = <ls_recchg>-rec_uuid.
          TRY.
              <allocationshare>-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.

        <allocationshare>-allockey = is_parameters-allocationkey.
        <allocationshare>-weightage = 100.
        <allocationshare>-initialreckpishare = ( <ls_receivers>-sharepercent / 100 ).
        <allocationshare>-reckpishare = ( <ls_receivers>-sharepercent / 100 ).
        <allocationshare>-reckpivalue = <ls_receivers>-sharevalue.

* Admin data
        <allocationshare>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <allocationshare>-created_at
        ).
        <allocationshare>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <allocationshare>-last_changed_at
        ).

**************************************************************************
*Determine Allocation values for traceability
**************************************************************************
        APPEND INITIAL LINE TO lt_allocationvalue ASSIGNING FIELD-SYMBOL(<allocationvalue>).
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          <allocationvalue>-parentuuid  = <allocationshare>-uuid.
          TRY.
              <allocationvalue>-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.

        <allocationvalue>-ryear     = <ls_cbstw>-ryear.
        <allocationvalue>-allockey  = is_parameters-allocationkey.
*        <allocationshare>-initialreckpishare = <ls_receivers>-sharepercent.
        <allocationvalue>-reckpivalue = <ls_receivers>-sharevalue.

* Admin data
        <allocationvalue>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <allocationvalue>-created_at
        ).
        <allocationvalue>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <allocationvalue>-last_changed_at
        ).

      ENDLOOP.



    ENDLOOP.

**************************************************************************
*Update Respective Line items with relevant information
**************************************************************************
    SELECT cbli~* FROM /esrcc/cb_li AS cbli
    INNER JOIN @it_cbli AS itcbli
      ON  cbli~belnr       = itcbli~belnr
     AND  cbli~ryear       = itcbli~ryear
     AND  cbli~poper       = itcbli~poper
     AND  cbli~legalentity = itcbli~legalentity
     AND  cbli~sysid       = itcbli~sysid
     AND  cbli~fplv        = itcbli~fplv
     AND cbli~ccode        = itcbli~ccode
     AND cbli~buzei        = itcbli~buzei
     AND cbli~costobject   = itcbli~costobject
     AND cbli~costelement  = itcbli~costelement
     INTO TABLE @DATA(lt_cbli).

    LOOP AT lt_cbli ASSIGNING FIELD-SYMBOL(<ls_cbli>).
*      <ls_cbli>-usagecal = 'E'.
      <ls_cbli>-status = /esrcc/if_calculate_chargeout=>finalized.
*      <ls_cbli>-reasonid = 7.
      <ls_cbli>-cc_guid = lv_ccuuid.
* Admin data
      <ls_cbli>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cbli>-last_changed_at
      ).
    ENDLOOP.

    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cb_stw.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_recchg.
    MODIFY /esrcc/cb_li     FROM TABLE @lt_cbli.
    MODIFY /esrcc/alocshare FROM TABLE @lt_allocationshare.
    MODIFY /esrcc/alcvalues FROM TABLE @lt_allocationvalue.
  ENDMETHOD.


  METHOD calculate_chargeout.

    DATA lt_rec_chg     TYPE TABLE OF /esrcc/rec_chg.
    DATA lt_rec_share   TYPE TABLE OF /esrcc/alocshare.
    DATA lt_aloc_values TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_procctrl    TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl    TYPE  /esrcc/procctrl.
    DATA ls_wf_leadobj  TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj  TYPE /esrcc/tt_wf_leadingobject.
    DATA lv_valid_from  TYPE /esrcc/validfrom.


*Derive poper from billing frequency customizing
    IF it_poper IS INITIAL.
      derive_poper(
        EXPORTING
          it_keys  = it_keys
        IMPORTING
          et_poper = DATA(_poper)
      ).
    ELSE.
      _poper = it_poper.
    ENDIF.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*validate chargeout
    validate_receiverchargeout(
      EXPORTING
        it_poper = _poper
      IMPORTING
        ev_failed = ev_failed
      CHANGING
        ct_keys  = lt_keys
    ).

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = /esrcc/if_calculate_chargeout=>chargeout
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

*Receiver charge out and markup
    SELECT recshare~*
       FROM /esrcc/i_chargeout_recshare  AS recshare
       INNER JOIN @lt_keys AS keys
          ON recshare~fplv           = keys~fplv
         AND recshare~ryear          = keys~ryear
         AND recshare~sysid          = keys~sysid
         AND recshare~legalentity    = keys~legalentity
         AND recshare~ccode          = keys~ccode
         AND recshare~costobject     = keys~costobject
         AND recshare~costcenter     = keys~costcenter
         AND recshare~serviceproduct = keys~serviceproduct
         WHERE recshare~poper         IN @_poper
         INTO TABLE @DATA(lt_rec_cost).

    CHECK lt_rec_cost IS NOT INITIAL.

*Delete old allocation data in case user re-triggered chargeout without re-open
*  Delete receiver cost
    delete_chargeout(
      it_keys  = it_keys
      it_poper = _poper
    ).

* Create New allocation data
    SELECT DISTINCT
                indkpishare~fplv,
                indkpishare~ryear,
                indkpishare~sysid,
                indkpishare~poper,
                indkpishare~legalentity,
                indkpishare~ccode,
                indkpishare~costobject,
                indkpishare~costcenter,
                indkpishare~serviceproduct,
                indkpishare~ReceiverSysId,
                indkpishare~ReceiverCompanyCode,
                indkpishare~ReceivingEntity,
                indkpishare~ReceiverCostObject,
                indkpishare~ReceiverCostCenter,
                indkpishare~allockey,
                indkpishare~keyversion,
                indkpishare~allocationperiod,
                indkpishare~refperiod,
                indkpishare~weightage,
                indkpishare~reckpivalue,
                indkpishare~initialreckpishare,
                indkpishare~reckpishare
       FROM /esrcc/i_chargeout_indkpishare AS indkpishare
       INNER JOIN @lt_keys AS keys
               ON indkpishare~fplv           = keys~fplv
              AND indkpishare~ryear          = keys~ryear
              AND indkpishare~sysid          = keys~sysid
              AND indkpishare~legalentity    = keys~legalentity
              AND indkpishare~ccode          = keys~ccode
              AND indkpishare~costobject     = keys~costobject
              AND indkpishare~costcenter     = keys~costcenter
              AND indkpishare~serviceproduct = keys~serviceproduct
              WHERE indkpishare~poper        IN @_poper
              ORDER BY  indkpishare~fplv,
                        indkpishare~ryear,
                        indkpishare~sysid,
                        indkpishare~poper,
                        indkpishare~legalentity,
                        indkpishare~ccode,
                        indkpishare~costobject,
                        indkpishare~costcenter,
                        indkpishare~serviceproduct,
                        indkpishare~ReceiverSysId,
                        indkpishare~ReceiverCompanyCode,
                        indkpishare~ReceivingEntity,
                        indkpishare~ReceiverCostObject,
                        indkpishare~ReceiverCostCenter
              INTO TABLE @DATA(lt_allocation_share).

    SELECT DISTINCT
             indallocvalues~fplv,
             indallocvalues~ryear,
             indallocvalues~sysid,
             indallocvalues~poper,
             indallocvalues~legalentity,
             indallocvalues~ccode,
             indallocvalues~costobject,
             indallocvalues~costcenter,
             indallocvalues~serviceproduct,
             indallocvalues~ReceiverSysId,
             indallocvalues~ReceiverCompanyCode,
             indallocvalues~ReceivingEntity,
             indallocvalues~ReceiverCostObject,
             indallocvalues~ReceiverCostCenter,
             indallocvalues~keyversion,
             indallocvalues~allockey,
             indallocvalues~allocationperiod,
             indallocvalues~refpoper,
             indallocvalues~refperiod,
             indallocvalues~reckpivalue
        FROM /esrcc/i_indallocvalues AS indallocvalues
        INNER JOIN @lt_keys AS keys
                ON  indallocvalues~fplv        = keys~fplv
               AND  indallocvalues~ryear       = keys~ryear
               AND  indallocvalues~sysid       = keys~sysid
               AND  indallocvalues~legalentity = keys~legalentity
               AND  indallocvalues~ccode       = keys~ccode
               AND  indallocvalues~costobject  = keys~costobject
               AND  indallocvalues~costcenter  = keys~costcenter
               AND  indallocvalues~serviceproduct = keys~serviceproduct
               WHERE  indallocvalues~poper      IN @_poper
               ORDER BY indallocvalues~fplv,
                        indallocvalues~ryear,
                        indallocvalues~sysid,
                        indallocvalues~poper,
                        indallocvalues~legalentity,
                        indallocvalues~ccode,
                        indallocvalues~costobject,
                        indallocvalues~costcenter,
                        indallocvalues~serviceproduct,
                        indallocvalues~ReceiverSysId,
                        indallocvalues~ReceiverCompanyCode,
                        indallocvalues~ReceivingEntity,
                        indallocvalues~ReceiverCostObject,
                        indallocvalues~ReceiverCostCenter,
                        indallocvalues~keyversion,
                        indallocvalues~allockey
               INTO TABLE @DATA(lt_allocation_values).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_rec_cost INTO DATA(ls_rec_cost)
                                GROUP BY ( legalentity = ls_rec_cost-legalentity ) INTO DATA(entitygroup).


      LOOP AT GROUP entitygroup ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).

        APPEND INITIAL LINE TO lt_rec_chg ASSIGNING FIELD-SYMBOL(<ls_rec_chg>).
        MOVE-CORRESPONDING <ls_rec_cost> TO <ls_rec_chg>.

        IF wf_active EQ abap_true.
          CLEAR ls_wf_leadobj.
          MOVE-CORRESPONDING <ls_rec_cost> TO ls_wf_leadobj.
          IF <key> IS ASSIGNED.
            ls_wf_leadobj-billfrequency = <key>-billingfreq.
            ls_wf_leadobj-billingperiod = <key>-billingperiod.
          ENDIF.
          APPEND ls_wf_leadobj TO lt_wf_leadobj.
          <ls_rec_chg>-status = /esrcc/if_calculate_chargeout=>inprocess.   "In Process
        ELSE.
          <ls_rec_chg>-status = /esrcc/if_calculate_chargeout=>approved.   "Approved
        ENDIF.

* Admin data
        <ls_rec_chg>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_rec_chg>-created_at
        ).
        <ls_rec_chg>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_rec_chg>-last_changed_at
        ).

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <ls_rec_chg>-rec_uuid = lo_uuid->create_uuid_x16( ).
              <ls_rec_chg>-commentid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.

* get exchange rate day
        determine_last_day(
          EXPORTING
            iv_ryear    = <ls_rec_cost>-ryear
            iv_poper    = <ls_rec_cost>-poper
          IMPORTING
            ev_valid_on = <ls_rec_chg>-exchdate
        ).

* Assign the 16 digit unique identifier for allocation share
        READ TABLE lt_allocation_share TRANSPORTING NO FIELDS WITH KEY
                                           fplv           = <ls_rec_cost>-fplv
                                          ryear           = <ls_rec_cost>-ryear
                                          sysid           = <ls_rec_cost>-sysid
                                          poper           = <ls_rec_cost>-poper
                                          legalentity     = <ls_rec_cost>-legalentity
                                          ccode           = <ls_rec_cost>-ccode
                                          costobject      = <ls_rec_cost>-costobject
                                          costcenter      = <ls_rec_cost>-costcenter
                                          serviceproduct  = <ls_rec_cost>-serviceproduct
                                          ReceiverSysId   = <ls_rec_cost>-receiversysid
                                          ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
                                          ReceivingEntity = <ls_rec_cost>-receivingentity
                                          ReceiverCostObject = <ls_rec_cost>-receivercostobject
                                          ReceiverCostCenter = <ls_rec_cost>-receivercostcenter
                                          BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_allocation_share ASSIGNING FIELD-SYMBOL(<ls_allocation_share>) FROM sy-tabix.

            IF <ls_allocation_share>-fplv           = <ls_rec_cost>-fplv
              AND <ls_allocation_share>-ryear       = <ls_rec_cost>-ryear
              AND <ls_allocation_share>-sysid       = <ls_rec_cost>-sysid
              AND <ls_allocation_share>-poper       = <ls_rec_cost>-poper
              AND <ls_allocation_share>-legalentity = <ls_rec_cost>-legalentity
              AND <ls_allocation_share>-ccode       = <ls_rec_cost>-ccode
              AND <ls_allocation_share>-costobject  = <ls_rec_cost>-costobject
              AND <ls_allocation_share>-costcenter  = <ls_rec_cost>-costcenter
              AND <ls_allocation_share>-serviceproduct      = <ls_rec_cost>-serviceproduct
              AND <ls_allocation_share>-ReceiverSysId       = <ls_rec_cost>-receiversysid
              AND <ls_allocation_share>-ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
              AND <ls_allocation_share>-ReceivingEntity     = <ls_rec_cost>-receivingentity
              AND <ls_allocation_share>-ReceiverCostObject  = <ls_rec_cost>-receivercostobject
              AND <ls_allocation_share>-ReceiverCostCenter  = <ls_rec_cost>-receivercostcenter.

              APPEND INITIAL LINE TO lt_rec_share ASSIGNING FIELD-SYMBOL(<ls_rec_share>).
              MOVE-CORRESPONDING <ls_allocation_share> TO <ls_rec_share>.
              IF lo_uuid IS BOUND.
                TRY.
                    <ls_rec_share>-uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
                <ls_rec_share>-parentuuid = <ls_rec_chg>-rec_uuid.
              ENDIF.

* Assign the 16 digit unique identifier for allocation values
              READ TABLE lt_allocation_values TRANSPORTING NO FIELDS WITH KEY
                                                 fplv            = <ls_rec_cost>-fplv
                                                 ryear            = <ls_rec_cost>-ryear
                                                 sysid            = <ls_rec_cost>-sysid
                                                 poper            = <ls_rec_cost>-poper
                                                 legalentity      = <ls_rec_cost>-legalentity
                                                 ccode            = <ls_rec_cost>-ccode
                                                 costobject       = <ls_rec_cost>-costobject
                                                 costcenter       = <ls_rec_cost>-costcenter
                                                 serviceproduct   = <ls_rec_cost>-serviceproduct
                                                 ReceiverSysId    = <ls_rec_cost>-receiversysid
                                                 ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
                                                 ReceivingEntity  = <ls_rec_cost>-receivingentity
                                                 ReceiverCostObject = <ls_rec_cost>-receivercostobject
                                                 ReceiverCostCenter = <ls_rec_cost>-receivercostcenter
                                                 KeyVersion         = <ls_allocation_share>-KeyVersion
                                                 Allockey           = <ls_allocation_share>-Allockey
                                                 BINARY SEARCH.
              IF sy-subrc = 0.
                LOOP AT lt_allocation_values ASSIGNING FIELD-SYMBOL(<ls_allocation_values>) FROM sy-tabix.

                  IF  <ls_allocation_values>-fplv                 = <ls_rec_cost>-fplv
                      AND <ls_allocation_values>-ryear            = <ls_rec_cost>-ryear
                      AND <ls_allocation_values>-sysid            = <ls_rec_cost>-sysid
                      AND <ls_allocation_values>-poper            = <ls_rec_cost>-poper
                      AND <ls_allocation_values>-legalentity      = <ls_rec_cost>-legalentity
                      AND <ls_allocation_values>-ccode            = <ls_rec_cost>-ccode
                      AND <ls_allocation_values>-costobject       = <ls_rec_cost>-costobject
                      AND <ls_allocation_values>-costcenter       = <ls_rec_cost>-costcenter
                      AND <ls_allocation_values>-serviceproduct   = <ls_rec_cost>-serviceproduct
                      AND <ls_allocation_values>-ReceiverSysId    = <ls_rec_cost>-receiversysid
                      AND <ls_allocation_values>-ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
                      AND <ls_allocation_values>-ReceivingEntity  = <ls_rec_cost>-receivingentity
                      AND <ls_allocation_values>-ReceiverCostObject = <ls_rec_cost>-receivercostobject
                      AND <ls_allocation_values>-ReceiverCostCenter = <ls_rec_cost>-receivercostcenter
                      AND <ls_allocation_values>-keyversion         = <ls_allocation_share>-KeyVersion
                      AND <ls_allocation_values>-allockey           = <ls_allocation_share>-Allockey.


                    APPEND INITIAL LINE TO lt_aloc_values ASSIGNING FIELD-SYMBOL(<ls_aloc_values>).
                    MOVE-CORRESPONDING <ls_allocation_values> TO <ls_aloc_values>.
                    IF lo_uuid IS BOUND.
                      TRY.
                          <ls_aloc_values>-uuid = lo_uuid->create_uuid_x16( ).
                        CATCH cx_uuid_error.
                          "handle exception
                      ENDTRY.
                      <ls_aloc_values>-parentuuid = <ls_rec_share>-uuid.
                    ENDIF.
                  ELSE.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ENDIF.
            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      MODIFY /esrcc/rec_chg   FROM TABLE @lt_rec_chg.
      MODIFY /esrcc/alocshare FROM TABLE @lt_rec_share.
      MODIFY /esrcc/alcvalues FROM TABLE @lt_aloc_values.
      CLEAR: lt_aloc_values, lt_rec_share, lt_rec_chg.
    ENDLOOP.

    IF wf_active EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = /esrcc/if_calculate_chargeout=>chargeout
      ).
    ENDIF.

    LOOP AT lt_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                    AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = /esrcc/if_calculate_chargeout=>chargeout.    "Charge-out
      IF wf_active EQ abap_false.
        ls_procctrl-status = /esrcc/if_calculate_chargeout=>chargeout_approved.     "Charge-out approved
      ELSE.
        ls_procctrl-status = /esrcc/if_calculate_chargeout=>chargeout_inprocess.     "Charge-out In Process
      ENDIF.

* Admin data
      ls_procctrl-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-created_at
      ).
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_calculat_chargeout
      it_keys   = lt_procctrl
    ).

    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.

    CLEAR: lt_procctrl, lt_rec_chg, lt_rec_share, lt_aloc_values.

  ENDMETHOD.


  METHOD calculate_costbase.

    DATA lt_cc_cost    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_cb_li      TYPE TABLE OF /esrcc/cb_li.
    DATA lt_tmp_cost   TYPE TABLE OF /esrcc/cb_stw.

*Derive poper from billing frequency customizing
    IF it_poper IS INITIAL.
      derive_poper(
        EXPORTING
          it_keys  = it_keys
        IMPORTING
          et_poper = DATA(_poper)
      ).
    ELSE.
      _poper = it_poper.
    ENDIF.

*** validate if costbase data was derived
    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE costcenter IS INITIAL.

    validate_costbase(
      EXPORTING
        it_poper = _poper
      IMPORTING
        ev_failed = ev_failed
      CHANGING
        ct_keys  = lt_keys
    ).

    CHECK lt_keys IS NOT INITIAL.

    SELECT coststw~* FROM /esrcc/i_costbase_stewardship AS coststw
            INNER JOIN @lt_keys AS keys
                    ON  coststw~fplv      = keys~fplv
                   AND coststw~ryear      = keys~ryear
                   AND coststw~sysid      = keys~sysid
                   AND coststw~legalentity = keys~legalentity
                   AND coststw~ccode      = keys~ccode
                   AND coststw~costobject = keys~costobject
                   AND coststw~costcenter = keys~costcenter
                   WHERE coststw~poper     IN @_poper
                   INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.

    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = /esrcc/if_calculate_chargeout=>costbase
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).

    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
           IMPORTING
             time_stamp = DATA(created_at)
         ).

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).




    LOOP AT lt_cc_cost INTO DATA(ls_cc_cost)
                       GROUP BY ( legalentity = ls_cc_cost-legalentity ) INTO DATA(entitygroup).

      LOOP AT GROUP entitygroup ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <ls_cc_cost>-cc_uuid = lo_uuid->create_uuid_x16( ).
              <ls_cc_cost>-commentid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.

        <ls_cc_cost>-billingperiod = lt_keys[ 1 ]-billingperiod.
        <ls_cc_cost>-processtype = /esrcc/if_calculate_chargeout=>standardprocesstype.
* Admin data
        <ls_cc_cost>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_cc_cost>-created_at
        ).
        <ls_cc_cost>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_cc_cost>-last_changed_at
        ).

        IF wf_active EQ abap_true.
          CLEAR ls_wf_leadobj.
          MOVE-CORRESPONDING <ls_cc_cost> TO ls_wf_leadobj.
          APPEND ls_wf_leadobj TO lt_wf_leadobj.
          <ls_cc_cost>-status = /esrcc/if_calculate_chargeout=>inprocess.
        ELSE.
          <ls_cc_cost>-status = /esrcc/if_calculate_chargeout=>approved.   "Approval
        ENDIF.


        APPEND <ls_cc_cost> TO lt_tmp_cost.

      ENDLOOP.

*Finalize cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        SELECT cb~*,
               ik~cc_uuid AS cc_guid,
               @sy-uname AS last_changed_by,
               @last_changed_at AS last_changed_at
          FROM /esrcc/cb_li AS cb
          INNER JOIN @lt_tmp_cost AS ik
            ON cb~fplv        = ik~fplv
           AND cb~ryear       = ik~ryear
           AND cb~sysid       = ik~sysid
           AND cb~legalentity = ik~legalentity
           AND cb~ccode       = ik~ccode
           AND cb~costobject  = ik~costobject
           AND cb~costcenter  = ik~costcenter
           AND cb~poper        = ik~poper
          AND cb~status <> @/esrcc/if_calculate_chargeout=>finalized
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.

      CLEAR: lt_tmp_cost, lt_cb_li.
    ENDLOOP.

    IF wf_active EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = /esrcc/if_calculate_chargeout=>costbase
      ).
    ENDIF.


    lt_procctrl = VALUE #(
                  FOR keys IN lt_keys
                  (
                    sysid          = keys-sysid
                    fplv           = keys-fplv
                    ryear          = keys-ryear
                    billingfreq    = keys-billingfreq
                    billingperiod  = keys-billingperiod
                    legalentity    = keys-legalentity
                    ccode          = keys-ccode
                    costobject     = keys-costobject
                    costcenter     = keys-costcenter
                    serviceproduct = keys-serviceproduct
                    process        = /esrcc/if_calculate_chargeout=>costbase
                    status         = COND #( WHEN wf_active = abap_false
                                             THEN /esrcc/if_calculate_chargeout=>costbase_approved
                                             ELSE /esrcc/if_calculate_chargeout=>costbase_inprocess )
                    created_by      = sy-uname
                    last_changed_by = sy-uname
                    created_at      = created_at
                    last_changed_at = last_changed_at ) ).

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_calculate_costbase
      it_keys   = lt_procctrl
    ).

*Delete old as user might have re-triggered costbase & stewardship calculation
    delete_costbase(
      it_keys  = lt_keys
      it_poper = _poper
    ).

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cb_stw FROM TABLE @lt_cc_cost.

    FREE: lt_cc_cost,
          lt_tmp_cost,
          lt_procctrl,
          lt_cb_li.

  ENDMETHOD.


  METHOD calculate_servicecostshare.

    DATA lt_srvshare   TYPE TABLE OF /esrcc/srv_share.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.

*Derive poper from billing frequency customizing
    IF it_poper IS INITIAL.
      derive_poper(
        EXPORTING
          it_keys  = it_keys
        IMPORTING
          et_poper = DATA(_poper)
      ).
    ELSE.
      _poper = it_poper.
    ENDIF.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*validate service cost share calculation
    validate_serviceproductcosting(
      EXPORTING
        it_poper = _poper
      IMPORTING
        ev_failed = ev_failed
      CHANGING
        ct_keys  = lt_keys
    ).

    CHECK lt_keys IS NOT INITIAL.

    SELECT DISTINCT cu~*
      FROM /esrcc/i_chargeout_unitcost AS cu
      INNER JOIN @lt_keys AS lk
        ON cu~fplv          = lk~fplv
       AND cu~ryear         = lk~ryear
       AND cu~sysid         = lk~sysid
       AND cu~legalentity   = lk~legalentity
       AND cu~ccode         = lk~ccode
       AND cu~costobject    = lk~costobject
       AND cu~costcenter    = lk~costcenter
       AND cu~serviceproduct = lk~serviceproduct
    WHERE cu~poper IN @_poper
      AND cu~serviceproduct IS NOT INITIAL
    INTO TABLE @DATA(lt_srv_cost).

    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = /esrcc/if_calculate_chargeout=>serviceshare
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

    CHECK lt_srv_cost IS NOT INITIAL.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>)
                        WHERE ServiceProduct IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).

      MOVE-CORRESPONDING <ls_srv_cost> TO <ls_srvshare>.
      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        MOVE-CORRESPONDING <ls_srv_cost> TO ls_wf_leadobj.
        IF <key> IS ASSIGNED.
          ls_wf_leadobj-billfrequency = <key>-billingfreq.
          ls_wf_leadobj-billingperiod = <key>-billingperiod.
        ENDIF.
        APPEND ls_wf_leadobj TO lt_wf_leadobj.
        <ls_srvshare>-status = /esrcc/if_calculate_chargeout=>inprocess.   "In process
      ELSE.
        <ls_srvshare>-status = /esrcc/if_calculate_chargeout=>approved.   "Approved
      ENDIF.

* Admin data
      <ls_srvshare>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-created_at
      ).
      <ls_srvshare>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-last_changed_at
      ).

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_srvshare>-srv_uuid = lo_uuid->create_uuid_x16( ).
            <ls_srvshare>-commentid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

    ENDLOOP.

    IF wf_active EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = /esrcc/if_calculate_chargeout=>serviceshare
      ).
    ENDIF.



    LOOP AT lt_keys ASSIGNING <key>.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = /esrcc/if_calculate_chargeout=>serviceshare.
      IF wf_active =  abap_false.
        ls_procctrl-status = /esrcc/if_calculate_chargeout=>serviceshare_approved.     "Stewardship Approved
      ELSE.
        ls_procctrl-status = /esrcc/if_calculate_chargeout=>serviceshare_inprocess.     "Stewardship In Process
      ENDIF.

* Admin data
      ls_procctrl-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-created_at
      ).
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct
      it_keys   = lt_procctrl
    ).

*delete old service product share as user might re-trigger calculations again
*  Delete service cost
    delete_servicecostshare(
      it_keys  = it_keys
      it_poper = _poper
    ).

    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.

    CLEAR: lt_procctrl, lt_srvshare, lt_srv_cost.

  ENDMETHOD.


  METHOD create_loginstance.

    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitem       TYPE /esrcc/log_item.

    IF key-serviceproduct IS INITIAL.

      READ TABLE procctrl ASSIGNING FIELD-SYMBOL(<procctrl>) WITH KEY fplv           = key-fplv
                                                                        ryear         = key-ryear
                                                                        sysid         = key-sysid
                                                                        legalentity   = key-legalentity
                                                                        ccode         = key-ccode
                                                                        costobject    = key-costobject
                                                                        costcenter    = key-costcenter
                                                                        billingfreq   = key-billingfreq
                                                                        billingperiod = key-billingperiod
                                                                        process       = process BINARY SEARCH.

      IF sy-subrc = 0 AND <procctrl>-log_header_uuid IS NOT INITIAL.
* check if logid is already available then call resue instance to get the existence instance
        /esrcc/cl_application_logs=>reuse_instance(
          EXPORTING
            log_header_id = <procctrl>-log_header_uuid
          RECEIVING
            instance      = loginstance
        ).

*    Clear old messages
        loginstance->clear_messages( ).

      ELSE.
*  create a new instance
        /esrcc/cl_application_logs=>create_instance(
          EXPORTING
            deter_save = abap_true
          RECEIVING
            instance   = loginstance
        ).

*    set log header info
        loghdr-application      = 'EXE'.
        loghdr-sub_application  = process.
        loghdr-company_code     = key-ccode.
        loghdr-legal_entity     = key-legalentity.
        loghdr-planning_version = key-fplv.
        loghdr-reporting_year   = key-ryear.
        loghdr-system_id        = key-sysid.
        loginstance->set_log_header_info( log_header = loghdr ).
      ENDIF.

*  set header message about the object
      CLEAR logitem.
      logitem-message_id = '/ESRCC/EXECCOCKPIT'.
      logitem-message_number = '022'.
      logitem-message_type = 'I'.
      CONCATENATE key-fplv key-ryear key-billingfreq key-billingperiod INTO DATA(perioddetials) SEPARATED BY '-'.
      CONCATENATE 'Period:' perioddetials INTO logitem-message_v1 SEPARATED BY space.
      CONCATENATE key-sysid key-legalentity key-ccode INTO logitem-message_v2 SEPARATED BY '/'.
      CONCATENATE 'Entity:' logitem-message_v2 INTO logitem-message_v2 SEPARATED BY space.
      CONCATENATE key-costobject key-costcenter INTO logitem-message_v3 SEPARATED BY '/'.
      CONCATENATE 'Object:' logitem-message_v3 INTO logitem-message_v3 SEPARATED BY space.
      loginstance->add_message(
        EXPORTING
          log_message      = logitem
      ).
    ELSE.

      READ TABLE procctrl ASSIGNING <procctrl> WITH KEY fplv             = key-fplv
                                                        ryear          = key-ryear
                                                        sysid          = key-sysid
                                                        legalentity    = key-legalentity
                                                        ccode          = key-ccode
                                                        costobject     = key-costobject
                                                        costcenter     = key-costcenter
                                                        serviceproduct = key-serviceproduct
                                                        billingfreq    = key-billingfreq
                                                        billingperiod  = key-billingperiod
                                                        process        = process BINARY SEARCH.

      IF sy-subrc = 0 AND <procctrl>-log_header_uuid IS NOT INITIAL.
* check if logid is already available then call resue instance to get the existence instance
        /esrcc/cl_application_logs=>reuse_instance(
          EXPORTING
            log_header_id = <procctrl>-log_header_uuid
          RECEIVING
            instance      = loginstance
        ).

*    Clear old messages
        loginstance->clear_messages( ).

      ELSE.
*  create a new instance
        /esrcc/cl_application_logs=>create_instance(
          EXPORTING
            deter_save = abap_true
          RECEIVING
            instance   = loginstance
        ).

*    set log header info
        loghdr-application      = 'EXE'.
        loghdr-sub_application  = process.
        loghdr-company_code     = key-ccode.
        loghdr-legal_entity     = key-legalentity.
        loghdr-planning_version = key-fplv.
        loghdr-reporting_year   = key-ryear.
        loghdr-system_id        = key-sysid.
        loginstance->set_log_header_info( log_header = loghdr ).
      ENDIF.

*  set header message about the object
      CLEAR logitem.
      logitem-message_id = '/ESRCC/EXECCOCKPIT'.
      logitem-message_number = '022'.
      logitem-message_type = 'I'.
      CONCATENATE key-fplv key-ryear key-billingfreq key-billingperiod INTO perioddetials SEPARATED BY '-'.
      CONCATENATE 'Period:' perioddetials INTO logitem-message_v1 SEPARATED BY space.
      CONCATENATE key-sysid key-legalentity key-ccode INTO logitem-message_v2 SEPARATED BY '/'.
      CONCATENATE 'Entity:' logitem-message_v2 INTO logitem-message_v2 SEPARATED BY space.
      CONCATENATE key-costobject key-costcenter key-serviceproduct INTO logitem-message_v3 SEPARATED BY '/'.
      CONCATENATE 'Object:' logitem-message_v3 INTO logitem-message_v3 SEPARATED BY space.
      loginstance->add_message(
        EXPORTING
          log_message      = logitem
      ).

    ENDIF.
  ENDMETHOD.


  METHOD create_processlogs.

    DATA processlog TYPE /esrcc/proclogs.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<procctrl>).
      MOVE-CORRESPONDING <procctrl> TO processlog.
* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            processlog-uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

      processlog-action = iv_action.

* Admin data
      processlog-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = processlog-created_at
      ).
      processlog-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = processlog-last_changed_at
      ).

      APPEND processlog TO et_processlogs.

    ENDLOOP.

    MODIFY /esrcc/proclogs FROM TABLE @et_processlogs.

  ENDMETHOD.


  METHOD delete_adhoc_chargeout.

    DATA lt_proctrl TYPE TABLE OF /esrcc/procctrl.

    IF id IS NOT INITIAL.
      SELECT * FROM /esrcc/cb_li WHERE cc_guid = @id
                                 INTO TABLE @DATA(lt_cbli).
      LOOP AT lt_cbli ASSIGNING FIELD-SYMBOL(<ls_cbli>).

        CLEAR <ls_cbli>-cc_guid.
        <ls_cbli>-status = 'A'.   "Approved
* Admin data
        <ls_cbli>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_cbli>-last_changed_at
        ).
      ENDLOOP.

      IF lt_cbli IS NOT INITIAL.

*Create process log entry
        CLEAR lt_proctrl.
        APPEND INITIAL LINE TO lt_proctrl ASSIGNING FIELD-SYMBOL(<ls_proctrl>).
        MOVE-CORRESPONDING <ls_cbli> TO <ls_proctrl>.
        <ls_proctrl>-process = 'ADH'.  "Adhoc
        /esrcc/cl_calculate_chargeout=>create_processlogs(
          iv_action = '13'
          it_keys   = lt_proctrl
        ).

      ENDIF.

      DATA(lv_ccuuid) = id.

      SELECT * FROM /esrcc/rec_chg WHERE cc_uuid = @id INTO TABLE @DATA(lt_receievers).

      IF lt_receievers IS NOT INITIAL.
        SELECT * FROM /esrcc/alocshare AS alocshare
            INNER JOIN /esrcc/rec_chg AS receievers
            ON receievers~rec_uuid = alocshare~parentuuid
            WHERE receievers~cc_uuid = @id INTO TABLE @DATA(lt_alocshare).
        IF lt_alocshare IS NOT INITIAL.
          SELECT * FROM /esrcc/alcvalues AS alocvalues
           INNER JOIN /esrcc/alocshare AS alocshare
            ON alocshare~uuid = alocvalues~parentuuid
            INNER JOIN /esrcc/rec_chg AS receievers
            ON receievers~rec_uuid = alocshare~parentuuid
           WHERE receievers~cc_uuid = @id INTO TABLE @DATA(lt_alcvalues).
        ENDIF.
      ENDIF.


      DELETE /esrcc/alcvalues FROM TABLE @lt_alcvalues.
      DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
      DELETE FROM /esrcc/rec_chg WHERE cc_uuid = @lv_ccuuid.
      DELETE FROM /esrcc/srv_share WHERE cc_uuid = @lv_ccuuid.
      DELETE FROM /esrcc/cb_stw WHERE cc_uuid = @lv_ccuuid.
      IF lt_cbli IS NOT INITIAL.
        MODIFY /esrcc/cb_li FROM TABLE @lt_cbli.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD delete_chargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    LOOP AT it_keys INTO DATA(keys) GROUP BY
                          ( legalentity = keys-legalentity ) INTO DATA(entitygroup).

      LOOP AT GROUP entitygroup ASSIGNING FIELD-SYMBOL(<keys>).
        APPEND <keys> TO lt_keys.
      ENDLOOP.
      IF iv_costbasereopen = abap_true.
        SELECT rec_chg~*
        FROM /esrcc/cb_stw AS cb_stw
        INNER JOIN /esrcc/srv_share AS srv_share
          ON srv_share~cc_uuid = cb_stw~cc_uuid
        INNER JOIN /esrcc/rec_chg AS rec_chg
          ON rec_chg~cc_uuid = cb_stw~cc_uuid
         AND rec_chg~srv_uuid = srv_share~srv_uuid
         AND rec_chg~status  NE @/esrcc/if_calculate_chargeout=>approval_pending
        INNER JOIN @lt_keys AS ik
          ON cb_stw~fplv         = ik~fplv
         AND cb_stw~ryear        = ik~ryear
         AND cb_stw~sysid        = ik~sysid
         AND cb_stw~legalentity  = ik~legalentity
         AND cb_stw~ccode        = ik~ccode
         AND cb_stw~costobject   = ik~costobject
         AND cb_stw~costcenter   = ik~costcenter
         WHERE cb_stw~poper IN @it_poper
         INTO TABLE @DATA(lt_recshare).
      ELSE.
        SELECT rec_chg~*
        FROM /esrcc/cb_stw AS cb_stw
        INNER JOIN /esrcc/srv_share AS srv_share
          ON srv_share~cc_uuid = cb_stw~cc_uuid
        INNER JOIN /esrcc/rec_chg AS rec_chg
          ON rec_chg~cc_uuid = cb_stw~cc_uuid
         AND rec_chg~srv_uuid = srv_share~srv_uuid
         AND rec_chg~status  NE @/esrcc/if_calculate_chargeout=>approval_pending
        INNER JOIN @lt_keys AS ik
          ON cb_stw~fplv         = ik~fplv
         AND cb_stw~ryear        = ik~ryear
         AND cb_stw~sysid        = ik~sysid
         AND cb_stw~legalentity  = ik~legalentity
         AND cb_stw~ccode        = ik~ccode
         AND cb_stw~costobject   = ik~costobject
         AND cb_stw~costcenter   = ik~costcenter
         WHERE cb_stw~poper IN @it_poper
           AND srv_share~serviceproduct = ik~serviceproduct
          INTO TABLE @lt_recshare.
      ENDIF.

      IF lt_recshare IS NOT INITIAL.
*  Delete Service Allocation
        SELECT alocshare~*
          FROM /esrcc/alocshare AS alocshare
          INNER JOIN @lt_recshare AS recshare
            ON alocshare~parentuuid = recshare~rec_uuid
        INTO TABLE @DATA(lt_alocshare).
        IF lt_alocshare IS NOT INITIAL.
          SELECT *
            FROM /esrcc/alcvalues AS alcvalues
            INNER JOIN @lt_alocshare AS alocshare
              ON alcvalues~parentuuid = alocshare~uuid
          INTO TABLE @DATA(lt_alocvalues).
        ENDIF.


        DELETE /esrcc/rec_chg   FROM TABLE @lt_recshare.
        DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
        DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.
      ENDIF.

      CLEAR: lt_keys,lt_recshare, lt_alocshare, lt_alocvalues.
    ENDLOOP.
  ENDMETHOD.


  METHOD delete_costbase.

    DATA lt_tmp_cost TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_cb_li    TYPE TABLE OF /esrcc/cb_li.
    DATA lv_refguid  TYPE sysuuid_x16.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT cb_stw~*
      FROM /esrcc/cb_stw AS cb_stw
      INNER JOIN @it_keys AS it_keys
        ON cb_stw~fplv         = it_keys~fplv
       AND cb_stw~ryear        = it_keys~ryear
       AND cb_stw~sysid        = it_keys~sysid
       AND cb_stw~legalentity  = it_keys~legalentity
       AND cb_stw~ccode        = it_keys~ccode
       AND cb_stw~costobject   = it_keys~costobject
       AND cb_stw~costcenter   = it_keys~costcenter
    WHERE cb_stw~poper IN @it_poper
    INTO TABLE @DATA(lt_cc_cost).

*Finalize cost base line items.
    LOOP AT lt_cc_cost INTO DATA(ls_cc_cost)
                       GROUP BY ( legalentity = ls_cc_cost-legalentity ) INTO DATA(entitygroup).

      CLEAR lt_tmp_cost.
      LOOP AT GROUP entitygroup INTO DATA(cc_cost).
        APPEND cc_cost TO lt_tmp_cost.
      ENDLOOP.

*Finalize cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        CLEAR lt_cb_li.
        SELECT cb~*,
               @/esrcc/if_calculate_chargeout=>approved AS status,
               @lv_refguid AS cc_guid,
               @sy-uname AS last_changed_by,
               @last_changed_at AS last_changed_at
          FROM /esrcc/cb_li AS cb
          INNER JOIN @lt_tmp_cost AS ik
            ON cb~fplv        = ik~fplv
           AND cb~ryear       = ik~ryear
           AND cb~sysid       = ik~sysid
           AND cb~legalentity = ik~legalentity
           AND cb~ccode       = ik~ccode
           AND cb~costobject  = ik~costobject
           AND cb~costcenter  = ik~costcenter
           AND cb~poper       = ik~poper
           AND cb~status      = @/esrcc/if_calculate_chargeout=>finalized
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.

    ENDLOOP.

    DELETE /esrcc/cb_stw   FROM TABLE @lt_cc_cost.

    CLEAR: lt_cc_cost,
           lt_tmp_cost,
           lt_cb_li.

  ENDMETHOD.


  METHOD delete_servicecostshare.

    IF iv_costbasereopen = abap_true.
      SELECT srv_share~*
      FROM /esrcc/cb_stw AS cb_stw
      INNER JOIN /esrcc/srv_share AS srv_share
        ON cb_stw~cc_uuid = srv_share~cc_uuid
      INNER JOIN @it_keys AS it_keys
        ON cb_stw~fplv         = it_keys~fplv
       AND cb_stw~ryear        = it_keys~ryear
       AND cb_stw~sysid        = it_keys~sysid
       AND cb_stw~legalentity  = it_keys~legalentity
       AND cb_stw~ccode        = it_keys~ccode
       AND cb_stw~costobject   = it_keys~costobject
       AND cb_stw~costcenter   = it_keys~costcenter
    WHERE cb_stw~poper IN @it_poper
    INTO TABLE @DATA(lt_srvshare).
    ELSE.
      SELECT srv_share~*
      FROM /esrcc/cb_stw AS cb_stw
      INNER JOIN /esrcc/srv_share AS srv_share
        ON cb_stw~cc_uuid = srv_share~cc_uuid
      INNER JOIN @it_keys AS it_keys
        ON cb_stw~fplv         = it_keys~fplv
       AND cb_stw~ryear        = it_keys~ryear
       AND cb_stw~sysid        = it_keys~sysid
       AND cb_stw~legalentity  = it_keys~legalentity
       AND cb_stw~ccode        = it_keys~ccode
       AND cb_stw~costobject   = it_keys~costobject
       AND cb_stw~costcenter   = it_keys~costcenter
       AND srv_share~serviceproduct = it_keys~serviceproduct
    WHERE cb_stw~poper IN @it_poper
    INTO TABLE @lt_srvshare.
    ENDIF.

    DELETE /esrcc/srv_share FROM TABLE @lt_srvshare.

    CLEAR lt_srvshare.
  ENDMETHOD.


  METHOD delete_virtual_postings.

    SELECT *
      FROM /esrcc/cb_li AS cb
      INNER JOIN @it_keys AS ik
        ON cb~fplv                 = ik~fplv
       AND cb~ryear                = ik~ryear
       AND cb~posting_sysid        = ik~sysid
       AND cb~posting_legalentity  = ik~legalentity
       AND cb~posting_ccode        = ik~ccode
       AND cb~posting_costobject   = ik~costobject
       AND cb~posting_costcenter   = ik~costcenter
    WHERE cb~poper IN @it_poper
      AND cb~value_source = 'SCC'
    INTO TABLE @DATA(lt_costbase).

    DELETE /esrcc/cb_li FROM TABLE @lt_costbase.

  ENDMETHOD.


  METHOD derive_poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @et_poper.
    ENDIF.

  ENDMETHOD.


  METHOD determine_delta_chargeout.

    DATA lt_recsharedelta TYPE TABLE OF /esrcc/rec_chg.

*Handling of delta for direct Scenario
*If there is cost base which is not allocated 100% due to difference between consumption & planning
* for a period then allocate that cost base and remaining comsumption to a dummy receiver

*get total share of allocated to all receivers
    SELECT DISTINCT
           rec_chg~cc_uuid,
           rec_chg~srv_uuid,
           reckpi,
           valueaddmarkup,
           passthrumarkup
          FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
            ON cb_stw~cc_uuid = srv_share~cc_uuid
           AND srv_share~chargeout = 'D'
          INNER JOIN /esrcc/rec_chg AS rec_chg
            ON cb_stw~cc_uuid = rec_chg~cc_uuid
           AND srv_share~srv_uuid = rec_chg~srv_uuid
          INNER JOIN @it_keys AS ik
            ON cb_stw~fplv          = ik~fplv
           AND cb_stw~ryear         = ik~ryear
           AND cb_stw~sysid         = ik~sysid
           AND cb_stw~legalentity   = ik~legalentity
           AND cb_stw~ccode         = ik~ccode
           AND cb_stw~costobject    = ik~costobject
           AND cb_stw~costcenter    = ik~costcenter
           AND srv_share~serviceproduct = ik~serviceproduct
        WHERE cb_stw~poper IN @it_poper
        ORDER BY rec_chg~cc_uuid,
                 rec_chg~srv_uuid
        INTO TABLE @DATA(lt_recshare).

*get total share assigned to service product
    SELECT DISTINCT
          cb_stw~ryear,
          cb_stw~poper,
          cb_stw~localcurr,
          srv_share~*
          FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
            ON cb_stw~cc_uuid = srv_share~cc_uuid
           AND srv_share~chargeout = 'D'
          INNER JOIN @it_keys AS ik
            ON cb_stw~fplv          = ik~fplv
           AND cb_stw~ryear         = ik~ryear
           AND cb_stw~sysid         = ik~sysid
           AND cb_stw~legalentity   = ik~legalentity
           AND cb_stw~ccode         = ik~ccode
           AND cb_stw~costobject    = ik~costobject
           AND cb_stw~costcenter    = ik~costcenter
           AND srv_share~serviceproduct = ik~serviceproduct
        WHERE cb_stw~poper IN @it_poper
        INTO TABLE @DATA(lt_srvshare).


    SELECT DISTINCT
           cc_uuid,
           srv_uuid,
           SUM( reckpi ) AS totalconsumption
           FROM @lt_recshare AS recshare
           GROUP BY
           cc_uuid,
           srv_uuid
           ORDER BY cc_uuid,
                    srv_uuid
           INTO TABLE @DATA(lt_totalconsumption).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

* get dummy cost object details
    SELECT SINGLE * FROM /esrcc/cst_objct WHERE legal_entity = 'REST'
                    INTO @DATA(dummyreceiver).


    LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).
      READ TABLE lt_totalconsumption ASSIGNING FIELD-SYMBOL(<totalconsumption>)
                                     WITH KEY cc_uuid = <ls_srvshare>-srv_share-cc_uuid
                                              srv_uuid = <ls_srvshare>-srv_share-srv_uuid
                                              BINARY SEARCH.

      IF sy-subrc = 0 AND <ls_srvshare>-srv_share-planning <> <totalconsumption>-totalconsumption.
** add a dummy receiver
        APPEND INITIAL LINE TO lt_recsharedelta ASSIGNING FIELD-SYMBOL(<recshare>).
        <recshare>-cc_uuid = <ls_srvshare>-srv_share-cc_uuid.
        <recshare>-srv_uuid = <ls_srvshare>-srv_share-srv_uuid.
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <recshare>-rec_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        IF dummyreceiver IS NOT INITIAL.
          <recshare>-receivingentity = dummyreceiver-legal_entity.
          <recshare>-receiversysid = dummyreceiver-sysid.
          <recshare>-receivercompanycode = dummyreceiver-company_code.
          <recshare>-receivercostobject = dummyreceiver-cost_object.
          <recshare>-receivercostcenter = dummyreceiver-cost_center.
        ELSE.
          <recshare>-receivingentity = 'REST'.
          <recshare>-receiversysid = 'RS'.
          <recshare>-receivercompanycode = 'RS01'.
          <recshare>-receivercostobject = 'CC'.
          <recshare>-receivercostcenter = 'DUMMY'.
        ENDIF.
*   get the markups applied at service product level for each receiever and apply for delta node as well
        READ TABLE lt_recshare ASSIGNING FIELD-SYMBOL(<ls_recshare>) WITH KEY cc_uuid = <totalconsumption>-cc_uuid
                                                                              srv_uuid = <totalconsumption>-srv_uuid
                                                                              BINARY SEARCH.
        IF sy-subrc = 0.
          <recshare>-valueaddmarkup = <ls_recshare>-valueaddmarkup.
          <recshare>-passthrumarkup = <ls_recshare>-passthrumarkup.
        ENDIF.
*    Assign local currency of the provider as the invoicing currency for REST.
        <recshare>-invoicingcurrency = <ls_srvshare>-localcurr.
        <recshare>-status = /esrcc/if_calculate_chargeout=>finalized.
        <recshare>-invoicestatus = '01'.
        <recshare>-reckpi = <ls_srvshare>-srv_share-planning - <totalconsumption>-totalconsumption.
        <recshare>-consumptionuom = <ls_srvshare>-srv_share-planninguom.
        determine_last_day(
          EXPORTING
            iv_ryear    = <ls_srvshare>-ryear
            iv_poper    = <ls_srvshare>-poper
          IMPORTING
            ev_valid_on = <recshare>-exchdate
        ).
* Admin data
        <recshare>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <recshare>-created_at
        ).
        <recshare>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <recshare>-last_changed_at
        ).

      ENDIF.
    ENDLOOP.

    MODIFY /esrcc/rec_chg FROM TABLE @lt_recsharedelta.

    CLEAR: lt_recshare, lt_totalconsumption, lt_recsharedelta, lt_srvshare.

  ENDMETHOD.


  METHOD determine_last_day.

    DATA lv_valid_from TYPE /esrcc/validfrom.

    CONCATENATE iv_ryear iv_poper+1(2) '01' INTO lv_valid_from.

    CALL FUNCTION '/ESRCC/FM_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in       = lv_valid_from
      IMPORTING
        end_of_month = ev_valid_on.

  ENDMETHOD.


  METHOD finalize_chargeout.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA _poper        TYPE RANGE OF poper.
    DATA ls_cbli       TYPE /esrcc/cb_li.
    DATA lt_cbli       TYPE TABLE OF /esrcc/cb_li.
    DATA lv_valid_from TYPE /esrcc/validfrom.
    DATA number        TYPE /esrcc/doc_no.
    DATA lo_badi     TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_recshare   TYPE TABLE OF /esrcc/rec_chg.
    DATA lv_invoicestatus TYPE /esrcc/invoicestatus VALUE '01'.

*Derive poper from billing frequency customizing
    IF it_poper IS INITIAL.
      READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
      IF sy-subrc = 0.
        SELECT 'I'  AS sign,
              'EQ'  AS option,
              poper AS low
              FROM /esrcc/billfreq
              WHERE billingfreq = @<key>-billingfreq
                AND billingvalue = @<key>-billingperiod
              ORDER BY low ASCENDING
              INTO CORRESPONDING FIELDS OF TABLE @_poper.
      ENDIF.
    ELSE.
      _poper = it_poper.
    ENDIF.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

*update execution process control
    SELECT procctrl~*,
           @/esrcc/if_calculate_chargeout=>chargeout_finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
           FROM /esrcc/procctrl AS procctrl
           INNER JOIN @lt_keys AS keys
           ON procctrl~sysid          = keys~sysid
          AND procctrl~fplv           = keys~fplv
          AND procctrl~ryear          = keys~ryear
          AND procctrl~billingfreq    = keys~billingfreq
          AND procctrl~billingperiod  = keys~billingperiod
          AND procctrl~legalentity    = keys~legalentity
          AND procctrl~ccode          = keys~ccode
          AND procctrl~costobject     = keys~costobject
          AND procctrl~costcenter     = keys~costcenter
          AND procctrl~serviceproduct = keys~serviceproduct
          WHERE procctrl~process = @/esrcc/if_calculate_chargeout=>chargeout
          INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.


*Finalize calculated receiever
    SELECT rec_chg~*,
           @lv_invoicestatus AS invoicestatus,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
          FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
            ON cb_stw~cc_uuid = srv_share~cc_uuid
          INNER JOIN /esrcc/rec_chg AS rec_chg
            ON cb_stw~cc_uuid = rec_chg~cc_uuid
           AND srv_share~srv_uuid = rec_chg~srv_uuid
          INNER JOIN @it_keys AS ik
            ON cb_stw~fplv          = ik~fplv
           AND cb_stw~ryear         = ik~ryear
           AND cb_stw~sysid         = ik~sysid
           AND cb_stw~legalentity   = ik~legalentity
           AND cb_stw~ccode         = ik~ccode
           AND cb_stw~costobject    = ik~costobject
           AND cb_stw~costcenter    = ik~costcenter
           AND srv_share~serviceproduct = ik~serviceproduct
        WHERE cb_stw~poper IN @_poper
        INTO CORRESPONDING FIELDS OF TABLE @lt_recshare.

*Handling of delta for direct chargeout Scenario
    determine_delta_chargeout(
      it_keys  = it_keys
      it_poper = _poper
    ).

*SCC Virtual posting
    IF lo_badi IS NOT BOUND.
      TRY.
          GET BADI lo_badi.
        CATCH cx_badi_not_implemented cx_badi_unknown_error.
      ENDTRY.
    ENDIF.

    IF lo_badi IS BOUND.

      CALL BADI lo_badi->virtual_posting
        EXPORTING
          it_keys  = it_keys
          it_poper = _poper.

    ENDIF.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_finalize_chargeout
      it_keys   = lt_procctrl
    ).

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/rec_chg FROM TABLE @lt_recshare.

    CLEAR: lt_procctrl, lt_recshare.

  ENDMETHOD.


  METHOD finalize_costbase.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.
    DATA lt_cc_cost TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_cb_li   TYPE TABLE OF /esrcc/cb_li.
    DATA lt_tmp_cost TYPE TABLE OF /esrcc/cb_stw.

*Derive poper from billing frequency customizing
    IF it_poper IS INITIAL.
      READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
      IF sy-subrc = 0.
        SELECT 'I'  AS sign,
              'EQ'  AS option,
              poper AS low
              FROM /esrcc/billfreq
              WHERE billingfreq = @<key>-billingfreq
                AND billingvalue = @<key>-billingperiod
              ORDER BY low ASCENDING
              INTO CORRESPONDING FIELDS OF TABLE @_poper.
      ENDIF.
    ELSE.
      _poper = it_poper.
    ENDIF.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE costcenter IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).


*Finalize calculated Cost base & Stewardship
    SELECT  cb~*,
            @/esrcc/if_calculate_chargeout=>finalized AS status,
            @sy-uname AS last_changed_by,
            @last_changed_at AS last_changed_at
      FROM /esrcc/cb_stw AS cb
      INNER JOIN @lt_keys AS ik
        ON cb~fplv        = ik~fplv
       AND cb~ryear       = ik~ryear
       AND cb~sysid       = ik~sysid
       AND cb~legalentity = ik~legalentity
       AND cb~ccode       = ik~ccode
       AND cb~costobject  = ik~costobject
       AND cb~costcenter  = ik~costcenter
    WHERE cb~poper IN @_poper
    INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.


*Finalize cost base line items.
    LOOP AT lt_cc_cost INTO DATA(ls_cc_cost)
                       GROUP BY ( legalentity = ls_cc_cost-legalentity ) INTO DATA(entitygroup).

      CLEAR lt_tmp_cost.
      LOOP AT GROUP entitygroup INTO DATA(cc_cost).
        APPEND cc_cost TO lt_tmp_cost.
      ENDLOOP.

*Finalize cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        CLEAR lt_cb_li.
        SELECT cb~*,
               @/esrcc/if_calculate_chargeout=>finalized AS status,
               @sy-uname AS last_changed_by,
               @last_changed_at AS last_changed_at
          FROM /esrcc/cb_li AS cb
          INNER JOIN @lt_tmp_cost AS ik
            ON cb~fplv        = ik~fplv
           AND cb~ryear       = ik~ryear
           AND cb~sysid       = ik~sysid
           AND cb~legalentity = ik~legalentity
           AND cb~ccode       = ik~ccode
           AND cb~costobject  = ik~costobject
           AND cb~costcenter  = ik~costcenter
           AND cb~poper        = ik~poper
          AND cb~status <> @/esrcc/if_calculate_chargeout=>finalized
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.
      FREE: lt_tmp_cost,
            lt_cb_li.
    ENDLOOP.

*update execution process control
    SELECT procctrl~*,
           @/esrcc/if_calculate_chargeout=>costbase_finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
           FROM /esrcc/procctrl AS procctrl
           INNER JOIN @lt_keys AS keys
           ON procctrl~sysid          = keys~sysid
          AND procctrl~fplv           = keys~fplv
          AND procctrl~ryear          = keys~ryear
          AND procctrl~billingfreq    = keys~billingfreq
          AND procctrl~billingperiod  = keys~billingperiod
          AND procctrl~legalentity    = keys~legalentity
          AND procctrl~ccode          = keys~ccode
          AND procctrl~costobject     = keys~costobject
          AND procctrl~costcenter     = keys~costcenter
          AND procctrl~serviceproduct = keys~serviceproduct
          AND procctrl~process = @/esrcc/if_calculate_chargeout=>costbase
          INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.



*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_finalize_costbase
      it_keys   = lt_procctrl
    ).

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cb_li    FROM TABLE @lt_cb_li.
    MODIFY /esrcc/cb_stw   FROM TABLE @lt_cc_cost.

    FREE: lt_cc_cost,
          lt_tmp_cost,
          lt_procctrl,
          lt_cb_li.
  ENDMETHOD.


  METHOD finalize_servicecostshare.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.
    DATA lt_srvshare TYPE TABLE OF /esrcc/srv_share.

*Derive poper from billing frequency customizing
    IF it_poper IS INITIAL.
      READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
      IF sy-subrc = 0.
        SELECT 'I'  AS sign,
              'EQ'  AS option,
              poper AS low
              FROM /esrcc/billfreq
              WHERE billingfreq = @<key>-billingfreq
                AND billingvalue = @<key>-billingperiod
              ORDER BY low ASCENDING
              INTO CORRESPONDING FIELDS OF TABLE @_poper.
      ENDIF.
    ELSE.
      _poper = it_poper.
    ENDIF.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

*update execution process control
    SELECT procctrl~*,
           @/esrcc/if_calculate_chargeout=>serviceshare_finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
           FROM /esrcc/procctrl AS procctrl
           INNER JOIN @lt_keys AS keys
           ON procctrl~sysid          = keys~sysid
          AND procctrl~fplv           = keys~fplv
          AND procctrl~ryear          = keys~ryear
          AND procctrl~billingfreq    = keys~billingfreq
          AND procctrl~billingperiod  = keys~billingperiod
          AND procctrl~legalentity    = keys~legalentity
          AND procctrl~ccode          = keys~ccode
          AND procctrl~costobject     = keys~costobject
          AND procctrl~costcenter     = keys~costcenter
          AND procctrl~serviceproduct = keys~serviceproduct
          WHERE procctrl~process = @/esrcc/if_calculate_chargeout=>serviceshare
          INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.

*Finalize calculated Cost base & Stewardship
    SELECT srv_share~*,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
      FROM /esrcc/cb_stw AS cb_stw
      INNER JOIN /esrcc/srv_share AS srv_share
        ON cb_stw~cc_uuid = srv_share~cc_uuid
      INNER JOIN @lt_keys AS ik
        ON cb_stw~fplv          = ik~fplv
       AND cb_stw~ryear         = ik~ryear
       AND cb_stw~sysid         = ik~sysid
       AND cb_stw~legalentity   = ik~legalentity
       AND cb_stw~ccode         = ik~ccode
       AND cb_stw~costobject    = ik~costobject
       AND cb_stw~costcenter    = ik~costcenter
       AND srv_share~serviceproduct = ik~serviceproduct
    WHERE cb_stw~poper IN @_poper
    INTO CORRESPONDING FIELDS OF TABLE @lt_srvshare.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_finalize_serviceproduct
      it_keys   = lt_procctrl
    ).

    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.

    CLEAR: lt_procctrl, lt_srvshare.

  ENDMETHOD.


  METHOD reopen_chargeout.


    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lt_alocshare  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

* Update status in execution cockpit process control
    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                 AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = /esrcc/if_calculate_chargeout=>chargeout.    "Costbase
      ls_procctrl-status = '04'.    "CalculateCostbase
      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_reopen_chargeout
      it_keys   = lt_procctrl
    ).

* Delete receiver cost
**Reopen Virtual posting in case done during finalizing chargeouts.
    delete_virtual_postings(
      it_keys  = it_keys
      it_poper = _poper
    ).

    delete_chargeout(
      it_keys  = it_keys
      it_poper = _poper
      iv_costbasereopen = iv_costbasereopen
    ).

    DELETE /esrcc/procctrl  FROM TABLE @lt_procctrl.

    CLEAR: lt_procctrl.

  ENDMETHOD.


  METHOD reopen_costbase.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lt_alocshare  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA _poper TYPE RANGE OF poper.
    DATA lt_cb_li TYPE TABLE OF /esrcc/cb_li.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE costcenter IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

*  reopen service cost share
    /esrcc/cl_calculate_chargeout=>reopen_serviceshare( it_keys = it_keys
                                                        iv_costbasereopen = abap_true ).

*  Delete cost center cost
    delete_costbase(
      it_keys  = lt_keys
      it_poper = _poper
    ).

*Update execution cockpit process control
    SELECT pc~*
      FROM /esrcc/procctrl AS pc
      INNER JOIN @lt_keys AS ik
        ON pc~fplv          = ik~fplv
       AND pc~ryear         = ik~ryear
       AND pc~sysid         = ik~sysid
       AND pc~legalentity   = ik~legalentity
       AND pc~ccode         = ik~ccode
       AND pc~costobject    = ik~costobject
       AND pc~costcenter    = ik~costcenter
       AND pc~billingfreq   = ik~billingfreq
       AND pc~billingperiod = ik~billingperiod
    INTO TABLE @lt_procctrl.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_reopen_costbase
      it_keys   = lt_procctrl
    ).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.

    CLEAR: lt_procctrl.

  ENDMETHOD.


  METHOD reopen_serviceshare.


    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA lt_alocshare TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

*Update execution cockpit process control
    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                    AND serviceproduct IS NOT INITIAL.

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = /esrcc/if_calculate_chargeout=>serviceshare.
      APPEND ls_procctrl TO lt_procctrl.

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = /esrcc/if_calculate_chargeout=>chargeout.
      ls_procctrl-status  = '01'. "calculate service product costing
      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>action_reopen_serviceproduct
      it_keys   = lt_procctrl
    ).

*  Reopen chargeout
    /esrcc/cl_calculate_chargeout=>reopen_chargeout( it_keys = it_keys
                                                     iv_costbasereopen = iv_costbasereopen ).

*  Delete service cost
    delete_servicecostshare(
      it_keys  = it_keys
      it_poper = _poper
      iv_costbasereopen = iv_costbasereopen
    ).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.

    CLEAR: lt_procctrl.

  ENDMETHOD.


  METHOD reopnesequentialchargeout.

    DATA ls_key TYPE /esrcc/procctrl.
    DATA lt_keys TYPE /esrcc/tt_keys.

*get the chain and sequence.
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS it_keys
          ON stewardship~sysid       = it_keys~sysid
         AND stewardship~legalentity = it_keys~legalentity
         AND stewardship~CompanyCode = it_keys~ccode
         AND stewardship~costobject  = it_keys~costobject
         AND stewardship~costcenter  = it_keys~costcenter
      WHERE stewardship~chain_id IS NOT INITIAL
      INTO TABLE @DATA(lt_stewardship).

      IF lt_stewardship IS NOT INITIAL.
        SELECT DISTINCT stewardship~*
          FROM /ESRCC/I_Stewardship AS stewardship
          INNER JOIN @lt_stewardship AS lt_stewardship
            ON stewardship~chain_id = lt_stewardship~chain_id
        INTO TABLE @DATA(lt_chain_stw).

      ENDIF.


      SORT lt_chain_stw DESCENDING BY chain_id chain_sequence.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>).
        CLEAR: ls_key, lt_keys.

        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-billingfreq = <keys>-billingfreq.
        ls_key-billingperiod = <keys>-billingperiod.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_keys.

        reopen_costbase( it_keys = lt_keys ).

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD sequentialchargeout.

    DATA ls_key TYPE /esrcc/procctrl.
    DATA lt_keys TYPE /esrcc/tt_keys.
*    DATA lt_key_serviceproduct TYPE /esrcc/tt_keys.
    DATA lv_validon TYPE /esrcc/validfrom.
    DATA lt_poper TYPE /esrcc/tt_poper_range.

*Derive poper from billing frequency customizing
    derive_poper(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        et_poper = DATA(_poper)
    ).

    SORT _poper BY low.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS it_keys
          ON stewardship~sysid       = it_keys~sysid
         AND stewardship~legalentity = it_keys~legalentity
         AND stewardship~CompanyCode = it_keys~ccode
         AND stewardship~costobject  = it_keys~costobject
         AND stewardship~costcenter  = it_keys~costcenter
      WHERE stewardship~chain_id IS NOT INITIAL
      INTO TABLE @DATA(lt_stewardship).

      IF lt_stewardship IS NOT INITIAL.
        SELECT DISTINCT stewardship~*
          FROM /ESRCC/I_Stewardship AS stewardship
          INNER JOIN @lt_stewardship AS lt_stewardship
            ON stewardship~chain_id = lt_stewardship~chain_id
        INTO TABLE @DATA(lt_chain_stw).

        SELECT DISTINCT serviceproduct~*
          FROM /esrcc/i_stw_serviceproduct AS serviceproduct
          INNER JOIN @lt_chain_stw AS lt_chain_stw
            ON serviceproduct~StewardshipUuid = lt_chain_stw~StewardshipUuid
        INTO TABLE @DATA(lt_stw_serviceproduct).


      ENDIF.


      SORT lt_chain_stw BY chain_id chain_sequence validfrom.

*   it could be billing frequency used quarterly or half yearly
      LOOP AT _poper ASSIGNING FIELD-SYMBOL(<poper>).


        CLEAR: lv_validon, lt_poper.
        APPEND <poper> TO lt_poper.
        CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO lv_validon.

        LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>) WHERE ValidFrom <= lv_validon
                                                                      AND Validto >= lv_validon.
          CLEAR: ls_key, lt_keys.


          MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
          ls_key-billingfreq = <keys>-billingfreq.
          ls_key-billingperiod = <keys>-billingperiod.
          ls_key-ryear = <keys>-ryear.
          ls_key-fplv = <keys>-fplv.
          ls_key-ccode = <ls_chain_stw>-CompanyCode.
          APPEND ls_key TO lt_keys.

* Step 1:
          calculate_costbase(
            EXPORTING
              it_keys   = lt_keys
              it_poper  = lt_poper
            IMPORTING
              ev_failed = DATA(failed)
          ).

          IF failed = abap_true.
*    Stop the chain executed and report the errors in log and exit
            RETURN.
          ENDIF.

* Step 2:
          finalize_costbase( it_keys = lt_keys
                             it_poper = lt_poper ).

          LOOP AT lt_stw_serviceproduct ASSIGNING FIELD-SYMBOL(<ls_serviceproduct>)
                                         WHERE CostObjectUuid = <ls_chain_stw>-CostObjectUuid
                                           AND StewardshipUuid = <ls_chain_stw>-StewardshipUuid
                                           AND SPValidFrom <= lv_validon
                                           AND SPValidto >= lv_validon.


            CLEAR lt_keys.
            ls_key-serviceproduct = <ls_serviceproduct>-ServiceProduct.
            APPEND ls_key TO lt_keys.


* Step 3:
            calculate_servicecostshare(
              EXPORTING
                it_keys   = lt_keys
                it_poper  = lt_poper
              IMPORTING
                ev_failed = failed
            ).

            IF failed = abap_true.
*    Stop the chain executed and report the errors in log and exit
              RETURN.
            ENDIF.

* Step 4:
            finalize_servicecostshare( it_keys = lt_keys
                                       it_poper = lt_poper ).

* Step 5:
            calculate_chargeout(
              EXPORTING
                it_keys   = lt_keys
                it_poper  = lt_poper
              IMPORTING
                ev_failed = failed
            ).

            IF failed = abap_true.
*    Stop the chain executed and report the errors in log and exit
              RETURN.
            ENDIF.

* Step 6:
            finalize_chargeout( it_keys = lt_keys
                                it_poper = lt_poper ).

          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD trigger_workflow.

    CALL FUNCTION '/ESRCC/FM_WF_START'
      EXPORTING
        it_leading_object = it_leading_object
        iv_apptype        = iv_application.

  ENDMETHOD.


  METHOD validate_costbase.

    DATA lt_cc_cost    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lv_validon    TYPE /esrcc/validfrom.
    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitems      TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY.
    DATA logitem       TYPE /esrcc/log_item.
    DATA procctrl       TYPE /esrcc/tt_keys.

*Check if company code and legal entity is still active for charge-out in configuration
    SELECT DISTINCT cc~sysid,
                    cc~ccode,
                    cc~legalentity
        FROM /esrcc/le_ccode AS cc
        INNER JOIN @ct_keys AS keys
        ON  cc~sysid  = keys~Sysid
        AND cc~ccode = keys~Ccode
        AND cc~legalentity = keys~legalentity
        AND cc~active = @abap_false
        ORDER BY cc~sysid,
                 cc~ccode,
                 cc~legalentity
        INTO TABLE @DATA(activeccode).

*Check if relationship in stewardship and service product and receiver configuration is still finalized.
    SELECT DISTINCT stw~Sysid,
                    stw~CompanyCode,
                    stw~LegalEntity,
                    stw~CostObject,
                    stw~CostCenter,
                    stw~ValidFrom,
                    stw~ValidTo
       FROM /ESRCC/I_Stewardship AS stw
      INNER JOIN  @ct_keys AS keys
         ON stw~sysid        = keys~Sysid
        AND stw~companycode = keys~Ccode
        AND stw~legalentity = keys~legalentity
        AND stw~CostObject  = keys~costobject
        AND stw~CostCenter  = keys~costcenter
        ORDER BY stw~Sysid,
                 stw~CompanyCode,
                 stw~LegalEntity,
                 stw~CostObject,
                 stw~CostCenter
*                 stw~ValidFrom,
*                 stw~validto
        INTO TABLE @DATA(stewardships).


*Check if total initial cost is zero including virtual cost
    SELECT DISTINCT cb~fplv,
                    cb~ryear,
                    cb~poper,
                    cb~sysid,
                    cb~legalentity,
                    cb~ccode,
                    cb~costobject,
                    cb~costcenter,
                    erptotalcost_l,
                    virtualtotalcost_l
            FROM /esrcc/i_totalcostabse AS cb
            INNER JOIN @ct_keys AS keys
                    ON  cb~fplv        = keys~fplv
                   AND  cb~ryear       = keys~ryear
                   AND  cb~sysid       = keys~sysid
                   AND  cb~legalentity = keys~legalentity
                   AND  cb~ccode       = keys~ccode
                   AND  cb~costobject  = keys~costobject
                   AND  cb~costcenter  = keys~costcenter
                   WHERE cb~poper     IN @it_poper
                   ORDER BY cb~fplv,
                            cb~ryear,
                            cb~poper,
                            cb~sysid,
                            cb~legalentity,
                            cb~ccode,
                            cb~costobject,
                            cb~costcenter
                   INTO TABLE @DATA(lineitems).

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
                    procctrl~ryear,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~billingfreq,
                    procctrl~billingperiod,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~billingfreq   = keys~billingfreq
                   AND  procctrl~billingperiod = keys~billingperiod
                   AND  procctrl~serviceproduct IS INITIAL
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>costbase
                   AND  procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~billingfreq,
                            procctrl~billingperiod,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING FIELD-SYMBOL(<keys>).

      DATA(failed) = abap_false.

*Authority check
      authority_check(
        EXPORTING
          keys   = <keys>
          action = /esrcc/if_calculate_chargeout=>action_calculate_costbase
        IMPORTING
          failed = failed
      ).
      IF failed = abap_true.
*      log an error
        CLEAR logitem.
        logitem-message_id     = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '006'.
        logitem-message_type   = 'E'.
        APPEND logitem TO logitems.
        failed = abap_true.
      ENDIF.


*validate if company code and legal entity is active
      READ TABLE activeccode TRANSPORTING NO FIELDS WITH KEY sysid = <keys>-sysid
                                                             ccode = <keys>-ccode
                                                             legalentity = <keys>-legalentity.
      IF sy-subrc = 0.
*      log an error
        CLEAR logitem.
        logitem-message_id     = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '017'.
        logitem-message_type   = 'E'.
        CONCATENATE <keys>-legalentity <keys>-ccode INTO logitem-message_v1 SEPARATED BY '/'.
        APPEND logitem TO logitems.
        failed = abap_true.
      ENDIF.

*Check for each month in case billing frequency is not monthly
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).
        DATA(stewardshipexist) = abap_false.

*  Information message about the period for which logs are being published
        CLEAR logitem.
        logitem-message_id     = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '018'.
        logitem-message_type   = 'I'.
        TRY.
            DATA(parentloguuid) = cl_system_uuid=>create_uuid_c32_static( ). .
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY. .
        logitem-log_uuid = parentloguuid.
        logitem-is_parent = abap_true.
        CONCATENATE <keys>-ryear <poper>-low INTO logitem-message_v1 SEPARATED BY '-'.
        APPEND logitem TO logitems.

        CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO lv_validon.

        READ TABLE stewardships TRANSPORTING NO FIELDS WITH KEY sysid       = <keys>-sysid
                                                                CompanyCode = <keys>-ccode
                                                                legalentity = <keys>-legalentity
                                                                CostObject  = <keys>-costobject
                                                                costcenter  = <keys>-costcenter
                                                                BINARY SEARCH.

        IF sy-subrc = 0.
          LOOP AT stewardships ASSIGNING FIELD-SYMBOL(<stewardship>) FROM sy-tabix WHERE ValidFrom <= lv_validon
                                                                                     AND Validto   >= lv_validon.

            stewardshipexist = abap_true.

          ENDLOOP.

          IF stewardshipexist = abap_false.
*      log an error
            CLEAR logitem.
            logitem-parent_log_uuid = parentloguuid.
            logitem-message_id = '/ESRCC/EXECCOCKPIT'.
            logitem-message_number = '019'.
            logitem-message_type = 'E'.
            CONCATENATE <keys>-legalentity <keys>-ccode INTO logitem-message_v1 SEPARATED BY '/'.
            APPEND logitem TO logitems.
            failed = abap_true.
          ENDIF.
        ENDIF.

        READ TABLE lineitems ASSIGNING FIELD-SYMBOL(<lineitem>) WITH KEY    fplv        = <keys>-fplv
                                                                ryear       = <keys>-ryear
                                                                poper       = <poper>-low
                                                                sysid       = <keys>-sysid
                                                                legalentity = <keys>-legalentity
                                                                ccode       = <keys>-ccode
                                                                CostObject  = <keys>-costobject
                                                                costcenter  = <keys>-costcenter
                                                                 BINARY SEARCH.
        IF sy-subrc <> 0.
*      log an error
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '020'.
          logitem-message_type = 'E'.
          CONCATENATE <keys>-legalentity <keys>-ccode INTO logitem-message_v1 SEPARATED BY '/'.
          APPEND logitem TO logitems.
          failed = abap_true.
        ELSEIF <lineitem>-erptotalcost_l = 0 AND <lineitem>-virtualtotalcost_l = 0.
*      log an warning
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '021'.
          logitem-message_type = 'E'.
          CONCATENATE <keys>-legalentity <keys>-ccode INTO logitem-message_v1 SEPARATED BY '/'.
          APPEND logitem TO logitems.
          failed = abap_true.
        ENDIF.

      ENDLOOP.

      IF failed = abap_true.

* create message logs
        create_loginstance(
          EXPORTING
            key         = <keys>
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>costbase
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>costbase.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>costbase_failed.     "Cost Base failed
        ls_procctrl-log_header_uuid = loginstance->get_log_header_id( ).
*Admin data
        ls_procctrl-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-created_at
        ).
        ls_procctrl-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-last_changed_at
        ).
        APPEND ls_procctrl TO lt_procctrl.

        DELETE ct_keys WHERE sysid = <keys>-sysid
                         AND ccode = <keys>-ccode
                         AND legalentity = <keys>-legalentity
                         AND costobject = <keys>-costobject
                         AND costcenter = <keys>-costcenter
                         AND fplv = <keys>-fplv
                         AND ryear = <keys>-ryear
                         AND billingfreq = <keys>-billingfreq
                         AND billingperiod = <keys>-billingperiod.
        ev_failed = failed.
      ENDIF.
      CLEAR loginstance.
    ENDLOOP.


    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    CLEAR: procctrl, lineitems, stewardships.

  ENDMETHOD.


  METHOD validate_receiverchargeout.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lv_validon    TYPE /esrcc/validfrom.
    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitems      TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY.
    DATA logitem       TYPE /esrcc/log_item.
    DATA procctrl      TYPE /esrcc/tt_keys.


*Check if receivers are maintained
    SELECT DISTINCT receivers~*
           FROM  /esrcc/i_srvproduct_receivers AS receivers
           INNER JOIN @ct_keys AS keys
             ON receivers~SystemId       = keys~sysid
            AND receivers~legalentity    = keys~legalentity
            AND receivers~CompanyCode    = keys~ccode
            AND receivers~costobject     = keys~costobject
            AND receivers~costcenter     = keys~costcenter
            AND receivers~serviceproduct = keys~serviceproduct
            WHERE receivers~active         = @abap_true
            INTO TABLE @DATA(receivers).

*Check if charge-out rule is configured
    SELECT DISTINCT
           recshare~fplv,
           recshare~ryear,
           recshare~poper,
           recshare~sysid,
           recshare~legalentity,
           recshare~ccode,
           recshare~costobject,
           recshare~costcenter,
           recshare~serviceproduct,
           recshare~chargeout,
           recshare~consumptionuom,
           SUM( reckpi ) AS totalreckpi,
           SUM( reckpishare ) AS totalreckpishare
       FROM /esrcc/i_chargeout_recshare  AS recshare
       INNER JOIN @ct_keys AS keys
          ON recshare~fplv           = keys~fplv
         AND recshare~ryear          = keys~ryear
         AND recshare~sysid          = keys~sysid
         AND recshare~legalentity    = keys~legalentity
         AND recshare~ccode          = keys~ccode
         AND recshare~costobject     = keys~costobject
         AND recshare~costcenter     = keys~costcenter
         AND recshare~serviceproduct = keys~serviceproduct
         WHERE recshare~poper         IN @it_poper
           AND ( ( recshare~chargeout = 'D' AND recshare~consumptionuom IS NOT INITIAL ) OR recshare~chargeout = 'I' )
         GROUP BY
         recshare~fplv,
         recshare~ryear,
         recshare~poper,
         recshare~sysid,
         recshare~legalentity,
         recshare~ccode,
         recshare~costobject,
         recshare~costcenter,
         recshare~serviceproduct,
         recshare~chargeout,
         recshare~consumptionuom
         ORDER BY recshare~fplv,
                 recshare~ryear,
                 recshare~poper,
                 recshare~sysid,
                 recshare~legalentity,
                 recshare~ccode,
                 recshare~costobject,
                 recshare~costcenter,
                 recshare~serviceproduct
         INTO TABLE @DATA(receiverchargeouts).

* Check if chargeout rule method is direct then if capacity has been defined
    SELECT DISTINCT
           cb_stw~fplv,
           cb_stw~ryear,
           cb_stw~poper,
           cb_stw~sysid,
           cb_stw~legalentity,
           cb_stw~ccode,
           cb_stw~costobject,
           cb_stw~costcenter,
           srvshare~serviceproduct,
           srvshare~planning,
           srvshare~planninguom
            FROM /ESRCC/srv_share AS srvshare
            INNER JOIN /ESRCC/cb_stw AS cb_stw
               ON srvshare~cc_uuid = cb_stw~cc_uuid
            INNER JOIN @ct_keys AS keys
               ON cb_stw~fplv           = keys~fplv
              AND cb_stw~ryear          = keys~ryear
              AND cb_stw~sysid          = keys~sysid
              AND cb_stw~legalentity    = keys~legalentity
              AND cb_stw~ccode          = keys~ccode
              AND cb_stw~costobject     = keys~costobject
              AND cb_stw~costcenter     = keys~costcenter
             WHERE srvshare~chargeout = 'D'
               AND cb_stw~poper          IN @it_poper
               ORDER BY cb_stw~fplv,
                        cb_stw~ryear,
                        cb_stw~poper,
                        cb_stw~sysid,
                        cb_stw~legalentity,
                        cb_stw~ccode,
                        cb_stw~costobject,
                        cb_stw~costcenter,
                        srvshare~serviceproduct
              INTO TABLE @DATA(serviceshares).

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
                    procctrl~ryear,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~serviceproduct,
                    procctrl~billingfreq,
                    procctrl~billingperiod,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~billingfreq   = keys~billingfreq
                   AND  procctrl~billingperiod = keys~billingperiod
                   AND  procctrl~serviceproduct = keys~serviceproduct
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>serviceshare
                   WHERE procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~serviceproduct,
                            procctrl~billingfreq,
                            procctrl~billingperiod,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING FIELD-SYMBOL(<keys>).

      DATA(failed) = abap_false.

*Authority check
      authority_check(
        EXPORTING
          keys   = <keys>
          action = /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct
        IMPORTING
          failed = failed
      ).
      IF failed = abap_true.
*      log an error
        CLEAR logitem.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '008'.
        logitem-message_type = 'E'.
        APPEND logitem TO logitems.
        failed = abap_true.
      ENDIF.

*Check for each month in case billing frequency is not monthly
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).


*  Information message about the period for which logs are being published
        CLEAR logitem.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '018'.
        logitem-message_type = 'I'.
        TRY.
            DATA(parentloguuid) = cl_system_uuid=>create_uuid_c32_static( ). .
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY. .
        logitem-log_uuid = parentloguuid.
        logitem-is_parent = abap_true.
        CONCATENATE <keys>-fplv <keys>-ryear <poper>-low INTO logitem-message_v1 SEPARATED BY '-'.
        APPEND logitem TO logitems.

        CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO lv_validon.

*check if atleast one receivers exist for the service product
        READ TABLE receivers TRANSPORTING NO FIELDS WITH KEY  SystemId       = <keys>-sysid
                                                              legalentity    = <keys>-legalentity
                                                              CompanyCode    = <keys>-ccode
                                                              costobject     = <keys>-costobject
                                                              costcenter     = <keys>-costcenter
                                                              serviceproduct = <keys>-serviceproduct.
        IF sy-subrc <> 0.
*      log an error
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '004'.
          logitem-message_type = 'E'.
          APPEND logitem TO logitems.
          failed = abap_true.
        ELSE.

          READ TABLE receiverchargeouts ASSIGNING FIELD-SYMBOL(<receiverchargeout>) WITH KEY fplv           = <keys>-fplv
                                                                                             ryear          = <keys>-ryear
                                                                                             poper          = <poper>-low
                                                                                             sysid          = <keys>-sysid
                                                                                             legalentity    = <keys>-legalentity
                                                                                             ccode          = <keys>-ccode
                                                                                             costobject     = <keys>-costobject
                                                                                             costcenter     = <keys>-costcenter
                                                                                             serviceproduct = <keys>-serviceproduct
                                                                                              BINARY SEARCH.

          IF sy-subrc <> 0.
*      log an error
            CLEAR logitem.
            logitem-parent_log_uuid = parentloguuid.
            logitem-message_id = '/ESRCC/EXECCOCKPIT'.
            logitem-message_number = '027'.
            logitem-message_type = 'E'.
            APPEND logitem TO logitems.
            failed = abap_true.
          ELSE.
            IF <receiverchargeout>-chargeout = 'I' AND <receiverchargeout>-totalreckpishare = 0.
*      log an error
              CLEAR logitem.
              logitem-parent_log_uuid = parentloguuid.
              logitem-message_id = '/ESRCC/EXECCOCKPIT'.
              logitem-message_number = '029'.
              logitem-message_type = 'E'.
              APPEND logitem TO logitems.
              failed = abap_true.
            ELSEIF <receiverchargeout>-chargeout = 'D' AND <receiverchargeout>-totalreckpi = 0.
*      log an error
              CLEAR logitem.
              logitem-parent_log_uuid = parentloguuid.
              logitem-message_id = '/ESRCC/EXECCOCKPIT'.
              logitem-message_number = '028'.
              logitem-message_type = 'E'.
              APPEND logitem TO logitems.
              failed = abap_true.
            ELSEIF <receiverchargeout>-chargeout = 'D' AND <receiverchargeout>-totalreckpi <> 0.
              READ TABLE serviceshares ASSIGNING FIELD-SYMBOL(<serviceshare>) WITH KEY fplv           = <receiverchargeout>-fplv
                                                                                       ryear          = <receiverchargeout>-ryear
                                                                                       poper          = <receiverchargeout>-poper
                                                                                       sysid          = <receiverchargeout>-sysid
                                                                                       legalentity    = <receiverchargeout>-legalentity
                                                                                       ccode          = <receiverchargeout>-ccode
                                                                                       costobject     = <receiverchargeout>-costobject
                                                                                       costcenter     = <receiverchargeout>-costcenter
                                                                                       serviceproduct = <receiverchargeout>-serviceproduct BINARY SEARCH.
              IF sy-subrc = 0 AND <receiverchargeout>-consumptionuom <> <serviceshare>-planninguom.
*      log an error
                CLEAR logitem.
                logitem-parent_log_uuid = parentloguuid.
                logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                logitem-message_number = '030'.
                logitem-message_type = 'E'.
                APPEND logitem TO logitems.
                failed = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF failed = abap_true.
* create message logs
        create_loginstance(
          EXPORTING
            key         = <keys>
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>chargeout
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*  update execution cockpit status
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>chargeout.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>chargeout_failed.     "Cost Base failed
        ls_procctrl-log_header_uuid = loginstance->get_log_header_id( ).
*Admin data
        ls_procctrl-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-created_at
        ).
        ls_procctrl-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-last_changed_at
        ).
        APPEND ls_procctrl TO lt_procctrl.

        DELETE ct_keys WHERE sysid = <keys>-sysid
                         AND ccode = <keys>-ccode
                         AND legalentity = <keys>-legalentity
                         AND costobject = <keys>-costobject
                         AND costcenter = <keys>-costcenter
                         AND serviceproduct = <keys>-serviceproduct
                         AND fplv = <keys>-fplv
                         AND ryear = <keys>-ryear
                         AND billingfreq = <keys>-billingfreq
                         AND billingperiod = <keys>-billingperiod.

        ev_failed = failed.
      ENDIF.
      CLEAR loginstance.
    ENDLOOP.


    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.

    CLEAR: procctrl, receivers,receiverchargeouts,serviceshares.

  ENDMETHOD.


  METHOD validate_serviceproductcosting.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lv_validon    TYPE /esrcc/validfrom.
    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitems      TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY.
    DATA logitem       TYPE /esrcc/log_item.
    DATA procctrl       TYPE /esrcc/tt_keys.


*Check if charge-out rule is configured
    SELECT DISTINCT cout~serviceproduct,
                    cout~validFrom,
                    cout~validto,
                    rule~chargeout_method
            FROM /esrcc/chargeout AS cout
            INNER JOIN /esrcc/co_rule AS rule
            ON rule~rule_id = cout~chargeout_rule_id
            AND rule~workflow_status = 'F'
            INNER JOIN @ct_keys AS keys
               ON cout~serviceproduct = keys~serviceproduct
            WHERE rule~cost_version = keys~fplv
              AND rule~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
            ORDER BY cout~serviceproduct
            INTO TABLE @DATA(rulesdetails).

* Check if chargeout rule method is direct then if capacity has been defined
    SELECT DISTINCT srvcap~Ryear,
                    srvcap~poper,
                    srvcap~Sysid,
                    srvcap~LegalEntity,
                    srvcap~CompanyCode,
                    srvcap~Costobject,
                    srvcap~Costcenter,
                    srvcap~ServiceProduct,
                    srvcap~planning,
                    srvcap~uom
            FROM /ESRCC/I_ServiceCapacity AS srvcap
            INNER JOIN @ct_keys AS keys
               ON srvcap~Sysid       = keys~sysid
              AND srvcap~LegalEntity = keys~legalentity
              AND srvcap~CompanyCode = keys~ccode
              AND srvcap~Ryear       = keys~ryear
              AND srvcap~Costobject  = keys~costobject
              AND srvcap~Costcenter  = keys~costcenter
              AND srvcap~ServiceProduct = keys~serviceproduct
              WHERE srvcap~poper       IN @it_poper
              ORDER BY srvcap~Ryear,
                       srvcap~poper,
                       srvcap~Sysid,
                       srvcap~LegalEntity,
                       srvcap~CompanyCode,
                       srvcap~Costobject,
                       srvcap~Costcenter,
                       srvcap~ServiceProduct
              INTO TABLE @DATA(capacities).

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
                    procctrl~ryear,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~serviceproduct,
                    procctrl~billingfreq,
                    procctrl~billingperiod,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~billingfreq   = keys~billingfreq
                   AND  procctrl~billingperiod = keys~billingperiod
                   AND  procctrl~serviceproduct = keys~serviceproduct
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>serviceshare
                   WHERE procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~serviceproduct,
                            procctrl~billingfreq,
                            procctrl~billingperiod,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING FIELD-SYMBOL(<keys>).

      DATA(failed) = abap_false.

*Authority check
      authority_check(
        EXPORTING
          keys   = <keys>
          action = /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct
        IMPORTING
          failed = failed
      ).
      IF failed = abap_true.
*      log an error
        CLEAR logitem.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '007'.
        logitem-message_type = 'E'.
        APPEND logitem TO logitems.
        failed = abap_true.
      ENDIF.


*Check for each month in case billing frequency is not monthly
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).
        DATA(ruleexist) = abap_false.

*  Information message about the period for which logs are being published
        CLEAR logitem.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '018'.
        logitem-message_type = 'I'.
        TRY.
            DATA(parentloguuid) = cl_system_uuid=>create_uuid_c32_static( ). .
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY. .
        logitem-log_uuid = parentloguuid.
        logitem-is_parent = abap_true.
        CONCATENATE <keys>-ryear <poper>-low INTO logitem-message_v1 SEPARATED BY '-'.
        APPEND logitem TO logitems.

        CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO lv_validon.

        READ TABLE rulesdetails TRANSPORTING NO FIELDS WITH KEY serviceproduct = <keys>-serviceproduct
                                                                BINARY SEARCH.

        IF sy-subrc = 0.
          LOOP AT rulesdetails ASSIGNING FIELD-SYMBOL(<rules>) FROM sy-tabix WHERE validfrom   <= lv_validon
                                                                               AND validto     >= lv_validon.

            ruleexist = abap_true.

          ENDLOOP.
        ENDIF.
        IF ruleexist = abap_false.
*      log an error
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '023'.
          logitem-message_type = 'E'.
          logitem-message_v1 = <keys>-serviceproduct.
          APPEND logitem TO logitems.
          failed = abap_true.
        ELSEIF <rules>-chargeout_method = 'D'.

          READ TABLE capacities ASSIGNING FIELD-SYMBOL(<capacity>) WITH KEY ryear          = <keys>-ryear
                                                                            poper          = <poper>-low
                                                                            Sysid          = <keys>-sysid
                                                                            LegalEntity    = <keys>-legalentity
                                                                            CompanyCode    = <keys>-ccode
                                                                            Costobject     = <keys>-costobject
                                                                            Costcenter     = <keys>-costcenter
                                                                            ServiceProduct = <keys>-serviceproduct BINARY SEARCH.

          IF sy-subrc <> 0.
*      log an error
            CLEAR logitem.
            logitem-parent_log_uuid = parentloguuid.
            logitem-message_id = '/ESRCC/EXECCOCKPIT'.
            logitem-message_number = '024'.
            logitem-message_type = 'E'.
            logitem-message_v1 = <keys>-serviceproduct.
            APPEND logitem TO logitems.
            failed = abap_true.
          ELSEIF <capacity>-planning = 0.
*      log an error
            CLEAR logitem.
            logitem-parent_log_uuid = parentloguuid.
            logitem-message_id = '/ESRCC/EXECCOCKPIT'.
            logitem-message_number = '025'.
            logitem-message_type = 'E'.
            logitem-message_v1 = <keys>-serviceproduct.
            APPEND logitem TO logitems.
            failed = abap_true.
          ENDIF.
        ENDIF.


      ENDLOOP.

      IF failed = abap_true.
* create message logs
        create_loginstance(
          EXPORTING
            key         = <keys>
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>serviceshare
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*  update execution cockpit status
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>serviceshare.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>serviceshare_failed.     "Cost Base failed
        ls_procctrl-log_header_uuid = loginstance->get_log_header_id( ).
*Admin data
        ls_procctrl-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-created_at
        ).
        ls_procctrl-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-last_changed_at
        ).
        APPEND ls_procctrl TO lt_procctrl.


        DELETE ct_keys WHERE sysid = <keys>-sysid
                         AND ccode = <keys>-ccode
                         AND legalentity = <keys>-legalentity
                         AND costobject = <keys>-costobject
                         AND costcenter = <keys>-costcenter
                         AND serviceproduct = <keys>-serviceproduct
                         AND fplv = <keys>-fplv
                         AND ryear = <keys>-ryear
                         AND billingfreq = <keys>-billingfreq
                         AND billingperiod = <keys>-billingperiod.
        ev_failed = failed.

      ENDIF.
      CLEAR loginstance.
    ENDLOOP.


    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    CLEAR: procctrl, rulesdetails, capacities.

  ENDMETHOD.


  METHOD virtual_posting.

    DATA ls_cbli    TYPE /esrcc/cb_li.
    DATA lt_cbli    TYPE TABLE OF /esrcc/cb_li.
    DATA lv_validon TYPE /esrcc/validfrom.
    DATA number     TYPE /esrcc/doc_no.

    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM /esrcc/group INTO @DATA(group).

    LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<ls_poper>).

      CONCATENATE <keys>-ryear <ls_poper>-low+1(2) '01' INTO lv_validon.

*get the list of receivers
      SELECT DISTINCT rec_chg~receiversysid,
                      rec_chg~receivingentity,
                      rec_chg~receivercompanycode,
                      le~local_curr AS receivercurrency
            FROM /esrcc/cb_stw AS cb_stw
            INNER JOIN /esrcc/srv_share AS srv_share
              ON cb_stw~cc_uuid = srv_share~cc_uuid
            INNER JOIN /esrcc/rec_chg AS rec_chg
              ON cb_stw~cc_uuid = rec_chg~cc_uuid
             AND srv_share~srv_uuid = rec_chg~srv_uuid
            INNER JOIN @it_keys AS ik
              ON cb_stw~fplv          = ik~fplv
             AND cb_stw~ryear         = ik~ryear
             AND cb_stw~sysid         = ik~sysid
             AND cb_stw~legalentity   = ik~legalentity
             AND cb_stw~ccode         = ik~ccode
             AND cb_stw~costobject    = ik~costobject
             AND cb_stw~costcenter    = ik~costcenter
             AND srv_share~serviceproduct = ik~serviceproduct
             LEFT OUTER JOIN /esrcc/le AS le
             ON rec_chg~receivingentity = le~legalentity
          WHERE cb_stw~poper = @<ls_poper>-low
          ORDER BY receivingentity
          INTO TABLE @DATA(receivers).

*check if virtual cost element  is configured for receivers.
      IF receivers IS NOT INITIAL.
        SELECT DISTINCT cel~sysid,
                        cel~company_code,
                        cel~legal_entity,
                        cel~cost_element,
                        le~local_curr,
                        costelem~*
              FROM /esrcc/cstelmtch AS costelem
              INNER JOIN /esrcc/cst_elmnt AS cel
              ON costelem~cost_element_uuid = cel~cost_element_uuid
              INNER JOIN /esrcc/le AS le
              ON le~legalentity = cel~legal_entity
              INNER JOIN @receivers AS rc
              ON cel~legal_entity  = rc~receivingentity
              AND cel~company_code = rc~receivercompanycode
              AND cel~sysid        = rc~receiversysid
              WHERE costelem~value_source = @/esrcc/if_calculate_chargeout=>scc_valuesource
                AND costelem~valid_from  <= @lv_validon
                AND costelem~valid_to    >= @lv_validon
              ORDER BY cel~sysid,
                       cel~company_code,
                       cel~legal_entity
              INTO TABLE @DATA(lt_costelement).


*SCC Virtual posting
        SELECT DISTINCT
               cb~fplv,
               cb~ryear,
               cb~poper,
               cb~sysid,
               cb~ccode,
               cb~legalentity,
               cb~Costobject,
               cb~Costcenter,
               co~uuid,
               co~ReceiverSysId,
               co~ReceiverCompanyCode,
               co~Receivingentity,
               co~ReceiverCostObject,
               co~ReceiverCostCenter,
               co~TotalChargeout AS TotalChargeoutAmount,
               co~currency,
               co~Exchdate
          FROM /ESRCC/I_ReceiverChargeout AS co
          INNER JOIN /esrcc/i_costbasestewardship AS cb
          ON co~RootUUID = cb~uuid
          INNER JOIN @lt_costelement AS ik
            ON co~ReceiverSysId        = ik~sysid
           AND co~Receivingentity      = ik~legal_entity
           AND co~ReceiverCompanyCode  = ik~company_code
        WHERE co~Currencytype   = 'G'
          AND cb~poper          = @<ls_poper>-low
          AND cb~ryear          = @<keys>-ryear
          AND cb~fplv           = @<keys>-fplv
          AND cb~Sysid          = @<keys>-sysid
          AND cb~Legalentity    = @<keys>-legalentity
          AND cb~ccode          = @<keys>-ccode
          AND cb~Costobject     = @<keys>-costobject
          AND cb~Costcenter     = @<keys>-costcenter
          AND co~Receivingentity IS NOT INITIAL
        INTO TABLE @DATA(lt_receiverchargeout).

        LOOP AT lt_receiverchargeout ASSIGNING FIELD-SYMBOL(<ls_receiverchargeout>).

          READ TABLE lt_costelement ASSIGNING FIELD-SYMBOL(<ls_costlement>)
                                    WITH KEY sysid = <ls_receiverchargeout>-ReceiverSysId
                                             company_code = <ls_receiverchargeout>-ReceiverCompanyCode
                                             legal_entity = <ls_receiverchargeout>-Receivingentity
                                             BINARY SEARCH.

          IF sy-subrc = 0.

            TRY.
                CALL METHOD cl_numberrange_runtime=>number_get
                  EXPORTING
                    nr_range_nr = '01'
                    object      = '/ESRCC/VP'
                  IMPORTING
                    number      = DATA(lv_number)
                    returncode  = DATA(lv_rcode).
              CATCH cx_nr_object_not_found
                    cx_number_ranges INTO DATA(cx_numberrange).
                DATA(error) = cx_numberrange->get_longtext(  ).
            ENDTRY.
            number = lv_number+10(10).
            ls_cbli-fplv         = <ls_receiverchargeout>-fplv.
            ls_cbli-ryear        = <ls_receiverchargeout>-ryear.
            ls_cbli-poper        = <ls_receiverchargeout>-Poper.
            ls_cbli-belnr        = number.
            ls_cbli-sysid        = <ls_receiverchargeout>-ReceiverSysId.
            ls_cbli-ccode        = <ls_receiverchargeout>-ReceiverCompanyCode.
            ls_cbli-legalentity  = <ls_receiverchargeout>-Receivingentity.
            ls_cbli-costobject   = <ls_receiverchargeout>-ReceiverCostObject.
            ls_cbli-costcenter   = <ls_receiverchargeout>-ReceiverCostCenter.
            ls_cbli-costelement  = <ls_costlement>-cost_element.
            ls_cbli-costind      = <ls_costlement>-costelem-cost_indicator.
            ls_cbli-costtype     = <ls_costlement>-costelem-cost_type.
            ls_cbli-usagecal     = <ls_costlement>-costelem-usage_type.
            ls_cbli-value_source = <ls_costlement>-costelem-value_source.
            ls_cbli-reasonid     = <ls_costlement>-costelem-reason_id.
            ls_cbli-postingtype  = <ls_costlement>-costelem-posting_type.

            ls_cbli-groupcurr           = group-group_currency.
            ls_cbli-ksl                 = <ls_receiverchargeout>-TotalChargeoutAmount.

            READ TABLE receivers ASSIGNING FIELD-SYMBOL(<receiver>)
                                            WITH KEY receivingentity = <ls_receiverchargeout>-Receivingentity
                                            BINARY SEARCH.
            IF sy-subrc = 0.
              ls_cbli-localcurr    = <ls_costlement>-local_curr.
              /esrcc/cl_utility_core=>currency_conversion(
                EXPORTING
                  amount          = <ls_receiverchargeout>-TotalChargeoutAmount
                  source_curr     = ls_cbli-groupcurr
                  target_curr     = ls_cbli-localcurr
                  validon         = <ls_receiverchargeout>-Exchdate
                IMPORTING
                  convertedamount = ls_cbli-hsl
              ).

            ENDIF.

            ls_cbli-vendor              = <ls_receiverchargeout>-Legalentity.
            ls_cbli-status              = /esrcc/if_calculate_chargeout=>approved.   "Approved
            ls_cbli-posting_sysid       = <ls_receiverchargeout>-Sysid.
            ls_cbli-posting_ccode       = <ls_receiverchargeout>-ccode.
            ls_cbli-posting_legalentity = <ls_receiverchargeout>-Legalentity.
            ls_cbli-posting_costobject  = <ls_receiverchargeout>-Costobject.
            ls_cbli-posting_costcenter  = <ls_receiverchargeout>-Costcenter.
* Admin data
            ls_cbli-created_by = sy-uname.
            /esrcc/cl_utility_core=>get_utc_date_time_ts(
              IMPORTING
                time_stamp = ls_cbli-created_at
            ).
            ls_cbli-last_changed_by = sy-uname.
            /esrcc/cl_utility_core=>get_utc_date_time_ts(
              IMPORTING
                time_stamp = ls_cbli-last_changed_at
            ).
            APPEND ls_cbli TO lt_cbli.
            CLEAR ls_cbli.
          ENDIF.
        ENDLOOP.
      ENDIF.

      MODIFY /esrcc/cb_li FROM TABLE @lt_cbli.

      CLEAR: lt_cbli, lt_receiverchargeout, lt_costelement, receivers.
    ENDLOOP.

  ENDMETHOD.
  METHOD set_process_control.

    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.

*update process control
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = process.    "Cost Base
      ls_procctrl-status = status.     "Cost Base Approved

*Admin data
      IF update = abap_false.
        ls_procctrl-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-created_at
        ).
      ENDIF.

      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.

  ENDMETHOD.

ENDCLASS.
