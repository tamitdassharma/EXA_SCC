CLASS /esrcc/cl_calculate_trueup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS: calculate_recalchargeout
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
        !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: finalize_recalchargeout
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
        !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: reopen_recalchargeout
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: calculate_recalseqchargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: finalize_recalseqchargeout
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
        !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: reopen_recalseqchargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: virtual_posting
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: determine_trueup
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
        !iv_workflow      TYPE abap_boolean DEFAULT abap_true.

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-METHODS: calculate_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_workflow      TYPE abap_boolean DEFAULT abap_true
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed        TYPE abap_boolean.

    CLASS-METHODS: calculate_servicecostshare
      IMPORTING
        !it_cbstw    TYPE /esrcc/tt_cbstw OPTIONAL
        !it_keys     TYPE /esrcc/tt_keys OPTIONAL
        !it_poper    TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_workflow TYPE abap_boolean DEFAULT abap_true
      EXPORTING
        !ev_failed   TYPE abap_boolean.

    CLASS-METHODS: calculate_chargeout
      IMPORTING
        !it_cbstw    TYPE /esrcc/tt_cbstw OPTIONAL
        !it_srvshare TYPE /esrcc/tt_srvshare OPTIONAL
        !it_keys     TYPE /esrcc/tt_keys OPTIONAL
        !it_poper    TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_workflow TYPE abap_boolean DEFAULT abap_true
      EXPORTING
        !ev_failed   TYPE abap_boolean.

    CLASS-METHODS: finalize_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: reopen_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: create_processlogs
      IMPORTING
        !iv_action      TYPE /esrcc/actions OPTIONAL
        !it_keys        TYPE /esrcc/tt_keys
      EXPORTING
        !et_processlogs TYPE /esrcc/tt_processlogs.

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

    CLASS-METHODS: set_prc_errorflag
      IMPORTING
        !keys   TYPE /esrcc/tt_keys
      EXPORTING
        !failed TYPE abap_boolean.

    CLASS-METHODS: determine_delta_chargeout
      IMPORTING
        !it_keys     TYPE /esrcc/tt_keys
        !it_poper    TYPE /esrcc/tt_poper_range
        !iv_workflow TYPE abap_boolean DEFAULT abap_true.

    CLASS-METHODS: determine_last_day
      IMPORTING
        !iv_ryear    TYPE /esrcc/ryear
        !iv_poper    TYPE poper
      EXPORTING
        !ev_valid_on TYPE /esrcc/validfrom.

    CLASS-METHODS: delete_virtual_postings
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: trigger_workflow
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
        !iv_application    TYPE /esrcc/application_type_de.

    CLASS-METHODS: delete_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: delete_trueups
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS: derive_poper
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
      EXPORTING
        !et_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: validate_costbase
      IMPORTING
        !it_poper           TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper   TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed          TYPE abap_boolean
        !ev_skip_validation TYPE abap_boolean
      CHANGING
        !ct_keys            TYPE /esrcc/tt_keys.

    CLASS-METHODS: validate_serviceproductcosting
      IMPORTING
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed        TYPE abap_boolean
        !et_srvkeys       TYPE /esrcc/tt_keys
      CHANGING
        !ct_keys          TYPE /esrcc/tt_keys.

    CLASS-METHODS: validate_receiverchargeout
      IMPORTING
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed        TYPE abap_boolean
      CHANGING
        !ct_keys          TYPE /esrcc/tt_keys.

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

    CLASS-METHODS: determine_validon
      IMPORTING
                !it_keys       TYPE /esrcc/tt_keys
                !it_poper      TYPE /esrcc/tt_poper_range
      RETURNING VALUE(validon) TYPE /esrcc/validfrom.

    CLASS-METHODS: check_if_objects_are_finalized
      IMPORTING
        !it_poper         TYPE /esrcc/tt_poper_range
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed        TYPE abap_boolean
      CHANGING
        !ct_keys          TYPE /esrcc/tt_keys.


ENDCLASS.



CLASS /esrcc/cl_calculate_trueup IMPLEMENTATION.


  METHOD add_logmessages.


  ENDMETHOD.


  METHOD authority_check.

    CLEAR failed.

*    Authorisation Check
    IF action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout OR
       action = /esrcc/if_calculate_chargeout=>calculate_recalseqchargeout.

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
    ELSEIF action = /esrcc/if_calculate_chargeout=>finalize_recalchargeout OR
           action = /esrcc/if_calculate_chargeout=>finalize_recalseqchargeout.

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
    ELSEIF action = /esrcc/if_calculate_chargeout=>reopen_recalchargeout OR
           action = /esrcc/if_calculate_chargeout=>reopen_recalseqchargeout.

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

  METHOD calculate_chargeout.

    DATA lt_rec_chg     TYPE TABLE OF /esrcc/rec_chg.
    DATA lt_rec_share   TYPE TABLE OF /esrcc/alocshare.
    DATA lt_aloc_values TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_procctrl    TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl    TYPE  /esrcc/procctrl.
    DATA ls_wf_leadobj  TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj  TYPE /esrcc/tt_wf_leadingobject.
    DATA lv_valid_from  TYPE /esrcc/validfrom.
    DATA lo_badi     TYPE REF TO /esrcc/badi_trueuprecal.


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

    CHECK lt_keys IS NOT INITIAL.


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

*Receiver charge out and markup
    SELECT keys~cc_uuid, recshare~*
       FROM /esrcc/i_chg_recshare_trueup  AS recshare
       INNER JOIN @it_cbstw AS keys
          ON recshare~fplv           = keys~fplv
         AND recshare~ryear          = keys~ryear
         AND recshare~poper          = keys~poper
         AND recshare~sysid          = keys~sysid
         AND recshare~legalentity    = keys~legalentity
         AND recshare~ccode          = keys~ccode
         AND recshare~costobject     = keys~costobject
         AND recshare~costcenter     = keys~costcenter
*         AND recshare~serviceproduct = keys~serviceproduct
*         WHERE recshare~poper         IN @_poper
         INTO TABLE @DATA(lt_rec_cost).

    CHECK lt_rec_cost IS NOT INITIAL.

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
       INNER JOIN @it_cbstw AS keys
               ON indkpishare~fplv           = keys~fplv
              AND indkpishare~ryear          = keys~ryear
              AND indkpishare~poper          = keys~poper
              AND indkpishare~sysid          = keys~sysid
              AND indkpishare~legalentity    = keys~legalentity
              AND indkpishare~ccode          = keys~ccode
              AND indkpishare~costobject     = keys~costobject
              AND indkpishare~costcenter     = keys~costcenter
*              AND indkpishare~serviceproduct = keys~serviceproduct
*              WHERE indkpishare~poper        IN @_poper
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
        INNER JOIN @it_cbstw AS keys
                ON  indallocvalues~fplv        = keys~fplv
               AND  indallocvalues~ryear       = keys~ryear
               AND  indallocvalues~poper       = keys~poper
               AND  indallocvalues~sysid       = keys~sysid
               AND  indallocvalues~legalentity = keys~legalentity
               AND  indallocvalues~ccode       = keys~ccode
               AND  indallocvalues~costobject  = keys~costobject
               AND  indallocvalues~costcenter  = keys~costcenter
*               AND  indallocvalues~serviceproduct = keys~serviceproduct
*               WHERE  indallocvalues~poper      IN @_poper
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
                                GROUP BY ( legalentity = ls_rec_cost-recshare-legalentity )
                                INTO DATA(entitygroup).


      LOOP AT GROUP entitygroup ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).

        APPEND INITIAL LINE TO lt_rec_chg ASSIGNING FIELD-SYMBOL(<ls_rec_chg>).
        MOVE-CORRESPONDING <ls_rec_cost>-recshare TO <ls_rec_chg>.

        IF iv_workflow EQ abap_true.
*          CLEAR ls_wf_leadobj.
*          MOVE-CORRESPONDING <ls_rec_cost> TO ls_wf_leadobj.
*          APPEND ls_wf_leadobj TO lt_wf_leadobj.
          <ls_rec_chg>-status = /esrcc/if_calculate_chargeout=>inprocess.   "In Process
        ELSE.
          <ls_rec_chg>-status = /esrcc/if_calculate_chargeout=>approved.   "Approved
        ENDIF.
        <ls_rec_chg>-invoicestatus = '01'.
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

        READ TABLE it_srvshare ASSIGNING FIELD-SYMBOL(<srvshare>)
                               WITH KEY cc_uuid        = <ls_rec_cost>-cc_uuid
                                        serviceproduct = <ls_rec_cost>-recshare-serviceproduct.
        IF sy-subrc = 0.
          <ls_rec_chg>-cc_uuid  = <srvshare>-cc_uuid.
          <ls_rec_chg>-srv_uuid = <srvshare>-srv_uuid.
        ENDIF.

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
            iv_ryear    = <ls_rec_cost>-recshare-ryear
            iv_poper    = <ls_rec_cost>-recshare-poper
          IMPORTING
            ev_valid_on = <ls_rec_chg>-exchdate
        ).

* Assign the 16 digit unique identifier for allocation share
        READ TABLE lt_allocation_share TRANSPORTING NO FIELDS WITH KEY
                                           fplv           = <ls_rec_cost>-recshare-fplv
                                          ryear           = <ls_rec_cost>-recshare-ryear
                                          sysid           = <ls_rec_cost>-recshare-sysid
                                          poper           = <ls_rec_cost>-recshare-poper
                                          legalentity     = <ls_rec_cost>-recshare-legalentity
                                          ccode           = <ls_rec_cost>-recshare-ccode
                                          costobject      = <ls_rec_cost>-recshare-costobject
                                          costcenter      = <ls_rec_cost>-recshare-costcenter
                                          serviceproduct  = <ls_rec_cost>-recshare-serviceproduct
                                          ReceiverSysId   = <ls_rec_cost>-recshare-receiversysid
                                          ReceiverCompanyCode = <ls_rec_cost>-recshare-receivercompanycode
                                          ReceivingEntity = <ls_rec_cost>-recshare-receivingentity
                                          ReceiverCostObject = <ls_rec_cost>-recshare-receivercostobject
                                          ReceiverCostCenter = <ls_rec_cost>-recshare-receivercostcenter
                                          BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_allocation_share ASSIGNING FIELD-SYMBOL(<ls_allocation_share>) FROM sy-tabix.

            IF <ls_allocation_share>-fplv           = <ls_rec_cost>-recshare-fplv
              AND <ls_allocation_share>-ryear       = <ls_rec_cost>-recshare-ryear
              AND <ls_allocation_share>-sysid       = <ls_rec_cost>-recshare-sysid
              AND <ls_allocation_share>-poper       = <ls_rec_cost>-recshare-poper
              AND <ls_allocation_share>-legalentity = <ls_rec_cost>-recshare-legalentity
              AND <ls_allocation_share>-ccode       = <ls_rec_cost>-recshare-ccode
              AND <ls_allocation_share>-costobject  = <ls_rec_cost>-recshare-costobject
              AND <ls_allocation_share>-costcenter  = <ls_rec_cost>-recshare-costcenter
              AND <ls_allocation_share>-serviceproduct      = <ls_rec_cost>-recshare-serviceproduct
              AND <ls_allocation_share>-ReceiverSysId       = <ls_rec_cost>-recshare-receiversysid
              AND <ls_allocation_share>-ReceiverCompanyCode = <ls_rec_cost>-recshare-receivercompanycode
              AND <ls_allocation_share>-ReceivingEntity     = <ls_rec_cost>-recshare-receivingentity
              AND <ls_allocation_share>-ReceiverCostObject  = <ls_rec_cost>-recshare-receivercostobject
              AND <ls_allocation_share>-ReceiverCostCenter  = <ls_rec_cost>-recshare-receivercostcenter.

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
                                                 fplv            = <ls_rec_cost>-recshare-fplv
                                                 ryear            = <ls_rec_cost>-recshare-ryear
                                                 sysid            = <ls_rec_cost>-recshare-sysid
                                                 poper            = <ls_rec_cost>-recshare-poper
                                                 legalentity      = <ls_rec_cost>-recshare-legalentity
                                                 ccode            = <ls_rec_cost>-recshare-ccode
                                                 costobject       = <ls_rec_cost>-recshare-costobject
                                                 costcenter       = <ls_rec_cost>-recshare-costcenter
                                                 serviceproduct   = <ls_rec_cost>-recshare-serviceproduct
                                                 ReceiverSysId    = <ls_rec_cost>-recshare-receiversysid
                                                 ReceiverCompanyCode = <ls_rec_cost>-recshare-receivercompanycode
                                                 ReceivingEntity  = <ls_rec_cost>-recshare-receivingentity
                                                 ReceiverCostObject = <ls_rec_cost>-recshare-receivercostobject
                                                 ReceiverCostCenter = <ls_rec_cost>-recshare-receivercostcenter
                                                 KeyVersion         = <ls_allocation_share>-KeyVersion
                                                 Allockey           = <ls_allocation_share>-Allockey
                                                 BINARY SEARCH.
              IF sy-subrc = 0.
                LOOP AT lt_allocation_values ASSIGNING FIELD-SYMBOL(<ls_allocation_values>) FROM sy-tabix.

                  IF  <ls_allocation_values>-fplv                 = <ls_rec_cost>-recshare-fplv
                      AND <ls_allocation_values>-ryear            = <ls_rec_cost>-recshare-ryear
                      AND <ls_allocation_values>-sysid            = <ls_rec_cost>-recshare-sysid
                      AND <ls_allocation_values>-poper            = <ls_rec_cost>-recshare-poper
                      AND <ls_allocation_values>-legalentity      = <ls_rec_cost>-recshare-legalentity
                      AND <ls_allocation_values>-ccode            = <ls_rec_cost>-recshare-ccode
                      AND <ls_allocation_values>-costobject       = <ls_rec_cost>-recshare-costobject
                      AND <ls_allocation_values>-costcenter       = <ls_rec_cost>-recshare-costcenter
                      AND <ls_allocation_values>-serviceproduct   = <ls_rec_cost>-recshare-serviceproduct
                      AND <ls_allocation_values>-ReceiverSysId    = <ls_rec_cost>-recshare-receiversysid
                      AND <ls_allocation_values>-ReceiverCompanyCode = <ls_rec_cost>-recshare-receivercompanycode
                      AND <ls_allocation_values>-ReceivingEntity  = <ls_rec_cost>-recshare-receivingentity
                      AND <ls_allocation_values>-ReceiverCostObject = <ls_rec_cost>-recshare-receivercostobject
                      AND <ls_allocation_values>-ReceiverCostCenter = <ls_rec_cost>-recshare-receivercostcenter
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


