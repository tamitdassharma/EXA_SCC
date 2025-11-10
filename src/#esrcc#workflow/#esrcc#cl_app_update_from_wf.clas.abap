class /ESRCC/CL_APP_UPDATE_FROM_WF definition
  public
  final
  create public .

public section.

  class-methods UPDATE_CB_LI
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_CC_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_REC_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_STDCHARGEOUT
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_TRUEUPCHARGEOUT
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_ADHOC_CHARGEOUT
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_ROYALTY
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_SRV_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_STEWARDSHIP_CONFIG
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_CO_RULE_CONFIG
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_SERVICE_MARKUP_CONFIG
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_HIER_DEF_CONFIG
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT_BC
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_APP_UPDATE_FROM_WF IMPLEMENTATION.


  METHOD update_cb_li.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT * FROM /esrcc/cb_li   FOR ALL ENTRIES IN @it_leading_data
          WHERE ryear        = @it_leading_data-ryear AND
                poper        = @it_leading_data-poper AND
                sysid        = @it_leading_data-sysid AND
                legalentity  = @it_leading_data-legalentity AND
                ccode        = @it_leading_data-ccode AND
                belnr        = @it_leading_data-belnr AND
                buzei        = @it_leading_data-buzei AND
                costobject   = @it_leading_data-costobject  AND
                costcenter   = @it_leading_data-costcenter AND
                costelement  = @it_leading_data-costelement
                INTO TABLE @DATA(lt_cb_li).


    IF sy-subrc EQ 0.
      LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<fs_cb_li>).
        <fs_cb_li>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_cb_li>-last_changed_by = iv_user.
        ENDIF.
        <fs_cb_li>-workflowid = iv_wi_id.

        IF iv_comment IS NOT INITIAL.
          ls_comment-worfklow_id = iv_wi_id.
          ls_comment-created_by = iv_user.
          ls_comment-last_changed_by = iv_user.
          ls_comment-status = iv_status.
          ls_comment-instanceid = <fs_cb_li>-commentid.
          /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = iv_comment
          ).
        ENDIF.

      ENDLOOP.
      UPDATE /esrcc/cb_li FROM TABLE @lt_cb_li.


    ENDIF.

  ENDMETHOD.


  METHOD update_cc_cost.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT * FROM /esrcc/cb_stw
          FOR ALL ENTRIES IN @it_leading_data
          WHERE  cc_uuid     =  @it_leading_data-cc_uuid
*                fplv        = @it_leading_data-fplv AND
*                ryear       = @it_leading_data-ryear AND
*                poper       = @it_leading_data-poper AND
*                sysid       = @it_leading_data-sysid AND
*                legalentity = @it_leading_data-legalentity AND
*                ccode       = @it_leading_data-ccode AND
*                costobject  = @it_leading_data-costobject  AND
*                costcenter  = @it_leading_data-costcenter
                INTO TABLE @DATA(lt_cc_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<fs_cc_cost>).
        <fs_cc_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_cc_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_cc_cost>-workflowid = iv_wi_id.
        IF iv_comment IS NOT INITIAL.
          ls_comment-worfklow_id     = iv_wi_id.
          ls_comment-created_by      = iv_user.
          ls_comment-last_changed_by = iv_user.
          ls_comment-status          = iv_status.
          ls_comment-instanceid      = <fs_cc_cost>-commentid.
          /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = iv_comment
          ).
        ENDIF.
      ENDLOOP.
    ENDIF.

*Update status in execution cockpit process control
    SELECT * FROM /esrcc/procctrl
             FOR ALL ENTRIES IN @lt_cc_cost
             WHERE  fplv          = @lt_cc_cost-fplv AND
                    ryear         = @lt_cc_cost-ryear AND
                    poper         = @lt_cc_cost-poper AND
