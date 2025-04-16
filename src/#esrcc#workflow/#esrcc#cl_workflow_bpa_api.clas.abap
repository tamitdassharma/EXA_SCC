CLASS /esrcc/cl_workflow_bpa_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS trigger_workflow.
    CLASS-METHODS determine_next_approver
      IMPORTING
        !parameters    TYPE /esrcc/c_workflow_users
      EXPORTING
        !next_approver TYPE /esrcc/approvallevel.

    CLASS-METHODS determine_previous_approver
      IMPORTING
        !parameters        TYPE /esrcc/c_workflow_users
      EXPORTING
        !previous_approver TYPE /esrcc/approvallevel.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_WORKFLOW_BPA_API IMPLEMENTATION.


  METHOD determine_next_approver.

    next_approver = parameters-approval_level + 1.
*
    SELECT single approvallevel  FROM /ESRCC/C_WfCust
                                       WHERE Application = @parameters-application
                                         AND Approvallevel = @next_approver
*                                         AND ( Sysid = @parameters-sysid
*                                         OR Legalentity = @parameters-legalentity
*                                         OR costobject = @parameters-costobject
*                                         OR Costcenter = @parameters-costcenter )
                                         INTO @DATA(lv_approvallevel).
**
*    next_approver = parameters-approval_level + 1.
    IF lv_approvallevel is INITIAL.
      CLEAR next_approver.
    ENDIF.

  ENDMETHOD.


  METHOD determine_previous_approver.
    CLEAR previous_approver.
  ENDMETHOD.


  METHOD trigger_workflow.

    DATA: CpWfHandle TYPE /esrcc/sww_wiid.

    SELECT * FROM /esrcc/procctrl WHERE ( ( status = '05' AND process = 'CBS' )
                                     OR ( status = '02' AND process = 'SCM' )
                                     OR ( status = '02' AND process = 'CHR' ) )
                                     AND wf_started = @abap_false
                                     INTO TABLE @DATA(lt_proctrl).

    IF lt_proctrl IS NOT INITIAL.
*Receiver allocation
      SELECT
            legalentity, ccode, costobject, costcenter,
            serviceproduct, receivingentity   FROM /esrcc/i_chargeout_receivers
      FOR ALL ENTRIES IN @lt_proctrl WHERE fplv = @lt_proctrl-fplv
                                       AND ryear = @lt_proctrl-ryear
                                       AND sysid = @lt_proctrl-sysid
*                                       AND billfrequency = @lt_proctrl-billingfreq
*                                       AND billingperiod = @lt_proctrl-billingperiod
                                       AND legalentity = @lt_proctrl-legalentity
                                       AND ccode = @lt_proctrl-ccode
                                       AND costobject = @lt_proctrl-costobject
                                       AND costcenter = @lt_proctrl-costcenter
                                       AND serviceproduct = @lt_proctrl-serviceproduct
                                       INTO TABLE @DATA(lt_receivers).

    ENDIF.

    LOOP AT lt_proctrl ASSIGNING FIELD-SYMBOL(<ls_prctrl>).

      IF <ls_prctrl>-process = 'CHR'.
        LOOP AT lt_receivers ASSIGNING FIELD-SYMBOL(<ls_receiver>)
                                     WHERE
