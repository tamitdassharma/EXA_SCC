INTERFACE /esrcc/if_file_upld_util_badi PUBLIC .

  INTERFACES if_badi_interface .

  METHODS:
    validate_business_field IMPORTING table_name   TYPE tabname
                                      component    TYPE abap_componentdescr
*                                      field_name     TYPE string
                                      field_value  TYPE any
*                                      header_structure TYPE any
                                      data_structure   TYPE any OPTIONAL
                            CHANGING  is_validated TYPE xsdboolean
                                      message      TYPE /esrcc/log_item,
    convert_standard_data_type IMPORTING component        TYPE abap_componentdescr
                                         decimal_notation TYPE xsdboolean
                                         date_format      TYPE xsdboolean
                               CHANGING  cell_value       TYPE any
                                         message          TYPE string,
    determine_business_field IMPORTING table_name       TYPE tabname
                             CHANGING  change_structure TYPE any.
ENDINTERFACE.
