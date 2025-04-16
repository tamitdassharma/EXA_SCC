CLASS lhc_C_BPA_INTEGRATION DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_bpa_integration RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_bpa_integration RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_bpa_integration.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_bpa_integration~approve.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_bpa_integration~reject.

    METHODS approvecomments FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_bpa_integration~approvecomments.

    METHODS rejectcomments FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_bpa_integration~rejectcomments.

    METHODS update_workflowid FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_bpa_integration~update_workflowid RESULT result.


ENDCLASS.

CLASS lhc_C_BPA_INTEGRATION IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD approve.

    DATA ls_bpa TYPE /esrcc/c_bpa_integration.
    DATA ls_param TYPE /esrcc/c_bpa_parameters.
    DATA _poper TYPE RANGE OF poper.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      ls_param = CORRESPONDING #( <key>-%param ).
    ENDIF.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(lv_timestamp)
    ).

    CASE ls_param-application.
      WHEN 'CBS'.

        UPDATE /esrcc/cb_stw SET status = 'A',
                                  last_changed_at = @lv_timestamp
                              WHERE workflowid = @ls_param-workflowid.

      WHEN 'SCM'.

        UPDATE /esrcc/srv_share SET status = 'A',
                                   last_changed_at = @lv_timestamp
                                    WHERE workflowid = @ls_param-workflowid.

      WHEN 'CHR'.

        UPDATE /esrcc/rec_chg SET status = 'A',
                                  last_changed_at = @lv_timestamp
                                  WHERE workflowid = @ls_param-workflowid.

      WHEN 'CBL'.

        UPDATE /esrcc/cb_li SET status = 'A',
                                last_changed_at = @lv_timestamp
                            WHERE workflowid = @ls_param-workflowid.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD reject.

    DATA ls_param TYPE /esrcc/c_bpa_parameters.
    DATA _poper TYPE RANGE OF poper.
    DATA lt_cpwf_handle TYPE TABLE OF swf_cpwf_handle.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      ls_param = CORRESPONDING #( <key>-%param ).
    ENDIF.

     /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(lv_timestamp)
    ).

    CASE ls_param-application.
      WHEN 'CBS'.

        UPDATE /esrcc/cb_stw SET status = 'R',
                                  last_changed_at = @lv_timestamp
                                   WHERE workflowid = @ls_param-workflowid.

      WHEN 'SCM'.

        UPDATE /esrcc/srv_share SET status = 'R',
                                   last_changed_at = @lv_timestamp
                                  WHERE workflowid = @ls_param-workflowid.

      WHEN 'CHR'.

        UPDATE /esrcc/rec_chg SET status = 'R',
                                  last_changed_at = @lv_timestamp
                                  WHERE workflowid = @ls_param-workflowid.

        SELECT SINGLE * FROM /esrcc/rec_chg WHERE workflowid = @ls_param-workflowid INTO @DATA(ls_rec_cost).

        IF ls_rec_cost IS NOT INITIAL.
          select workflowid from /esrcc/rec_chg
                            where cc_uuid = @ls_rec_cost-cc_uuid
                              AND srv_uuid = @ls_rec_cost-srv_uuid
                              AND status = 'W'
                              AND workflowid is NOT INITIAL
                 INTO TABLE @DATA(lt_recchg).

          MODIFY ENTITIES OF i_cpwf_inst
            ENTITY CPWFInstance
            EXECUTE registerWorkflowCancel
            FROM VALUE #( FOR recchg IN lt_recchg  (
                            %key-CpWfHandle = recchg-workflowid
                            ) ).

          UPDATE /esrcc/rec_chg SET status = 'R',
                                    last_changed_at = @lv_timestamp
                                where cc_uuid  = @ls_rec_cost-cc_uuid
                                  AND srv_uuid = @ls_rec_cost-srv_uuid
                                  AND status = 'W'.
        ENDIF.

      WHEN 'CBL'.

        UPDATE /esrcc/cb_li SET status = 'R',
                                   last_changed_at = @lv_timestamp
                                  WHERE workflowid = @ls_param-workflowid.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD update_workflowid.

    DATA ls_param TYPE /esrcc/c_workflow_details.
    DATA lv_workflowid TYPE /esrcc/workflowid.
    DATA _poper TYPE RANGE OF poper.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      ls_param = CORRESPONDING #( <key>-%param ).
      lv_workflowid = ls_param-workflow_id.
    ELSE.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    CASE ls_param-application.
      WHEN 'CBS'.

        UPDATE /esrcc/procctrl SET status = '06',
                                   wf_started = @abap_false,
                                   last_changed_at = @lv_timestamp
                               WHERE fplv = @ls_param-fplv
                                 AND ryear = @ls_param-ryear
                                 AND process = 'CBS'
                                 AND billingfreq = @ls_param-billfrequency
                                 AND billingperiod = @ls_param-billingperiod
                                 AND sysid = @ls_param-sysid
                                 AND ccode = @ls_param-ccode
                                 AND legalentity = @ls_param-legalentity
                                 AND costobject = @ls_param-costobject
                                 AND costcenter = @ls_param-costnumber.

        UPDATE /esrcc/cb_stw SET status = 'W',
                                  workflowid = @lv_workflowid,
                                  last_changed_at = @lv_timestamp
                              WHERE fplv = @ls_param-fplv
                                AND ryear = @ls_param-ryear
                                AND billfrequency = @ls_param-billfrequency
                                AND billingperiod = @ls_param-billingperiod
                                AND sysid = @ls_param-sysid
                                AND ccode = @ls_param-ccode
                                AND legalentity = @ls_param-legalentity
                                AND costobject = @ls_param-costobject
                                AND costcenter = @ls_param-costnumber.


      WHEN 'SCM'.

        SELECT 'I'  AS sign,
                'EQ'  AS option,
                poper AS low
                FROM /esrcc/billfreq
                WHERE billingfreq = @ls_param-billfrequency
                  AND billingvalue = @ls_param-billingperiod
                ORDER BY low ASCENDING
                INTO CORRESPONDING FIELDS OF TABLE @_poper.

        UPDATE /esrcc/procctrl SET status = '03',
                                   wf_started = @abap_false,
                                   last_changed_at = @lv_timestamp
                               WHERE fplv = @ls_param-fplv
                                 AND ryear = @ls_param-ryear
                                 AND process = 'SCM'
                                 AND billingfreq = @ls_param-billfrequency
                                 AND billingperiod = @ls_param-billingperiod
                                 AND sysid = @ls_param-sysid
                                 AND ccode = @ls_param-ccode
                                 AND legalentity = @ls_param-legalentity
                                 AND costobject = @ls_param-costobject
                                 AND costcenter = @ls_param-costnumber
                                 AND serviceproduct = @ls_param-serviceproduct.

        select srv_share~* from /esrcc/srv_share as srv_share
               inner join /esrcc/cb_stw as cb_stw
               on cb_stw~cc_uuid           = srv_share~cc_uuid
               WHERE cb_stw~fplv           = @ls_param-fplv
                 AND cb_stw~ryear          = @ls_param-ryear
                 AND cb_stw~billfrequency  = @ls_param-billfrequency
                 AND cb_stw~poper          IN @_poper
                 AND cb_stw~sysid          = @ls_param-sysid
                 AND cb_stw~ccode          = @ls_param-ccode
                 AND cb_stw~legalentity    = @ls_param-legalentity
                 AND cb_stw~costobject     = @ls_param-costobject
                 AND cb_stw~costcenter     = @ls_param-costnumber
                 AND srv_share~serviceproduct = @ls_param-serviceproduct
                 INTO TABLE @DATA(lt_srvcost).

        lt_srvcost = VALUE #( for srvcost IN lt_srvcost
                            (  status = 'W'
                              workflowid = lv_workflowid
                              last_changed_at = lv_timestamp
                             ) ).

        MODIFY /esrcc/srv_share FROM TABLE @lt_srvcost.


      WHEN 'CHR'.

        SELECT 'I'  AS sign,
                'EQ'  AS option,
                poper AS low
                FROM /esrcc/billfreq
                WHERE billingfreq = @ls_param-billfrequency
                  AND billingvalue = @ls_param-billingperiod
                ORDER BY low ASCENDING
                INTO CORRESPONDING FIELDS OF TABLE @_poper.

        UPDATE /esrcc/procctrl SET status = '03',
                                   wf_started = @abap_false,
                                   last_changed_at = @lv_timestamp
                               WHERE fplv = @ls_param-fplv
                                 AND ryear = @ls_param-ryear
                                 AND process = 'CHR'
                                 AND billingfreq = @ls_param-billfrequency
                                 AND billingperiod = @ls_param-billingperiod
                                 AND sysid = @ls_param-sysid
                                 AND ccode = @ls_param-ccode
                                 AND legalentity = @ls_param-legalentity
                                 AND costobject = @ls_param-costobject
                                 AND costcenter = @ls_param-costnumber
                                 AND serviceproduct = @ls_param-serviceproduct.

        select rec_chg~* from /esrcc/rec_chg as rec_chg
               inner join /esrcc/cb_stw as cb_stw
               on cb_stw~cc_uuid           = rec_chg~cc_uuid
               inner join /esrcc/srv_share as srv_share
               on  srv_share~cc_uuid        = rec_chg~cc_uuid
               AND srv_share~srv_uuid       = rec_chg~srv_uuid
               WHERE cb_stw~fplv           = @ls_param-fplv
                 AND cb_stw~ryear          = @ls_param-ryear
                 AND cb_stw~billfrequency  = @ls_param-billfrequency
                 AND cb_stw~poper          IN @_poper
                 AND cb_stw~sysid          = @ls_param-sysid
                 AND cb_stw~ccode          = @ls_param-ccode
                 AND cb_stw~legalentity    = @ls_param-legalentity
                 AND cb_stw~costobject     = @ls_param-costobject
                 AND cb_stw~costcenter     = @ls_param-costnumber
                 AND srv_share~serviceproduct = @ls_param-serviceproduct
                 AND rec_chg~receivingentity = @ls_param-receivingentity
                 INTO TABLE @DATA(lt_recchg).

        lt_recchg = VALUE #( for recchg IN lt_recchg
                            ( status = 'W'
                              workflowid = lv_workflowid
                              last_changed_at = lv_timestamp
                             ) ).

        MODIFY /esrcc/rec_chg FROM TABLE @lt_recchg.


      WHEN 'CBL'.
      WHEN OTHERS.
    ENDCASE.

    result = VALUE #( ( %cid = <key>-%cid
                       %param-approval_level = 1 ) ).

  ENDMETHOD.

  METHOD approvecomments.