**********************************************************
*Handling of delta for direct chargeout Scenario
**********************************************************
    determine_delta_chargeout(
      it_keys  = it_keys
      it_poper = _poper
      iv_workflow = iv_workflow
    ).

    CLEAR: lt_rec_chg, lt_rec_share, lt_aloc_values.

  ENDMETHOD.


  METHOD calculate_costbase.

    DATA lt_cc_cost    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_cb_li      TYPE TABLE OF /esrcc/cb_li.
    DATA lt_tmp_cost   TYPE TABLE OF /esrcc/cb_stw.
    DATA validon       TYPE /esrcc/validfrom.
    DATA lo_badi       TYPE REF TO /esrcc/badi_trueuprecal.

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

    CHECK lt_keys IS NOT INITIAL.

    CLEAR: lt_wf_leadobj.

*Delete old as user might have re-triggered costbase & stewardship calculation
    delete_costbase(
      it_keys  = lt_keys
      it_poper = _poper
      iv_recalrefpoper = iv_recalrefpoper
    ).

    SELECT coststw~* FROM /esrcc/i_cb_stewardship_trueup AS coststw
            INNER JOIN @lt_keys AS keys
                    ON  coststw~fplv       = keys~fplv
                   AND coststw~ryear       = keys~ryear
                   AND coststw~sysid       = keys~sysid
                   AND coststw~legalentity = keys~legalentity
                   AND coststw~ccode       = keys~ccode
                   AND coststw~costobject  = keys~costobject
                   AND coststw~costcenter  = keys~costcenter
                   WHERE coststw~poper     IN @_poper
                   INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.

    IF iv_workflow = abap_true.
      /esrcc/cl_wf_utility=>is_wf_on(
        EXPORTING
          iv_apptype   = /esrcc/if_calculate_chargeout=>trueuprecal
        IMPORTING
          ev_wf_active = DATA(wf_active)
      ).
    ENDIF.

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
        <ls_cc_cost>-recalrefpoper = iv_recalrefpoper.
        <ls_cc_cost>-processtype = /esrcc/if_calculate_chargeout=>recalprocesstype.
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
          ls_wf_leadobj-refpoper = iv_recalrefpoper.
          APPEND ls_wf_leadobj TO lt_wf_leadobj.
          <ls_cc_cost>-status = /esrcc/if_calculate_chargeout=>inprocess.
        ELSE.
          <ls_cc_cost>-status = /esrcc/if_calculate_chargeout=>approved.   "Approval
        ENDIF.

        APPEND <ls_cc_cost> TO lt_tmp_cost.

      ENDLOOP.

*link cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        SELECT cb~*,
               ik~cc_uuid AS cc_guid,
               @iv_recalrefpoper AS recalrefpoper,
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
           AND cb~value_source <> @/esrcc/if_calculate_chargeout=>scc_valuesource
           AND cb~status = @/esrcc/if_calculate_chargeout=>approved
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.

      CLEAR: lt_tmp_cost, lt_cb_li.
    ENDLOOP.

    MODIFY /esrcc/cb_stw FROM TABLE @lt_cc_cost.

    calculate_servicecostshare(
      EXPORTING
        it_cbstw  = lt_cc_cost
        it_keys   = lt_keys
        it_poper  = _poper
        iv_workflow = wf_active
    ).

**********************************************************
*           SCC Virtual posting
**********************************************************
    IF lo_badi IS NOT BOUND.
      TRY.
          GET BADI lo_badi.
        CATCH cx_badi_not_implemented cx_badi_unknown_error.
      ENDTRY.
    ENDIF.

    IF lo_badi IS BOUND.

      CALL BADI lo_badi->virtual_posting
        EXPORTING
          it_keys          = it_keys
          it_poper         = _poper
          iv_recalrefpoper = iv_recalrefpoper.

    ENDIF.

    IF iv_recalrefpoper = it_keys[ 1 ]-poper.
**********************************************************
*           Determine & Save Trueup
**********************************************************
      IF lo_badi IS BOUND.

        CALL BADI lo_badi->determine_trueup
          EXPORTING
            it_keys          = it_keys
            it_poper         = _poper
            iv_recalrefpoper = iv_recalrefpoper
            iv_workflow      = wf_active.

      ENDIF.

**********************************************************
*Check if workflow is to be triggered
**********************************************************
      IF iv_workflow EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
        trigger_workflow(
          it_leading_object = lt_wf_leadobj
          iv_application    = /esrcc/if_calculate_chargeout=>trueuprecal
        ).
      ENDIF.

**********************************************************
*Add process control status for monitoring in execution cockpit
**********************************************************
      set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>trueuprecal
          status  = COND #( WHEN wf_active = abap_true THEN /esrcc/if_calculate_chargeout=>recalculation_inprocess
                                                       ELSE /esrcc/if_calculate_chargeout=>recalculation_approved )
          update  = abap_false
*      IMPORTING
*        failed  =
      ).

**********************************************************
*Add process logs for traceability
**********************************************************
      create_processlogs(
        iv_action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
        it_keys   = lt_procctrl
      ).

    ENDIF.

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

    CHECK lt_keys IS NOT INITIAL.

    SELECT DISTINCT lk~cc_uuid,cu~*
      FROM /esrcc/i_chr_unitcost_trueup AS cu
      INNER JOIN @it_cbstw AS lk
        ON cu~fplv          = lk~fplv
       AND cu~ryear         = lk~ryear
       AND cu~poper         = lk~poper
       AND cu~sysid         = lk~sysid
       AND cu~legalentity   = lk~legalentity
       AND cu~ccode         = lk~ccode
       AND cu~costobject    = lk~costobject
       AND cu~costcenter    = lk~costcenter
    INTO TABLE @DATA(lt_srv_cost).


    CHECK lt_srv_cost IS NOT INITIAL.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).



    LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>).

      APPEND INITIAL LINE TO lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).


      MOVE-CORRESPONDING <ls_srv_cost>-cu TO <ls_srvshare>.
      IF iv_workflow EQ abap_true.
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
            <ls_srvshare>-cc_uuid = <ls_srv_cost>-cc_uuid.
            <ls_srvshare>-srv_uuid = lo_uuid->create_uuid_x16( ).
            <ls_srvshare>-commentid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
    ENDLOOP.

    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.

    calculate_chargeout(
     EXPORTING
       it_cbstw    = it_cbstw
       it_srvshare = lt_srvshare
       it_keys     = it_keys
       it_poper    = _poper
       iv_workflow = iv_workflow
   ).



    CLEAR: lt_procctrl, lt_srvshare, lt_srv_cost.

  ENDMETHOD.


  METHOD create_loginstance.

    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitem       TYPE /esrcc/log_item.

*    IF key-serviceproduct IS INITIAL.

    READ TABLE procctrl ASSIGNING FIELD-SYMBOL(<procctrl>) WITH KEY fplv           = key-fplv
                                                                      ryear         = key-ryear
                                                                      poper         = key-poper
                                                                      sysid         = key-sysid
                                                                      legalentity   = key-legalentity
                                                                      ccode         = key-ccode
                                                                      costobject    = key-costobject
                                                                      costcenter    = key-costcenter
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
    CONCATENATE key-fplv key-ryear key-poper INTO DATA(perioddetials) SEPARATED BY '-'.
*      CONCATENATE 'Period:' perioddetials INTO logitem-message_v1 SEPARATED BY space.
    CONCATENATE key-sysid key-legalentity key-ccode INTO logitem-message_v2 SEPARATED BY '/'.
    CONCATENATE 'Entity:' logitem-message_v2 INTO logitem-message_v2 SEPARATED BY space.
    CONCATENATE key-costobject key-costcenter INTO logitem-message_v3 SEPARATED BY '/'.
    CONCATENATE 'Object:' logitem-message_v3 INTO logitem-message_v3 SEPARATED BY space.
    loginstance->add_message(
      EXPORTING
        log_message      = logitem
    ).
*    ELSE.
*
*      READ TABLE procctrl ASSIGNING <procctrl> WITH KEY fplv             = key-fplv
*                                                        ryear          = key-ryear
*                                                        poper          = key-poper
*                                                        sysid          = key-sysid
*                                                        legalentity    = key-legalentity
*                                                        ccode          = key-ccode
*                                                        costobject     = key-costobject
*                                                        costcenter     = key-costcenter
*                                                        serviceproduct = key-serviceproduct
**                                                        billingfreq    = key-billingfreq
**                                                        billingperiod  = key-billingperiod
*                                                        process        = process BINARY SEARCH.
*
*      IF sy-subrc = 0 AND <procctrl>-log_header_uuid IS NOT INITIAL.
** check if logid is already available then call resue instance to get the existence instance
*        /esrcc/cl_application_logs=>reuse_instance(
*          EXPORTING
*            log_header_id = <procctrl>-log_header_uuid
*          RECEIVING
*            instance      = loginstance
*        ).
*
**    Clear old messages
*        loginstance->clear_messages( ).
*
*      ELSE.
**  create a new instance
*        /esrcc/cl_application_logs=>create_instance(
*          EXPORTING
*            deter_save = abap_true
*          RECEIVING
*            instance   = loginstance
*        ).
*
**    set log header info
*        loghdr-application      = 'EXE'.
*        loghdr-sub_application  = process.
*        loghdr-company_code     = key-ccode.
*        loghdr-legal_entity     = key-legalentity.
*        loghdr-planning_version = key-fplv.
*        loghdr-reporting_year   = key-ryear.
*        loghdr-system_id        = key-sysid.
*        loginstance->set_log_header_info( log_header = loghdr ).
*      ENDIF.
*
**  set header message about the object
*      CLEAR logitem.
*      logitem-message_id = '/ESRCC/EXECCOCKPIT'.
*      logitem-message_number = '022'.
*      logitem-message_type = 'I'.
*      CONCATENATE key-fplv key-ryear key-poper INTO perioddetials SEPARATED BY '-'.
**      CONCATENATE 'Period:' perioddetials INTO logitem-message_v1 SEPARATED BY space.
*      CONCATENATE key-sysid key-legalentity key-ccode INTO logitem-message_v2 SEPARATED BY '/'.
*      CONCATENATE 'Entity:' logitem-message_v2 INTO logitem-message_v2 SEPARATED BY space.
*      CONCATENATE key-costobject key-costcenter key-serviceproduct INTO logitem-message_v3 SEPARATED BY '/'.
*      CONCATENATE 'Object:' logitem-message_v3 INTO logitem-message_v3 SEPARATED BY space.
*      loginstance->add_message(
*        EXPORTING
*          log_message      = logitem
*      ).
*
*    ENDIF.
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

  METHOD delete_costbase.

    DATA lt_tmp_cost TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_cb_li    TYPE TABLE OF /esrcc/cb_li.
    DATA lv_refguid  TYPE sysuuid_x16.
    DATA lv_recalpoper TYPE /esrcc/poper.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT cb_stw~*
      FROM /esrcc/cb_stw AS cb_stw
      INNER JOIN @it_keys AS it_keys