*                    billingfreq = @lt_cc_cost-billfrequency AND
*                    billingperiod = @lt_cc_cost-billingperiod AND
                    sysid         = @lt_cc_cost-sysid AND
                    legalentity   = @lt_cc_cost-legalentity AND
                    ccode         = @lt_cc_cost-ccode AND
                    costobject    = @lt_cc_cost-costobject  AND
                    costcenter    = @lt_cc_cost-costcenter AND
                    process       = @/esrcc/if_calculate_chargeout=>stdchargeout
             INTO TABLE @DATA(procctrl).

    LOOP AT procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
      <procctrl>-last_changed_by = iv_user.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = <procctrl>-last_changed_at
    ).
      IF iv_status = 'A'.
        <procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_approved.
      ELSEIF iv_status = 'R'.
        <procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_rejected.
      ELSEIF iv_status = 'W'.
        <procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_pending.
      ENDIF.
    ENDLOOP.

    IF iv_status = 'R'. "rejected

      SELECT * FROM /esrcc/cb_li   FOR ALL ENTRIES IN @it_leading_data
                WHERE cc_guid = @it_leading_data-cc_uuid
                INTO TABLE @DATA(lt_cb_li).


      IF sy-subrc EQ 0.
        LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<fs_cb_li>).
          <fs_cb_li>-status = /esrcc/if_calculate_chargeout=>approved.
          IF iv_user IS SUPPLIED.
            <fs_cb_li>-last_changed_by = iv_user.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.

    UPDATE /esrcc/procctrl FROM TABLE @procctrl.
    UPDATE /esrcc/cb_stw   FROM TABLE @lt_cc_cost.
    UPDATE /esrcc/cb_li    FROM TABLE @lt_cb_li.
  ENDMETHOD.


  METHOD update_co_rule_config.
    DATA lr_rule_id TYPE RANGE OF /esrcc/chargeout_rule_id.

    CHECK it_leading_data IS NOT INITIAL.
    lr_rule_id = VALUE #( FOR rule IN it_leading_data ( sign = 'I' option = 'EQ' low = rule-rule_id ) ).

    UPDATE /esrcc/co_rule SET workflow_id     = @iv_wi_id,
                              workflow_status = @iv_status,
                              last_changed_by = @iv_user
                          WHERE rule_id IN @lr_rule_id.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SELECT DISTINCT rule~comment_id AS comment_id
        FROM /esrcc/co_rule AS rule
        INNER JOIN @it_leading_data AS lobj
          ON  lobj~rule_id = rule~rule_id
        INTO TABLE @DATA(lt_comment).

      LOOP AT lt_comment INTO DATA(ls_comment).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = ls_comment-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_rec_cost.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT recchg~* FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
             INNER JOIN /esrcc/rec_chg AS recchg
               ON cb~cc_uuid = recchg~cc_uuid
              AND srvshare~srv_uuid = recchg~srv_uuid
                FOR ALL ENTRIES IN @it_leading_data
          WHERE  cb~cc_uuid      = @it_leading_data-cc_uuid AND
*                fplv            = @it_leading_data-fplv AND
*                ryear           = @it_leading_data-ryear AND
*                poper           = @it_leading_data-poper AND
*                sysid           = @it_leading_data-sysid AND
*                legalentity     = @it_leading_data-legalentity AND
*                ccode           = @it_leading_data-ccode AND
*                costobject      = @it_leading_data-costobject  AND
*                costcenter      = @it_leading_data-costcenter AND
                serviceproduct  = @it_leading_data-serviceproduct AND
                receivingentity = @it_leading_data-receivingentity
                INTO TABLE @DATA(lt_rec_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<fs_rec_cost>).
        <fs_rec_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_rec_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_rec_cost>-workflowid = iv_wi_id.
        IF iv_comment IS NOT INITIAL.
          ls_comment-worfklow_id = iv_wi_id.
          ls_comment-created_by = iv_user.
          ls_comment-last_changed_by = iv_user.
          ls_comment-status = iv_status.
          ls_comment-instanceid = <fs_rec_cost>-commentid.
          /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = iv_comment
          ).
        ENDIF.
      ENDLOOP.

*Update status in execution cockpit process control
*get all recievers for serviceproduct
      SELECT recchg~* FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
             INNER JOIN /esrcc/rec_chg AS recchg
               ON cb~cc_uuid        = recchg~cc_uuid
              AND srvshare~srv_uuid = recchg~srv_uuid
              AND recchg~status     = 'W'
               FOR ALL ENTRIES IN @it_leading_data
          WHERE cb~cc_uuid     = @it_leading_data-cc_uuid AND
