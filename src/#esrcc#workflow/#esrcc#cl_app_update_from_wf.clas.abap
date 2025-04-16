CLASS /esrcc/cl_app_update_from_wf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS update_cb_li
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_cc_cost
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_rec_cost
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_srv_cost
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_stewardship_config
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_co_rule_config
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_service_markup_config
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_APP_UPDATE_FROM_WF IMPLEMENTATION.


  METHOD update_cb_li.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT * FROM /esrcc/cb_li   FOR ALL ENTRIES IN @it_leading_data
          WHERE ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                belnr = @it_leading_data-belnr AND
                buzei = @it_leading_data-buzei AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
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

    SELECT * FROM /esrcc/cb_stw   FOR ALL ENTRIES IN @it_leading_data
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter
                INTO TABLE @DATA(lt_cc_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<fs_cc_cost>).
        <fs_cc_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_cc_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_cc_cost>-workflowid = iv_wi_id.
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
    ENDIF.

*Update status in execution cockpit process control
    SELECT * FROM /esrcc/procctrl
             FOR ALL ENTRIES IN @lt_cc_cost
             WHERE  fplv  = @lt_cc_cost-fplv AND
                    ryear = @lt_cc_cost-ryear AND
                    billingfreq = @lt_cc_cost-billfrequency AND
                    billingperiod = @lt_cc_cost-billingperiod AND
                    sysid = @lt_cc_cost-sysid AND
                    legalentity = @lt_cc_cost-legalentity AND
                    ccode = @lt_cc_cost-ccode AND
                    costobject = @lt_cc_cost-costobject  AND
                    costcenter = @lt_cc_cost-costcenter AND
                    process = @/esrcc/cl_calculate_chargeout=>costbase
             INTO TABLE @DATA(procctrl).

    LOOP AT procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
      <procctrl>-last_changed_by = iv_user.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = <procctrl>-last_changed_at
    ).
      IF iv_status = 'A'.
        <procctrl>-status = /esrcc/cl_calculate_chargeout=>costbase_approved.
      ELSEIF iv_status = 'R'.
        <procctrl>-status = /esrcc/cl_calculate_chargeout=>costbase_rejected.
      ELSEIF iv_status = 'W'.
        <procctrl>-status = /esrcc/cl_calculate_chargeout=>costbase_pending.
      ENDIF.
    ENDLOOP.

    UPDATE /esrcc/procctrl FROM TABLE @procctrl.
    UPDATE /esrcc/cb_stw FROM TABLE @lt_cc_cost.
  ENDMETHOD.


  METHOD update_co_rule_config.
    DATA lr_rule_id TYPE RANGE OF /esrcc/chargeout_rule_id.

    CHECK it_leading_data IS NOT INITIAL.
    lr_rule_id = VALUE #( FOR rule IN it_leading_data ( sign = 'I' option = 'EQ' low = rule-rule_id ) ).

    UPDATE /esrcc/co_rule SET workflow_id     = @iv_wi_id,
                              workflow_status = @iv_status,
                              last_changed_by = @iv_user
*                            last_changed_at = @sy-timlo
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
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
                serviceproduct = @it_leading_data-serviceproduct AND
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
               ON cb~cc_uuid = recchg~cc_uuid
              AND srvshare~srv_uuid = recchg~srv_uuid
              AND recchg~status = 'W'
               FOR ALL ENTRIES IN @it_leading_data
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
                serviceproduct = @it_leading_data-serviceproduct
                INTO TABLE @DATA(lt_totalrec).

            SELECT procctrl~*
                 FROM /esrcc/procctrl as procctrl
                 INNER JOIN /esrcc/cb_stw AS cb_stw
                 ON cb_stw~fplv          = procctrl~fplv AND
                    cb_stw~ryear         = procctrl~ryear AND
                    cb_stw~billfrequency = procctrl~billingfreq AND
                    cb_stw~billingperiod = procctrl~billingperiod AND
                    cb_stw~sysid         = procctrl~sysid AND
                    cb_stw~legalentity   = procctrl~legalentity AND
                    cb_stw~ccode         = procctrl~ccode AND
                    cb_stw~costobject    = procctrl~costobject  AND
                    cb_stw~costcenter    = procctrl~costcenter
                 INNER JOIN /esrcc/srv_share AS srv_share
                 ON srv_share~cc_uuid = cb_stw~cc_uuid
                 AND srv_share~serviceproduct = procctrl~serviceproduct
                 INNER JOIN @lt_rec_cost AS rec_cost
                 ON cb_stw~cc_uuid = rec_cost~cc_uuid
                 AND srv_share~srv_uuid = rec_cost~srv_uuid
                 WHERE process = @/esrcc/cl_calculate_chargeout=>chargeout
                 INTO TABLE @DATA(lt_procctrl).

        LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
          <procctrl>-last_changed_by = iv_user.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <procctrl>-last_changed_at
        ).
          IF iv_status = 'A'.
            IF lines( lt_totalrec ) < 2.
              <procctrl>-status = /esrcc/cl_calculate_chargeout=>chargeout_approved.
            ENDIF.
          ELSEIF iv_status = 'R'.
            <procctrl>-status = /esrcc/cl_calculate_chargeout=>chargeout_rejected.
          ELSEIF iv_status = 'W'.
            <procctrl>-status = /esrcc/cl_calculate_chargeout=>chargeout_pending.
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

    SELECT srvshare~* FROM /esrcc/cb_stw AS cb
             INNER JOIN /esrcc/srv_share AS srvshare
               ON cb~cc_uuid = srvshare~cc_uuid
               FOR ALL ENTRIES IN @it_leading_data
                WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
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
              billfrequency,
              billingperiod,
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
                 FROM /esrcc/procctrl as procctrl
                 INNER JOIN /esrcc/cb_stw AS cb_stw
                 ON cb_stw~fplv          = procctrl~fplv AND
                    cb_stw~ryear         = procctrl~ryear AND
                    cb_stw~billfrequency = procctrl~billingfreq AND
                    cb_stw~billingperiod = procctrl~billingperiod AND
                    cb_stw~sysid         = procctrl~sysid AND
                    cb_stw~legalentity   = procctrl~legalentity AND
                    cb_stw~ccode         = procctrl~ccode AND
                    cb_stw~costobject    = procctrl~costobject  AND
                    cb_stw~costcenter    = procctrl~costcenter
                 INNER JOIN @lt_srv_cost AS srv_share
                 ON srv_share~cc_uuid = cb_stw~cc_uuid
                 AND srv_share~serviceproduct = procctrl~serviceproduct
                 WHERE process = @/esrcc/cl_calculate_chargeout=>serviceshare
                 INTO TABLE @DATA(lt_procctrl).

        LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).
          <procctrl>-last_changed_by = iv_user.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <procctrl>-last_changed_at
        ).
          IF iv_status = 'A'.
            <procctrl>-status = /esrcc/cl_calculate_chargeout=>serviceshare_approved.
          ELSEIF iv_status = 'R'.
            <procctrl>-status = /esrcc/cl_calculate_chargeout=>serviceshare_rejected.
          ELSEIF iv_status = 'W'.
            <procctrl>-status = /esrcc/cl_calculate_chargeout=>serviceshare_pending.
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
ENDCLASS.
