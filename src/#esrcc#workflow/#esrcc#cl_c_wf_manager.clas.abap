CLASS /esrcc/cl_c_wf_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_C_WF_MANAGER IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(cx_query).
            DATA(_error) = cx_query->get_longtext(  ).
            "handle exception
        ENDTRY.

**parameters
*            DATA(lt_parameters) = io_request->get_parameters( ).
*            DATA(lv_next_year) =  CONV /dmo/end_date( cl_abap_context_info=>get_system_date( ) + 365 )  .
*            DATA(lv_par_filter) = | BEGIN_DATE >= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_START_DATE' ]-value
*                                                                                              DEFAULT cl_abap_context_info=>get_system_date( ) ) ) }'| &&
*                                  | AND | &&
*                                  | END_DATE <= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_END_DATE' ]-value
*                                                                                            DEFAULT lv_next_year ) ) }'| .
*            IF lv_sql_filter IS INITIAL.
*              lv_sql_filter = lv_par_filter.
*            ELSE.
*              lv_sql_filter = |( { lv_sql_filter } AND { lv_par_filter } )| .
*            ENDIF.
**search
        DATA(lv_search_string) = io_request->get_search_expression( ).
        DATA(lv_search_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

        IF lv_sql_filter IS INITIAL.
          lv_sql_filter = lv_search_sql.
        ELSE.
          lv_sql_filter = |( { lv_sql_filter } AND { lv_search_sql } )|.
        ENDIF.
**request data
        IF io_request->is_data_requested( ) = abap_true.
***paging
          DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                      THEN 0 ELSE lv_page_size ).

**sorting
          DATA(sort_elements) = io_request->get_sort_elements( ).
          DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                     ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` descending`
                                                                                                                                     ELSE ` ascending` ) ) ).
          DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
                                                                           ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
**requested elements
          DATA(lt_req_elements) = io_request->get_requested_elements( ).
**aggregate
          DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).

          IF lt_aggr_element IS NOT INITIAL.
            LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
              DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
              DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
              APPEND lv_aggregation TO lt_req_elements.
            ENDLOOP.
          ENDIF.
          DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).
****grouping
          DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
          DATA(lv_grouping) = concat_lines_of( table = lt_grouped_element sep = `, ` ).

          TYPES: BEGIN OF ty_task,
                   taskstatus    TYPE string,
                   taskid        TYPE string,
                   taskprocessby TYPE string,
                   taskdecision  TYPE string,
                   taskcomments  TYPE string,
                 END OF ty_task.

          DATA lt_result TYPE STANDARD TABLE OF /esrcc/c_wf_manager.
          DATA ls_result TYPE /esrcc/c_wf_manager.
          DATA _sysid           TYPE RANGE OF /esrcc/sysid.
          DATA _fplv            TYPE RANGE OF /esrcc/costdataset_de.
          DATA _ryear           TYPE RANGE OF /esrcc/ryear.
          DATA _poper           TYPE RANGE OF poper.
          DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
          DATA _receivingentity TYPE RANGE OF /esrcc/legalentity.
          DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
          DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
          DATA _costnumber      TYPE RANGE OF /esrcc/costcenter.
          DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
          DATA _billingfreq     TYPE RANGE OF /esrcc/billfrequency.
          DATA _billingperiod   TYPE RANGE OF /esrcc/billperiod.
          DATA _application     TYPE /esrcc/application_type_de.
          DATA cpwf_handle TYPE swf_cpwf_handle.
          DATA _workflowid      TYPE RANGE OF /esrcc/sww_wiid.
          DATA ls_task          TYPE ty_task.
          DATA lt_task          TYPE TABLE OF ty_task.