*        ON cb_stw~fplv         = it_keys~fplv
        ON cb_stw~ryear        = it_keys~ryear
       AND cb_stw~sysid        = it_keys~sysid
       AND cb_stw~legalentity  = it_keys~legalentity
       AND cb_stw~ccode        = it_keys~ccode
       AND cb_stw~costobject   = it_keys~costobject
       AND cb_stw~costcenter   = it_keys~costcenter
    WHERE cb_stw~poper IN @it_poper
*      AND cb_stw~processtype = @/esrcc/if_calculate_chargeout=>recalprocesstype
      AND cb_stw~recalrefpoper = @iv_recalrefpoper
    INTO TABLE @DATA(lt_cbstw).

    SELECT srv_share~*
      FROM /esrcc/srv_share AS srv_share
      INNER JOIN @lt_cbstw AS cbstw
        ON cbstw~cc_uuid = srv_share~cc_uuid
       INTO TABLE @DATA(lt_srvshare).

    SELECT rec_chg~*
       FROM /esrcc/rec_chg AS rec_chg
       INNER JOIN @lt_cbstw AS cbstw
         ON cbstw~cc_uuid = rec_chg~cc_uuid
        INTO TABLE @DATA(lt_recchg).

    IF lt_recchg IS NOT INITIAL.
*  Delete Service Allocation
      SELECT alocshare~*
        FROM /esrcc/alocshare AS alocshare
        INNER JOIN @lt_recchg AS recshare
          ON alocshare~parentuuid = recshare~rec_uuid
      INTO TABLE @DATA(lt_alocshare).
      IF lt_alocshare IS NOT INITIAL.
        SELECT *
          FROM /esrcc/alcvalues AS alcvalues
          INNER JOIN @lt_alocshare AS alocshare
            ON alcvalues~parentuuid = alocshare~uuid
        INTO TABLE @DATA(lt_alocvalues).
      ENDIF.
    ENDIF.

*reset cost base line items.
    LOOP AT lt_cbstw INTO DATA(ls_cbstw)
                       GROUP BY ( legalentity = ls_cbstw-legalentity )
                       INTO DATA(entitygroup).

      CLEAR lt_tmp_cost.
      LOOP AT GROUP entitygroup INTO DATA(cbstw).
        APPEND cbstw TO lt_tmp_cost.
      ENDLOOP.

*reset cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        CLEAR lt_cb_li.
        SELECT cb~*,
               @/esrcc/if_calculate_chargeout=>approved AS status,
               @lv_refguid AS cc_guid,
               @lv_recalpoper AS recalrefpoper,
               @sy-uname AS last_changed_by,
               @last_changed_at AS last_changed_at
          FROM /esrcc/cb_li AS cb
          INNER JOIN @lt_tmp_cost AS ik
            ON cb~cc_guid = ik~cc_uuid
          WHERE cb~recalrefpoper = @iv_recalrefpoper
            AND cb~value_source <> 'SCC'
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.

    ENDLOOP.

**Reopen Virtual posting in case done during finalizing chargeouts.
    delete_virtual_postings(
      it_keys  = it_keys
      it_poper = it_poper
      iv_recalrefpoper = iv_recalrefpoper
    ).

**Delete trueups
    delete_trueups(
      it_keys          = it_keys
      it_poper         = it_poper
      iv_recalrefpoper = iv_recalrefpoper
    ).

    DELETE /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    DELETE /esrcc/srv_share FROM TABLE @lt_srvshare.
    DELETE /esrcc/rec_chg   FROM TABLE @lt_recchg.
    DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
    DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.

    CLEAR: lt_cbstw,
           lt_srvshare,
           lt_recchg,
           lt_alocshare,
           lt_alocvalues,
           lt_tmp_cost,
           lt_cb_li.

  ENDMETHOD.

  METHOD delete_virtual_postings.


    SELECT *
      FROM /esrcc/cb_li AS cb
      INNER JOIN @it_keys AS ik
*        ON cb~fplv                 = ik~fplv
       ON  cb~ryear                = ik~ryear
       AND cb~posting_sysid        = ik~sysid
       AND cb~posting_legalentity  = ik~legalentity
       AND cb~posting_ccode        = ik~ccode
       AND cb~posting_costobject   = ik~costobject
       AND cb~posting_costcenter   = ik~costcenter
    WHERE cb~poper IN @it_poper
      AND cb~value_source = 'SCC'
      AND cb~recalrefpoper = @iv_recalrefpoper
    INTO TABLE @DATA(lt_costbase).

    DELETE /esrcc/cb_li FROM TABLE @lt_costbase.

  ENDMETHOD.


  METHOD derive_poper.

    DATA poper TYPE /esrcc/poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      WHILE ( poper < <key>-poper ).
        poper = poper + 1.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = poper high = '' ) TO et_poper.
      ENDWHILE.
      SORT et_poper BY low.
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
           rec_chg~rec_uuid,
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
*           AND srv_share~serviceproduct = ik~serviceproduct
        WHERE cb_stw~poper IN @it_poper
        ORDER BY rec_chg~cc_uuid,
                 rec_chg~srv_uuid,
                 rec_chg~rec_uuid
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
*           AND srv_share~serviceproduct = ik~serviceproduct
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
        IF iv_workflow = abap_true.
          <recshare>-status = /esrcc/if_calculate_chargeout=>approval_pending.
        ELSE.
          <recshare>-status = /esrcc/if_calculate_chargeout=>approved.
        ENDIF.
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

  METHOD finalize_costbase.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA lt_cbstw    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srvshare TYPE TABLE OF /esrcc/srv_share.
    DATA lt_trueup   TYPE TABLE OF /esrcc/trueup.
    DATA lt_cb_li    TYPE TABLE OF /esrcc/cb_li.
    DATA lt_tmp_cost TYPE TABLE OF /esrcc/cb_stw.
    DATA number      TYPE /esrcc/doc_no.
    DATA lo_badi     TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_recshare TYPE TABLE OF /esrcc/rec_chg.
    DATA lv_invoicestatus TYPE /esrcc/invoicestatus VALUE '01'.

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
*        ON cb~fplv        = ik~fplv
       ON  cb~ryear       = ik~ryear
       AND cb~sysid       = ik~sysid
       AND cb~legalentity = ik~legalentity
       AND cb~ccode       = ik~ccode
       AND cb~costobject  = ik~costobject
       AND cb~costcenter  = ik~costcenter
*       AND cb~processtype = @/esrcc/if_calculate_chargeout=>recalprocesstype
     WHERE cb~poper IN @_poper
       AND cb~recalrefpoper = @iv_recalrefpoper
    INTO CORRESPONDING FIELDS OF TABLE @lt_cbstw.

*Finalize service product costing
    SELECT srv_share~*,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
      FROM /esrcc/srv_share AS srv_share
       INNER JOIN @lt_cbstw AS cb_stw
        ON cb_stw~cc_uuid = srv_share~cc_uuid
    INTO CORRESPONDING FIELDS OF TABLE @lt_srvshare.

*Finalize calculated receiever
    SELECT rec_chg~*,
           @lv_invoicestatus AS invoicestatus,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
          FROM /esrcc/rec_chg AS rec_chg
          INNER JOIN @lt_cbstw AS cbstw
            ON cbstw~cc_uuid = rec_chg~cc_uuid
        INTO CORRESPONDING FIELDS OF TABLE @lt_recshare.


*Finalize cost base line items.
    LOOP AT lt_cbstw INTO DATA(ls_cbstw)
                       GROUP BY ( legalentity = ls_cbstw-legalentity )
                       INTO DATA(entitygroup).

      CLEAR lt_tmp_cost.
      LOOP AT GROUP entitygroup INTO DATA(cbstw).
        APPEND cbstw TO lt_tmp_cost.
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
            ON cb~cc_guid     = ik~cc_uuid
           WHERE cb~recalrefpoper = @iv_recalrefpoper
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.
      FREE: lt_tmp_cost,
            lt_cb_li.
    ENDLOOP.

*finalize True-ups
    SELECT trueup~*,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
        FROM /esrcc/trueup AS trueup
        INNER JOIN @lt_keys AS ik
*        ON cb~fplv        = ik~fplv
       ON  trueup~ryear       = ik~ryear
       AND trueup~sysid       = ik~sysid
       AND trueup~legalentity = ik~legalentity
       AND trueup~ccode       = ik~ccode
       AND trueup~costobject  = ik~costobject
       AND trueup~costcenter  = ik~costcenter
*       AND cb~processtype = @/esrcc/if_calculate_chargeout=>recalprocesstype
     WHERE trueup~poper IN @_poper
       AND trueup~recalrefpoper = @iv_recalrefpoper
    INTO CORRESPONDING FIELDS OF TABLE @lt_trueup.

*update execution process control
    set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_finalized
        update  = abap_true
    ).

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>finalize_recalchargeout
      it_keys   = lt_procctrl
    ).


    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_recshare.
    MODIFY /esrcc/trueup    FROM TABLE @lt_trueup.

    FREE: lt_cbstw,
          lt_tmp_cost,
          lt_procctrl,
          lt_trueup,
          lt_cb_li.

  ENDMETHOD.


  METHOD reopen_costbase.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lt_alocshare  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_cb_li TYPE TABLE OF /esrcc/cb_li.

*Derive poper from billing frequency customizing
    derive_poper(
        EXPORTING
          it_keys  = it_keys
        IMPORTING
          et_poper = DATA(_poper)
      ).

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE costcenter IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

*  Delete cost center cost
    delete_costbase(
      it_keys  = lt_keys
      it_poper = _poper
      iv_recalrefpoper = iv_recalrefpoper
    ).

*Update execution cockpit process control
    SELECT pc~*
      FROM /esrcc/procctrl AS pc
      INNER JOIN @lt_keys AS ik
*        ON pc~fplv          = ik~fplv
       ON  pc~ryear         = ik~ryear
       AND pc~sysid         = ik~sysid
       AND pc~legalentity   = ik~legalentity
       AND pc~ccode         = ik~ccode
       AND pc~costobject    = ik~costobject
       AND pc~costcenter    = ik~costcenter
       AND pc~poper         = @iv_recalrefpoper
       AND pc~process       = @/esrcc/if_calculate_chargeout=>trueuprecal
    INTO TABLE @lt_procctrl.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>reopen_recalchargeout
      it_keys   = lt_procctrl
    ).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.

    CLEAR: lt_procctrl.

  ENDMETHOD.

  METHOD reopen_recalseqchargeout.

    DATA ls_key TYPE /esrcc/procctrl.
    DATA lt_keys TYPE /esrcc/tt_keys.