*                                          fplv = <ls_prctrl>-fplv
*                                       AND ryear = <ls_prctrl>-ryear
*                                       AND sysid = <ls_prctrl>-sysid
**                                       AND billfrequency = <ls_prctrl>-billingfreq
**                                       AND billingperiod = <ls_prctrl>-billingperiod

  legalentity = <ls_prctrl>-legalentity
                                    AND ccode = <ls_prctrl>-ccode
                                       AND costobject = <ls_prctrl>-costobject
                                       AND costcenter = <ls_prctrl>-costcenter
                                       AND serviceproduct = <ls_prctrl>-serviceproduct.

          TRY.
              CALL METHOD cl_numberrange_runtime=>number_get
                EXPORTING
                  nr_range_nr = '01'
                  object      = '/ESRCC/WF'
                IMPORTING
                  number      = DATA(number)
                  returncode  = DATA(lv_rcode).
            CATCH cx_nr_object_not_found
                  cx_number_ranges INTO DATA(cx_numberrange).
              DATA(error) = cx_numberrange->get_longtext(  ).
          ENDTRY.
          cpwfhandle = number.

          DATA(wf_context) = VALUE /esrcc/s_wf_bpa_object(
                 fplv = <ls_prctrl>-fplv
                 ryear = <ls_prctrl>-ryear
                 sysid = <ls_prctrl>-sysid
                 legalentity = <ls_prctrl>-legalentity
                 ccode = <ls_prctrl>-ccode
                 costobject = <ls_prctrl>-costobject
                 costnumber = <ls_prctrl>-costcenter
                 serviceproduct = <ls_prctrl>-serviceproduct
                 receivingentity = <ls_receiver>-receivingentity
                 billfrequency = <ls_prctrl>-billingfreq
                 billingperiod = <ls_prctrl>-billingperiod
                 application = <ls_prctrl>-process
                 workflowid = CpWfHandle
               ).

          MODIFY ENTITIES OF i_cpwf_inst
               ENTITY CPWFInstance
               EXECUTE registerWorkflowStart
               FROM VALUE #( (
                               %key-CpWfHandle = CpWfHandle
                               %param-RetentionTime = '30'
                               %param-PaWfDefId = 'eu10.dev-abap-cloud.sccworkflow1.SCCWorkflow'
                               %param-CallbackClass = '/ESRCC/CL_SWF_CPWF_CALLBACK'
                               %param-Consumer = 'DEFAULT' ) ).

          TRY.
              DATA(cpwf_api_instance) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
            CATCH cx_swf_cpwf_api INTO DATA(cx_cpwf_api).
              error = cx_cpwf_api->get_longtext(  ).
          ENDTRY.

          DATA(lo_json) = cpwf_api_instance->get_json_converter(
*                              it_name_mapping              =
                                      iv_camel_case                = abap_false
                                      iv_capital_letter            = abap_false
*                              it_uppercase_word            =
                                      iv_suppress_empty_components = abap_true
                                      iv_uppercase                 = abap_false
                                    ).

          DATA(wf_context_json) = lo_json->serialize( wf_context ).


          MODIFY ENTITIES OF i_cpwf_inst
               ENTITY CPWFInstance
               EXECUTE setPayload
               FROM VALUE #( ( %key-CpWfHandle = CpWfHandle
                               %param-context = wf_context_json ) ).

        ENDLOOP.
      ELSE.

        TRY.
            CALL METHOD cl_numberrange_runtime=>number_get
              EXPORTING
                nr_range_nr = '01'
                object      = '/ESRCC/WF'
              IMPORTING
                number      = number
                returncode  = lv_rcode.
          CATCH cx_nr_object_not_found
                 cx_number_ranges INTO DATA(cx_numberranges).
            error = cx_numberranges->get_longtext(  ).
        ENDTRY.

        cpwfhandle = number.

        wf_context = VALUE /esrcc/s_wf_bpa_object(
                  fplv = <ls_prctrl>-fplv
                  ryear = <ls_prctrl>-ryear
                  sysid = <ls_prctrl>-sysid
                  legalentity = <ls_prctrl>-legalentity
                  ccode = <ls_prctrl>-ccode
                  costobject = <ls_prctrl>-costobject
                  costnumber = <ls_prctrl>-costcenter
                  serviceproduct = COND #( WHEN <ls_prctrl>-serviceproduct IS INITIAL THEN 'TEST' ELSE <ls_prctrl>-serviceproduct )
                  receivingentity = 'TEST'
                  billfrequency = <ls_prctrl>-billingfreq
                  billingperiod = <ls_prctrl>-billingperiod
                  application = <ls_prctrl>-process
                  workflowid = CpWfHandle
                ).

        MODIFY ENTITIES OF i_cpwf_inst
             ENTITY CPWFInstance
             EXECUTE registerWorkflowStart
             FROM VALUE #( (
                             %key-CpWfHandle = CpWfHandle
                             %param-RetentionTime = '30'
                             %param-PaWfDefId = 'eu10.dev-abap-cloud.sccworkflow1.SCCWorkflow'
                             %param-CallbackClass = '/ESRCC/CL_SWF_CPWF_CALLBACK'
                             %param-Consumer = 'DEFAULT' ) ).

        TRY.
            cpwf_api_instance = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
          CATCH cx_swf_cpwf_api INTO cx_cpwf_api.
            error = cx_cpwf_api->get_longtext(  ).
        ENDTRY.

        lo_json = cpwf_api_instance->get_json_converter(
*                              it_name_mapping              =
                                   iv_camel_case                = abap_false
                                   iv_capital_letter            = abap_false
*                              it_uppercase_word            =
                                   iv_suppress_empty_components = abap_true
                                   iv_uppercase                 = abap_false
                                 ).

        wf_context_json = lo_json->serialize( wf_context ).


        MODIFY ENTITIES OF i_cpwf_inst
             ENTITY CPWFInstance
             EXECUTE setPayload
             FROM VALUE #( ( %key-CpWfHandle = CpWfHandle
                             %param-context = wf_context_json ) ).
      ENDIF.
    ENDLOOP.

    LOOP AT lt_proctrl ASSIGNING FIELD-SYMBOL(<ls_proctrl>).
      <ls_proctrl>-wf_started = abap_true.
    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_proctrl.

  ENDMETHOD.
ENDCLASS.