*                fplv           = @it_leading_data-fplv AND
*                ryear          = @it_leading_data-ryear AND
*                poper          = @it_leading_data-poper AND
*                sysid          = @it_leading_data-sysid AND
*                legalentity    = @it_leading_data-legalentity AND
*                ccode          = @it_leading_data-ccode AND
*                costobject     = @it_leading_data-costobject  AND
*                costcenter     = @it_leading_data-costcenter AND
                serviceproduct = @it_leading_data-serviceproduct
                INTO TABLE @DATA(lt_totalrec).

      SELECT procctrl~*
           FROM /esrcc/procctrl AS procctrl
           INNER JOIN /esrcc/cb_stw AS cb_stw
           ON cb_stw~fplv          = procctrl~fplv AND
              cb_stw~ryear         = procctrl~ryear AND
              cb_stw~poper         = procctrl~poper AND
*              cb_stw~billfrequency = procctrl~billingfreq AND
*              cb_stw~billingperiod = procctrl~billingperiod AND
              cb_stw~sysid         = procctrl~sysid AND
              cb_stw~legalentity   = procctrl~legalentity AND
              cb_stw~ccode         = procctrl~ccode AND
              cb_stw~costobject    = procctrl~costobject  AND
              cb_stw~costcenter    = procctrl~costcenter
           INNER JOIN /esrcc/srv_share AS srv_share
           ON  srv_share~cc_uuid        = cb_stw~cc_uuid
           AND srv_share~serviceproduct = procctrl~serviceproduct
           INNER JOIN @lt_rec_cost AS rec_cost
           ON  cb_stw~cc_uuid     = rec_cost~cc_uuid
           AND srv_share~srv_uuid = rec_cost~srv_uuid
           WHERE process = @/esrcc/if_calculate_chargeout=>chargeout
           INTO TABLE @DATA(lt_procctrl).

      LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
        <procctrl>-last_changed_by = iv_user.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <procctrl>-last_changed_at
      ).
        IF iv_status = 'A'.
          IF lines( lt_totalrec ) < 2.
            <procctrl>-status = /esrcc/if_calculate_chargeout=>chargeout_approved.
          ENDIF.
        ELSEIF iv_status = 'R'.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>chargeout_rejected.
        ELSEIF iv_status = 'W'.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>chargeout_pending.
        ENDIF.
      ENDLOOP.

      UPDATE /esrcc/procctrl FROM TABLE @lt_procctrl.
      UPDATE /esrcc/rec_chg FROM TABLE @lt_rec_cost.

    ENDIF.

  ENDMETHOD.


  METHOD update_service_markup_config.
    DATA lt_markup TYPE TABLE OF /esrcc/srvmkp.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT mkp~*
      FROM /esrcc/srvmkp AS mkp
      INNER JOIN @it_leading_data AS lobj
        ON  lobj~serviceproduct = mkp~serviceproduct
        AND lobj~valid_from     = mkp~validfrom
      INTO CORRESPONDING FIELDS OF TABLE @lt_markup.

    MODIFY lt_markup FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE serviceproduct IS NOT INITIAL.

    UPDATE /esrcc/srvmkp FROM TABLE @lt_markup.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_markup BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_markup COMPARING comment_id.
      LOOP AT lt_markup INTO DATA(markup) GROUP BY ( comment_id = markup-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_srv_cost.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT srvshare~*
    FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
               FOR ALL ENTRIES IN @it_leading_data
                WHERE
                 cb~cc_uuid = @it_leading_data-cc_uuid AND
                serviceproduct = @it_leading_data-serviceproduct
                INTO TABLE @DATA(lt_srv_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<fs_srv_cost>).
        <fs_srv_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_srv_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_srv_cost>-workflowid = iv_wi_id.
        IF iv_comment IS NOT INITIAL.
          ls_comment-worfklow_id = iv_wi_id.
          ls_comment-created_by = iv_user.
          ls_comment-last_changed_by = iv_user.
          ls_comment-status = iv_status.
          ls_comment-instanceid = <fs_srv_cost>-commentid.
          /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = iv_comment
          ).
        ENDIF.
      ENDLOOP.