*get the chain and sequence.
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS it_keys
          ON stewardship~sysid       = it_keys~sysid
         AND stewardship~legalentity = it_keys~legalentity
         AND stewardship~CompanyCode = it_keys~ccode
         AND stewardship~costobject  = it_keys~costobject
         AND stewardship~costcenter  = it_keys~costcenter
         AND stewardship~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
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
        ls_key-poper = <keys>-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_keys.

        reopen_costbase( it_keys = lt_keys
                         iv_recalrefpoper = recalrefpoper ).

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD calculate_recalseqchargeout.

    DATA ls_key     TYPE /esrcc/procctrl.
    DATA lt_keys    TYPE /esrcc/tt_keys.
    DATA lv_validon TYPE /esrcc/validfrom.
    DATA lt_poper   TYPE /esrcc/tt_poper_range.

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
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS it_keys
          ON stewardship~sysid       = it_keys~sysid
         AND stewardship~legalentity = it_keys~legalentity
         AND stewardship~CompanyCode = it_keys~ccode
         AND stewardship~costobject  = it_keys~costobject
         AND stewardship~costcenter  = it_keys~costcenter
         AND stewardship~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
      WHERE stewardship~chain_id IS NOT INITIAL
      INTO TABLE @DATA(lt_stewardship).

      IF lt_stewardship IS NOT INITIAL.
        SELECT DISTINCT stewardship~*
          FROM /ESRCC/I_Stewardship AS stewardship
          INNER JOIN @lt_stewardship AS lt_stewardship
            ON stewardship~chain_id = lt_stewardship~chain_id
        INTO TABLE @DATA(lt_chain_stw).

      ENDIF.


      SORT lt_chain_stw BY chain_id chain_sequence validfrom.



      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>).

        LOOP AT _poper ASSIGNING FIELD-SYMBOL(<poper>).


          CLEAR: lv_validon, lt_poper.
          CLEAR: ls_key, lt_keys.
          APPEND <poper> TO lt_poper.
          CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO lv_validon.

          IF <ls_chain_stw>-ValidFrom <= lv_validon AND <ls_chain_stw>-Validto   >= lv_validon.

            MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
            ls_key-poper = <poper>-low.
            ls_key-ryear = <keys>-ryear.
            ls_key-fplv = <keys>-fplv.
            ls_key-ccode = <ls_chain_stw>-CompanyCode.
            APPEND ls_key TO lt_keys.

********************************************************************
*                   Perform Consistency Checks
*********************************************************************
            check_if_objects_are_finalized(
               EXPORTING
                 it_poper         = lt_poper
                 iv_recalrefpoper = recalrefpoper
               IMPORTING
                 ev_failed        = DATA(failed)
               CHANGING
                 ct_keys          = lt_keys
             ).

            IF failed = abap_true.
              RETURN.
            ENDIF.

            validate_costbase(
              EXPORTING
                it_poper  = lt_poper
                iv_recalrefpoper = recalrefpoper
              IMPORTING
                ev_failed          = failed
                ev_skip_validation = DATA(ignore_error)
              CHANGING
                ct_keys   = lt_keys
            ).

            IF failed = abap_true.
*Set error for root node to stop finalization process
              CONCATENATE <keys>-ryear recalrefpoper+1(2) '01' INTO lv_validon.
              LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<root_node>)
                             WHERE ValidFrom <= lv_validon
                               AND Validto   >= lv_validon
                               AND chain_id  = <ls_chain_stw>-chain_id
                               AND chain_sequence = 1.

                CLEAR: ls_key, lt_keys.
                MOVE-CORRESPONDING <root_node> TO ls_key.
                ls_key-poper = recalrefpoper.
                ls_key-ryear = <keys>-ryear.
                ls_key-fplv  = <keys>-fplv.
                ls_key-ccode = <root_node>-CompanyCode.
                APPEND ls_key TO lt_keys.
                set_prc_errorflag(
                  EXPORTING
                    keys   = lt_keys
*                IMPORTING
*                  failed =
                ).

*    Stop the chain executed and report the errors in log and exit
                RETURN.
              ENDLOOP.
            ENDIF.

            IF ignore_error = abap_false.
              validate_serviceproductcosting(
                EXPORTING
                  it_poper  = lt_poper
                  iv_recalrefpoper = recalrefpoper
                IMPORTING
                  ev_failed = failed
                CHANGING
                  ct_keys   = lt_keys
              ).

              IF failed = abap_true.
*Set error for root node to stop finalization process
                CONCATENATE <keys>-ryear recalrefpoper+1(2) '01' INTO lv_validon.
                LOOP AT lt_chain_stw ASSIGNING <root_node>
                              WHERE ValidFrom <= lv_validon
                                AND Validto   >= lv_validon
                                AND chain_id  = <ls_chain_stw>-chain_id
                                AND chain_sequence = 1.

                  CLEAR: ls_key, lt_keys.
                  MOVE-CORRESPONDING <root_node> TO ls_key.
                  ls_key-poper = recalrefpoper.
                  ls_key-ryear = <keys>-ryear.
                  ls_key-fplv  = <keys>-fplv.
                  ls_key-ccode = <root_node>-CompanyCode.
                  APPEND ls_key TO lt_keys.
                  set_prc_errorflag(
                    EXPORTING
                      keys   = lt_keys
*                IMPORTING
*                  failed =
                  ).

*    Stop the chain executed and report the errors in log and exit
                  RETURN.
                ENDLOOP.
              ENDIF.

              validate_receiverchargeout(
                EXPORTING
                  it_poper  = lt_poper
                  iv_recalrefpoper = recalrefpoper
                IMPORTING
                  ev_failed = failed
                CHANGING
                  ct_keys   = lt_keys
              ).

              IF failed = abap_true.
*Set error for root node to stop finalization process
                CONCATENATE <keys>-ryear recalrefpoper+1(2) '01' INTO lv_validon.
                LOOP AT lt_chain_stw ASSIGNING <root_node>
                             WHERE ValidFrom <= lv_validon
                               AND Validto   >= lv_validon
                               AND chain_id  = <ls_chain_stw>-chain_id
                               AND chain_sequence = 1.

                  CLEAR: ls_key, lt_keys.
                  MOVE-CORRESPONDING <root_node> TO ls_key.
                  ls_key-poper = recalrefpoper.
                  ls_key-ryear = <keys>-ryear.
                  ls_key-fplv  = <keys>-fplv.
                  ls_key-ccode = <root_node>-CompanyCode.
                  APPEND ls_key TO lt_keys.
                  set_prc_errorflag(
                    EXPORTING
                      keys   = lt_keys
*                IMPORTING
*                  failed =
                  ).

*    Stop the chain executed and report the errors in log and exit
                  RETURN.
                ENDLOOP.
              ENDIF.
            ENDIF.
********************************************************************
*                   Calculate Charge-Outs
*********************************************************************
            calculate_costbase(
              EXPORTING
                it_keys     = lt_keys
                it_poper    = lt_poper
                iv_workflow = abap_false
                iv_recalrefpoper = recalrefpoper
              IMPORTING
                ev_failed = failed
            ).

            IF failed = abap_true.
*    Stop the chain executed and report the errors in log and exit
              RETURN.
            ENDIF.

          ENDIF.
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
    DATA procctrl      TYPE /esrcc/tt_keys.

    CLEAR: ev_failed,ev_skip_validation.

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
            FROM /esrcc/i_totalcostabse_trueup AS cb
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
                    procctrl~poper,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~poper         = keys~poper
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>trueuprecal
                   AND  procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~poper,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING FIELD-SYMBOL(<keys>).

      DATA(failed) = abap_false.

