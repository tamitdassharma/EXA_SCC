CLASS /esrcc/cl_apj_rt_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS : action_param TYPE c LENGTH 8   VALUE 'ACTION'.
    CONSTANTS : id_param     TYPE c LENGTH 8   VALUE 'ID'.
    INTERFACES:
      if_apj_rt_exec_object,
      if_apj_dt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_apj_rt_service IMPLEMENTATION.


  METHOD if_apj_rt_exec_object~execute.

* Execute the program in background
    DATA lo_badi TYPE REF TO /esrcc/badi_cockpit.

    IF lo_badi IS NOT BOUND.
      TRY.
          GET BADI lo_badi.
        CATCH cx_badi_not_implemented cx_badi_unknown_error.
      ENDTRY.
    ENDIF.

    IF lo_badi IS BOUND.

      CALL BADI lo_badi->background_scheduler
        EXPORTING
          it_parameters = it_parameters.

    ENDIF.

  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.

* Add parameters to Job Template
    et_parameter_def = VALUE if_apj_dt_exec_object=>tt_templ_def(
    (
        selname         = action_param
        kind            = if_apj_dt_exec_object=>select_option
        datatype        = 'C'
        length          = 2
        component_type  = '/ESRCC/ACTIONS'
        param_text      = 'Chargeout Process'
        changeable_ind  = abap_true
    )
    (
        selname         = id_param
        kind            = if_apj_dt_exec_object=>select_option
        datatype        = 'RAW'
        length          = 16
        param_text      = 'Chargeout Id'
        changeable_ind  = abap_true
    )
    ).

  ENDMETHOD.

ENDCLASS.