*Update status in execution cockpit process control
      SELECT  fplv,
              ryear,
              poper,
              sysid,
              legalentity,
              ccode,
              costobject,
              costcenter,
              serviceproduct
              FROM /esrcc/cb_stw AS cb_stw
              INNER JOIN @lt_srv_cost AS srv_cost
              ON cb_stw~cc_uuid = srv_cost~cc_uuid
              INTO TABLE @DATA(lt_cc_cost).

      IF lt_cc_cost IS NOT INITIAL.

        SELECT procctrl~*
                FROM /esrcc/procctrl AS procctrl
                INNER JOIN /esrcc/cb_stw AS cb_stw
                ON cb_stw~fplv          = procctrl~fplv AND
                   cb_stw~ryear         = procctrl~ryear AND
                   cb_stw~poper         = procctrl~poper AND
                   cb_stw~sysid         = procctrl~sysid AND
                   cb_stw~legalentity   = procctrl~legalentity AND
                   cb_stw~ccode         = procctrl~ccode AND
                   cb_stw~costobject    = procctrl~costobject  AND
                   cb_stw~costcenter    = procctrl~costcenter
                INNER JOIN @lt_srv_cost AS srv_share
                ON srv_share~cc_uuid = cb_stw~cc_uuid
                AND srv_share~serviceproduct = procctrl~serviceproduct
                WHERE process = @/esrcc/if_calculate_chargeout=>trueuprecal
                INTO TABLE @DATA(lt_procctrl).

        LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
          <procctrl>-last_changed_by = iv_user.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <procctrl>-last_changed_at
        ).
          IF iv_status = 'A'.
            <procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_approved.
          ELSEIF iv_status = 'R'.
            <procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_rejected.
          ELSEIF iv_status = 'W'.
            <procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_pending.
          ENDIF.
        ENDLOOP.

        UPDATE /esrcc/procctrl FROM TABLE @lt_procctrl.
        UPDATE /esrcc/srv_share FROM TABLE @lt_srv_cost.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_stewardship_config.
    DATA lr_stewardship_uuid TYPE RANGE OF sysuuid_x16.

    CHECK it_leading_data IS NOT INITIAL.
    lr_stewardship_uuid = VALUE #( FOR stw IN it_leading_data ( sign = 'I' option = 'EQ' low = stw-stewardship_uuid ) ).

    UPDATE /esrcc/stewrdshp SET workflow_id     = @iv_wi_id,
                                workflow_status = @iv_status,
                                last_changed_by = @iv_user
