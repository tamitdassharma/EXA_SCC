INTERFACE /esrcc/if_domain_validator PUBLIC .
  METHODS:
    validate_domain IMPORTING domain_name     TYPE /esrcc/domain_name OPTIONAL
                              field_name      TYPE /esrcc/field_name OPTIONAL
                              table_name      TYPE tabname
                              value           TYPE /esrcc/domain_value
                    RETURNING VALUE(is_valid) TYPE abap_boolean.
ENDINTERFACE.
