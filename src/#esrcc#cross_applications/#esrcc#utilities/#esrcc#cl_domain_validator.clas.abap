CLASS /esrcc/cl_domain_validator DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES /esrcc/if_domain_validator.

    CLASS-METHODS:
      create_instance RETURNING VALUE(instance) TYPE REF TO /esrcc/if_domain_validator,
      get_instance    RETURNING VALUE(instance) TYPE REF TO /esrcc/if_domain_validator.

  PRIVATE SECTION.
    CLASS-DATA:
      validator TYPE REF TO /esrcc/if_domain_validator.

    TYPES:
      BEGIN OF _value_type,
        value TYPE /ESRCC/domain_value,
      END OF _value_type,

      _value_types TYPE STANDARD TABLE OF _value_type WITH EMPTY KEY,

      BEGIN OF _domain_value_type,
        field_name  TYPE /esrcc/field_name,
        domain_name TYPE /esrcc/domain_name,
        values      TYPE _value_types,
      END OF _domain_value_type,

      _domain_value_types TYPE STANDARD TABLE OF _domain_value_type WITH EMPTY KEY.

    DATA:
      _domain_values_pool TYPE _domain_value_types.

    METHODS:
      _validate_using_domain_name IMPORTING domain_name     TYPE /esrcc/domain_name
                                            table_name      TYPE tabname
                                            !value          TYPE /esrcc/domain_value
                                  RETURNING VALUE(is_valid) TYPE abap_boolean,

      _validate_using_field_name IMPORTING field_name      TYPE /esrcc/field_name
                                           table_name      TYPE tabname
                                           !value          TYPE /esrcc/domain_value
                                 RETURNING VALUE(is_valid) TYPE abap_boolean,

      _check_domain_exists_in_pool IMPORTING domain_name              TYPE /esrcc/domain_name
                                   RETURNING VALUE(does_value_exists) TYPE _value_types,

      _check_field_exists_in_pool IMPORTING field_name               TYPE /esrcc/field_name
                                  RETURNING VALUE(does_value_exists) TYPE _value_types,

      _fill_domain_pool IMPORTING domain_name TYPE /esrcc/domain_name OPTIONAL
                                  field_name  TYPE /esrcc/field_name  OPTIONAL
                                  table_name  TYPE tabname.

ENDCLASS.


CLASS /esrcc/cl_domain_validator IMPLEMENTATION.
  METHOD /esrcc/if_domain_validator~validate_domain.
    is_valid = COND #( WHEN domain_name IS SUPPLIED THEN _validate_using_domain_name( domain_name = domain_name
                                                                                      table_name  = table_name
                                                                                      value       = value )
                       WHEN field_name IS SUPPLIED  THEN _validate_using_field_name( field_name = field_name
                                                                                     table_name = table_name
                                                                                     value      = value ) ).
  ENDMETHOD.

  METHOD create_instance.
    instance = NEW /esrcc/cl_domain_validator( ).
  ENDMETHOD.

  METHOD get_instance.
    IF validator IS NOT BOUND.
      validator = NEW /esrcc/cl_domain_validator( ).
    ENDIF.

    instance = validator.
  ENDMETHOD.

  METHOD _check_domain_exists_in_pool.
    does_value_exists = VALUE #( _domain_values_pool[ domain_name = domain_name ]-values OPTIONAL ).
  ENDMETHOD.

  METHOD _check_field_exists_in_pool.
    does_value_exists = VALUE #( _domain_values_pool[ field_name = field_name ]-values OPTIONAL ).
  ENDMETHOD.

  METHOD _fill_domain_pool.
    IF domain_name IS SUPPLIED AND domain_name IS NOT INITIAL.
      DATA(name) = domain_name.
*      SELECT FROM DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: domain_name ) as domain_values
*        FIELDS value_low as value
*        WHERE domain_name = @domain_name AND language = @sy-langu
*        INTO TABLE @DATA(domain_values).
*      SELECT domvalue_l AS value FROM dd07l AS domain_values
*          INNER JOIN dd03l AS table_fields ON domain_values~domname = table_fields~domname "#EC CI_BUFFJOIN
*          WHERE tabname = @table_name AND table_fields~domname = @domain_name AND table_fields~as4local = 'A'
*          AND domain_values~as4local = 'A' AND table_fields~as4vers = '0000' AND domain_values~as4vers = '0000'
*          INTO TABLE @DATA(domain_values).
    ELSEIF field_name IS SUPPLIED AND field_name IS NOT INITIAL.
      name = /esrcc/cl_dyn_table_generator=>get( )->get_field_list( table_name = table_name
                                                                    field_name = field_name
                                )-domname.
*      SELECT domvalue_l AS value FROM dd07l AS domain_values
*          INNER JOIN dd03l AS table_fields ON domain_values~domname = table_fields~domname "#EC CI_BUFFJOIN
*          WHERE tabname = @table_name AND table_fields~fieldname = @field_name AND table_fields~as4local = 'A'
*          AND domain_values~as4local = 'A' AND table_fields~as4vers = '0000' AND domain_values~as4vers = '0000'
*          INTO TABLE @domain_values.
    ENDIF.

    IF name IS INITIAL.
      RETURN.
    ENDIF.
    SELECT
      FROM ddcds_customer_domain_value_t( p_domain_name = @name ) AS domain_values
      FIELDS value_low AS value
      WHERE domain_name = @domain_name AND language = @sy-langu
      INTO TABLE @FINAL(domain_values).
    IF sy-subrc = 0.
      APPEND VALUE #( field_name  = field_name
                      domain_name = domain_name
                      values      = domain_values  ) TO _domain_values_pool.
    ENDIF.
  ENDMETHOD.

  METHOD _validate_using_domain_name.
    DATA(domain_values) = _check_domain_exists_in_pool( domain_name ).

    IF lines( domain_values ) > 0 AND line_exists( domain_values[ value = value ] ).
      is_valid = abap_true.
    ELSE.
      _fill_domain_pool( domain_name = domain_name
                         table_name  = table_name ).
      domain_values = _check_field_exists_in_pool( domain_name ).
      IF lines( domain_values ) > 0 AND line_exists( domain_values[ value = value ] ).
        is_valid = abap_true.
      ELSEIF lines( domain_values ) = 0.
        is_valid = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD _validate_using_field_name.
    DATA(domain_values) = _check_field_exists_in_pool( field_name ).

    IF lines( domain_values ) > 0 AND line_exists( domain_values[ value = value ] ).
      is_valid = abap_true.
    ELSE.
      _fill_domain_pool( field_name = field_name
                         table_name = table_name ).
      domain_values = _check_field_exists_in_pool( field_name ).
      IF lines( domain_values ) > 0 AND line_exists( domain_values[ value = value ] ).
        is_valid = abap_true.
      ELSEIF lines( domain_values ) = 0.
        is_valid = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