*   filters
          LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

            CASE <ls_filter>-name.

              WHEN 'SYSID'.
                _sysid = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'FPLV'.
                _fplv = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'RYEAR'.
                _ryear = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'LEGALENTITY'.
                _legalentity = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'CCODE'.
                _ccode = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'COSTOBJECT'.
                _costobject = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'COSTNUMBER'.
                _costnumber = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'BILLFREQUENCY'.
                _billingfreq = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'BILLINGPERIOD'.
                _billingperiod = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'SERVICEPRODUCT'.
                _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'RECEIVINGENTITY'.
                _receivingentity = CORRESPONDING #( <ls_filter>-range ).
              WHEN 'APPLICATION'.
                _application = <ls_filter>-range[ 1 ]-low.
              WHEN 'WORKFLOWID'.
                _workflowid = CORRESPONDING #( <ls_filter>-range ).
              WHEN OTHERS.
            ENDCASE.

          ENDLOOP.

          TRY.
              DATA(cpwf_api_instance) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
            CATCH cx_swf_cpwf_api INTO DATA(cx_cpwf_api).
              _error = cx_cpwf_api->get_longtext(  ).
          ENDTRY.

          DATA(lo_json) = cpwf_api_instance->get_json_converter( ).



          SELECT LastName, FirstName, PersonFullName, DefaultEmailAddress, Userid FROM I_BusinessUserBasic AS bususr
                       INNER JOIN I_WorkplaceAddress AS address
                         ON bususr~BusinessPartnerUUID = address~BusinessPartnerUUID
                          INTO TABLE @DATA(lt_wf_users).


          CASE _application.

            WHEN 'CBS'.

              SELECT * FROM /esrcc/c_cc_cost_workflow WHERE workflowid IS NOT INITIAL
                                             AND sysid IN @_sysid
                                             AND fplv IN @_fplv
                                             AND ryear IN @_ryear
                                             AND legalentity IN @_legalentity
                                             AND ccode IN @_ccode
                                             AND costobject IN @_costobject
                                             AND costcenter IN @_costnumber
                                             AND Billingfrequqncy IN @_billingfreq
                                             AND billingperiod IN @_billingperiod
                                             AND workflowid IN @_workflowid
                                             INTO TABLE @DATA(lt_ccost).

              SORT lt_ccost BY workflowid DESCENDING.
              DELETE ADJACENT DUPLICATES FROM lt_ccost COMPARING workflowid.

              IF lt_ccost IS NOT INITIAL.
                SELECT worfklow_id, taskid, status, created_by FROM /esrcc/comments FOR ALL ENTRIES IN @lt_ccost
                                              WHERE worfklow_id = @lt_ccost-Workflowid
                                              INTO TABLE @DATA(lt_comments).
              ENDIF.

              LOOP AT lt_ccost ASSIGNING FIELD-SYMBOL(<ls_ccost>).

                TRY.
                    CLEAR: ls_result, cpwf_handle .

                    cpwf_handle = <ls_ccost>-workflowid.
                    DATA(wf_usr_task) = cpwf_api_instance->get_user_task_instances( iv_cpwf_handle = cpwf_handle ).

                    IF wf_usr_task IS NOT INITIAL.
                      MOVE-CORRESPONDING <ls_ccost> TO ls_result.
                      ls_result-workflow_status = cpwf_api_instance->get_workflow_status( iv_cpwf_handle = cpwf_handle ).
                      ls_result-workflowid = <ls_ccost>-workflowid.
                    ELSE.
                      CONTINUE.
                    ENDIF.
                    SORT wf_usr_task BY last_changed_at DESCENDING.
                    CLEAR lt_task.
                    LOOP AT wf_usr_task ASSIGNING FIELD-SYMBOL(<wf_task>).
                      CLEAR: ls_task.
                      ls_task-taskid = <wf_task>-id.
                      ls_task-taskstatus = <wf_task>-status.
                      ls_result-subject = <wf_task>-subject.

                      READ TABLE lt_comments ASSIGNING FIELD-SYMBOL(<ls_comments>) WITH KEY worfklow_id = ls_result-workflowid
                                                                                             taskid = <wf_task>-id.
                      IF sy-subrc = 0.
                        ls_task-taskdecision = <ls_comments>-status.
                        <wf_task>-processor = <ls_comments>-created_by.
                      ENDIF.

                      IF <wf_task>-processor IS INITIAL.
                        <wf_task>-processor = ls_result-lastchangedby.
                      ENDIF.

                      READ TABLE lt_wf_users ASSIGNING FIELD-SYMBOL(<wf_users>) WITH KEY UserID = <wf_task>-processor.
                      IF sy-subrc = 0.
