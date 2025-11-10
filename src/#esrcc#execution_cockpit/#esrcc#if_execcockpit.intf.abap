INTERFACE /esrcc/if_execcockpit
  PUBLIC .

  INTERFACES: if_badi_interface.

  CLASS-METHODS background_scheduler
    IMPORTING
      !it_parameters TYPE if_apj_rt_exec_object=>tt_templ_val
    .

ENDINTERFACE.