*                              last_changed_at = @sy-timlo
      WHERE stewardship_uuid IN @lr_stewardship_uuid.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SELECT DISTINCT stw~comment_id AS comment_id
        FROM /esrcc/stewrdshp AS stw
        INNER JOIN @it_leading_data AS lobj
          ON  lobj~stewardship_uuid = stw~stewardship_uuid
        INTO TABLE @DATA(lt_comment).

      LOOP AT lt_comment INTO DATA(ls_comment).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = ls_comment-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_adhoc_chargeout.

    DATA ls_comment TYPE /esrcc/comments.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT * FROM /esrcc/cb_stw
       FOR ALL ENTRIES IN @it_leading_data
       WHERE cc_uuid = @it_leading_data-cc_uuid
       INTO TABLE @DATA(lt_cc_cost).

    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<fs_cc_cost>).
      IF iv_status = 'A'.
        <fs_cc_cost>-status = /esrcc/if_calculate_chargeout=>finalized.
      ELSE.
        <fs_cc_cost>-status = iv_status.
      ENDIF.
      IF iv_user IS SUPPLIED.
        <fs_cc_cost>-last_changed_by = iv_user.
        <fs_cc_cost>-last_changed_at = last_changed_at.
      ENDIF.
      IF iv_comment IS NOT INITIAL.
        ls_comment-worfklow_id = iv_wi_id.
        ls_comment-created_by = iv_user.
        ls_comment-last_changed_by = iv_user.
        ls_comment-status = iv_status.
        ls_comment-instanceid = <fs_cc_cost>-commentid.
        /esrcc/cl_comments_util=>modify_comments(
          comments    = ls_comment
          iv_comments = iv_comment
        ).
      ENDIF.
    ENDLOOP.


    SELECT * FROM /esrcc/srv_share
     FOR ALL ENTRIES IN @it_leading_data
          WHERE cc_uuid = @it_leading_data-cc_uuid
           INTO TABLE @DATA(lt_srv_share).

    LOOP AT lt_srv_share ASSIGNING FIELD-SYMBOL(<fs_srv_share>).

      IF iv_status = 'A'.
        <fs_srv_share>-status = /esrcc/if_calculate_chargeout=>finalized.
      ELSE.
        <fs_srv_share>-status = iv_status.
      ENDIF.
      IF iv_user IS SUPPLIED.
        <fs_srv_share>-last_changed_by = iv_user.
        <fs_srv_share>-last_changed_at = last_changed_at.
      ENDIF.
    ENDLOOP.

    SELECT * FROM /esrcc/rec_chg
        FOR ALL ENTRIES IN @it_leading_data
           WHERE cc_uuid = @it_leading_data-cc_uuid
           INTO TABLE @DATA(lt_rec_share).

    LOOP AT lt_rec_share ASSIGNING FIELD-SYMBOL(<fs_rec_share>).

      IF iv_status = 'A'.
        <fs_rec_share>-status = /esrcc/if_calculate_chargeout=>finalized.
      ELSE.
        <fs_rec_share>-status = iv_status.
      ENDIF.
      IF iv_user IS SUPPLIED.
        <fs_rec_share>-last_changed_by = iv_user.
        <fs_rec_share>-last_changed_at = last_changed_at.
      ENDIF.
      <fs_rec_share>-workflowid = iv_wi_id.

    ENDLOOP.

    SELECT * FROM /esrcc/cb_li
        FOR ALL ENTRIES IN @it_leading_data
         WHERE cc_guid = @it_leading_data-cc_uuid
         INTO TABLE @DATA(lt_cb_li).

    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<fs_cb_li>).

      IF iv_status = 'A'. "Approved.
        <fs_cb_li>-status = /esrcc/if_calculate_chargeout=>finalizedbyadhoc.
      ELSEIF iv_status = 'R'. "Rejected..
        <fs_cb_li>-status = iv_status.
        CLEAR <fs_cb_li>-cc_guid.
      ELSE.
        <fs_cb_li>-status = iv_status.
      ENDIF.
      IF iv_user IS SUPPLIED.
        <fs_cb_li>-last_changed_by = iv_user.
        <fs_cb_li>-last_changed_at = last_changed_at.
      ENDIF.
      <fs_cb_li>-workflowid = iv_wi_id.

    ENDLOOP.

    UPDATE /esrcc/cb_stw    FROM TABLE @lt_cc_cost.
    UPDATE /esrcc/srv_share FROM TABLE @lt_srv_share.
    UPDATE /esrcc/rec_chg   FROM TABLE @lt_rec_share.
    UPDATE /esrcc/cb_li     FROM TABLE @lt_cb_li.

  ENDMETHOD.


  METHOD update_stdchargeout.

    DATA ls_comment TYPE /esrcc/comments.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT recchg~*
             FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
             INNER JOIN /esrcc/rec_chg AS recchg
               ON cb~cc_uuid = recchg~cc_uuid
              AND srvshare~srv_uuid = recchg~srv_uuid
                FOR ALL ENTRIES IN @it_leading_data
          WHERE  cb~cc_uuid      = @it_leading_data-cc_uuid AND
                 serviceproduct  = @it_leading_data-serviceproduct AND
                 receivingentity = @it_leading_data-receivingentity AND
                 receiversysid   = @it_leading_data-recsysid AND
                 receivercompanycode = @it_leading_data-recccode AND
                 receivercostobject  =  @it_leading_data-reccostobject AND
                 receivercostcenter  = @it_leading_data-reccostcenter AND
                 cb~processtype  = @/esrcc/if_calculate_chargeout=>standardprocesstype
                INTO TABLE @DATA(lt_rec_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<fs_rec_cost>).
        <fs_rec_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_rec_cost>-last_changed_by = iv_user.
          <fs_rec_cost>-last_changed_at = last_changed_at.
        ENDIF.
        <fs_rec_cost>-workflowid = iv_wi_id.
        IF iv_comment IS NOT INITIAL.
          ls_comment-worfklow_id = iv_wi_id.
          ls_comment-created_by = iv_user.
          ls_comment-last_changed_by = iv_user.
          ls_comment-status = iv_status.
          ls_comment-instanceid = <fs_rec_cost>-commentid.
          /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = iv_comment
          ).
        ENDIF.
      ENDLOOP.