*                        IF <wf_task>-status = 'COMPLETED'.
                        ls_result-lastchangedby = <wf_users>-PersonFullName.
                        ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
                        ls_task-taskprocessby = <wf_users>-PersonFullName.
*                      ELSE.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_task>-processor.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_task>-processor.
                      ENDIF.


                      IF <wf_task>-status = 'READY'.
                        LOOP AT <wf_task>-recipient_users ASSIGNING FIELD-SYMBOL(<recipients>).
                          READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY DefaultEmailAddress = <recipients>.
                          IF sy-subrc = 0.
                            IF ls_result-recipients IS INITIAL.
                              ls_result-recipients = <wf_users>-PersonFullName.
                            ELSE.
                              CONCATENATE ls_result-recipients <wf_users>-PersonFullName  INTO ls_result-recipients SEPARATED BY ','.
                            ENDIF.
                          ENDIF.
                        ENDLOOP.

                      ENDIF.
                      APPEND ls_task TO lt_task.
                    ENDLOOP.

                    lo_json->serialize(
                          EXPORTING
                            data   = lt_task
                          RECEIVING
                            result = ls_result-overviewstep
                        ).

                    APPEND ls_result TO lt_result.

                  CATCH cx_swf_cpwf_api INTO DATA(lr_exc).
                    DATA(_errortext) = lr_exc->get_longtext(  ).
                ENDTRY.


              ENDLOOP.

            WHEN 'SCM'.

              SELECT * FROM /esrcc/i_srv_workflow WHERE workflowid IS NOT INITIAL
                                               AND sysid IN @_sysid
                                               AND fplv IN @_fplv
                                               AND ryear IN @_ryear
                                               AND legalentity IN @_legalentity
                                               AND ccode IN @_ccode
                                               AND costobject IN @_costobject
                                               AND costcenter IN @_costnumber
*                                               AND Billingfrequqncy IN @_billingfreq
*                                               AND billingperiod IN @_billingperiod
                                               AND workflowid IN @_workflowid
                                               INTO TABLE @DATA(lt_srv_cost).

              SORT lt_srv_cost BY workflowid DESCENDING.
              DELETE ADJACENT DUPLICATES FROM lt_srv_cost COMPARING workflowid.

              IF lt_srv_cost IS NOT INITIAL.
                SELECT worfklow_id, taskid, status, created_by FROM /esrcc/comments FOR ALL ENTRIES IN @lt_srv_cost
                                              WHERE worfklow_id = @lt_srv_cost-Workflowid
                                              INTO TABLE @lt_comments.
              ENDIF.

              LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>).
                TRY.
                    CLEAR: ls_result, wf_usr_task,cpwf_handle.

                    cpwf_handle = <ls_srv_cost>-workflowid.
*        Data(wf_log) = cpwf_api_instance->get_workflow_log( iv_cpwf_handle = cpwf_handle ).
                    wf_usr_task = cpwf_api_instance->get_user_task_instances( iv_cpwf_handle = cpwf_handle ).


                    IF wf_usr_task IS NOT INITIAL.
                      MOVE-CORRESPONDING <ls_srv_cost> TO ls_result.
                      ls_result-workflow_status = cpwf_api_instance->get_workflow_status( iv_cpwf_handle = cpwf_handle ).
                      ls_result-workflowid = <ls_srv_cost>-workflowid.
                    ELSE.
                      CONTINUE.
                    ENDIF.
                    SORT wf_usr_task BY last_changed_at ASCENDING.
                    CLEAR lt_task.
                    LOOP AT wf_usr_task ASSIGNING <wf_task>.
                      CLEAR: ls_task.
                      ls_task-taskid = <wf_task>-id.
                      ls_task-taskstatus = <wf_task>-status.
                      ls_result-subject = <wf_task>-subject.

                      READ TABLE lt_comments ASSIGNING <ls_comments> WITH KEY worfklow_id = ls_result-workflowid
                                                                                   taskid = <wf_task>-id.
                      IF sy-subrc = 0.
                        ls_task-taskdecision = <ls_comments>-status.
                        <wf_task>-processor = <ls_comments>-created_by.
                      ENDIF.


                      IF <wf_task>-processor IS INITIAL.
                        <wf_task>-processor = ls_result-lastchangedby.
                      ENDIF.

                      READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY UserID = <wf_task>-processor.
                      IF sy-subrc = 0.
