CLASS lhc_I_CHGINVOICE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/i_chginvoice RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/i_chginvoice RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/i_chginvoice.

    METHODS createInvoice FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/i_chginvoice~createInvoice RESULT result.

    METHODS finalizeInvoice FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/i_chginvoice~finalizeInvoice RESULT result.

    METHODS DiscardInvoice FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/i_chginvoice~DiscardInvoice RESULT result.

ENDCLASS.

CLASS lhc_I_CHGINVOICE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD createInvoice.

    DATA legtmp   TYPE /esrcc/legalentity.
    DATA ccodetmp TYPE /esrcc/ccode_de.
    DATA rectmp   TYPE /esrcc/receivingntity.

    " Return result to UI
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT * FROM /esrcc/rec_chg
               FOR ALL ENTRIES IN @keys
               WHERE rec_uuid = @keys-uuid
                 AND srv_uuid = @keys-ParentUUID
                 AND cc_uuid  = @keys-RootUUID
               INTO TABLE @DATA(lt_chargeouts).

*      SORT lt_chargeouts BY cc_uuid receivingentity.

      LOOP AT lt_chargeouts ASSIGNING FIELD-SYMBOL(<ls_chargeout>).
        IF <ls_chargeout>-invoicestatus = '01'.
          <ls_chargeout>-invoicestatus = '03'.

*          IF legtmp <> <ls_chargeout>-legalentity OR
*             ccodetmp <> <ls_chargeout>-ccode OR
*             rectmp <> <ls_chargeout>-receivingentity OR
*             <key>-%param-InvoiceOption = 2.

          TRY.
              CALL METHOD cl_numberrange_runtime=>number_get
                EXPORTING
                  nr_range_nr = '01'
                  object      = '/ESRCC/INV'
                IMPORTING
                  number      = DATA(number)
                  returncode  = DATA(lv_rcode).
            CATCH cx_nr_object_not_found
                  cx_number_ranges INTO DATA(cx_numberrange).
              DATA(error) = cx_numberrange->get_longtext(  ).
          ENDTRY.

          TRY.
              DATA(guid) = cl_system_uuid=>create_uuid_c32_static( ).
            CATCH cx_uuid_error INTO DATA(cx_uuid).
              error = cx_uuid->get_longtext(  ).
          ENDTRY.

*            legtmp = <ls_chargeout>-legalentity.
*            ccodetmp = <ls_chargeout>-ccode.
*            rectmp = <ls_chargeout>-receivingentity.
*          ENDIF.

          <ls_chargeout>-invoicenumber = number.
          <ls_chargeout>-invoicestatus = '02'.
          <ls_chargeout>-invoiceuuid = guid.

        ELSE.
          READ TABLE keys ASSIGNING FIELD-SYMBOL(<keys>)
                          WITH KEY uuid = <ls_chargeout>-rec_uuid.
