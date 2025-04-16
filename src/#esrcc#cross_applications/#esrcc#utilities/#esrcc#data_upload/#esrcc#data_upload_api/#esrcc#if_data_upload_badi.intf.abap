INTERFACE /esrcc/if_data_upload_badi PUBLIC .


  INTERFACES if_badi_interface .
  METHODS:
    validate IMPORTING parent_msg_id TYPE sysuuid_c32
                       row_data      TYPE any
             CHANGING  valid         TYPE abap_boolean.
ENDINTERFACE.
