CLASS /esrcc/generate_pdf_invoice DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES:
      /esrcc/generate_invoice.

    CLASS-METHODS:
      create RETURNING VALUE(instance) TYPE REF TO /esrcc/generate_invoice.

  PRIVATE SECTION.
    DATA:
      _chargeouts_for_invoice TYPE STANDARD TABLE OF /esrcc/c_chginvoice WITH DEFAULT KEY,
      _other_details          TYPE REF TO data,
      _invoice_dto            TYPE REF TO data,
      _invoice_create_plugin  TYPE REF TO /esrcc/create_invoice,
      _invoice_builder_plugin TYPE REF TO /esrcc/build_invoice.

    METHODS:
      _get_chargeout_for_invoice IMPORTING invoice_ref_id TYPE sysuuid_c32
                                           invoice_curr_type TYPE abap_bool,
      _get_other_details_for_invoice,
      _build_invoice_data,
      _create_invoice            RETURNING VALUE(raw_pdf) TYPE cmis_s_content_raw-stream.

ENDCLASS.



CLASS /ESRCC/GENERATE_PDF_INVOICE IMPLEMENTATION.


  METHOD /esrcc/generate_invoice~generate_invoice.
    _get_chargeout_for_invoice( invoice_ref_id = invoice_reference_id
                                invoice_curr_type = invoice_currency_type ).

    _get_other_details_for_invoice( ).

    _build_invoice_data( ).

    pdf_in_raw_format = _create_invoice( ).
  ENDMETHOD.


  METHOD create.
    instance = NEW /esrcc/generate_pdf_invoice( ).
  ENDMETHOD.


  METHOD _build_invoice_data.
    TRY.
        IF _invoice_builder_plugin IS NOT BOUND.
          GET BADI _invoice_builder_plugin
              FILTERS
                language = sy-langu
                country  = 'DE'.
        ENDIF.

        CALL BADI _invoice_builder_plugin->build_invoice_data
          EXPORTING chargeouts    = _chargeouts_for_invoice
                    other_details = _other_details
          CHANGING  invoice_dto   = _invoice_dto.
      CATCH cx_badi_not_implemented cx_badi_initial_reference
cx_sy_dyn_call_illegal_method.
    ENDTRY.
  ENDMETHOD.


  METHOD _create_invoice.
    TRY.
        IF _invoice_create_plugin IS NOT BOUND.
          GET BADI _invoice_create_plugin
              FILTERS
                language = sy-langu
                country  = 'DE'.
        ENDIF.

        CALL BADI _invoice_create_plugin->create_invoice
          EXPORTING invoice_dto = _invoice_dto
          CHANGING  raw_pdf     = raw_pdf.
      CATCH cx_badi_not_implemented cx_badi_initial_reference
cx_sy_dyn_call_illegal_method.
    ENDTRY.
  ENDMETHOD.


  METHOD _get_chargeout_for_invoice.
    " Get the charge-outs for the given invoice number, i.e., Invoice Reference ID
    SELECT * FROM /esrcc/c_chginvoice AS chargeout_invoice
      WHERE InvoiceUUID = @invoice_ref_id
        AND Currencytype = @invoice_curr_type
      INTO TABLE @_chargeouts_for_invoice.
  ENDMETHOD.


  METHOD _get_other_details_for_invoice.
    TRY.
        IF _invoice_builder_plugin IS NOT BOUND.
          GET BADI _invoice_builder_plugin
              FILTERS
                language = sy-langu
                country  = 'DE'.
        ENDIF.

        CALL BADI _invoice_builder_plugin->get_other_details_for_invoice
          EXPORTING chargeouts    = _chargeouts_for_invoice
          CHANGING  other_details = _other_details.
      CATCH cx_badi_not_implemented cx_badi_initial_reference
cx_sy_dyn_call_illegal_method.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
