INTERFACE /esrcc/if_wf_handler
  PUBLIC .
  METHODS:
    trigger_workflow
      IMPORTING
        leading_objects       TYPE /esrcc/tt_wf_leadingobject
      EXPORTING
        leading_objects_error TYPE /esrcc/tt_wf_leadingobject_err,

    trigger_workflow_bc
      IMPORTING
        leading_objects       TYPE /esrcc/tt_wf_leadingobject_bc
      EXPORTING
        leading_objects_error TYPE /esrcc/tt_wf_leadingobject_err.
ENDINTERFACE.