*                                  ryear = <ls_chargeout>-ryear
*                                  poper = <ls_chargeout>-poper
*                            legalentity = <ls_chargeout>-Legalentity
*                                  ccode = <ls_chargeout>-Ccode
*                         serviceproduct = <ls_chargeout>-Serviceproduct
*                        receivingentity = <ls_chargeout>-Receivingentity.
*
          IF sy-subrc = 0.
            IF <ls_chargeout>-invoicestatus = '02'.
              APPEND VALUE #(
                              %tky = <keys>-%tky
                              %msg = new_message(
                              id   = '/ESRCC/INVOICE'
                              number = '000'
*                        v1   = <costbase>-belnr
                              severity  = if_abap_behv_message=>severity-error )
                             ) TO reported-/esrcc/i_chginvoice.
              APPEND VALUE #( %tky = <keys>-%tky ) TO
                              failed-/esrcc/i_chginvoice.
            ELSEIF <ls_chargeout>-invoicestatus = '03'.
              APPEND VALUE #(
                              %tky = <keys>-%tky
                              %msg = new_message(
                              id   = '/ESRCC/INVOICE'
                              number = '001'
                              severity  = if_abap_behv_message=>severity-error )
                             ) TO reported-/esrcc/i_chginvoice.
              APPEND VALUE #( %tky = <keys>-%tky ) TO
                              failed-/esrcc/i_chginvoice.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      MODIFY /esrcc/rec_chg FROM TABLE @lt_chargeouts.
    ENDIF.

  ENDMETHOD.

  METHOD finalizeInvoice.

    " Return result to UI
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT * FROM /esrcc/rec_chg
             FOR ALL ENTRIES IN @keys
             WHERE rec_uuid = @keys-uuid
               AND srv_uuid = @keys-ParentUUID
               AND cc_uuid  = @keys-RootUUID
             INTO TABLE @DATA(lt_chargeouts).

      LOOP AT lt_chargeouts ASSIGNING FIELD-SYMBOL(<ls_chargeout>).
        IF <ls_chargeout>-invoicestatus = '02'.
          <ls_chargeout>-invoicestatus = '03'.
        ELSE.
          READ TABLE keys ASSIGNING FIELD-SYMBOL(<keys>)
                          WITH KEY uuid = <ls_chargeout>-rec_uuid.
*                                  ryear = <ls_chargeout>-ryear
*                                  poper = <ls_chargeout>-poper
*                            legalentity = <ls_chargeout>-Legalentity
*                                  ccode = <ls_chargeout>-Ccode
*                         serviceproduct = <ls_chargeout>-Serviceproduct
*                        receivingentity = <ls_chargeout>-Receivingentity.
*
          IF sy-subrc = 0.
            APPEND VALUE #(
                            %tky = <keys>-%tky
                            %msg = new_message(
                            id   = '/ESRCC/INVOICE'
                            number = '002'
*                        v1   = <costbase>-belnr
                            severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-/esrcc/i_chginvoice.
            APPEND VALUE #( %tky = <keys>-%tky ) TO
                            failed-/esrcc/i_chginvoice.
          ENDIF.
        ENDIF.
      ENDLOOP.

      MODIFY /esrcc/rec_chg FROM TABLE @lt_chargeouts.
    ENDIF.

  ENDMETHOD.

  METHOD DiscardInvoice.

    " Return result to UI
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT * FROM /esrcc/rec_chg
               FOR ALL ENTRIES IN @keys
               WHERE rec_uuid = @keys-uuid
                 AND srv_uuid = @keys-ParentUUID
                 AND cc_uuid  = @keys-RootUUID
               INTO TABLE @DATA(lt_chargeouts).


      LOOP AT lt_chargeouts ASSIGNING FIELD-SYMBOL(<ls_chargeout>).
        IF <ls_chargeout>-invoicestatus = '02'.
          <ls_chargeout>-invoicestatus = '01'.
          CLEAR <ls_chargeout>-invoicenumber.
        ELSE.
          READ TABLE keys ASSIGNING FIELD-SYMBOL(<keys>)
                          WITH KEY uuid = <ls_chargeout>-rec_uuid.
*                                  ryear = <ls_chargeout>-ryear
*                                  poper = <ls_chargeout>-poper
*                            legalentity = <ls_chargeout>-Legalentity
*                                  ccode = <ls_chargeout>-Ccode
*                         serviceproduct = <ls_chargeout>-Serviceproduct
*                        receivingentity = <ls_chargeout>-Receivingentity.
          IF sy-subrc = 0.
            APPEND VALUE #(
                            %tky = <keys>-%tky
                            %msg = new_message(
                            id   = '/ESRCC/INVOICE'
                            number = '003'
                            severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-/esrcc/i_chginvoice.
            APPEND VALUE #( %tky = <keys>-%tky ) TO
                            failed-/esrcc/i_chginvoice.
          ENDIF.
        ENDIF.
      ENDLOOP.

      MODIFY /esrcc/rec_chg FROM TABLE @lt_chargeouts.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_I_CHGINVOICE DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_CHGINVOICE IMPLEMENTATION.

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