*Update status in execution cockpit process control
*get all recievers for serviceproduct
      SELECT recchg~* FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
             INNER JOIN /esrcc/rec_chg AS recchg
               ON cb~cc_uuid        = recchg~cc_uuid
              AND srvshare~srv_uuid = recchg~srv_uuid
              AND recchg~status     = 'W'
               FOR ALL ENTRIES IN @it_leading_data
          WHERE cb~cc_uuid     = @it_leading_data-cc_uuid AND
                serviceproduct = @it_leading_data-serviceproduct
                INTO TABLE @DATA(lt_totalrec).

      SELECT procctrl~*
          FROM /esrcc/procctrl AS procctrl
          INNER JOIN @it_leading_data AS data
          ON data~fplv          = procctrl~fplv AND
             data~ryear         = procctrl~ryear AND
             data~poper         = procctrl~poper AND
             data~sysid         = procctrl~sysid AND
             data~legalentity   = procctrl~legalentity AND
             data~ccode         = procctrl~ccode AND
             data~costobject    = procctrl~costobject  AND
             data~costcenter    = procctrl~costcenter
          WHERE process = @/esrcc/if_calculate_chargeout=>stdchargeout
          INTO TABLE @DATA(lt_procctrl).


      LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
        <procctrl>-last_changed_by = iv_user.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <procctrl>-last_changed_at
      ).
        IF iv_status = 'A'.
          IF lines( lt_totalrec ) < 2.
            <procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_approved.
          ENDIF.
        ELSEIF iv_status = 'R'.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_rejected.
        ELSEIF iv_status = 'W'.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>stdchargeout_pending.
        ENDIF.
      ENDLOOP.

* Update the status of costbasestewardship.
      SELECT cbstw~* FROM /esrcc/cb_stw AS cbstw
       INNER JOIN @it_leading_data AS data
        ON data~cc_uuid = cbstw~cc_uuid
        INTO TABLE @DATA(lt_cbstw).

      LOOP AT lt_cbstw ASSIGNING FIELD-SYMBOL(<cbstw>).
        IF iv_status = 'A'.
          IF lines( lt_totalrec ) < 2.
            <cbstw>-status = iv_status.
          ENDIF.
        ELSE.
          <cbstw>-status = iv_status.
        ENDIF.
        IF iv_user IS SUPPLIED.
          <cbstw>-last_changed_by = iv_user.
          <cbstw>-last_changed_at = last_changed_at.
        ENDIF.
      ENDLOOP.

* Update the status of service product share.
      SELECT srv_share~*
       FROM /esrcc/cb_stw AS cbstw
       INNER JOIN /esrcc/srv_share AS srv_share
        ON srv_share~cc_uuid = cbstw~cc_uuid
       INNER JOIN @it_leading_data AS data
        ON data~cc_uuid = cbstw~cc_uuid
        AND data~serviceproduct = srv_share~serviceproduct
        INTO TABLE @DATA(lt_srvshare).

      LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<srvshare>).
        IF iv_status = 'A'.
          IF lines( lt_totalrec ) < 2.
            <srvshare>-status = iv_status.
          ENDIF.
        ELSE.
          <srvshare>-status = iv_status.
        ENDIF.
        IF iv_user IS SUPPLIED.
          <srvshare>-last_changed_by = iv_user.
          <srvshare>-last_changed_at = last_changed_at.
        ENDIF.
      ENDLOOP.



      UPDATE /esrcc/procctrl  FROM TABLE @lt_procctrl.
      UPDATE /esrcc/cb_stw    FROM TABLE @lt_cbstw.
      UPDATE /esrcc/srv_share FROM TABLE @lt_srvshare.
      UPDATE /esrcc/rec_chg   FROM TABLE @lt_rec_cost.

    ENDIF.


  ENDMETHOD.


  METHOD update_trueupchargeout.

    DATA ls_comment TYPE /esrcc/comments.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT recchg~*
             FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
             INNER JOIN /esrcc/rec_chg AS recchg
               ON cb~cc_uuid = recchg~cc_uuid
              AND srvshare~srv_uuid = recchg~srv_uuid
                FOR ALL ENTRIES IN @it_leading_data
          WHERE  cb~ryear        = @it_leading_data-ryear AND
                 cb~sysid        = @it_leading_data-sysid AND
                 cb~ccode        = @it_leading_data-ccode AND
                 cb~legalentity  = @it_leading_data-legalentity AND
                 cb~costobject   = @it_leading_data-costobject AND
                 cb~costcenter   = @it_leading_data-costcenter AND
                 cb~recalrefpoper  =  @it_leading_data-refpoper
