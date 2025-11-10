CLASS /esrcc/default_dao DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES /esrcc/if_data_model_dao.

  CLASS-METHODS:
    create RETURNING VALUE(dao) TYPE REF TO /esrcc/if_data_model_dao.
ENDCLASS.


CLASS /esrcc/default_dao IMPLEMENTATION.
  METHOD create.
    dao = NEW /esrcc/default_dao( ).
  ENDMETHOD.

  METHOD /esrcc/if_data_model_dao~modify.
    DATA:
      dao_badi   TYPE REF TO /esrcc/dao_badi.

    FIELD-SYMBOLS:
      <model> TYPE STANDARD TABLE.

    " Get the BAdI instance for modifying the data model
    GET BADI dao_badi
        FILTERS
          model = name.

    " Ensure the model is not empty before proceeding
    IF model IS INITIAL.
      RETURN. " No data to validate
    ENDIF.

    ASSIGN model TO <model>.

    " Validate the data model before modification
    DATA(name_of_model) = CONV tabname( name ).
    CALL BADI dao_badi->validate_data
      EXPORTING model_name = name_of_model
      CHANGING  model      = <model>.

    " Ensure the data model is valid before proceeding
    IF <model> IS INITIAL.
      RETURN. " No valid data to modify
    ENDIF.

    " Modify the data model using the BAdI method
    CALL BADI dao_badi->determine_data
      CHANGING model = <model>.

    " Update the data model in the database
    MODIFY (name) FROM TABLE @model.
  ENDMETHOD.

ENDCLASS.
