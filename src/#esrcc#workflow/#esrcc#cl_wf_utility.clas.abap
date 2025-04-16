CLASS /esrcc/cl_wf_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_workflow_status TYPE RANGE OF /esrcc/status_de .

    CONSTANTS:
      BEGIN OF wf_status,
        draft               TYPE /esrcc/status_de VALUE 'D',
        in_process          TYPE /esrcc/status_de VALUE 'P',
        approval_pending    TYPE /esrcc/status_de VALUE 'W',
        approved            TYPE /esrcc/status_de VALUE 'A',
        rejected            TYPE /esrcc/status_de VALUE 'R',
        finalize_in_process TYPE /esrcc/status_de VALUE 'J',
        finalized           TYPE /esrcc/status_de VALUE 'F',
        failed              TYPE /esrcc/status_de VALUE 'E',
        reopen_in_process   TYPE /esrcc/status_de VALUE 'L',
      END OF wf_status .
    CONSTANTS:
      BEGIN OF app,
        cost_base_line_item   TYPE /esrcc/application_type_de VALUE 'CBL',
        cost_base_stewardship TYPE /esrcc/application_type_de VALUE 'CBS',
        cost_share_markup     TYPE /esrcc/application_type_de VALUE 'SCM',
        charge_out_receiver   TYPE /esrcc/application_type_de VALUE 'CHR',
        bc_stewardship        TYPE /esrcc/application_type_de VALUE 'CST',
        bc_charge_out_rule    TYPE /esrcc/application_type_de VALUE 'CCR',
        bc_product_markup     TYPE /esrcc/application_type_de VALUE 'CPM',
      END OF app .

    CLASS-METHODS is_wf_on
      IMPORTING
        !iv_apptype   TYPE /esrcc/application_type_de
      EXPORTING
        !ev_wf_active TYPE /esrcc/workflow_on .
    CLASS-METHODS wf_status_action_update
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_delete
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_submit
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_finalize
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_reopen
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_criticality
      IMPORTING
        !status            TYPE /esrcc/status_de
      RETURNING
        VALUE(criticality) TYPE int1 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_WF_UTILITY IMPLEMENTATION.


  METHOD is_wf_on.
    CLEAR ev_wf_active.
    SELECT SINGLE application , workflowactive FROM /esrcc/wf_switch  WHERE application = @iv_apptype INTO @DATA(ls_switch).
    IF sy-subrc EQ 0.
      ev_wf_active =  ls_switch-workflowactive.
    ENDIF.

  ENDMETHOD.


  METHOD wf_status_action_delete.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = '' )
                       ( sign = 'I' option = 'EQ' low = wf_status-draft )
                       ( sign = 'I' option = 'EQ' low = wf_status-approved )
                       ( sign = 'I' option = 'EQ' low = wf_status-rejected )
                       ( sign = 'I' option = 'EQ' low = wf_status-failed ) ).
  ENDMETHOD.


  METHOD wf_status_action_finalize.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = wf_status-approved ) ).
  ENDMETHOD.


  METHOD wf_status_action_reopen.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = wf_status-finalized ) ).
  ENDMETHOD.


  METHOD wf_status_action_submit.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = wf_status-draft ) ).
  ENDMETHOD.


  METHOD wf_status_action_update.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = '' )
                       ( sign = 'I' option = 'EQ' low = wf_status-draft )
                       ( sign = 'I' option = 'EQ' low = wf_status-approved )
                       ( sign = 'I' option = 'EQ' low = wf_status-rejected )
                       ( sign = 'I' option = 'EQ' low = wf_status-failed ) ).
  ENDMETHOD.


  METHOD wf_status_criticality.
    criticality = SWITCH #( status " Red
                                   WHEN wf_status-rejected OR
                                        wf_status-failed THEN 1
                                   " Yellow
                                   WHEN wf_status-draft OR
                                        wf_status-in_process OR
                                        wf_status-approval_pending OR
                                        wf_status-finalize_in_process OR
                                        wf_status-reopen_in_process THEN 2
                                   " Green
                                   WHEN wf_status-approved OR
                                        wf_status-finalized THEN 3 ).
  ENDMETHOD.
ENDCLASS.
