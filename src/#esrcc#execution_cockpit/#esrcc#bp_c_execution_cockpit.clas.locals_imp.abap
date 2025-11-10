CLASS lhc_c_execution_cockpit DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_execution_cockpit RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /esrcc/c_execution_cockpit.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_execution_cockpit RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_execution_cockpit.

    METHODS finalize_recalchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_recalchargeout.

    METHODS finalize_recalseqchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_recalseqchargeout.

    METHODS finalize_stdchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_stdchargeout.

    METHODS finalize_stdseqchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_stdseqchargeout.

    METHODS perform_recalchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_recalchargeout RESULT result.

    METHODS perform_recalseqchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_recalseqchargeout RESULT result.

    METHODS perform_stdchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_stdchargeout RESULT result.

    METHODS perform_stdseqchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_stdseqchargeout RESULT result.

    METHODS reopen_recalchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_recalchargeout.

    METHODS reopen_recalseqchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_recalseqchargeout.

    METHODS reopen_stdchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_stdchargeout.

    METHODS reopen_stdseqchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_stdseqchargeout.

    METHODS schedule_job
      IMPORTING
        action   TYPE /esrcc/actions
        proclogs TYPE /esrcc/tt_processlogs.

ENDCLASS.

CLASS lhc_c_execution_cockpit IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD schedule_job.

**********************************************************************
*Schedule a JOB
**********************************************************************
    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE '/ESRCC/CHARGEOUT_CALCULATION_JT'.
    DATA job_start_info    TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters    TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_parameter     TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA range_value       TYPE cl_apj_rt_api=>ty_value_range.
    DATA job_name          TYPE cl_apj_rt_api=>ty_jobname VALUE '/ESRCC/CALCULATE_CHARGEOUT'.
    DATA job_count         TYPE cl_apj_rt_api=>ty_jobcount.

    job_start_info-start_immediately = abap_true.

    job_parameter-name = /esrcc/cl_apj_rt_service=>action_param.
    range_value-sign = 'I'.
    range_value-option = 'EQ'.
    range_value-low = action.
    APPEND range_value TO job_parameter-t_value.
    APPEND job_parameter TO job_parameters.
    CLEAR job_parameter.

    LOOP AT proclogs ASSIGNING FIELD-SYMBOL(<ls_proclogs>).
      CLEAR:  range_value.
      job_parameter-name = 'ID'.
      range_value-sign = 'I'.
      range_value-option = 'EQ'.
      range_value-low = <ls_proclogs>-uuid.
      APPEND range_value TO job_parameter-t_value.
      APPEND job_parameter TO job_parameters.
    ENDLOOP.


    TRY.
        cl_apj_rt_api=>schedule_job(
                          EXPORTING
                          iv_job_template_name = job_template_name
                          iv_job_text = |Calculate Chargeout|
                          is_start_info = job_start_info
                          it_job_parameter_value = job_parameters
*                          iv_jobname = job_name
                          IMPORTING
                          ev_jobname  = job_name
                          ev_jobcount = job_count
                          ).
      CATCH cx_apj_rt INTO DATA(job_scheduling_error).

        DATA(error_message) = job_scheduling_error->bapimsg-message.
        "handle exception
    ENDTRY.

  ENDMETHOD.

  METHOD Finalize_recalchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->finalize_recalchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_fin_inproces
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_recalchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_recalchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD finalize_recalseqchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.
    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lv_validon       TYPE /esrcc/validfrom.
    DATA lt_procctrl_keys TYPE /esrcc/tt_keys.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costcenter IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->finalize_recalseqchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @lt_keys AS it_keys
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
*        APPEND <poper> TO lt_poper.
      DATA(poper) = lt_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = lt_keys[ 1 ]-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_procctrl_keys.

      ENDLOOP.
    ENDIF.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_fin_inproces
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_recalseqchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_recalseqchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD Finalize_stdchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->finalize_stdchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_fin_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_stdchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_stdchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD Finalize_stdseqchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.
    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lv_validon       TYPE /esrcc/validfrom.
    DATA lt_procctrl_keys TYPE /esrcc/tt_keys.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->finalize_stdseqchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @lt_keys AS it_keys
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
*        APPEND <poper> TO lt_poper.
      DATA(poper) = lt_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = lt_keys[ 1 ]-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_procctrl_keys.

      ENDLOOP.
    ENDIF.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl_keys
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_fin_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_stdseqchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_stdseqchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD perform_recalchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->calculate_recalchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD perform_recalseqchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.
    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lv_validon       TYPE /esrcc/validfrom.
    DATA lt_procctrl_keys TYPE /esrcc/tt_keys.


    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costcenter IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->calculate_recalseqchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @lt_keys AS it_keys
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
*        APPEND <poper> TO lt_poper.
      DATA(poper) = lt_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = lt_keys[ 1 ]-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_procctrl_keys.

      ENDLOOP.
    ENDIF.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_recalseqchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_recalseqchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD perform_stdchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->calculate_stdchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_stdchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_stdchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD perform_stdseqchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.
    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lv_validon       TYPE /esrcc/validfrom.
    DATA lt_procctrl_keys TYPE /esrcc/tt_keys.


    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->calculate_stdseqchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @lt_keys AS it_keys
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
*        APPEND <poper> TO lt_poper.
      DATA(poper) = lt_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = lt_keys[ 1 ]-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_procctrl_keys.

      ENDLOOP.
    ENDIF.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl_keys
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_stdseqchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_stdseqchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD reopen_recalchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->reopen_recalchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_recalchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_recalchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD reopen_recalseqchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.
    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lv_validon       TYPE /esrcc/validfrom.
    DATA lt_procctrl_keys TYPE /esrcc/tt_keys.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costcenter IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->reopen_recalseqchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @lt_keys AS it_keys
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
*        APPEND <poper> TO lt_poper.
      DATA(poper) = lt_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = lt_keys[ 1 ]-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_procctrl_keys.

      ENDLOOP.
    ENDIF.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_recalseqchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_recalseqchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD reopen_stdchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->reopen_stdchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.
*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_stdchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_stdchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

  METHOD reopen_stdseqchargeout.

    DATA lt_keys          TYPE /esrcc/tt_keys.
    DATA lo_badi          TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs     TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl      TYPE /esrcc/procctrl.
    DATA lt_procctrl      TYPE TABLE OF /esrcc/procctrl.
    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lv_validon       TYPE /esrcc/validfrom.
    DATA lt_procctrl_keys TYPE /esrcc/tt_keys.



    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.
*    DELETE lt_keys WHERE serviceproduct IS INITIAL.

*    IF lines( lt_keys ) < 100.
*      IF lo_badi IS NOT BOUND.
*        TRY.
*            GET BADI lo_badi.
*          CATCH cx_badi_not_implemented cx_badi_unknown_error.
*        ENDTRY.
*      ENDIF.
*
*      IF lo_badi IS BOUND.
*
*        CALL BADI lo_badi->reopen_stdseqchargeout
*          EXPORTING
*            it_keys = lt_keys
**           it_poper =
*          .
*      ENDIF.
*    ELSE.


*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @lt_keys AS it_keys
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
*        APPEND <poper> TO lt_poper.
      DATA(poper) = lt_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = lt_keys[ 1 ]-poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO lt_procctrl_keys.

      ENDLOOP.
    ENDIF.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl_keys
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_stdseqchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_stdseqchargeout
      proclogs = lt_procclogs
    ).

*    ENDIF.

  ENDMETHOD.

ENDCLASS.