*                        IF <wf_task>-status = 'COMPLETED'.
                        ls_result-lastchangedby = <wf_users>-PersonFullName.
                        ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
                        ls_task-taskprocessby = <wf_users>-PersonFullName.
*                      ELSE.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_task>-processor.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_task>-processor.
                      ENDIF.


                      IF <wf_task>-status = 'READY'.
                        LOOP AT <wf_task>-recipient_users ASSIGNING <recipients>.
                          READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY DefaultEmailAddress = <recipients>.
                          IF sy-subrc = 0.
                            IF ls_result-recipients IS INITIAL.
                              ls_result-recipients = <wf_users>-PersonFullName.
                            ELSE.
                              CONCATENATE ls_result-recipients <wf_users>-PersonFullName  INTO ls_result-recipients SEPARATED BY ','.
                            ENDIF.
                          ENDIF.
                        ENDLOOP.
                      ENDIF.
                      APPEND ls_task TO lt_task.
                    ENDLOOP.

                    IF lt_task IS NOT INITIAL.
                      lo_json->serialize(
                            EXPORTING
                              data   = lt_task
                            RECEIVING
                              result = ls_result-overviewstep
                          ).

                      APPEND ls_result TO lt_result.
                    ENDIF.

                  CATCH cx_swf_cpwf_api INTO lr_exc.
                    _errortext = lr_exc->get_longtext(  ).
                ENDTRY.

*                lo_json->serialize(
*                  EXPORTING
*                    data   = lt_task
*                  RECEIVING
*                    result = ls_result-overviewstep
*                ).
*
*                APPEND ls_result TO lt_result.
              ENDLOOP.

            WHEN 'CHR'.

              SELECT * FROM /esrcc/i_reccost_workflow
                                             WHERE workflowid IS NOT INITIAL
                                               AND sysid IN @_sysid
                                               AND fplv IN @_fplv
                                               AND ryear IN @_ryear
                                               AND legalentity IN @_legalentity
                                               AND ccode IN @_ccode
                                               AND costobject IN @_costobject
                                               AND costcenter IN @_costnumber
                                               AND Billingfrequqncy IN @_billingfreq
                                               AND billingperiod IN @_billingperiod
                                               AND workflowid IN @_workflowid
                                               INTO TABLE @DATA(lt_rec_cost).

              SORT lt_rec_cost BY workflowid DESCENDING.
              DELETE ADJACENT DUPLICATES FROM lt_rec_cost COMPARING workflowid.

              IF lt_rec_cost IS NOT INITIAL.
                SELECT worfklow_id, taskid, status, created_by FROM /esrcc/comments FOR ALL ENTRIES IN @lt_rec_cost
                                              WHERE worfklow_id = @lt_rec_cost-Workflowid
                                              INTO TABLE @lt_comments.
              ENDIF.

              LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).

                TRY.
                    CLEAR ls_result.

                    cpwf_handle = <ls_rec_cost>-workflowid.
                    wf_usr_task = cpwf_api_instance->get_user_task_instances( iv_cpwf_handle = cpwf_handle ).

                    IF wf_usr_task IS NOT INITIAL.
                      MOVE-CORRESPONDING <ls_rec_cost> TO ls_result.
                      ls_result-workflow_status = cpwf_api_instance->get_workflow_status( iv_cpwf_handle = cpwf_handle ).
                      ls_result-workflowid = <ls_rec_cost>-workflowid.
                    ELSE.
                      CONTINUE.
                    ENDIF.
                    SORT wf_usr_task BY last_changed_at ASCENDING.
                    CLEAR lt_task.
                    LOOP AT wf_usr_task ASSIGNING <wf_task>.
                      CLEAR: ls_task.
                      ls_task-taskid = <wf_task>-id.
                      ls_task-taskstatus = <wf_task>-status.
                      ls_result-subject = <wf_task>-subject.

                      READ TABLE lt_comments ASSIGNING <ls_comments> WITH KEY worfklow_id = ls_result-workflowid
                                                                                   taskid = <wf_task>-id.
                      IF sy-subrc = 0.
                        ls_task-taskdecision = <ls_comments>-status.
                        <wf_task>-processor = <ls_comments>-created_by.
                      ENDIF.


                      IF <wf_task>-processor IS INITIAL.
                        <wf_task>-processor = ls_result-lastchangedby.
                      ENDIF.

                      READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY UserID = <wf_task>-processor.
                      IF sy-subrc = 0.
