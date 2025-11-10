CLASS /esrcc/dao DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-DATA:
      cb_li   TYPE REF TO /esrcc/if_data_model_dao,
      default TYPE REF TO /esrcc/if_data_model_dao.

    CLASS-METHODS:
      class_constructor.
ENDCLASS.


CLASS /esrcc/dao IMPLEMENTATION.
  METHOD class_constructor.
    cb_li = /esrcc/cb_li_dao=>create( ).
    default = /esrcc/default_dao=>create( ).
  ENDMETHOD.

ENDCLASS.