*Authority check
      authority_check(
        EXPORTING
          keys   = <keys>
          action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
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

*Check for each month in case of YTD
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
          logitem-message_type = 'W'.
          CONCATENATE <keys>-legalentity <keys>-ccode INTO logitem-message_v1 SEPARATED BY '/'.
          APPEND logitem TO logitems.
          ev_skip_validation = abap_true.
        ELSEIF <lineitem>-erptotalcost_l = 0 AND <lineitem>-virtualtotalcost_l = 0.
*      log an warning
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '021'.
          logitem-message_type = 'W'.
          CONCATENATE <keys>-legalentity <keys>-ccode INTO logitem-message_v1 SEPARATED BY '/'.
          APPEND logitem TO logitems.
          ev_skip_validation = abap_true.
        ENDIF.

      ENDLOOP.

      IF failed = abap_true.

* create message logs
        create_loginstance(
          EXPORTING
            key         = <keys>
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>trueuprecal
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-poper = iv_recalrefpoper.
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>trueuprecal.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>recalculation_failed.     "Cost Base failed
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
                         AND poper = <keys>-poper.
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

    READ TABLE ct_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      CONCATENATE <keys>-ryear <keys>-poper+1(2) '01' INTO lv_validon.
    ENDIF.


*Check if service is configured for the cost objects
    SELECT stewardship~*
      FROM /esrcc/i_stw_serviceproduct AS stewardship
      INNER JOIN @ct_keys AS it_keys
        ON stewardship~sysid       = it_keys~sysid
       AND stewardship~legalentity = it_keys~legalentity
       AND stewardship~CompanyCode = it_keys~ccode
       AND stewardship~costobject  = it_keys~costobject
       AND stewardship~costcenter  = it_keys~costcenter
       WHERE stewardship~workflow_status = @/esrcc/if_calculate_chargeout=>finalized AND
             stewardship~ValidFrom <= @lv_validon AND
             stewardship~Validto >= @lv_validon
    ORDER BY stewardship~Sysid,
             stewardship~legalentity,
             stewardship~CompanyCode,
             stewardship~costobject,
             stewardship~costcenter
    INTO TABLE @DATA(lt_stw_stewardship).

*Check if receivers are maintained
    SELECT DISTINCT receivers~*
           FROM  /esrcc/i_srvproduct_receivers AS receivers
           INNER JOIN @ct_keys AS keys
             ON receivers~SystemId       = keys~sysid
            AND receivers~legalentity    = keys~legalentity
            AND receivers~CompanyCode    = keys~ccode
            AND receivers~costobject     = keys~costobject
            AND receivers~costcenter     = keys~costcenter
*            AND receivers~serviceproduct = keys~serviceproduct
            WHERE receivers~active         = @abap_true AND
                  receivers~StewardshipValidFrom <= @lv_validon AND
                  receivers~StewardshipValidTo >= @lv_validon
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
           recshare~planninguom,
           recshare~consumptionuom,
           SUM( reckpi ) AS totalreckpi,
           SUM( reckpishare ) AS totalreckpishare
       FROM /esrcc/i_chg_recshare_trueup  AS recshare
       INNER JOIN @ct_keys AS keys
          ON recshare~fplv           = keys~fplv
         AND recshare~ryear          = keys~ryear
         AND recshare~sysid          = keys~sysid
         AND recshare~legalentity    = keys~legalentity
         AND recshare~ccode          = keys~ccode
         AND recshare~costobject     = keys~costobject
         AND recshare~costcenter     = keys~costcenter
*         AND recshare~serviceproduct = keys~serviceproduct
         WHERE recshare~poper         IN @it_poper
           AND ( ( recshare~chargeout = 'D' AND recshare~consumptionuom IS NOT INITIAL )
            OR recshare~chargeout = 'I' )
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
         recshare~planninguom,
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

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
                    procctrl~ryear,
                    procctrl~poper,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~poper         = keys~poper
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>trueuprecal
                   WHERE procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~poper,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING <keys>.

      DATA(failed) = abap_false.

*Authority check
      authority_check(
        EXPORTING
          keys   = <keys>
          action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
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

        READ TABLE lt_stw_stewardship TRANSPORTING NO FIELDS WITH KEY
                                               sysid = <keys>-sysid
                                               legalentity = <keys>-legalentity
                                               companycode = <keys>-ccode
                                               costobject  = <keys>-costobject
                                               costcenter  = <keys>-costcenter
                                               BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_stw_stewardship ASSIGNING FIELD-SYMBOL(<stewardship>) FROM sy-tabix
                                               WHERE validfrom <= lv_validon
                                               AND   validto   >= lv_validon
                                               AND   spvalidfrom <= lv_validon
                                               AND   spvalidto   >= lv_validon.

            IF <stewardship>-sysid = <keys>-sysid
               AND <stewardship>-legalentity = <keys>-legalentity
               AND <stewardship>-companycode = <keys>-ccode
               AND <stewardship>-costobject  = <keys>-costobject
               AND <stewardship>-costcenter  = <keys>-costcenter.

*check if atleast one receivers exist for the service product
              READ TABLE receivers TRANSPORTING NO FIELDS
                                   WITH KEY  SystemId       = <keys>-sysid
                                             legalentity    = <keys>-legalentity
                                             CompanyCode    = <keys>-ccode
                                             costobject     = <keys>-costobject
                                             costcenter     = <keys>-costcenter
                                             serviceproduct = <stewardship>-serviceproduct.
              IF sy-subrc <> 0.
*      log an error
                CLEAR logitem.
                logitem-parent_log_uuid = parentloguuid.
                logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                logitem-message_v1 = <stewardship>-serviceproduct.
                logitem-message_number = '004'.
                logitem-message_type = 'E'.
                APPEND logitem TO logitems.
                failed = abap_true.
              ELSE.

                READ TABLE receiverchargeouts ASSIGNING FIELD-SYMBOL(<receiverchargeout>)
                                        WITH KEY fplv           = <keys>-fplv
                                                 ryear          = <keys>-ryear
                                                 poper          = <poper>-low
                                                 sysid          = <keys>-sysid
                                                 legalentity    = <keys>-legalentity
                                                 ccode          = <keys>-ccode
                                                 costobject     = <keys>-costobject
                                                 costcenter     = <keys>-costcenter
                                                 serviceproduct = <stewardship>-serviceproduct
                                                 BINARY SEARCH.

                IF sy-subrc <> 0.
*      log an error
                  CLEAR logitem.
                  logitem-parent_log_uuid = parentloguuid.
                  logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                  logitem-message_v1 = <stewardship>-serviceproduct.
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
                    logitem-message_v1 = <stewardship>-serviceproduct.
                    logitem-message_number = '029'.
                    logitem-message_type = 'E'.
                    APPEND logitem TO logitems.
                    failed = abap_true.
                  ELSEIF <receiverchargeout>-chargeout = 'D' AND <receiverchargeout>-totalreckpi = 0.
*      log an error
                    CLEAR logitem.
                    logitem-parent_log_uuid = parentloguuid.
                    logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                    logitem-message_v1 = <stewardship>-serviceproduct.
                    logitem-message_number = '028'.
                    logitem-message_type = 'W'.
                    APPEND logitem TO logitems.
                    failed = abap_false.
                  ELSEIF <receiverchargeout>-chargeout = 'D' AND <receiverchargeout>-totalreckpi <> 0.
*              READ TABLE serviceshares ASSIGNING FIELD-SYMBOL(<serviceshare>) WITH KEY fplv           = <receiverchargeout>-fplv
*                                                                                       ryear          = <receiverchargeout>-ryear
*                                                                                       poper          = <receiverchargeout>-poper
*                                                                                       sysid          = <receiverchargeout>-sysid
*                                                                                       legalentity    = <receiverchargeout>-legalentity
*                                                                                       ccode          = <receiverchargeout>-ccode
*                                                                                       costobject     = <receiverchargeout>-costobject
*                                                                                       costcenter     = <receiverchargeout>-costcenter
*                                                                                       serviceproduct = <receiverchargeout>-serviceproduct
*                                                                                       BINARY SEARCH.
                    IF sy-subrc = 0 AND <receiverchargeout>-consumptionuom <> <receiverchargeout>-planninguom.
*      log an error
                      CLEAR logitem.
                      logitem-parent_log_uuid = parentloguuid.
                      logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                      logitem-message_v1 = <stewardship>-serviceproduct.
                      logitem-message_number = '030'.
                      logitem-message_type = 'E'.
                      APPEND logitem TO logitems.
                      failed = abap_true.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      IF failed = abap_true.
* create message logs
        create_loginstance(
          EXPORTING
            key         = <keys>
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>trueuprecal
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-poper = iv_recalrefpoper.
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>trueuprecal.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>recalculation_failed.     "Cost Base failed
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
                         AND poper = <keys>-poper.
        ev_failed = failed.
      ENDIF.
      CLEAR loginstance.
    ENDLOOP.


    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.

    CLEAR: procctrl, receivers,receiverchargeouts.

  ENDMETHOD.


  METHOD validate_serviceproductcosting.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lv_validon    TYPE /esrcc/validfrom.
    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitems      TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY.
    DATA logitem       TYPE /esrcc/log_item.
    DATA procctrl      TYPE /esrcc/tt_keys.


    READ TABLE ct_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      CONCATENATE <keys>-ryear <keys>-poper+1(2) '01' INTO lv_validon.
    ENDIF.

*Check if service is configured for the cost objects
    SELECT stewardship~*
      FROM /esrcc/i_stw_serviceproduct AS stewardship
      INNER JOIN @ct_keys AS it_keys
        ON stewardship~sysid       = it_keys~sysid
       AND stewardship~legalentity = it_keys~legalentity
       AND stewardship~CompanyCode = it_keys~ccode
       AND stewardship~costobject  = it_keys~costobject
       AND stewardship~costcenter  = it_keys~costcenter
       WHERE stewardship~workflow_status = @/esrcc/if_calculate_chargeout=>finalized AND
             stewardship~ValidFrom <= @lv_validon AND
             stewardship~Validto >= @lv_validon
    ORDER BY stewardship~Sysid,
             stewardship~legalentity,
             stewardship~CompanyCode,
             stewardship~costobject,
             stewardship~costcenter
    INTO TABLE @DATA(lt_stw_stewardship).

*Check if charge-out rule is configured & Finalized
    SELECT DISTINCT cout~serviceproduct,
                    cout~validFrom,
                    cout~validto,
                    rule~chargeout_method,
                    rule~capacity_version
            FROM /esrcc/chgtrup AS cout
            INNER JOIN /esrcc/co_rule AS rule
            ON rule~rule_id = cout~chargeout_rule_id
            AND rule~workflow_status = 'F'
            INNER JOIN @lt_stw_stewardship AS keys
               ON cout~serviceproduct = keys~serviceproduct
            WHERE rule~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
            ORDER BY cout~serviceproduct
            INTO TABLE @DATA(rulesdetails).

* Check if chargeout rule method is direct then if capacity has been defined
    IF ct_keys IS NOT INITIAL.
      DATA(ryear) = ct_keys[ 1 ]-ryear.
      SELECT DISTINCT srvcap~fplv,
                      srvcap~Ryear,
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
              INNER JOIN @lt_stw_stewardship AS keys
                 ON srvcap~Sysid       = keys~sysid
                AND srvcap~LegalEntity = keys~legalentity
                AND srvcap~CompanyCode = keys~companycode
                AND srvcap~Costobject  = keys~costobject
                AND srvcap~Costcenter  = keys~costcenter
                AND srvcap~ServiceProduct = keys~serviceproduct
                WHERE srvcap~ryear            = @ryear
                  AND srvcap~poper       IN @it_poper
                ORDER BY srvcap~fplv,
                         srvcap~Ryear,
                         srvcap~poper,
                         srvcap~Sysid,
                         srvcap~LegalEntity,
                         srvcap~CompanyCode,
                         srvcap~Costobject,
                         srvcap~Costcenter,
                         srvcap~ServiceProduct
                INTO TABLE @DATA(capacities).
    ENDIF.

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
                    procctrl~ryear,
                    procctrl~poper,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~poper         = keys~poper
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>trueuprecal
                   WHERE procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~poper,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING <keys>.

      DATA(failed) = abap_false.

*Authority check
      authority_check(
        EXPORTING
          keys   = <keys>
          action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
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


*Check for each month in case of YTD
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).
        DATA(ruleexist) = abap_false.
        DATA(stewardship) = abap_false.

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

        READ TABLE lt_stw_stewardship TRANSPORTING NO FIELDS WITH KEY
                                               sysid = <keys>-sysid
                                               legalentity = <keys>-legalentity
                                               companycode = <keys>-ccode
                                               costobject  = <keys>-costobject
                                               costcenter  = <keys>-costcenter
                                               BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_stw_stewardship ASSIGNING FIELD-SYMBOL(<stewardship>) FROM sy-tabix
                                               WHERE validfrom <= lv_validon
                                               AND   validto   >= lv_validon
                                               AND   spvalidfrom <= lv_validon
                                               AND   spvalidto   >= lv_validon.

            IF <stewardship>-sysid = <keys>-sysid
               AND <stewardship>-legalentity = <keys>-legalentity
               AND <stewardship>-companycode = <keys>-ccode
               AND <stewardship>-costobject  = <keys>-costobject
               AND <stewardship>-costcenter  = <keys>-costcenter.
              stewardship = abap_true.
            ELSE.
              EXIT.
            ENDIF.

            READ TABLE rulesdetails TRANSPORTING NO FIELDS WITH KEY
                                    serviceproduct = <stewardship>-serviceproduct
                                    BINARY SEARCH.

            IF sy-subrc = 0.
              LOOP AT rulesdetails ASSIGNING FIELD-SYMBOL(<rules>) FROM sy-tabix
                                                    WHERE validfrom   <= lv_validon
                                                      AND validto     >= lv_validon.

                IF <stewardship>-serviceproduct = <rules>-serviceproduct.
                  ruleexist = abap_true.
                ELSE.
                  EXIT.
                ENDIF.

              ENDLOOP.
            ENDIF.
            IF ruleexist = abap_false.
*      log an error
              CLEAR logitem.
              logitem-parent_log_uuid = parentloguuid.
              logitem-message_id = '/ESRCC/EXECCOCKPIT'.
              logitem-message_number = '023'.
              logitem-message_type = 'E'.
              logitem-message_v1 = <stewardship>-serviceproduct.
              APPEND logitem TO logitems.
              failed = abap_true.
            ELSEIF <rules>-chargeout_method = 'D'.

              READ TABLE capacities ASSIGNING FIELD-SYMBOL(<capacity>)
                                    WITH KEY fplv           = <rules>-capacity_version
                                             ryear          = <keys>-ryear
                                             poper          = <poper>-low
                                             Sysid          = <keys>-sysid
                                             LegalEntity    = <keys>-legalentity
                                             CompanyCode    = <keys>-ccode
                                             Costobject     = <keys>-costobject
                                             Costcenter     = <keys>-costcenter
                                             ServiceProduct = <stewardship>-serviceproduct
                                             BINARY SEARCH.

              IF sy-subrc <> 0.
*      log an error
                CLEAR logitem.
                logitem-parent_log_uuid = parentloguuid.
                logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                logitem-message_number = '024'.
                logitem-message_type = 'E'.
                logitem-message_v1 = <stewardship>-serviceproduct.
                APPEND logitem TO logitems.
                failed = abap_true.
              ELSEIF <capacity>-planning = 0.
*      log an error
                CLEAR logitem.
                logitem-parent_log_uuid = parentloguuid.
                logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                logitem-message_number = '025'.
                logitem-message_type = 'W'.
                logitem-message_v1 = <stewardship>-serviceproduct.
                APPEND logitem TO logitems.
                failed = abap_false.
              ENDIF.
            ENDIF.

          ENDLOOP.
        ENDIF.
        IF stewardship = abap_false.
*      log an error
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '031'.
          logitem-message_type = 'E'.
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
            process     = /esrcc/if_calculate_chargeout=>trueuprecal
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control

        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-poper = iv_recalrefpoper.
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>trueuprecal.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>recalculation_failed.     "Cost Base failed
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
                         AND poper = <keys>-poper.
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

*get virtual postings already existing as line items
    SELECT DISTINCT
               cb~ryear,
               cb~poper,
               cb~sysid,
               cb~ccode,
               cb~legalentity,
               cb~Costobject,
               cb~Costcenter,
               sp~serviceproduct,
               co~ReceiverSysId,
               co~ReceiverCompanyCode,
               co~Receivingentity,
               co~ReceiverCostObject,
               co~ReceiverCostCenter,
               co~currency,
               co~TotalChargeout AS TotalChargeoutAmount
          FROM /ESRCC/I_ReceiverChargeout AS co
          INNER JOIN /esrcc/i_costbasestewardship AS cb
          ON co~RootUUID = cb~uuid
          INNER JOIN /ESRCC/I_ServiceProductShare AS sp
          ON co~ParentUUID = sp~uuid
        WHERE co~Currencytype   = 'G'
          AND cb~poper          IN @it_poper
          AND cb~ryear          = @<keys>-ryear
          AND cb~Sysid          = @<keys>-sysid
          AND cb~Legalentity    = @<keys>-legalentity
          AND cb~ccode          = @<keys>-ccode
          AND cb~Costobject     = @<keys>-costobject
          AND cb~Costcenter     = @<keys>-costcenter
          AND cb~ProcessType    = @/esrcc/if_calculate_chargeout=>standardprocesstype
        ORDER BY
               cb~ryear,
               cb~poper,
               cb~sysid,
               cb~ccode,
               cb~legalentity,
               cb~Costobject,
               cb~Costcenter,
               sp~serviceproduct,
               co~ReceiverSysId,
               co~ReceiverCompanyCode,
               co~Receivingentity,
               co~ReceiverCostObject,
               co~ReceiverCostCenter
        INTO TABLE @DATA(lt_std_receiverchargeout).


    SELECT SINGLE group_currency FROM /esrcc/group INTO @DATA(groupcurrency).

    LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<ls_poper>).

      CONCATENATE <keys>-ryear <ls_poper>-low+1(2) '01' INTO lv_validon.

*get the list of receivers
      SELECT DISTINCT cb_stw~receiversysid,
                      cb_stw~receivingentity,
                      cb_stw~receivercompanycode,
                      le~local_curr AS receivercurrency
            FROM /esrcc/i_chg_recshare_trueup AS cb_stw
            INNER JOIN @it_keys AS ik
              ON cb_stw~fplv          = ik~fplv
             AND cb_stw~ryear         = ik~ryear
             AND cb_stw~sysid         = ik~sysid
             AND cb_stw~legalentity   = ik~legalentity
             AND cb_stw~ccode         = ik~ccode
             AND cb_stw~costobject    = ik~costobject
             AND cb_stw~costcenter    = ik~costcenter
             LEFT OUTER JOIN /esrcc/le AS le
             ON cb_stw~receivingentity = le~legalentity
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

        DELETE ADJACENT DUPLICATES FROM lt_costelement COMPARING sysid company_code legal_entity.


*SCC Virtual posting
        SELECT DISTINCT
               cb~fplv,
               cb~ryear,
               cb~poper,
               cb~Refpoper,
               cb~sysid,
               cb~ccode,
               cb~legalentity,
               cb~Costobject,
               cb~Costcenter,
               sp~serviceproduct,
               co~uuid,
               co~ParentUUID,
               co~rootuuid,
               co~ReceiverSysId,
               co~ReceiverCompanyCode,
               co~Receivingentity,
               co~ReceiverCostObject,
               co~ReceiverCostCenter,
               coscen~FunctionalArea,
               coscen~BusinessDivision,
               coscen~ProfitCenter,
               co~TotalChargeout AS TotalChargeoutAmount,
               co~currency,
               co~Exchdate
          FROM /ESRCC/I_ReceiverChargeout AS co
          INNER JOIN /esrcc/i_costbasestewardship AS cb
          ON co~RootUUID  = cb~uuid
          INNER JOIN /ESRCC/I_ServiceProductShare AS sp
          ON co~ParentUUID = sp~uuid
          INNER JOIN @lt_costelement AS ik
            ON co~ReceiverSysId        = ik~sysid
           AND co~Receivingentity      = ik~legal_entity
           AND co~ReceiverCompanyCode  = ik~company_code
         INNER JOIN /esrcc/i_coscen_f4 as coscen
          on coscen~Sysid = co~ReceiverSysId
          and coscen~LegalEntity = co~Receivingentity
          and coscen~CompanyCode = co~ReceiverCompanyCode
          and coscen~Costobject = co~ReceiverCostObject
          and coscen~Costcenter = co~ReceiverCostCenter
        WHERE co~Currencytype   = 'G'
          AND cb~poper          = @<ls_poper>-low
          AND cb~ryear          = @<keys>-ryear
          AND cb~fplv           = @<keys>-fplv
          AND cb~Sysid          = @<keys>-sysid
          AND cb~Legalentity    = @<keys>-legalentity
          AND cb~ccode          = @<keys>-ccode
          AND cb~Costobject     = @<keys>-costobject
          AND cb~Costcenter     = @<keys>-costcenter
          AND cb~RefPoper       <= @iv_recalrefpoper
          AND cb~ProcessType    = @/esrcc/if_calculate_chargeout=>recalprocesstype
          AND co~Receivingentity IS NOT INITIAL
          ORDER BY RefPoper DESCENDING
        INTO TABLE @DATA(lt_receiverchargeout).

        LOOP AT lt_receiverchargeout ASSIGNING FIELD-SYMBOL(<ls_receiverchargeout>) WHERE RefPoper = iv_recalrefpoper.

          READ TABLE lt_costelement ASSIGNING FIELD-SYMBOL(<ls_costlement>)
                                    WITH KEY sysid = <ls_receiverchargeout>-ReceiverSysId
                                             company_code = <ls_receiverchargeout>-ReceiverCompanyCode
                                             legal_entity = <ls_receiverchargeout>-Receivingentity
                                             BINARY SEARCH.

          IF sy-subrc = 0.



            ls_cbli-fplv                = <ls_receiverchargeout>-fplv.
            ls_cbli-ryear               = <ls_receiverchargeout>-ryear.
            ls_cbli-poper               = <ls_receiverchargeout>-Poper.
            ls_cbli-buzei               = 1.
            ls_cbli-sysid               = <ls_receiverchargeout>-ReceiverSysId.
            ls_cbli-ccode               = <ls_receiverchargeout>-ReceiverCompanyCode.
            ls_cbli-legalentity         = <ls_receiverchargeout>-Receivingentity.
            ls_cbli-costobject          = <ls_receiverchargeout>-ReceiverCostObject.
            ls_cbli-costcenter          = <ls_receiverchargeout>-ReceiverCostCenter.
            ls_cbli-costelement         = <ls_costlement>-cost_element.
            ls_cbli-costind             = <ls_costlement>-costelem-cost_indicator.
            ls_cbli-costtype            = <ls_costlement>-costelem-cost_type.
            ls_cbli-usagecal            = <ls_costlement>-costelem-usage_type.
            ls_cbli-value_source        = <ls_costlement>-costelem-value_source.
            ls_cbli-reasonid            = <ls_costlement>-costelem-reason_id.
            ls_cbli-postingtype         = <ls_costlement>-costelem-posting_type.
            ls_cbli-vendor              = <ls_receiverchargeout>-Legalentity.
            ls_cbli-status              = /esrcc/if_calculate_chargeout=>approved.   "Approved
            ls_cbli-functionalarea      = <ls_receiverchargeout>-FunctionalArea.
            ls_cbli-businessdivision    = <ls_receiverchargeout>-BusinessDivision.
            ls_cbli-profitcenter        = <ls_receiverchargeout>-ProfitCenter.
            ls_cbli-posting_sysid       = <ls_receiverchargeout>-Sysid.
            ls_cbli-posting_ccode       = <ls_receiverchargeout>-ccode.
            ls_cbli-posting_legalentity = <ls_receiverchargeout>-Legalentity.
            ls_cbli-posting_costobject  = <ls_receiverchargeout>-Costobject.
            ls_cbli-posting_costcenter  = <ls_receiverchargeout>-Costcenter.
            ls_cbli-recalrefpoper       = iv_recalrefpoper.

            ls_cbli-groupcurr           = groupcurrency.
            ls_cbli-ksl                 = <ls_receiverchargeout>-TotalChargeoutAmount.



            LOOP AT lt_receiverchargeout ASSIGNING FIELD-SYMBOL(<recal_receiverchargeout>)
                                              WHERE  ryear               = <ls_receiverchargeout>-ryear
                                                AND  poper               = <ls_receiverchargeout>-poper
                                                AND  Sysid               = <ls_receiverchargeout>-Sysid
                                                AND  ccode               = <ls_receiverchargeout>-ccode
                                                AND  Legalentity         = <ls_receiverchargeout>-Legalentity
                                                AND  Costobject          = <ls_receiverchargeout>-Costobject
                                                AND  Costcenter          = <ls_receiverchargeout>-Costcenter
                                                AND  Serviceproduct      = <ls_receiverchargeout>-Serviceproduct
                                                AND  ReceiverSysId       = <ls_receiverchargeout>-ReceiverSysId
                                                AND  ReceiverCompanyCode = <ls_receiverchargeout>-ReceiverCompanyCode
                                                AND  Receivingentity     = <ls_receiverchargeout>-Receivingentity
                                                AND  ReceiverCostObject  = <ls_receiverchargeout>-ReceiverCostObject
                                                AND  ReceiverCostCenter  = <ls_receiverchargeout>-ReceiverCostCenter
                                                AND  refpoper            < iv_recalrefpoper.

              ls_cbli-ksl = ls_cbli-ksl - <recal_receiverchargeout>-totalchargeoutamount.
              EXIT.
            ENDLOOP.
            IF sy-subrc <> 0.
*determine the delta in SCC posting value and post for Recalculations
              READ TABLE lt_std_receiverchargeout ASSIGNING FIELD-SYMBOL(<std_chargeout>)
                                   WITH KEY ryear               = <ls_receiverchargeout>-ryear
                                            poper               = <ls_receiverchargeout>-poper
                                            Sysid               = <ls_receiverchargeout>-Sysid
                                            ccode               = <ls_receiverchargeout>-ccode
                                            Legalentity         = <ls_receiverchargeout>-Legalentity
                                            Costobject          = <ls_receiverchargeout>-Costobject
                                            Costcenter          = <ls_receiverchargeout>-Costcenter
                                            Serviceproduct      = <ls_receiverchargeout>-Serviceproduct
                                            ReceiverSysId       = <ls_receiverchargeout>-ReceiverSysId
                                            ReceiverCompanyCode = <ls_receiverchargeout>-ReceiverCompanyCode
                                            Receivingentity     = <ls_receiverchargeout>-Receivingentity
                                            ReceiverCostObject  = <ls_receiverchargeout>-ReceiverCostObject
                                            ReceiverCostCenter  = <ls_receiverchargeout>-ReceiverCostCenter
                                            BINARY SEARCH.

              IF sy-subrc = 0.
                ls_cbli-ksl = ls_cbli-ksl - <std_chargeout>-totalchargeoutamount.
              ENDIF.
            ENDIF.

            READ TABLE receivers ASSIGNING FIELD-SYMBOL(<receiver>)
                                           WITH KEY receivingentity = <ls_receiverchargeout>-Receivingentity
                                           BINARY SEARCH.
            IF sy-subrc = 0.
              ls_cbli-localcurr    = <ls_costlement>-local_curr.
              /esrcc/cl_utility_core=>currency_conversion(
                EXPORTING
                  amount          = ls_cbli-ksl
                  source_curr     = ls_cbli-groupcurr
                  target_curr     = ls_cbli-localcurr
                  validon         = <ls_receiverchargeout>-Exchdate
                IMPORTING
                  convertedamount = ls_cbli-hsl
              ).

            ENDIF.

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
            IF ls_cbli-hsl <> 0.
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
              ls_cbli-belnr               = number.
              CLEAR: lv_number, number.
              APPEND ls_cbli TO lt_cbli.
            ENDIF.
            CLEAR ls_cbli.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lt_cbli IS NOT INITIAL.
        MODIFY /esrcc/cb_li FROM TABLE @lt_cbli.
      ENDIF.

      CLEAR: lt_cbli, lt_receiverchargeout, lt_costelement, receivers.
    ENDLOOP.

  ENDMETHOD.

  METHOD set_process_control.

    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.

    IF update = abap_true.
      SELECT procctrl~*  FROM /esrcc/procctrl AS procctrl
         INNER JOIN @keys AS keys
         ON procctrl~ryear = keys~ryear
         AND procctrl~poper = keys~poper
         AND procctrl~sysid = keys~sysid
         AND procctrl~ccode = keys~ccode
         AND procctrl~legalentity = keys~legalentity
         AND procctrl~costobject = keys~costobject
         AND procctrl~costcenter = keys~costcenter
         AND procctrl~process = @process
         INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.

*update process control
      LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).

*      ls_procctrl = CORRESPONDING #( <procctrl> ).
        <procctrl>-process = process.    "Cost Base
        <procctrl>-status = status.     "Cost Base Approved

*Admin data
        <procctrl>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <procctrl>-last_changed_at
        ).

      ENDLOOP.

    ELSE.

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

    ENDIF.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.

  ENDMETHOD.

  METHOD determine_validon.

    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<keys>).
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).
        CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO validon.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD calculate_recalchargeout.

    DATA ls_key     TYPE /esrcc/procctrl.
    DATA lt_keys    TYPE /esrcc/tt_keys.
    DATA lt_key     TYPE /esrcc/tt_keys.
    DATA lv_validon TYPE /esrcc/validfrom.
    DATA lt_poper   TYPE /esrcc/tt_poper_range.

