INTERFACE /esrcc/if_data_model_dao PUBLIC .
  METHODS:
    modify IMPORTING name  TYPE string
                     model TYPE STANDARD TABLE.
ENDINTERFACE.
