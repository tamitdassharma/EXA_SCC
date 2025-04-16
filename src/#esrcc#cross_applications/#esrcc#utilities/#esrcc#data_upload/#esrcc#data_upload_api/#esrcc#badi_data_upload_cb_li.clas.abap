CLASS /esrcc/badi_data_upload_cb_li DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_data_upload_badi .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/badi_data_upload_cb_li IMPLEMENTATION.


  METHOD /esrcc/if_data_upload_badi~validate.
  ENDMETHOD.
ENDCLASS.