*    consider YTD scenario and derive all popers
    derive_poper(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        et_poper = DATA(_poper)
      ).

    lt_keys = it_keys.


    DELETE lt_keys WHERE costcenter IS INITIAL.

    IF lt_keys IS NOT INITIAL.
      DATA(recalrefpoper) = lt_keys[ 1 ]-poper.
    ENDIF.

    SORT _poper BY low.

    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      LOOP AT _poper ASSIGNING FIELD-SYMBOL(<poper>).

        CLEAR: lt_poper.
        APPEND <poper> TO lt_poper.

        CLEAR:lt_key.
        <ls_key>-poper = <poper>-low.
        APPEND <ls_key> TO lt_key.

********************************************************************
*                   Perform Consistency Checks
*********************************************************************
        check_if_objects_are_finalized(
          EXPORTING
            it_poper         = lt_poper
            iv_recalrefpoper = recalrefpoper
          IMPORTING
            ev_failed        = DATA(failed)
          CHANGING
            ct_keys          = lt_key
        ).

        IF failed = abap_true.
          EXIT.
        ENDIF.

        validate_costbase(
          EXPORTING
            it_poper         = lt_poper
            iv_recalrefpoper = recalrefpoper
        IMPORTING
          ev_failed          = failed
          ev_skip_validation = DATA(skip_validation)
        CHANGING
            ct_keys   = lt_key
        ).

        IF failed = abap_true.
          EXIT.
        ENDIF.

        IF skip_validation = abap_false.
          validate_serviceproductcosting(
            EXPORTING
              it_poper  = lt_poper
              iv_recalrefpoper = recalrefpoper
            IMPORTING
              ev_failed = failed
            CHANGING
              ct_keys   = lt_key
          ).

          IF failed = abap_true.
            EXIT.
          ENDIF.

          validate_receiverchargeout(
            EXPORTING
              it_poper  = lt_poper
              iv_recalrefpoper = recalrefpoper
            IMPORTING
              ev_failed = failed
            CHANGING
              ct_keys   = lt_key
          ).

          IF failed = abap_true.
            EXIT.
          ENDIF.

        ENDIF.

