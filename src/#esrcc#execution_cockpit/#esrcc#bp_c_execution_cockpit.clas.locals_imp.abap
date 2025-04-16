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

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD finalizecostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD finalizestewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD performchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD performstewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD reopenchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

    IF lo_badi IS NOT BOUND.
      TRY.
          GET BADI lo_badi.
        CATCH cx_badi_not_implemented cx_badi_unknown_error.
      ENDTRY.
    ENDIF.

    IF lo_badi IS BOUND.

      CALL BADI lo_badi->reopen_chargeout
        EXPORTING
          it_keys = lt_keys
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD reopencostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD reopenstewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD performcostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

*    DATA lt_keys      TYPE /esrcc/tt_keys.
*    DATA lo_badi      TYPE REF TO /esrcc/badi_cockpit.
*    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
*    DATA ls_procctrl  TYPE /esrcc/procctrl.
*    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.
*
*
*    lt_keys = CORRESPONDING #( keys ).
*    DELETE lt_keys WHERE costobject IS INITIAL.
*
**update process control
*    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<key>) WHERE costcenter IS NOT INITIAL
*                                    AND serviceproduct IS INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = /esrcc/cl_calculate_chargeout=>costbase.    "Cost Base
*      ls_procctrl-status = /esrcc/cl_calculate_chargeout=>costbase_inprocess.     "Cost Base Approved
*
**Admin data
*      ls_procctrl-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-created_at
*      ).
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
*    /esrcc/cl_calculate_chargeout=>create_processlogs(
*      EXPORTING
*        iv_action      = '01'
*        it_keys        = lt_keys
*      IMPORTING
*        et_processlogs = lt_procclogs
*    ).
*
*    CALL FUNCTION '/ESRCC/FM_EXECUTIONCOCKPIT'
*      EXPORTING
*        it_keys = lt_procclogs
*        iv_action = '01'.
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.

  ENDMETHOD.

  METHOD automate_sequentialchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

  METHOD reopen_sequentialchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA: lo_badi TYPE REF TO /esrcc/badi_cockpit.

    lt_keys = CORRESPONDING #( keys ).

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
*         it_poper =
        .

    ENDIF.

  ENDMETHOD.

ENDCLASS.
