CLASS /esrcc/build_invoice_retreat DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_badi_interface.
    INTERFACES /esrcc/build_invoice_badi.

    TYPES:
      BEGIN OF invoice_detail,
        sender              TYPE /esrcc/entity_details,
        receiver            TYPE /esrcc/entity_details,
        bank_information    TYPE /esrcc/entity_bank_detail,
        invoice_information TYPE /esrcc/invoice_detail,
        items               TYPE /esrcc/items,
        totals              TYPE /esrcc/total,
      END OF invoice_detail.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF _other_invoice_detail_type,
        BEGIN OF sender,
          address           TYPE /esrcc/le_addres,
          bank_information  TYPE /esrcc/lebnkinfo,
          tax_information   TYPE /esrcc/letaxinfo,
          other_information TYPE /esrcc/le_others,
        END OF sender,
        BEGIN OF receiver,
          address           TYPE /esrcc/le_addres,
          tax_information   TYPE /esrcc/letaxinfo,
          other_information TYPE /esrcc/le_others,
        END OF receiver,
      END OF _other_invoice_detail_type.

ENDCLASS.



CLASS /ESRCC/BUILD_INVOICE_RETREAT IMPLEMENTATION.


  METHOD /esrcc/build_invoice_badi~build_invoice_data.
*    FIELD-SYMBOLS:
*      <other_detail> TYPE _other_invoice_detail_type.
*
*    ASSIGN other_details->* TO <other_detail>.
*
*    IF <other_detail> IS NOT ASSIGNED.
*      RETURN.
*    ENDIF.
*
*    DATA(invoice_data) = VALUE invoice_detail( ).