*                        IF <wf_task>-status = 'COMPLETED'.
                        ls_result-lastchangedby = <wf_users>-PersonFullName.
                        ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
                        ls_task-taskprocessby = <wf_users>-PersonFullName.
*                      ELSE.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_task>-processor.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_task>-processor.
                      ENDIF.
*                      READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY UserID = <wf_task>-processor.
*                      IF sy-subrc = 0.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_users>-PersonFullName.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_users>-PersonFullName.
*                      ELSE.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_task>-processor.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_task>-processor.
*                      ENDIF.


                      IF <wf_task>-status = 'READY'.
                        LOOP AT <wf_task>-recipient_users ASSIGNING <recipients>.
                          READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY DefaultEmailAddress = <recipients>.
                          IF sy-subrc = 0.
                            IF ls_result-recipients IS INITIAL.
                              ls_result-recipients = <wf_users>-PersonFullName.
                            ELSE.
                              CONCATENATE ls_result-recipients <wf_users>-PersonFullName  INTO ls_result-recipients SEPARATED BY ','.
                            ENDIF.
                          ENDIF.

                        ENDLOOP.
                      ENDIF.
                      APPEND ls_task TO lt_task.
                    ENDLOOP.

                    IF lt_task IS NOT INITIAL.
                      lo_json->serialize(
                            EXPORTING
                              data   = lt_task
                            RECEIVING
                              result = ls_result-overviewstep
                          ).

                      APPEND ls_result TO lt_result.
                    ENDIF.

                  CATCH cx_swf_cpwf_api INTO lr_exc.
                    _errortext = lr_exc->get_longtext(  ).
                ENDTRY.

*                lo_json->serialize(
*                  EXPORTING
*                    data   = lt_task
*                  RECEIVING
*                    result = ls_result-overviewstep
*                ).
*
*                APPEND ls_result TO lt_result.
              ENDLOOP.

            WHEN 'CBL'.

              SELECT * FROM /esrcc/c_opentaskcostbase
                                               WHERE workflowid IS NOT INITIAL
                                                 AND sysid IN @_sysid
                                                 AND fplv IN @_fplv
                                                 AND ryear IN @_ryear
                                                 AND legalentity IN @_legalentity
                                                 AND ccode IN @_ccode
                                                 AND costobject IN @_costobject
                                                 AND costcenter IN @_costnumber
                                                 AND workflowid IN @_workflowid
                                                 INTO TABLE @DATA(lt_cb_li).

              SORT lt_cb_li BY workflowid DESCENDING.
              DELETE ADJACENT DUPLICATES FROM lt_cb_li COMPARING workflowid.

              IF lt_cb_li IS NOT INITIAL.
                SELECT worfklow_id, taskid, status, created_by FROM /esrcc/comments FOR ALL ENTRIES IN @lt_cb_li
                                              WHERE worfklow_id = @lt_cb_li-Workflowid
                                              INTO TABLE @lt_comments.
              ENDIF.

              LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
                TRY.
                    CLEAR: ls_result, wf_usr_task.

                    cpwf_handle = <ls_cb_li>-workflowid.
                    wf_usr_task = cpwf_api_instance->get_user_task_instances( iv_cpwf_handle = cpwf_handle ).
                    IF wf_usr_task IS NOT INITIAL.
                      MOVE-CORRESPONDING <ls_cb_li> TO ls_result.
                      ls_result-workflow_status = cpwf_api_instance->get_workflow_status( iv_cpwf_handle = cpwf_handle ).
                      ls_result-workflowid = <ls_cb_li>-workflowid.
                    ELSE.
                      CONTINUE.
                    ENDIF.
                    SORT wf_usr_task BY last_changed_at ASCENDING.
                    CLEAR lt_task.
                    LOOP AT wf_usr_task ASSIGNING <wf_task> WHERE subject IS NOT INITIAL.
                      CLEAR: ls_task.
                      ls_task-taskid = <wf_task>-id.
                      ls_task-taskstatus = <wf_task>-status.
                      ls_result-subject = <wf_task>-subject.

                      READ TABLE lt_comments ASSIGNING <ls_comments> WITH KEY worfklow_id = ls_result-workflowid
                                                                                   taskid = <wf_task>-id.
                      IF sy-subrc = 0.
                        ls_task-taskdecision = <ls_comments>-status.
                        <wf_task>-processor = <ls_comments>-created_by.
                      ENDIF.

                      IF <wf_task>-processor IS INITIAL.
                        <wf_task>-processor = ls_result-lastchangedby.
                      ENDIF.

                      READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY UserID = <wf_task>-processor.
                      IF sy-subrc = 0.
