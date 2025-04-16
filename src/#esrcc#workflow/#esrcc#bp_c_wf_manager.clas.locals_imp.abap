CLASS lhc_C_WF_MANAGER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_wf_manager RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_wf_manager RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_wf_manager.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_wf_manager~approve.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_wf_manager~reject.

ENDCLASS.

CLASS lhc_C_WF_MANAGER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD approve.

    DATA ls_comments TYPE /esrcc/comments.
    DATA cpwf_handle TYPE swf_cpwf_handle.
    DATA lv_payload         TYPE string.
    CONSTANTS: lv_approve TYPE string VALUE 'approve',
               lv_status TYPE string VALUE 'COMPLETED',
               lv_uri TYPE STRING VALUE 'workflow/rest/v1/task-instances/'.

    TRY.
        DATA(cpwf_api_instance) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
      CATCH cx_swf_cpwf_api INTO DATA(exc_cpwf_api).
          DATA(_error) = exc_cpwf_api->get_longtext(  ).
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      TRY.

          DATA(http_destination) =  cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = '/ESRCC/CS_WORKFLOW_ACTIONS'
                                    service_id     = '/ESRCC/WORKFLOWACTIONS_BPA_REST'
                                  ).

        CATCH cx_http_dest_provider_error INTO DATA(exc_http).
          _error = exc_http->get_longtext(  ).
          "handle exception
      ENDTRY.

      TRY.
          DATA(http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = http_destination ).

          http_client->enable_path_prefix( ).

          cpwf_handle = <key>-Workflowid.
          DATA(wf_usr_task) = cpwf_api_instance->get_user_task_instances( iv_cpwf_handle = cpwf_handle ).

          READ TABLE wf_usr_task ASSIGNING FIELD-SYMBOL(<wf_usr_task>) WITH KEY status = 'READY'.
          IF sy-subrc = 0.

            CONCATENATE lv_uri <wf_usr_task>-id INTO DATA(uri_path).
            http_client->get_http_request( )->set_uri_path(
              EXPORTING
                i_uri_path = uri_path
              RECEIVING
                r_value    = DATA(http_value)
            ).
          ENDIF.

          http_client->get_http_request( )->set_content_type( content_type = 'application/json' ).

          lv_payload = |\{"decision":"{ lv_approve }",| &&
                       |  "status":"{ lv_status }",| &&
                       |  "context": \{ "comments":"{ <key>-%param-comments }" \}\}|.

          http_client->get_http_request( )->set_text(
            EXPORTING
              i_text   = lv_payload ).

          DATA(http_result) = http_client->execute( if_web_http_client=>patch ).
          IF http_result->get_status( )-code = 200 OR
             http_result->get_status( )-code = 204.

             clear ls_comments.
             ls_comments-worfklow_id = <key>-Workflowid.
             ls_comments-status = 'A'.
             ls_comments-taskid = <wf_usr_task>-id.
             /esrcc/cl_comments_util=>modify_comments(
                  comments    = ls_comments
                  iv_comments = <key>-%param-comments
                ).


          ENDIF.

        CATCH cx_web_http_client_error
              cx_web_message_error
              cx_swf_cpwf_api  INTO DATA(lx_client).
          DATA(error) = lx_client->get_longtext(  ).

      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD reject.

    DATA ls_comments TYPE /esrcc/comments.
    DATA cpwf_handle TYPE swf_cpwf_handle.
    DATA lv_payload         TYPE string.
    CONSTANTS: lv_reject TYPE string VALUE 'reject',
               lv_status TYPE string VALUE 'COMPLETED',
               lv_uri TYPE STRING VALUE 'workflow/rest/v1/task-instances/'.

    TRY.
        DATA(cpwf_api_instance) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
      CATCH cx_swf_cpwf_api INTO DATA(exc_cpwf_api).
          DATA(_error) = exc_cpwf_api->get_longtext(  ).
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      TRY.

          DATA(http_destination) =  cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = '/ESRCC/CS_WORKFLOW_ACTIONS'
                                    service_id     = '/ESRCC/WORKFLOWACTIONS_BPA_REST'
                                  ).

        CATCH cx_http_dest_provider_error INTO DATA(exc_http).
          _error = exc_http->get_longtext(  ).
          "handle exception
      ENDTRY.

      TRY.
          DATA(http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = http_destination ).

          http_client->enable_path_prefix( ).

          cpwf_handle = <key>-Workflowid.
          DATA(wf_usr_task) = cpwf_api_instance->get_user_task_instances( iv_cpwf_handle = cpwf_handle ).

          READ TABLE wf_usr_task ASSIGNING FIELD-SYMBOL(<wf_usr_task>) WITH KEY status = 'READY'.
          IF sy-subrc = 0.

            CONCATENATE lv_uri <wf_usr_task>-id INTO DATA(uri_path).
            http_client->get_http_request( )->set_uri_path(
              EXPORTING
                i_uri_path = uri_path
              RECEIVING
                r_value    = DATA(http_value)
            ).
          ENDIF.

          http_client->get_http_request( )->set_content_type( content_type = 'application/json' ).

          lv_payload = |\{"decision":"{ lv_reject }",| &&
                       |  "status":"{ lv_status }",| &&
                       |  "context": \{ "comments":"{ <key>-%param-comments }" \}\}|.

          http_client->get_http_request( )->set_text(
            EXPORTING
              i_text   = lv_payload ).

          DATA(http_result) = http_client->execute( if_web_http_client=>patch ).
          IF http_result->get_status( )-code = 200 OR
             http_result->get_status( )-code = 204.
             clear ls_comments.
             ls_comments-worfklow_id = <key>-Workflowid.
             ls_comments-status = 'R'.
             ls_comments-taskid = <wf_usr_task>-id.
             /esrcc/cl_comments_util=>modify_comments(
                  comments    = ls_comments
                  iv_comments = <key>-%param-comments
                ).


          ENDIF.

        CATCH cx_web_http_client_error
              cx_web_message_error
              cx_swf_cpwf_api  INTO DATA(lx_client).
          DATA(error) = lx_client->get_longtext(  ).

      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_C_WF_MANAGER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_C_WF_MANAGER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
