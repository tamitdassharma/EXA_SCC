INTERFACE /esrcc/if_extract_data PUBLIC.

  TYPES:
    BEGIN OF filter_type,
      filter_name  TYPE string,
      filter_value TYPE REF TO data,
    END OF filter_type,

    filters_type TYPE STANDARD TABLE OF filter_type WITH DEFAULT KEY.

  METHODS:
    filter IMPORTING !filters      TYPE filters_type
           RETURNING VALUE(result) TYPE REF TO /esrcc/if_extract_data,
    extract RETURNING VALUE(result) TYPE REF TO /esrcc/if_extract_data.
ENDINTERFACE.
