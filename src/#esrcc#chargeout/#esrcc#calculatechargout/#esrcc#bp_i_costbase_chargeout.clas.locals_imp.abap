CLASS lhc_CostbaseChargeout DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR CostbaseChargeout RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ CostbaseChargeout RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK CostbaseChargeout.

    METHODS deleteadhochargeout FOR MODIFY
      IMPORTING keys FOR ACTION CostbaseChargeout~deleteadhochargeout.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR CostbaseChargeout RESULT result.

    METHODS precheck_deleteadhochargeout FOR PRECHECK
      IMPORTING keys FOR ACTION CostbaseChargeout~deleteadhochargeout.

ENDCLASS.

CLASS lhc_CostbaseChargeout IMPLEMENTATION.

  METHOD get_instance_authorizations.
    IF keys IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD deleteadhochargeout.
    DATA lo_badi     TYPE REF TO /esrcc/badi_cockpit.

    IF lo_badi IS NOT BOUND.
      TRY.
          GET BADI lo_badi.
        CATCH cx_badi_not_implemented cx_badi_unknown_error.
      ENDTRY.
    ENDIF.



    IF keys IS NOT INITIAL.

      IF lo_badi IS BOUND.

        DATA(id) = keys[ 1 ]-CcUuid.
        CALL BADI lo_badi->delete_adhoc_chargeout
          EXPORTING
            id = id.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD precheck_deleteadhochargeout.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_costbase_chargeout IN LOCAL MODE
        ENTITY CostbaseChargeout
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <costbase>-legalentity
              ID 'ACTVT'      FIELD '06'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <costbase>-costobject
          ID '/ESRCC/CN' FIELD <costbase>-costcenter
          ID 'ACTVT'      FIELD '06'.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <costbase>-%tky
                          %msg = new_message(
                                     id    = '/ESRCC/MESSAGES'
                                     number = '001'
                                     v1     = <costbase>-Costobject
                                     v2     = <costbase>-Costcenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-costbasechargeout.
          APPEND VALUE #( %tky = <costbase>-%tky ) TO
                          failed-costbasechargeout.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <costbase>-%tky
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '000'
                                       v1     = <costbase>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-costbasechargeout.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-costbasechargeout.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_I_COSTBASE_CHARGEOUT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_COSTBASE_CHARGEOUT IMPLEMENTATION.

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