*    FINAL(charge_out) = VALUE #( chargeouts[ 1 ] OPTIONAL ).
*    invoice_data-bank_information    = CORRESPONDING #( <other_detail>-sender-bank_information MAPPING iban = bank_account_number bic = bic_code ).
*    invoice_data-items               = VALUE #(
*        FOR <charge_out> IN chargeouts INDEX INTO chargeout_index
*        ( VALUE #( BASE CORRESPONDING #( <charge_out> MAPPING service_product = Serviceproduct description = Serviceproductdescription
*                                       method = chargeoutdescription billing_period = Poper "unit_of_measure = Uom
*                                       quantity = Reckpi
*                                       unit_price_per_share = Reckpishare total_amount = TotalChargeout )
*                   tax           = <other_detail>-sender-tax_information-tax_percentage
*                   item_position = chargeout_index ) ) ).
*    invoice_data-sender              = VALUE #( BASE CORRESPONDING #(
*                                           CORRESPONDING /esrcc/entity_details(
*                                             BASE (
*                                                CORRESPONDING /esrcc/entity_details(
*                                                    BASE ( CORRESPONDING #( <other_detail>-sender-tax_information ) )
*                                                         <other_detail>-sender-address MAPPING entity = legal_entity address_street1 = street_1
*                                                                                               address_street2 = street_2 address_city = city
*                                                                                               address_zip = zip address_state = state
*                                                                                               address_country = country ) )
*                                                            <other_detail>-sender-other_information MAPPING account_pnl = account
*                                                                                                            controlling_object = cost_object
*                                                                                                            tp_transaction_group = transaction_group  ) )
*                                                posting_period = charge_out-Poper ).
*    invoice_data-receiver            = VALUE #( BASE CORRESPONDING #(
*                                            CORRESPONDING /esrcc/entity_details(
*                                              BASE (
*                                                CORRESPONDING /esrcc/entity_details(
*                                                    BASE ( CORRESPONDING #( <other_detail>-receiver-tax_information ) )
*                                                        <other_detail>-receiver-address MAPPING entity = legal_entity address_street1 = street_1
*                                                                                               address_street2 = street_2 address_city = city
*                                                                                               address_zip = zip address_state = state
*                                                                                               address_country = country ) )
*                                                            <other_detail>-receiver-other_information MAPPING account_pnl = account
*                                                                                                            controlling_object = cost_object
*                                                                                                            tp_transaction_group = transaction_group ) )
*                                                posting_period = charge_out-Poper ).
*    invoice_data-invoice_information = VALUE #( BASE CORRESPONDING #( charge_out MAPPING invoice_number = InvoiceNumber  reference_number = InvoiceNumber )
*                                                invoice_date  = cl_abap_context_info=>get_system_date( )
*                                                delivery_date = cl_abap_context_info=>get_system_date( ) ).
*    DATA(total) = VALUE f( ).
*    DATA(tax) = VALUE f( ).
*    LOOP AT invoice_data-items ASSIGNING FIELD-SYMBOL(<item>).
*      total += <item>-total_amount.
*      tax += ( ( <item>-total_amount * <item>-tax ) / 100 ).
*    ENDLOOP.
*
*    invoice_data-totals-gross_value      = <item>-total_amount + <item>-tax.
*    invoice_data-totals-total_value      = |{ total CURRENCY = charge_out-Currency } { charge_out-Currency } |.
*    invoice_data-totals-vat_or_sales_tax = |{ tax CURRENCY = charge_out-Currency } { charge_out-Currency }|.
*    invoice_data-totals-gross_value      = |{ ( total + tax ) CURRENCY = charge_out-Currency } { charge_out-Currency }|.
*    invoice_dto = NEW invoice_detail( invoice_data ).
  ENDMETHOD.


  METHOD /esrcc/build_invoice_badi~get_other_details_for_invoice.
    DATA(other_invoice_detail) = VALUE _other_invoice_detail_type( ).
    SELECT ##ITAB_DB_SELECT
        DISTINCT legalentity     AS sender,
                 receivingentity AS receiver
      FROM @chargeouts AS charge_outs ##ITAB_KEY_IN_SELECT
      INTO TABLE @FINAL(charge_outs).
    FINAL(charge_out) = VALUE #( charge_outs[ 1 ] ).

    SELECT SINGLE * FROM /esrcc/lebnkinfo AS bank_info "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-sender
      INTO @other_invoice_detail-sender-bank_information.

    SELECT SINGLE * FROM /esrcc/letaxinfo AS tax_info "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-sender
      INTO @other_invoice_detail-sender-tax_information.
    SELECT SINGLE * FROM /esrcc/letaxinfo AS tax_info "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-receiver
      INTO @other_invoice_detail-receiver-tax_information.

    SELECT SINGLE * FROM /esrcc/le_addres AS address "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-sender
      INTO @other_invoice_detail-sender-address.
    SELECT SINGLE * FROM /esrcc/le_addres AS address "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-receiver
      INTO @other_invoice_detail-receiver-address.

    SELECT * FROM /esrcc/le_others AS other "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-sender AND role = 'R1'
      ORDER BY company_code DESCENDING,
               cost_object DESCENDING,
               business_division DESCENDING,
               transaction_group DESCENDING
      INTO TABLE @FINAL(other_sender_info).
    IF sy-subrc = 0.
      other_invoice_detail-sender-other_information = VALUE #( other_sender_info[ 1 ] OPTIONAL ).
    ENDIF.
    SELECT * FROM /esrcc/le_others AS other "#EC CI_ALL_FIELDS_NEEDED
      WHERE legal_entity = @charge_out-receiver AND role = 'R2'
      ORDER BY company_code DESCENDING,
               cost_object DESCENDING,
               business_division DESCENDING,
               transaction_group DESCENDING
      INTO TABLE @FINAL(other_receiver_info).
    IF sy-subrc = 0.
      other_invoice_detail-receiver-other_information = VALUE #( other_receiver_info[ 1 ] OPTIONAL ).
    ENDIF.

    other_details = NEW _other_invoice_detail_type( other_invoice_detail ).
  ENDMETHOD.
ENDCLASS.
