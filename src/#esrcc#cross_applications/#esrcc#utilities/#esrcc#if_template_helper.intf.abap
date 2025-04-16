INTERFACE /esrcc/if_template_helper PUBLIC.
  TYPES:
    BEGIN OF table_metadata,
      name    TYPE sxco_ad_object_name,
      alias   TYPE sxco_ad_object_name,
      parents TYPE STANDARD TABLE OF sxco_ad_object_name WITH EMPTY KEY,
      method  TYPE sxco_clas_method_name,
    END OF table_metadata.

  METHODS:
    check_table_registered IMPORTING name              TYPE sxco_ad_object_name
                           RETURNING VALUE(registered) TYPE abap_bool,

    check_alias_registered IMPORTING alias             TYPE sxco_ad_object_name
                           RETURNING VALUE(registered) TYPE abap_bool,

    get_table_alias      RETURNING VALUE(alias)      TYPE sxco_ad_object_name,
    get_table_name       RETURNING VALUE(table_name) TYPE sxco_ad_object_name,

    upload_template_data IMPORTING excel_structured_data      TYPE REF TO data
                         RETURNING VALUE(records) TYPE i.
ENDINTERFACE.
