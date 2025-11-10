CLASS /esrcc/cb_li_dao DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES: /esrcc/if_data_model_dao.

    CLASS-METHODS:
      create RETURNING VALUE(dao) TYPE REF TO /esrcc/if_data_model_dao.
ENDCLASS.


CLASS /esrcc/cb_li_dao IMPLEMENTATION.
  METHOD create.
    dao = NEW /esrcc/cb_li_dao( ).
  ENDMETHOD.

  METHOD /esrcc/if_data_model_dao~modify.
    DATA:
      dao_badi   TYPE REF TO /esrcc/dao_badi,
      line_items TYPE STANDARD TABLE OF /esrcc/cb_li WITH DEFAULT KEY.

    " Get the BAdI instance for modifying the data model
    GET BADI dao_badi
        FILTERS
          model = name.

    " Convert the input model to a table of line items
    line_items = CORRESPONDING #( model ).

    " Ensure the table is not empty before proceeding
    IF line_items IS INITIAL.
      RETURN. " No data to validate
    ENDIF.

    " Validate the data model before modification
    DATA(name_of_model) = CONV tabname( name ).
    CALL BADI dao_badi->validate_data
      EXPORTING model_name = name_of_model
      CHANGING  model      = line_items.

    " Ensure the data model is valid before proceeding
    IF line_items IS INITIAL.
      RETURN. " No valid data to modify
    ENDIF.

    " Modify the data model using the BAdI method
    CALL BADI dao_badi->determine_data
      CHANGING model = line_items.

    " Update the database table with the modified line items
    MODIFY /esrcc/cb_li FROM TABLE @line_items.
    IF sy-subrc = 0.
    ELSE.
      " Handle the error if the modification fails
      RAISE EXCEPTION TYPE cx_sy_open_sql_db
        EXPORTING textid = cx_sy_open_sql_db=>internal_db_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
