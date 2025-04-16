CLASS /esrcc/default_virtual_element DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.



CLASS /ESRCC/DEFAULT_VIRTUAL_ELEMENT IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES:
      original_data TYPE STANDARD TABLE OF /esrcc/c_chginvoice WITH DEFAULT KEY.

    FINAL(original_data) = CORRESPONDING original_data( it_original_data ).

    ct_calculated_data = CORRESPONDING #( VALUE original_data(
                                              FOR <data> IN original_data
                                              ( VALUE #(
                                                    BASE <data>
                                                    Stream   = /esrcc/generate_pdf_invoice=>create( )->generate_invoice(
                                                                   invoice_reference_id = <data>-InvoiceUUID
                                                                   invoice_currency_type = <data>-Currencytype ) ) ) ) ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = '/ESRCC/C_CHGINVOICE'.
      APPEND LINES OF VALUE if_sadl_exit_calc_element_read=>tt_elements( ( CONV #( 'INVOICEUUID' ) )
                                                                         ( CONV #( 'INVOICESTATUS' ) )
                                                                         ( CONV #( 'CURRENCYTYPE' ) ) )
             TO et_requested_orig_elements.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
