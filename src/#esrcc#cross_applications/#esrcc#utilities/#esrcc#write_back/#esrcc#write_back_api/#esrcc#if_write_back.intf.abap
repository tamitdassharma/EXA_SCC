INTERFACE /esrcc/if_write_back PUBLIC.
  TYPES:
    BEGIN OF filter_type,
      filter_name  TYPE string,
      filter_value TYPE REF TO data,
    END OF filter_type,

    filters_type TYPE STANDARD TABLE OF filter_type WITH DEFAULT KEY.

  METHODS:
    filter IMPORTING !filters      TYPE filters_type
           RETURNING VALUE(result) TYPE REF TO /esrcc/if_write_back,
    write_back RETURNING VALUE(result) TYPE REF TO /esrcc/if_write_back.
ENDINTERFACE.
