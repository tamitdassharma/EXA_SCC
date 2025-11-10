CLASS /esrcc/cl_hier_def_scheduler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_m_option,
        cost_object     TYPE /esrcc/mass_create_option VALUE 'CO',
        cost_element    TYPE /esrcc/mass_create_option VALUE 'CE',
        service_product TYPE /esrcc/mass_create_option VALUE 'SP',
      END OF c_m_option.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_hier_def_scheduler IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE if_apj_dt_exec_object=>tt_templ_def(
        ( selname         = 'HIER1'
          kind            = if_apj_dt_exec_object=>select_option
          length          = 20
          component_type  = '/ESRCC/HIERARCHY1'
          param_text      = 'Hierarchy 1'
          changeable_ind  = abap_true
          mandatory_ind   = abap_true )
        ( selname         = 'HIER2'
          kind            = if_apj_dt_exec_object=>select_option
          length          = 20
          component_type  = '/ESRCC/HIERARCHY2'
          param_text      = 'Hierarchy 2'
          changeable_ind  = abap_true
          mandatory_ind   = abap_true )
        ( selname         = 'HIER3'
          kind            = if_apj_dt_exec_object=>select_option
          length          = 20
          component_type  = '/ESRCC/HIERARCHY3'
          param_text      = 'Hierarchy 3'
          changeable_ind  = abap_true
          mandatory_ind   = abap_true )
        ( selname         = 'HIER4'
          kind            = if_apj_dt_exec_object=>select_option
          length          = 20
          component_type  = '/ESRCC/HIERARCHY4'
          param_text      = 'Hierarchy 4'
          changeable_ind  = abap_true
          mandatory_ind   = abap_true )
        ( selname         = 'VALIDFR'
          kind            = if_apj_dt_exec_object=>select_option
          length          = 8
          component_type  = '/ESRCC/VALIDFROM'
          param_text      = 'Valid From'
          changeable_ind  = abap_true
          mandatory_ind   = abap_true )
        ( selname         = 'SYNC'
          kind            = if_apj_dt_exec_object=>parameter
          datatype        = 'C'
          length          = 1
          param_text      = 'Synchronize (Finalized)'
          changeable_ind  = abap_true
          mandatory_ind   = abap_false
          checkbox_ind    = abap_true )
        ( selname         = 'OPTIONS'
          kind            = if_apj_dt_exec_object=>parameter
          length          = 3
          component_type  = '/ESRCC/MASS_CREATE_OPTION'
          param_text      = 'Option (Auto-Generate)'
          changeable_ind  = abap_true
          mandatory_ind   = abap_false )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA lo_badi TYPE REF TO /esrcc/badi_stewardshipconfig.
    DATA ls_config TYPE /esrcc/hier_def.

    LOOP AT it_parameters INTO DATA(parameter).
      CASE parameter-selname.
        WHEN 'HIER1'.
          ls_config-hierarchy1 = CONV /esrcc/hierarchy1( parameter-low ).
        WHEN 'HIER2'.
          ls_config-hierarchy2 = CONV /esrcc/hierarchy2( parameter-low ).
        WHEN 'HIER3'.
          ls_config-hierarchy3 = CONV /esrcc/hierarchy3( parameter-low ).
        WHEN 'HIER4'.
          ls_config-hierarchy4 = CONV /esrcc/hierarchy4( parameter-low ).
        WHEN 'VALIDFR'.
          ls_config-valid_from = CONV /esrcc/validfrom( parameter-low ).
        WHEN 'SYNC'.
          DATA(lv_sync) = CONV abap_boolean( parameter-low ).
        WHEN 'OPTIONS'.
          DATA(lv_option) = CONV /esrcc/mass_create_option( parameter-low ).
      ENDCASE.
    ENDLOOP.

* Execute the program in background

    IF lo_badi IS NOT BOUND.
      TRY.
          GET BADI lo_badi.
        CATCH cx_badi_not_implemented cx_badi_unknown_error.
      ENDTRY.
    ENDIF.

    IF lo_badi IS BOUND.
      CASE lv_option.
        WHEN c_m_option-cost_object.
          CALL BADI lo_badi->derive_costobjects
            EXPORTING
              is_config = ls_config
            IMPORTING
              ev_failed = DATA(failed).

        WHEN c_m_option-cost_element.
          CALL BADI lo_badi->derive_costelements
            EXPORTING
              is_config = ls_config
            IMPORTING
              ev_failed = failed.

        WHEN c_m_option-service_product.
          CALL BADI lo_badi->derive_serviceproducts
            EXPORTING
              is_config = ls_config
            IMPORTING
              ev_failed = failed.

        WHEN OTHERS.
          CALL BADI lo_badi->derive_stewardshipconfig
            EXPORTING
              is_config = ls_config
            IMPORTING
              ev_failed = failed.
      ENDCASE.


    ENDIF.

*    required to trigger workflow
    COMMIT WORK AND WAIT.
    IF failed = abap_false.
      UPDATE /esrcc/hier_def SET workflow_status = @/esrcc/cl_wf_utility=>wf_status-finalized
        WHERE hierarchy1 = @ls_config-hierarchy1
          AND hierarchy2 = @ls_config-hierarchy2
          AND hierarchy3 = @ls_config-hierarchy3
          AND hierarchy4 = @ls_config-hierarchy4
          AND valid_from = @ls_config-valid_from.
    ENDIF.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.
ENDCLASS.
