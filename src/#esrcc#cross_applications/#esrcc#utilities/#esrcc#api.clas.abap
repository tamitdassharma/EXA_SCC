CLASS /esrcc/api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA:
      document_service      TYPE REF TO /esrcc/if_write_back,
      extraction_service    TYPE REF TO /esrcc/if_extract_data,
      extraction_bw_service TYPE REF TO /esrcc/if_extract_data.

    CLASS-METHODS:
      class_constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/api IMPLEMENTATION.
  METHOD class_constructor.
    document_service = /esrcc/write_back=>create( ).
    extraction_service = /esrcc/extract_data=>create( ).
    extraction_bw_service = /esrcc/extract_data_bw=>create( ).
  ENDMETHOD.

ENDCLASS.