*                 cb~processtype  = @/esrcc/if_calculate_chargeout=>recalprocesstype
                INTO TABLE @DATA(lt_rec_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<fs_rec_cost>).
        <fs_rec_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_rec_cost>-last_changed_by = iv_user.
          <fs_rec_cost>-last_changed_at = last_changed_at.
        ENDIF.
        <fs_rec_cost>-workflowid = iv_wi_id.
        IF iv_comment IS NOT INITIAL.
          ls_comment-worfklow_id = iv_wi_id.
          ls_comment-created_by = iv_user.
          ls_comment-last_changed_by = iv_user.
          ls_comment-status = iv_status.
          ls_comment-instanceid = <fs_rec_cost>-commentid.
          /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = iv_comment
          ).
        ENDIF.
      ENDLOOP.

      SELECT procctrl~*
          FROM /esrcc/procctrl AS procctrl
          INNER JOIN @it_leading_data AS data
          ON data~fplv          = procctrl~fplv AND
             data~ryear         = procctrl~ryear AND
             data~refpoper      = procctrl~poper AND
             data~sysid         = procctrl~sysid AND
             data~legalentity   = procctrl~legalentity AND
             data~ccode         = procctrl~ccode AND
             data~costobject    = procctrl~costobject  AND
             data~costcenter    = procctrl~costcenter
          WHERE process = @/esrcc/if_calculate_chargeout=>trueuprecal
          INTO TABLE @DATA(lt_procctrl).


      LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
        <procctrl>-last_changed_by = iv_user.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <procctrl>-last_changed_at
      ).
        IF iv_status = 'A'.
*          IF lines( lt_totalrec ) < 2.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_approved.
*          ENDIF.
        ELSEIF iv_status = 'R'.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_rejected.
        ELSEIF iv_status = 'W'.
          <procctrl>-status = /esrcc/if_calculate_chargeout=>recalculation_pending.
        ENDIF.
      ENDLOOP.

* Update the status of costbasestewardship.
      SELECT cb~* FROM /esrcc/cb_stw AS cb
       INNER JOIN @it_leading_data AS data
        ON cb~ryear        = data~ryear AND
           cb~recalrefpoper  =  data~refpoper AND
           cb~sysid        = data~sysid AND
           cb~ccode        = data~ccode AND
           cb~legalentity  = data~legalentity AND
           cb~costobject   = data~costobject AND
           cb~costcenter   = data~costcenter
*           cb~processtype  = @/esrcc/if_calculate_chargeout=>recalprocesstype
        INTO TABLE @DATA(lt_cbstw).

      LOOP AT lt_cbstw ASSIGNING FIELD-SYMBOL(<cbstw>).
        IF iv_status = 'A'.
*          IF lines( lt_totalrec ) < 2.
          <cbstw>-status = iv_status.
*          ENDIF.
        ELSE.
          <cbstw>-status = iv_status.
        ENDIF.
        IF iv_user IS SUPPLIED.
          <cbstw>-last_changed_by = iv_user.
          <cbstw>-last_changed_at = last_changed_at.
        ENDIF.
      ENDLOOP.

* Update the status of service product share.
      SELECT srv_share~*
       FROM /esrcc/cb_stw AS cb
       INNER JOIN /esrcc/srv_share AS srv_share
        ON srv_share~cc_uuid = cb~cc_uuid
       INNER JOIN @it_leading_data AS data
        ON cb~ryear        = data~ryear AND
           cb~recalrefpoper  =  data~refpoper AND
           cb~sysid        = data~sysid AND
           cb~ccode        = data~ccode AND
           cb~legalentity  = data~legalentity AND
           cb~costobject   = data~costobject AND
           cb~costcenter   = data~costcenter
