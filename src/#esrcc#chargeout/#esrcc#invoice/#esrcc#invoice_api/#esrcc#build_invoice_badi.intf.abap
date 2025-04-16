INTERFACE /esrcc/build_invoice_badi PUBLIC.


  INTERFACES if_badi_interface.

  TYPES:
    chargeout_type TYPE STANDARD TABLE OF /esrcc/c_chginvoice WITH DEFAULT KEY.

  METHODS:
    get_other_details_for_invoice IMPORTING chargeouts    TYPE chargeout_type
                                  CHANGING  other_details TYPE REF TO data,

    build_invoice_data IMPORTING chargeouts    TYPE chargeout_type
                                 other_details TYPE REF TO data
                       CHANGING  invoice_dto   TYPE REF TO data.

ENDINTERFACE.