********************************************************************
*                   Calculate Charge-Outs
*********************************************************************
        calculate_costbase(
          EXPORTING
            it_keys   = lt_key
            it_poper  = lt_poper
            iv_recalrefpoper = recalrefpoper
*      IMPORTING
*        ev_failed =
        ).

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD finalize_recalchargeout.

    IF it_keys IS NOT INITIAL.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
    ENDIF.

    finalize_costbase(
      it_keys  = it_keys
      iv_recalrefpoper = recalrefpoper
*      it_poper =
    ).

  ENDMETHOD.

  METHOD finalize_recalseqchargeout.

    DATA ls_key TYPE /esrcc/procctrl.
    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA lv_validon TYPE /esrcc/validfrom.

*get the chain and sequence.
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      CONCATENATE <keys>-ryear <keys>-poper+1(2) '01' INTO lv_validon.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS it_keys
          ON stewardship~sysid       = it_keys~sysid
         AND stewardship~legalentity = it_keys~legalentity
         AND stewardship~CompanyCode = it_keys~ccode
         AND stewardship~costobject  = it_keys~costobject
         AND stewardship~costcenter  = it_keys~costcenter
         AND stewardship~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
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

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>) WHERE validfrom <= lv_validon
                                                                    AND validto   >= lv_validon.
        CLEAR: ls_key, lt_keys.

        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = <keys>-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_keys.

        finalize_costbase( it_keys = lt_keys
                           iv_recalrefpoper = recalrefpoper ).

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD reopen_recalchargeout.

    IF it_keys IS NOT INITIAL.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
    ENDIF.

    reopen_costbase(
      it_keys  = it_keys
      iv_recalrefpoper = recalrefpoper
*      it_poper =
    ).


  ENDMETHOD.

  METHOD determine_trueup.

    DATA trueupamount     TYPE /esrcc/amount.
    DATA lt_trueup        TYPE TABLE OF /esrcc/trueup.
    DATA ls_trueup        TYPE /esrcc/trueup.
    DATA ls_cbstw         TYPE /esrcc/cb_stw.
    DATA ls_srvshare      TYPE /esrcc/srv_share.
    DATA ls_receiver      TYPE /esrcc/rec_chg.
    DATA lt_cbstw         TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srvshare      TYPE TABLE OF /esrcc/srv_share.
    DATA lt_receiver      TYPE TABLE OF /esrcc/rec_chg.

*   Get the recalculated chargeouts
    SELECT trueup~* FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE RefPoper              = @iv_recalrefpoper
        AND  ProcessType           = @/esrcc/if_calculate_chargeout=>recalprocesstype
        AND  Currencytype          = 'L'   "sender local currency
        INTO TABLE @DATA(lt_recalculated).

*   Get the standard chargeouts
    SELECT trueup~* FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE trueup~poper          <= @iv_recalrefpoper
        AND  ProcessType           = @/esrcc/if_calculate_chargeout=>standardprocesstype
        AND  Currencytype          = 'L'   "sender local currency
        INTO TABLE @DATA(lt_standard).

*   Get the true up amounts
    SELECT trueup~* FROM /esrcc/trueup AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE recalrefpoper         < @iv_recalrefpoper
        INTO TABLE @DATA(lt_trueups).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    SELECT SINGLE group_currency FROM /esrcc/group INTO @DATA(groupcurrency).

    LOOP AT lt_recalculated ASSIGNING FIELD-SYMBOL(<recalculated>).
      READ TABLE lt_standard ASSIGNING FIELD-SYMBOL(<standard>)
                               WITH KEY ryear          = <recalculated>-ryear
                                        poper          = <recalculated>-poper
                                        sysid          = <recalculated>-sysid
                                        Legalentity    = <recalculated>-Legalentity
                                        ccode          = <recalculated>-ccode
                                        costobject     = <recalculated>-costobject
                                        costcenter     = <recalculated>-Costcenter
                                        ServiceProduct = <recalculated>-ServiceProduct
                                        ReceiverSysId = <recalculated>-ReceiverSysId
                                        ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                        Receivingentity = <recalculated>-Receivingentity
                                        ReceiverCostObject = <recalculated>-ReceiverCostObject
                                        ReceiverCostCenter = <recalculated>-ReceiverCostCenter.
      IF sy-subrc = 0.
        CLEAR trueupamount.
        LOOP AT lt_trueups INTO DATA(trueup)
                             WHERE ryear               = <recalculated>-ryear
                               AND poper               = <recalculated>-poper
                               AND sysid               = <recalculated>-sysid
                               AND Legalentity         = <recalculated>-Legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-Costcenter
                               AND ServiceProduct      = <recalculated>-ServiceProduct
                               AND ReceiverSysId       = <recalculated>-ReceiverSysId
                               AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                               AND Receivingentity     = <recalculated>-Receivingentity
                               AND ReceiverCostObject  = <recalculated>-ReceiverCostObject
                               AND ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.

          trueupamount = trueup-amount_l + trueupamount.
        ENDLOOP.

        CLEAR ls_trueup.
        MOVE-CORRESPONDING <recalculated> TO ls_trueup.
        ls_trueup-recalrefpoper = <recalculated>-RefPoper.
        ls_trueup-localcurr = <recalculated>-Currency.
        ls_trueup-exchdate  = <recalculated>-Exchdate.
        ls_trueup-invoicestatus = '01'.
*        ls_trueup-invoicingcurrency = <recalculated>-InvoicingCurrency.
*        ls_trueup-erpsalesorder = <recalculated>-ErpSalesOrder.
*        ls_trueup-contractid    = <recalculated>-contractid.
        IF iv_workflow = abap_true.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>inprocess.
        ELSE.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>approved.
        ENDIF.

        ls_trueup-groupcurr = groupcurrency.
        ls_trueup-amount_l = <recalculated>-TotalChargeoutAmount - ( <standard>-TotalChargeoutAmount + trueupamount ).
        /esrcc/cl_utility_core=>currency_conversion(
          EXPORTING
            amount          = ls_trueup-amount_l
            source_curr     = ls_trueup-localcurr
            target_curr     = ls_trueup-groupcurr
            validon         = <recalculated>-Exchdate
          IMPORTING
            convertedamount = ls_trueup-amount_g
        ).

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              ls_trueup-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        ls_trueup-cc_uuid = <standard>-RootUUID.
        ls_trueup-srv_uuid = <standard>-ParentUUID.

* Admin data
        ls_trueup-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-created_at
        ).
        ls_trueup-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-last_changed_at
        ).
        IF ls_trueup-amount_l <> 0.
          APPEND ls_trueup TO lt_trueup.
        ENDIF.

        DELETE lt_standard WHERE ryear       = <recalculated>-ryear
                                 AND poper       = <recalculated>-poper
                                 AND sysid       = <recalculated>-sysid
                                 AND Legalentity = <recalculated>-Legalentity
                                 AND ccode       = <recalculated>-ccode
                                 AND costobject  = <recalculated>-costobject
                                 AND costcenter  = <recalculated>-Costcenter
                                 AND ServiceProduct = <recalculated>-ServiceProduct
                                 AND ReceiverSysId = <recalculated>-ReceiverSysId
                                 AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                 AND Receivingentity = <recalculated>-Receivingentity
                                 AND ReceiverCostObject = <recalculated>-ReceiverCostObject
                                 AND ReceiverCostCenter = <recalculated>-ReceiverCostCenter.
      ELSE.

* if there is no standard chargeout for the receiever than create a dummy standard chargeout
        CLEAR: ls_cbstw, ls_srvshare, ls_receiver.

        READ TABLE lt_cbstw INTO ls_cbstw
                            WITH KEY ryear          = <recalculated>-ryear
                                     poper          = <recalculated>-poper
                                     sysid          = <recalculated>-sysid
                                     Legalentity    = <recalculated>-Legalentity
                                     ccode          = <recalculated>-ccode
                                     costobject     = <recalculated>-costobject
                                     costcenter     = <recalculated>-Costcenter.
        IF sy-subrc <> 0.

          ls_cbstw-fplv        = <recalculated>-fplv.
          ls_cbstw-ryear       = <recalculated>-ryear.
          ls_cbstw-poper       = <recalculated>-poper.
          ls_cbstw-recalrefpoper = iv_recalrefpoper.
          ls_cbstw-sysid       = <recalculated>-sysid.
          ls_cbstw-Legalentity = <recalculated>-Legalentity.
          ls_cbstw-ccode       = <recalculated>-ccode.
          ls_cbstw-costobject  = <recalculated>-costobject.
          ls_cbstw-costcenter  = <recalculated>-Costcenter.
          ls_cbstw-processtype = /esrcc/if_calculate_chargeout=>standardprocesstype.
          ls_cbstw-businessdivision = <recalculated>-Businessdivision.
          ls_cbstw-functionalarea   = <recalculated>-functionalarea.
          ls_cbstw-profitcenter     = <recalculated>-profitcenter.
          ls_cbstw-localcurr        = <recalculated>-Currency.
          ls_cbstw-groupcurr        = groupcurrency.
          ls_cbstw-validon          = <recalculated>-Exchdate.
          IF iv_workflow = abap_true.
            ls_cbstw-status = /esrcc/if_calculate_chargeout=>inprocess.
          ELSE.
            ls_cbstw-status = /esrcc/if_calculate_chargeout=>approved.
          ENDIF.

* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                ls_cbstw-cc_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
        ENDIF.
* Admin data
        ls_cbstw-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_cbstw-created_at
        ).
        ls_cbstw-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_cbstw-last_changed_at
        ).


        READ TABLE lt_srvshare INTO ls_srvshare
                           WITH KEY cc_uuid        = ls_cbstw-cc_uuid
                                    serviceproduct = <recalculated>-ServiceProduct.
        IF sy-subrc <> 0.

          ls_srvshare-ServiceProduct      = <recalculated>-ServiceProduct.
          ls_srvshare-servicetype         = <recalculated>-servicetype.
          ls_srvshare-transactiongroup    = <recalculated>-transactiongroup.
          ls_srvshare-chargeout           = <recalculated>-Chargeout.
          ls_srvshare-validon             = <recalculated>-Exchdate.
          IF iv_workflow = abap_true.
            ls_srvshare-status = /esrcc/if_calculate_chargeout=>inprocess.
          ELSE.
            ls_srvshare-status = /esrcc/if_calculate_chargeout=>approved.
          ENDIF.
*        ls_srvshare-oecd                = <recalculated>-oecd.
          ls_srvshare-cc_uuid             = ls_cbstw-cc_uuid.
* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                ls_srvshare-srv_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
        ENDIF.

* Admin data
        ls_srvshare-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_srvshare-created_at
        ).
        ls_srvshare-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_srvshare-last_changed_at
        ).

        READ TABLE lt_receiver INTO ls_receiver
                           WITH KEY cc_uuid             = ls_srvshare-cc_uuid
                                    srv_uuid            = ls_srvshare-srv_uuid
                                    ReceiverSysId       = <recalculated>-ReceiverSysId
                                    ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                    Receivingentity     = <recalculated>-Receivingentity
                                    ReceiverCostObject  = <recalculated>-ReceiverCostObject
                                    ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.
        IF sy-subrc <> 0.

          ls_receiver-ReceiverSysId       = <recalculated>-ReceiverSysId.
          ls_receiver-ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode.
          ls_receiver-Receivingentity     = <recalculated>-Receivingentity.
          ls_receiver-ReceiverCostObject  = <recalculated>-ReceiverCostObject.
          ls_receiver-ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.
          ls_receiver-invoicingcurrency   = <recalculated>-invoicingcurrency.
          ls_receiver-exchdate            = <recalculated>-Exchdate.
          ls_receiver-invoicestatus       = '01'.
          ls_receiver-cc_uuid             = ls_srvshare-cc_uuid.
          ls_receiver-srv_uuid            = ls_srvshare-srv_uuid.
          IF iv_workflow = abap_true.
            ls_receiver-status = /esrcc/if_calculate_chargeout=>inprocess.
          ELSE.
            ls_receiver-status = /esrcc/if_calculate_chargeout=>approved.
          ENDIF.
* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                ls_receiver-rec_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
        ENDIF.

* Admin data
        ls_receiver-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_receiver-created_at
        ).
        ls_receiver-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_receiver-last_changed_at
        ).

        APPEND ls_cbstw TO lt_cbstw.
        APPEND ls_srvshare TO lt_srvshare.
        APPEND ls_receiver TO lt_receiver.

        CLEAR trueupamount.
        LOOP AT lt_trueups INTO trueup
                             WHERE ryear               = <recalculated>-ryear
                               AND poper               = <recalculated>-poper
                               AND sysid               = <recalculated>-sysid
                               AND Legalentity         = <recalculated>-Legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-Costcenter
                               AND ServiceProduct      = <recalculated>-ServiceProduct
                               AND ReceiverSysId       = <recalculated>-ReceiverSysId
                               AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                               AND Receivingentity     = <recalculated>-Receivingentity
                               AND ReceiverCostObject  = <recalculated>-ReceiverCostObject
                               AND ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.

          trueupamount = trueup-amount_l + trueupamount.
        ENDLOOP.

        CLEAR ls_trueup.
        MOVE-CORRESPONDING <recalculated> TO ls_trueup.
        ls_trueup-recalrefpoper = <recalculated>-RefPoper.
        ls_trueup-localcurr = <recalculated>-Currency.
        ls_trueup-exchdate  = <recalculated>-Exchdate.
        ls_trueup-invoicestatus = '01'.
*        ls_trueup-invoicingcurrency = <recalculated>-InvoicingCurrency.
*        ls_trueup-erpsalesorder = <recalculated>-ErpSalesOrder.
*        ls_trueup-contractid    = <recalculated>-contractid.
        IF iv_workflow = abap_true.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>inprocess.
        ELSE.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>approved.
        ENDIF.

        ls_trueup-groupcurr = groupcurrency.
        ls_trueup-amount_l = <recalculated>-TotalChargeoutAmount - trueupamount .
        /esrcc/cl_utility_core=>currency_conversion(
          EXPORTING
            amount          = ls_trueup-amount_l
            source_curr     = ls_trueup-localcurr
            target_curr     = ls_trueup-groupcurr
            validon         = <recalculated>-Exchdate
          IMPORTING
            convertedamount = ls_trueup-amount_g
        ).

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              ls_trueup-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        ls_trueup-cc_uuid = ls_receiver-cc_uuid.
        ls_trueup-srv_uuid = ls_receiver-srv_uuid.

* Admin data
        ls_trueup-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-created_at
        ).
        ls_trueup-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-last_changed_at
        ).
        IF ls_trueup-amount_l <> 0.
          APPEND ls_trueup TO lt_trueup.
        ENDIF.


      ENDIF.

    ENDLOOP.

*  For the scenario where receivers not found in recalculation
    LOOP AT lt_standard ASSIGNING <standard>.

      CLEAR trueupamount.
      LOOP AT lt_trueups INTO trueup
                           WHERE ryear               = <standard>-ryear
                             AND poper               = <standard>-poper
                             AND sysid               = <standard>-sysid
                             AND Legalentity         = <standard>-Legalentity
                             AND ccode               = <standard>-ccode
                             AND costobject          = <standard>-costobject
                             AND costcenter          = <standard>-Costcenter
                             AND ServiceProduct      = <standard>-ServiceProduct
                             AND ReceiverSysId       = <standard>-ReceiverSysId
                             AND ReceiverCompanyCode = <standard>-ReceiverCompanyCode
                             AND Receivingentity     = <standard>-Receivingentity
                             AND ReceiverCostObject  = <standard>-ReceiverCostObject
                             AND ReceiverCostCenter  = <standard>-ReceiverCostCenter.

        trueupamount = trueup-amount_l + trueupamount.
      ENDLOOP.

      CLEAR ls_trueup.
      MOVE-CORRESPONDING <standard> TO ls_trueup.
      ls_trueup-recalrefpoper = iv_recalrefpoper.
      ls_trueup-localcurr = <standard>-Currency.
      ls_trueup-exchdate  = <standard>-Exchdate.
      ls_trueup-invoicestatus = '01'.
*      ls_trueup-invoicingcurrency = <standard>-InvoicingCurrency.
*      ls_trueup-erpsalesorder = <standard>-ErpSalesOrder.
*      ls_trueup-contractid    = <standard>-contractid.
      IF iv_workflow = abap_true.
        ls_trueup-status = /esrcc/if_calculate_chargeout=>inprocess.
      ELSE.
        ls_trueup-status = /esrcc/if_calculate_chargeout=>approved.
      ENDIF.

      ls_trueup-groupcurr = groupcurrency.
      ls_trueup-amount_l = -1 * ( <standard>-TotalChargeoutAmount + trueupamount ).
      /esrcc/cl_utility_core=>currency_conversion(
        EXPORTING
          amount          = ls_trueup-amount_l
          source_curr     = ls_trueup-localcurr
          target_curr     = ls_trueup-groupcurr
          validon         = <standard>-Exchdate
        IMPORTING
          convertedamount = ls_trueup-amount_g
      ).

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            ls_trueup-uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
      ls_trueup-cc_uuid = <standard>-RootUUID.
      ls_trueup-srv_uuid = <standard>-ParentUUID.

* Admin data
      ls_trueup-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_trueup-created_at
      ).
      ls_trueup-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_trueup-last_changed_at
      ).
      IF ls_trueup-amount_l <> 0.
        APPEND ls_trueup TO lt_trueup.
      ENDIF.

    ENDLOOP.


    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_receiver.
    MODIFY /esrcc/trueup    FROM TABLE @lt_trueup.

  ENDMETHOD.

  METHOD delete_trueups.

*   Get the true ups
    SELECT trueup~* FROM /esrcc/trueup AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE recalrefpoper         = @iv_recalrefpoper
        INTO TABLE @DATA(lt_trueups).

    DELETE /esrcc/trueup FROM TABLE @lt_trueups.

  ENDMETHOD.

  METHOD set_prc_errorflag.

    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.

    SELECT procctrl~*  FROM /esrcc/procctrl AS procctrl
       INNER JOIN @keys AS keys
       ON procctrl~ryear = keys~ryear
       AND procctrl~poper = keys~poper
       AND procctrl~sysid = keys~sysid
       AND procctrl~ccode = keys~ccode
       AND procctrl~legalentity = keys~legalentity
       AND procctrl~costobject = keys~costobject
       AND procctrl~costcenter = keys~costcenter
       AND procctrl~process = @/esrcc/if_calculate_chargeout=>trueuprecal
       INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.

*update process control
    LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).

      <procctrl>-errorflag = abap_true.     "Cost Base Approved

*Admin data
      <procctrl>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <procctrl>-last_changed_at
      ).

    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.


  ENDMETHOD.

  METHOD check_if_objects_are_finalized.

    DATA lt_cc_cost    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lv_validon    TYPE /esrcc/validfrom.
    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitems      TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY.
    DATA logitem       TYPE /esrcc/log_item.
    DATA procctrl      TYPE /esrcc/tt_keys.


    CLEAR: ev_failed.

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
                    procctrl~ryear,
                    procctrl~poper,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter,
                    procctrl~process,
                    procctrl~log_header_uuid
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~fplv          = keys~fplv
                   AND  procctrl~ryear         = keys~ryear
                   AND  procctrl~poper         = keys~poper
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~process        = @/esrcc/if_calculate_chargeout=>trueuprecal
                   AND  procctrl~log_header_uuid IS NOT INITIAL
                   ORDER BY procctrl~fplv,
                            procctrl~ryear,
                            procctrl~poper,
                            procctrl~sysid,
                            procctrl~legalentity,
                            procctrl~ccode,
                            procctrl~costobject,
                            procctrl~costcenter,
                            procctrl~process
                   INTO CORRESPONDING FIELDS OF TABLE @procctrl.

* read the process control data to get the statuses
    SELECT DISTINCT procctrl~*
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @ct_keys AS keys
                    ON  procctrl~ryear         = keys~ryear
                   AND  procctrl~poper         = keys~poper
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~process       = @/esrcc/if_calculate_chargeout=>stdchargeout
                   AND  procctrl~status        <> @/esrcc/if_calculate_chargeout=>stdchargeout_finalized
                   INTO TABLE @DATA(procctrlstatus).


*Check if errors needs to be reported
    LOOP AT ct_keys ASSIGNING FIELD-SYMBOL(<keys>).

      DATA(failed) = abap_false.


*Check for each month in case of YTD
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).

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

        IF lines( procctrlstatus ) IS NOT INITIAL.
*      log an error
          CLEAR logitem.
          logitem-parent_log_uuid = parentloguuid.
          logitem-message_id = '/ESRCC/EXECCOCKPIT'.
          logitem-message_number = '033'.
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
            process     = /esrcc/if_calculate_chargeout=>trueuprecal
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( <keys> ).
        ls_procctrl-poper = iv_recalrefpoper.
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>trueuprecal.    "Cost Base
        ls_procctrl-status  = /esrcc/if_calculate_chargeout=>recalculation_failed.     "Cost Base failed
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
                         AND poper = <keys>-poper.
        ev_failed = failed.
      ENDIF.
      CLEAR loginstance.
    ENDLOOP.


    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    CLEAR: procctrl.


  ENDMETHOD.

ENDCLASS.
