INTERFACE /esrcc/if_workflow_enh
  PUBLIC .


  INTERFACES if_badi_interface .

  METHODS split_and_create_wf_data
    IMPORTING
      !it_leading_object TYPE /esrcc/tt_wf_leadingobject
    CHANGING
      !et_wf_split_data  TYPE /esrcc/tt_split_workflow .
  METHODS set_wf_task_title
    IMPORTING
      !it_leading_object TYPE /esrcc/tt_wf_leadingobject
    CHANGING
      !ev_header         TYPE string .
  METHODS set_wf_task_description
    IMPORTING
      !it_leading_object TYPE /esrcc/tt_wf_leadingobject
    CHANGING
      !et_task_desc      TYPE /esrcc/tt_wf_st_len .
  METHODS get_agents
    IMPORTING
      !iv_wf_id          TYPE /esrcc/workflowid
      !iv_approval_level TYPE /esrcc/approvallevel
    CHANGING
      !et_agents         TYPE /esrcc/agent_list .
ENDINTERFACE.