*           cb~processtype  = @/esrcc/if_calculate_chargeout=>recalprocesstype
        INTO TABLE @DATA(lt_srvshare).

      LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<srvshare>).
        IF iv_status = 'A'.
*          IF lines( lt_totalrec ) < 2.
          <srvshare>-status = iv_status.
*          ENDIF.
        ELSE.
          <srvshare>-status = iv_status.
        ENDIF.
        IF iv_user IS SUPPLIED.
          <srvshare>-last_changed_by = iv_user.
          <srvshare>-last_changed_at = last_changed_at.
        ENDIF.
      ENDLOOP.

*      Update trueups
      SELECT trueup~*,
             @iv_status AS status,
             @iv_user AS last_changed_by,
             @last_changed_at AS last_changed_at
      FROM /esrcc/trueup AS trueup
      INNER JOIN @it_leading_data AS data
        ON trueup~ryear          = data~ryear AND
           trueup~recalrefpoper  =  data~refpoper AND
           trueup~sysid          = data~sysid AND
           trueup~ccode          = data~ccode AND
           trueup~legalentity    = data~legalentity AND
           trueup~costobject     = data~costobject AND
           trueup~costcenter     = data~costcenter
*           cb~processtype  = @/esrcc/if_calculate_chargeout=>recalprocesstype
        INTO TABLE @DATA(lt_trueups).


      UPDATE /esrcc/procctrl FROM TABLE @lt_procctrl.
      UPDATE /esrcc/cb_stw FROM TABLE @lt_cbstw.
      UPDATE /esrcc/srv_share FROM TABLE @lt_srvshare.
      UPDATE /esrcc/rec_chg FROM TABLE @lt_rec_cost.


    ENDIF.


  ENDMETHOD.


  METHOD update_royalty.

    DATA ls_comment TYPE /esrcc/comments.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT royalcal~*
       FROM /esrcc/royalcal AS royalcal
       FOR ALL ENTRIES IN @it_leading_data
       WHERE uuid = @it_leading_data-cc_uuid
       INTO TABLE @DATA(lt_royalcal).

    LOOP AT lt_royalcal ASSIGNING FIELD-SYMBOL(<royalcal>).
      <royalcal>-status = iv_status.
      <royalcal>-workflowid = iv_wi_id..
      IF iv_user IS SUPPLIED.
        <royalcal>-last_changed_by = iv_user.
        <royalcal>-last_changed_at = last_changed_at.
      ENDIF.
      IF iv_comment IS NOT INITIAL.
        ls_comment-worfklow_id = iv_wi_id.
        ls_comment-created_by = iv_user.
        ls_comment-last_changed_by = iv_user.
        ls_comment-status = iv_status.
        ls_comment-instanceid = <royalcal>-uuid.
        /esrcc/cl_comments_util=>modify_comments(
          comments    = ls_comment
          iv_comments = iv_comment
        ).
      ENDIF.
    ENDLOOP.

    UPDATE /esrcc/royalcal FROM TABLE @lt_royalcal.


  ENDMETHOD.


  METHOD update_hier_def_config.
    DATA lt_hier_def TYPE TABLE OF /esrcc/hier_def.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT FROM /esrcc/hier_def AS hd
      INNER JOIN @it_leading_data AS lobj
        ON  lobj~hierarchy1 = hd~hierarchy1
        AND lobj~hierarchy2 = hd~hierarchy2
        AND lobj~hierarchy3 = hd~hierarchy3
        AND lobj~hierarchy4 = hd~hierarchy4
        AND lobj~valid_from = hd~valid_from
      FIELDS hd~*
      INTO CORRESPONDING FIELDS OF TABLE @lt_hier_def.

    MODIFY lt_hier_def FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE valid_from IS NOT INITIAL.

    UPDATE /esrcc/hier_def FROM TABLE @lt_hier_def.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_hier_def BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_hier_def COMPARING comment_id.
      LOOP AT lt_hier_def INTO DATA(hier_def) GROUP BY ( comment_id = hier_def-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
