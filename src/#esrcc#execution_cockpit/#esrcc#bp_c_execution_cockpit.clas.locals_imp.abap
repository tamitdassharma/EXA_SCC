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

    METHODS finalizechargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalizechargeout.

    METHODS finalizecostbase FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalizecostbase.

    METHODS finalizestewardship FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalizestewardship.

    METHODS performcostbase FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~performcostbase.

    METHODS performchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~performchargeout.

    METHODS performstewardship FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~performstewardship.

    METHODS reopenchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopenchargeout.

    METHODS reopencostbase FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopencostbase.

    METHODS reopenstewardship FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopenstewardship.

    METHODS automate_sequentialchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~automate_sequentialchargeout.

    METHODS reopen_sequentialchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_sequentialchargeout.

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

  METHOD finalizechargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->finalize_chargeout
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>chargeout
          status  = /esrcc/if_calculate_chargeout=>chargeout_fin_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_finalize_chargeout
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_finalize_chargeout
        proclogs = lt_procclogs
      ).

    ENDIF.

  ENDMETHOD.

  METHOD finalizecostbase.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->finalize_costbase
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>costbase
          status  = /esrcc/if_calculate_chargeout=>costbase_fin_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_finalize_costbase
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_finalize_costbase
        proclogs = lt_procclogs
      ).

    ENDIF.


  ENDMETHOD.

  METHOD finalizestewardship.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->finalize_servicecostshare
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>serviceshare
          status  = /esrcc/if_calculate_chargeout=>serviceshare_fin_inproces
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_finalize_serviceproduct
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_finalize_serviceproduct
        proclogs = lt_procclogs
      ).

    ENDIF.


  ENDMETHOD.

  METHOD performchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->calculate_chargeout
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>chargeout
          status  = /esrcc/if_calculate_chargeout=>chargeout_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_calculat_chargeout
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_calculat_chargeout
        proclogs = lt_procclogs
      ).

    ENDIF.


  ENDMETHOD.

  METHOD performstewardship.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->calculate_servicecostshare
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>serviceshare
          status  = /esrcc/if_calculate_chargeout=>serviceshare_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct
        proclogs = lt_procclogs
      ).

    ENDIF.

  ENDMETHOD.

  METHOD reopenchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->finalize_chargeout
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>chargeout
          status  = /esrcc/if_calculate_chargeout=>chargeout_reopen_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_reopen_chargeout
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_reopen_chargeout
        proclogs = lt_procclogs
      ).

    ENDIF.

  ENDMETHOD.

  METHOD reopencostbase.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->reopen_costbase
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>costbase
          status  = /esrcc/if_calculate_chargeout=>costbase_reopen_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_reopen_costbase
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_reopen_costbase
        proclogs = lt_procclogs
      ).

    ENDIF.

  ENDMETHOD.

  METHOD reopenstewardship.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->reopen_serviceshare
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>serviceshare
          status  = /esrcc/if_calculate_chargeout=>serviceshare_reopen_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_reopen_serviceproduct
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_reopen_serviceproduct
        proclogs = lt_procclogs
      ).

    ENDIF.


  ENDMETHOD.

  METHOD performcostbase.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->calculate_costbase
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>costbase
          status  = /esrcc/if_calculate_chargeout=>costbase_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_calculate_costbase
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_calculate_costbase
        proclogs = lt_procclogs
      ).

    ENDIF.

  ENDMETHOD.

  METHOD automate_sequentialchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costcenter IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->sequentialchargeout
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>costbase
          status  = /esrcc/if_calculate_chargeout=>costbase_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_sequential_chargeout
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_sequential_chargeout
        proclogs = lt_procclogs
      ).

    ENDIF.

  ENDMETHOD.

  METHOD reopen_sequentialchargeout.

 DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costcenter IS INITIAL.

    IF lines( lt_keys ) < 100.
      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      IF lo_badi IS BOUND.

        CALL BADI lo_badi->reopnesequentialchargeout
          EXPORTING
            it_keys = lt_keys
*           it_poper =
          .
      ENDIF.
    ELSE.
*update process control
      /esrcc/cl_calculate_chargeout=>set_process_control(
        EXPORTING
          keys    = lt_keys
          process = /esrcc/if_calculate_chargeout=>costbase
          status  = /esrcc/if_calculate_chargeout=>costbase_reopen_inprocess
          update  = abap_false
        IMPORTING
          failed  = DATA(failure)
      ).

* set process logs
      /esrcc/cl_calculate_chargeout=>create_processlogs(
         EXPORTING
           iv_action      = /esrcc/if_calculate_chargeout=>action_reopenseq_chargeout
           it_keys        = lt_keys
         IMPORTING
           et_processlogs = lt_procclogs
       ).

*Schedule the job
      schedule_job(
        action   = /esrcc/if_calculate_chargeout=>action_reopenseq_chargeout
        proclogs = lt_procclogs
      ).

    ENDIF.


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

ENDCLASS.
