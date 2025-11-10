CLASS /esrcc/apj_extraction_bw DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
ENDCLASS.


CLASS /esrcc/apj_extraction_bw IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE if_apj_dt_exec_object=>tt_templ_def(
                                 changeable_ind = abap_true
                                 ( selname        = 'EXT_OBJ'
                                   kind           = if_apj_dt_exec_object=>parameter
                                   length         = 2
                                   component_type = '/ESRCC/EXTRACTION_OBJECT'
                                   section_text   = 'Extraction Object'
                                   group_text     = 'Filters'
                                   param_text     = 'Extraction Object'
                                   mandatory_ind  = abap_true
                                 )
                                 ( selname        = 'REP_YEAR'
                                   kind           = if_apj_dt_exec_object=>parameter
                                   length         = 4
                                   component_type = '/ESRCC/RYEAR'
                                   section_text   = 'Year'
                                   group_text     = 'Filters'
                                   param_text     = 'Year'
                                   mandatory_ind  = abap_true
                                 )
                                 ( selname        = 'PERIOD'
                                   kind           = if_apj_dt_exec_object=>select_option
                                   length         = 3
                                   component_type = '/ESRCC/POPER'
                                   section_text   = 'Posting Period'
                                   group_text     = 'Filters'
                                   param_text     = 'Posting Period'
                                   mandatory_ind  = abap_true
                                 )
                                 ( selname        = 'PKG_CODE'
                                   kind           = if_apj_dt_exec_object=>select_option
                                   length         = 2
                                   component_type = '/ESRCC/PACKAGE_CODE'
                                   section_text   = 'Package Code'
                                   group_text     = 'Filters'
                                   param_text     = 'Package Code'
                                 )
                                 ( selname        = 'LEDGER'
                                   kind           = if_apj_dt_exec_object=>parameter
                                   length         = 2
                                   component_type = '/ESRCC/LEDGER_DE'
                                   section_text   = 'Ledger'
                                   group_text     = 'Filters'
                                   param_text     = 'Ledger'
                                 )
                                 ( selname        = 'ENTITY'
                                   kind           = if_apj_dt_exec_object=>select_option
                                   length         = 4
                                   component_type = '/ESRCC/LEGALENTITY'
                                   section_text   = 'Legal Entity'
                                   group_text     = 'Filters'
                                   param_text     = 'Legal Entity'
                                 )
                                 ( selname        = 'CSTCENTR'
                                   kind           = if_apj_dt_exec_object=>select_option
                                   length         = 24
                                   component_type = '/ESRCC/COSTCENTER'
                                   section_text   = 'Cost Center(s)'
                                   group_text     = 'Filters'
                                   param_text     = 'Cost Center(s)'
                                 )
                                 ( selname        = 'CSTELEM'
                                   kind           = if_apj_dt_exec_object=>select_option
                                   length         = 10
                                   component_type = '/ESRCC/COSTELEMENT'
                                   section_text   = 'Cost Element(s)'
                                   group_text     = 'Filters'
                                   param_text     = 'Cost Element(s)'
                                 )
                                 ( selname        = 'PKG_SIZE'
                                   kind           = if_apj_dt_exec_object=>parameter
                                   datatype       = 'C'
                                   length         = 5
                                   section_text   = 'Package Size'
                                   group_text     = 'Run Mode'
                                   param_text     = 'Package Size'
                                 )
                                 ( selname        = 'SIMULATE'
                                   kind           = if_apj_dt_exec_object=>parameter
                                   datatype       = 'C'
                                   length         = 1
                                   section_text   = 'Simulation'
                                   group_text     = 'Run Mode'
                                   param_text     = 'Simulation'
                                   checkbox_ind   = abap_true
    ) ).
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    /esrcc/api=>extraction_bw_service->filter(

        filters = VALUE #( FOR GROUPS <group> OF <parameter> IN it_parameters
                           GROUP BY
                           ( key = <parameter>-selname )
                           LET inputs = VALUE if_apj_rt_exec_object=>tt_templ_val( FOR <param> IN GROUP <group>
                                                                                   ( <param> ) ) IN
                           ( filter_name = <group>
                             filter_value = NEW if_apj_rt_exec_object=>tt_templ_val( inputs ) ) ) )->extract( ).
  ENDMETHOD.
ENDCLASS.
