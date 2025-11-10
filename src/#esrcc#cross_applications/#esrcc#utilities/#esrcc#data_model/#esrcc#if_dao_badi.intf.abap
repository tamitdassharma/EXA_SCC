INTERFACE /esrcc/if_dao_badi PUBLIC.
  INTERFACES if_badi_interface.

  METHODS:
    validate_data  IMPORTING model_name TYPE tabname
                   CHANGING model TYPE STANDARD TABLE,
    determine_data CHANGING model TYPE STANDARD TABLE.
ENDINTERFACE.
