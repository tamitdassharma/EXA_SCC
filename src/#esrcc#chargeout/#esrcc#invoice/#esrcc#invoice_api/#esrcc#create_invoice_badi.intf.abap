INTERFACE /esrcc/create_invoice_badi PUBLIC.


  INTERFACES if_badi_interface.

  METHODS:
    create_invoice IMPORTING invoice_dto TYPE REF TO data
                   CHANGING  raw_pdf     TYPE cmis_s_content_raw-stream.
ENDINTERFACE.
