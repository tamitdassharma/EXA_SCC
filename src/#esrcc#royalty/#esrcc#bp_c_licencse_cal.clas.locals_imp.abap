CLASS lhc_C_LICENCSE_CAL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_licencse_cal RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_licencse_cal RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_licencse_cal.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR /esrcc/c_licencse_cal RESULT result.

    METHODS calculate FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~calculate RESULT result.

    METHODS precheck_calculate FOR PRECHECK
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~calculate.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~reopen RESULT result.

    METHODS precheck_reopen FOR PRECHECK
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~reopen.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~submit RESULT result.

    METHODS precheck_submit FOR PRECHECK
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~submit.
    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~finalize RESULT result.

    METHODS precheck_finalize FOR PRECHECK
      IMPORTING keys FOR ACTION /esrcc/c_licencse_cal~finalize.

ENDCLASS.

CLASS lhc_C_LICENCSE_CAL IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD Calculate.

    DATA royalties TYPE TABLE OF /esrcc/c_licencse_cal.
    DATA royalcal  TYPE TABLE OF /esrcc/royalcal.
    DATA validon   TYPE /esrcc/validfrom.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
       IMPORTING
         time_stamp = DATA(created_at)
     ).


    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT basevalue~*,
           royalcal~uuid,
           'C' AS status,
          @sy-uname AS created_by,
          @created_at AS created_at,
          @sy-uname AS last_changed_by,
          @last_changed_at AS last_changed_at
    FROM /esrcc/i_determine_royalty AS basevalue
     INNER JOIN @keys AS key
     ON  basevalue~LicensorCCode = key~licensorccode
     AND basevalue~LicensorLegalEntity = key~licensorlegalentity
     AND basevalue~LicensorCostObject  = key~licensorcostobject
     AND basevalue~LicensorCostCenter  = key~licensorcostcenter
     AND basevalue~License             = key~license
     AND basevalue~licenseeCCode       = key~licenseeccode
     AND basevalue~licenseeLegalEntity = key~licenseelegalentity
     AND basevalue~licenseeCostObject  = key~licenseecostobject
     AND basevalue~licenseeCostCenter  = key~licenseecostcenter
     AND basevalue~Ryear               = key~ryear
     AND basevalue~poper               = key~poper
     AND basevalue~fplv                = key~fplv
     LEFT OUTER JOIN /esrcc/i_read_royalty AS royalcal
     ON  basevalue~LicensorCCode       = royalcal~licensorccode
     AND basevalue~LicensorLegalEntity = royalcal~licensorlegalentity
     AND basevalue~LicensorCostObject  = royalcal~licensorcostobject
     AND basevalue~LicensorCostCenter  = royalcal~licensorcostcenter
     AND basevalue~License             = royalcal~license
     AND basevalue~licenseeCCode       = royalcal~licenseeccode
     AND basevalue~licenseeLegalEntity = royalcal~licenseelegalentity
     AND basevalue~licenseeCostObject  = royalcal~licenseecostobject
     AND basevalue~licenseeCostCenter  = royalcal~licenseecostcenter
     AND basevalue~Ryear               = royalcal~ryear
     AND basevalue~poper               = royalcal~poper
     AND basevalue~fplv                = royalcal~fplv
     INTO CORRESPONDING FIELDS OF TABLE @royalties.


    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT royalties ASSIGNING FIELD-SYMBOL(<royalty>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
      MOVE-CORRESPONDING <royalty> TO <result>.
      MOVE-CORRESPONDING <royalty> TO <result>-%param.

      APPEND INITIAL LINE TO royalcal ASSIGNING FIELD-SYMBOL(<royalcal>).
      MOVE-CORRESPONDING <royalty> TO <royalcal>.
      IF <royalcal>-uuid IS INITIAL.
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <royalcal>-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.

      ENDIF.
      CONCATENATE <royalty>-ryear <royalty>-poper+1(2) '01' INTO validon.
      /esrcc/cl_utility_core=>get_last_day_of_month(
        EXPORTING
          date     = validon
        RECEIVING
          end_date = <royalcal>-exchdate
      ).
      IF <royalcal>-royaltycomputationmethod = 'ME'.
        READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>)
                   WITH KEY  LicensorCCode       = <royalty>-licensorccode
                             LicensorLegalEntity = <royalty>-licensorlegalentity
                             LicensorCostObject  = <royalty>-licensorcostobject
                             LicensorCostCenter  = <royalty>-licensorcostcenter
                             License             = <royalty>-license
                             licenseeCCode       = <royalty>-licenseeccode
                             licenseeLegalEntity = <royalty>-licenseelegalentity
                             licenseeCostObject  = <royalty>-licenseecostobject
                             licenseeCostCenter  = <royalty>-licenseecostcenter
                             Ryear               = <royalty>-ryear
                             poper               = <royalty>-poper
                             fplv                = <royalty>-fplv.
        IF sy-subrc = 0.
          /esrcc/cl_utility_core=>curr_external_to_internal(
            EXPORTING
              currency        = <royalcal>-invoicecurrency
              amount_external = <key>-%param-chargeoutamount
            IMPORTING
              amount_internal = <royalcal>-chargeoutamount
          ).

        ENDIF.
      ENDIF.

    ENDLOOP.

    MODIFY /esrcc/royalcal FROM TABLE @royalcal.

  ENDMETHOD.

  METHOD precheck_Calculate.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <key>-licenseelegalentity
              ID 'ACTVT'      FIELD '01'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <key>-licenseecostobject
          ID '/ESRCC/CN' FIELD <key>-licenseecostcenter
          ID 'ACTVT'      FIELD '01'.
        IF sy-subrc <> 0.
          APPEND VALUE #( ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                          %msg = new_message(
                                     id    = '/ESRCC/ROYALTY'
                                     number = '007'
                                     v1     = <key>-licenseecostobject
                                     v2     = <key>-licenseecostcenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-/esrcc/c_licencse_cal.
          APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #(   ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                            %msg = new_message(
                                       id    = '/ESRCC/ROYALTY'
                                       number = '006'
                                       v1     = <key>-licenseelegalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-/esrcc/c_licencse_cal.
        APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD reopen.

    DATA royalties TYPE TABLE OF /esrcc/c_licencse_cal.
    DATA royalcal  TYPE TABLE OF /esrcc/royalcal.


    SELECT basevalue~*,
           'N' AS status
    FROM /esrcc/i_determine_royalty AS basevalue
     INNER JOIN @keys AS key
     ON  basevalue~LicensorCCode = key~licensorccode
     AND basevalue~LicensorLegalEntity = key~licensorlegalentity
     AND basevalue~LicensorCostObject  = key~licensorcostobject
     AND basevalue~LicensorCostCenter  = key~licensorcostcenter
     AND basevalue~License             = key~license
     AND basevalue~licenseeCCode       = key~licenseeccode
     AND basevalue~licenseeLegalEntity = key~licenseelegalentity
     AND basevalue~licenseeCostObject  = key~licenseecostobject
     AND basevalue~licenseeCostCenter  = key~licenseecostcenter
     AND basevalue~Ryear               = key~ryear
     AND basevalue~poper               = key~poper
     AND basevalue~fplv                = key~fplv
     INTO CORRESPONDING FIELDS OF TABLE @royalties.


    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT royalties ASSIGNING FIELD-SYMBOL(<royalty>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
      MOVE-CORRESPONDING <royalty> TO <result>.
      MOVE-CORRESPONDING <royalty> TO <result>-%param.

    ENDLOOP.

    SELECT * FROM /esrcc/royalcal AS royalcal
       INNER JOIN @keys AS key
                  ON  royalcal~LicensorCCode = key~licensorccode
                  AND royalcal~LicensorLegalEntity = key~licensorlegalentity
                  AND royalcal~LicensorCostObject  = key~licensorcostobject
                  AND royalcal~LicensorCostCenter  = key~licensorcostcenter
                  AND royalcal~License             = key~license
                  AND royalcal~LicenseeCCode       = key~licenseeccode
                  AND royalcal~LicenseeLegalEntity = key~licenseelegalentity
                  AND royalcal~LicenseeCostObject  = key~licenseecostobject
                  AND royalcal~LicenseeCostCenter  = key~licenseecostcenter
                  AND royalcal~Ryear               = key~ryear
                  AND royalcal~poper               = key~poper
                  AND royalcal~fplv                = key~fplv
                  INTO CORRESPONDING FIELDS OF TABLE @royalcal.

    DELETE /esrcc/royalcal FROM TABLE @royalcal.

  ENDMETHOD.

  METHOD precheck_reopen.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <key>-licenseelegalentity
              ID 'ACTVT'      FIELD '06'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <key>-licenseecostobject
          ID '/ESRCC/CN' FIELD <key>-licenseecostcenter
          ID 'ACTVT'      FIELD '06'.
        IF sy-subrc <> 0.
          APPEND VALUE #( ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                          %msg = new_message(
                                     id    = '/ESRCC/ROYALTY'
                                     number = '001'
                                     v1     = <key>-licenseecostobject
                                     v2     = <key>-licenseecostcenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-/esrcc/c_licencse_cal.
          APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #(   ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                            %msg = new_message(
                                       id    = '/ESRCC/ROYALTY'
                                       number = '000'
                                       v1     = <key>-licenseelegalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-/esrcc/c_licencse_cal.
        APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD submit.

    DATA royalties TYPE TABLE OF /esrcc/c_licencse_cal.
    DATA royalcal  TYPE TABLE OF /esrcc/royalcal.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_comment  TYPE /esrcc/comments.
    DATA lt_comments TYPE TABLE OF /esrcc/comments.


    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    /esrcc/cl_utility_core=>check_workflow_active(
      EXPORTING
        application = 'ROY'
      IMPORTING
        wf_flag     = DATA(wf_flag)
    ).

    SELECT royalcal~*,
           CASE WHEN @wf_flag = 'X' THEN
           'P'
           ELSE
           'A' END AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
           FROM /esrcc/royalcal AS royalcal
       INNER JOIN @keys AS key
       ON  royalcal~LicensorCCode = key~licensorccode
       AND royalcal~LicensorLegalEntity = key~licensorlegalentity
       AND royalcal~LicensorCostObject  = key~licensorcostobject
       AND royalcal~LicensorCostCenter  = key~licensorcostcenter
       AND royalcal~License             = key~license
       AND royalcal~LicenseeCCode       = key~licenseeccode
       AND royalcal~LicenseeLegalEntity = key~licenseelegalentity
       AND royalcal~LicenseeCostObject  = key~licenseecostobject
       AND royalcal~LicenseeCostCenter  = key~licenseecostcenter
       AND royalcal~Ryear               = key~ryear
       AND royalcal~poper               = key~poper
       AND royalcal~fplv                = key~fplv
       INTO CORRESPONDING FIELDS OF TABLE @royalcal.

    LOOP AT royalcal ASSIGNING FIELD-SYMBOL(<royalty>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
      MOVE-CORRESPONDING <royalty> TO <result>.
      MOVE-CORRESPONDING <royalty> TO <result>-%param.
      CLEAR <royalty>-workflowid.
      CLEAR: ls_wf_leadobj.
      ls_wf_leadobj-cc_uuid = <royalty>-uuid.
      APPEND ls_wf_leadobj  TO lt_wf_leadobj.

**********************************************************
*Add comments if provided
**********************************************************
      IF keys[ 1 ]-%param-comments IS NOT INITIAL.
        ls_comment-instanceid = <royalty>-uuid.
*      ls_comment-worfklow_id = <costbase>-WorkflowId.
        ls_comment-wfcomment = keys[ 1 ]-%param-comments.
        ls_comment-status = 'A'.
        /esrcc/cl_comments_util=>modify_comments(
            comments    = ls_comment
            iv_comments = keys[ 1 ]-%param-comments
          ).
      ENDIF.
    ENDLOOP.

**********************************************************
*Check if workflow is to be triggered
**********************************************************
    IF wf_flag EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object = lt_wf_leadobj
          iv_apptype        = 'ROY'.
    ENDIF.


    MODIFY /esrcc/royalcal FROM TABLE @royalcal.

  ENDMETHOD.

  METHOD precheck_submit.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
      ID '/ESRCC/LE' FIELD <key>-licenseelegalentity
      ID 'ACTVT'      FIELD '02'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
        ID '/ESRCC/OBJ' FIELD <key>-licenseecostobject
        ID '/ESRCC/CN' FIELD <key>-licenseecostcenter
        ID 'ACTVT'      FIELD '02'.
        IF sy-subrc <> 0.
          APPEND VALUE #( ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                          %msg = new_message(
                                     id    = '/ESRCC/ROYALTY'
                                     number = '003'
                                     v1     = <key>-licenseecostobject
                                     v2     = <key>-licenseecostcenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-/esrcc/c_licencse_cal.
          APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #(   ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                            %msg = new_message(
                                       id    = '/ESRCC/ROYALTY'
                                       number = '002'
                                       v1     = <key>-licenseelegalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-/esrcc/c_licencse_cal.
        APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD Finalize.

    DATA royalties TYPE TABLE OF /esrcc/c_licencse_cal.
    DATA royalcal  TYPE TABLE OF /esrcc/royalcal.


    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

    SELECT royalcal~*,
           'F' AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
           FROM /esrcc/royalcal AS royalcal
       INNER JOIN @keys AS key
       ON  royalcal~LicensorCCode = key~licensorccode
       AND royalcal~LicensorLegalEntity = key~licensorlegalentity
       AND royalcal~LicensorCostObject  = key~licensorcostobject
       AND royalcal~LicensorCostCenter  = key~licensorcostcenter
       AND royalcal~License             = key~license
       AND royalcal~LicenseeCCode       = key~licenseeccode
       AND royalcal~LicenseeLegalEntity = key~licenseelegalentity
       AND royalcal~LicenseeCostObject  = key~licenseecostobject
       AND royalcal~LicenseeCostCenter  = key~licenseecostcenter
       AND royalcal~Ryear               = key~ryear
       AND royalcal~poper               = key~poper
       AND royalcal~fplv                = key~fplv
       INTO CORRESPONDING FIELDS OF TABLE @royalcal.

    LOOP AT royalcal ASSIGNING FIELD-SYMBOL(<royalty>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
      MOVE-CORRESPONDING <royalty> TO <result>.
      MOVE-CORRESPONDING <royalty> TO <result>-%param.

    ENDLOOP.

    MODIFY /esrcc/royalcal FROM TABLE @royalcal.
  ENDMETHOD.

  METHOD precheck_Finalize.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
      ID '/ESRCC/LE' FIELD <key>-licenseelegalentity
      ID 'ACTVT'      FIELD '02'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
        ID '/ESRCC/OBJ' FIELD <key>-licenseecostobject
        ID '/ESRCC/CN' FIELD <key>-licenseecostcenter
        ID 'ACTVT'      FIELD '02'.
        IF sy-subrc <> 0.
          APPEND VALUE #( ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                          %msg = new_message(
                                     id    = '/ESRCC/ROYALTY'
                                     number = '005'
                                     v1     = <key>-licenseecostobject
                                     v2     = <key>-licenseecostcenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-/esrcc/c_licencse_cal.
          APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #(   ryear = <key>-ryear
                          poper = <key>-poper
                          fplv  = <key>-fplv
                          licenseesysid = <key>-licenseesysid
                          licenseelegalentity = <key>-licenseelegalentity
                          licenseecostobject  = <key>-licenseecostobject
                          licenseecostcenter  = <key>-licenseecostcenter
                          license             = <key>-license
                          licensorsysid       = <key>-licensorsysid
                          licensorlegalentity = <key>-licensorlegalentity
                          licensorcostobject  = <key>-licensorcostobject
                          licensorcostcenter  = <key>-licensorcostcenter
                            %msg = new_message(
                                       id    = '/ESRCC/ROYALTY'
                                       number = '004'
                                       v1     = <key>-licenseelegalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-/esrcc/c_licencse_cal.
        APPEND VALUE #( %key = <key>-%key ) TO failed-/esrcc/c_licencse_cal.
        EXIT.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_C_LICENCSE_CAL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_C_LICENCSE_CAL IMPLEMENTATION.

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