*                        IF <wf_task>-status = 'COMPLETED'.
                        ls_result-lastchangedby = <wf_users>-PersonFullName.
                        ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
                        ls_task-taskprocessby = <wf_users>-PersonFullName.
*                      ELSE.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_task>-processor.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_task>-processor.
                      ENDIF.

*                      READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY UserID = <wf_task>-processor.
*                      IF sy-subrc = 0.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_users>-PersonFullName.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_users>-PersonFullName.
*                      ELSE.
*                        IF <wf_task>-status = 'COMPLETED'.
*                          ls_result-lastchangedby = <wf_task>-processor.
*                          ls_result-lastchangedon = <wf_task>-last_changed_at.
*                        ENDIF.
*                        ls_task-taskprocessby = <wf_task>-processor.
*                      ENDIF.

                      IF <wf_task>-status = 'READY'.
                        LOOP AT <wf_task>-recipient_users ASSIGNING <recipients>.
                          READ TABLE lt_wf_users ASSIGNING <wf_users> WITH KEY DefaultEmailAddress = <recipients>.
                          IF sy-subrc = 0.
                            IF ls_result-recipients IS INITIAL.
                              ls_result-recipients = <wf_users>-PersonFullName.
                            ELSE.
                              CONCATENATE ls_result-recipients <wf_users>-PersonFullName  INTO ls_result-recipients SEPARATED BY ','.
                            ENDIF.
                          ENDIF.

                        ENDLOOP.
                      ENDIF.
                      APPEND ls_task TO lt_task.
                    ENDLOOP.

                    IF lt_task IS NOT INITIAL.
                      lo_json->serialize(
                            EXPORTING
                              data   = lt_task
                            RECEIVING
                              result = ls_result-overviewstep
                          ).


                      APPEND ls_result TO lt_result.
                    ENDIF.

                  CATCH cx_swf_cpwf_api INTO lr_exc.
                    _errortext = lr_exc->get_longtext(  ).
                ENDTRY.

*                lo_json->serialize(
*                  EXPORTING
*                    data   = lt_task
*                  RECEIVING
*                    result = ls_result-overviewstep
*                ).
*
*                APPEND ls_result TO lt_result.

              ENDLOOP.
            WHEN OTHERS.

          ENDCASE.

          LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
            CASE <ls_result>-workflow_status.
              WHEN 'COMPLETED'.
                <ls_result>-statuscriticality = 3.
              WHEN 'RUNNING'.
                <ls_result>-statuscriticality = 2.
              WHEN 'ERROR'.
                <ls_result>-statuscriticality = 1.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP..

*    ***fill response
          io_response->set_data( lt_result ).
*        ENDIF.
**request count
          IF io_request->is_total_numb_of_rec_requested( ).
**select count
*
**fill response
            io_response->set_total_number_of_records( lines( lt_result ) ).
          ENDIF.
        ENDIF.
      CATCH cx_rap_query_provider INTO DATA(cx_query_provider).
        _error = cx_query_provider->get_longtext(  ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