*    DATA ls_param TYPE /esrcc/c_bpa_parameters.
*    DATA ls_comments TYPE /esrcc/comments.
*
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      ls_param = CORRESPONDING #( <key>-%param ).
*    ENDIF.
*
*    ls_comments-worfklow_id = ls_param-workflowid.
*    ls_comments-status = 'A'.
*    ls_comments-taskid = ls_param-instanceid.
*
*    /esrcc/cl_comments_util=>modify_comments(
*      comments    = ls_comments
*      iv_comments = ls_param-comments
*    ).

  ENDMETHOD.

  METHOD rejectcomments.

*    DATA ls_param TYPE /esrcc/c_bpa_parameters.
*    DATA ls_comments TYPE /esrcc/comments.
*
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      ls_param = CORRESPONDING #( <key>-%param ).
*    ENDIF.
*
*    ls_comments-worfklow_id = ls_param-workflowid.
*    ls_comments-status = 'R'.
*    ls_comments-taskid = ls_param-instanceid.
*
*    /esrcc/cl_comments_util=>modify_comments(
*      comments    = ls_comments
*      iv_comments = ls_param-comments
*    ).

  ENDMETHOD.

ENDCLASS.

CLASS lsc_C_BPA_INTEGRATION DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_C_BPA_INTEGRATION IMPLEMENTATION.

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
