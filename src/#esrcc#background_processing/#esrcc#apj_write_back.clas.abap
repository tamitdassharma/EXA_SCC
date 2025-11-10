CLASS /esrcc/apj_write_back DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
ENDCLASS.


CLASS /esrcc/apj_write_back IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #( changeable_ind = abap_true
                                ( selname        = 'REP_YEAR'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'C'
                                  length         = 4
*                                  decimals       =
                                  component_type = '/ESRCC/RYEAR'
*                                  section_text   =
                                  group_text     = 'Planning Parameters'
                                  param_text     = 'Reporting Year'
*                                  lowercase_ind  =
*                                  hidden_ind     =
                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'PERIOD'
                                  kind           = if_apj_dt_exec_object=>select_option
*                                  datatype       =
                                  length         = 3
*                                  decimals       =
                                  component_type = '/ESRCC/POPER'
                                  section_text   = 'Validity Period'
                                  group_text     = 'Planning Parameters'
                                  param_text     = 'Validity Period'
*                                  lowercase_ind  =
*                                  hidden_ind     =
                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'PLAN_VER'
                                  kind           = if_apj_dt_exec_object=>select_option
*                                  datatype       =
                                  length         = 3
*                                  decimals       =
                                  component_type = '/ESRCC/FPLV_DE'
                                  section_text   = 'Planning Version'
                                  group_text     = 'Planning Parameters'
                                  param_text     = 'Planning Version'
*                                  lowercase_ind  =
*                                  hidden_ind     =
                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'SENDER'
                                  kind           = if_apj_dt_exec_object=>select_option
*                                  datatype       =
                                  length         = 4
*                                  decimals       =
                                  component_type = '/ESRCC/LEGALENTITY'
                                  section_text   = 'Sending Entity'
                                  group_text     = 'Entities'
                                  param_text     = 'Sending Entity'
*                                  lowercase_ind  =
*                                  hidden_ind     =
                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'RECEIVER'
                                  kind           = if_apj_dt_exec_object=>select_option
*                                  datatype       =
                                  length         = 4
*                                  decimals       =
                                  component_type = '/ESRCC/LEGALENTITY'
                                  section_text   = 'Receiving Entity'
                                  group_text     = 'Entities'
                                  param_text     = 'Receiving Entity'
*                                  lowercase_ind  =
*                                  hidden_ind     =
                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'DOCUMENT'
                                  kind           = if_apj_dt_exec_object=>select_option
*                                  datatype       =
                                  length         = 10
*                                  decimals       =
                                  component_type = '/ESRCC/DOC_NO'
                                  section_text   = 'Document Number'
                                  group_text     = 'Document Details'
                                  param_text     = 'Document Number'
*                                  lowercase_ind  =
*                                  hidden_ind     =
*                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'ITEM_NO'
                                  kind           = if_apj_dt_exec_object=>select_option
*                                  datatype       =
                                  length         = 5
*                                  decimals       =
                                  component_type = '/ESRCC/BUZEI'
                                  section_text   = 'Item Number'
                                  group_text     = 'Document Details'
                                  param_text     = 'Item Number'
*                                  lowercase_ind  =
*                                  hidden_ind     =
*                                  mandatory_ind  = abap_true
*                                  checkbox_ind   =
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
                                )
                                ( selname        = 'SIMULATE'
                                  kind           = if_apj_dt_exec_object=>parameter
                                  datatype       = 'C'
                                  length         = 1
*                                  decimals       =
                                  component_type = 'ABAP_BOOL'
                                  section_text   = 'Simulation'
                                  group_text     = 'Execution Options'
                                  param_text     = 'Simulation'
*                                  lowercase_ind  =
*                                  hidden_ind     =
*                                  mandatory_ind  = abap_true
                                  checkbox_ind   = abap_true
*                                  list_ind       =
*                                  radio_group_ind =
*                                  radio_group_id =
    ) ).

*    et_parameter_val = VALUE #( ( selname = 'SIMULATE'
*                                  kind    = if_apj_dt_exec_object=>parameter
**                                  sign    = if_apj_dt_exec_object=>paramet
**                                  option  =
*                                  low     = abap_true
**                                  high    =
*    ) ).
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    /esrcc/api=>document_service->filter(
        filters = VALUE #( FOR GROUPS <group> OF <parameter> IN it_parameters
                           GROUP BY
                           ( key = <parameter>-selname )
                           LET inputs = VALUE if_apj_rt_exec_object=>tt_templ_val( FOR <param> IN GROUP <group>
                                                                                   ( <param> ) ) IN
                           ( filter_name  = <group>
                             filter_value = NEW if_apj_rt_exec_object=>tt_templ_val( inputs ) ) ) )->write_back( ).
  ENDMETHOD.
ENDCLASS.
