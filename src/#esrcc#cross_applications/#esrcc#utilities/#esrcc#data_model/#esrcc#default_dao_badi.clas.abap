CLASS /esrcc/default_dao_badi DEFINITION PUBLIC FINAL CREATE PUBLIC GLOBAL FRIENDS /esrcc/cb_li_badi.

  PUBLIC SECTION.
    INTERFACES /esrcc/if_dao_badi.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF _master_data_type,
        relative_name TYPE string,
        valid_data    TYPE REF TO data,
        field_name    TYPE string,
      END OF _master_data_type,

      _master_data_list_type TYPE SORTED TABLE OF _master_data_type WITH UNIQUE KEY relative_name.

    METHODS:
      _populate_master_data_store
        IMPORTING model_name               TYPE tabname
                  key_field_list           TYPE sxco_t_ad_field_names
                  all_fields_list          TYPE sxco_t_dbt_fields
        RETURNING VALUE(master_data_store) TYPE _master_data_list_type,
      _validate_data IMPORTING key_field_list    TYPE sxco_t_ad_field_names
                               all_fields_list   TYPE sxco_t_dbt_fields
                               master_data_store TYPE _master_data_list_type
                               model             TYPE STANDARD TABLE
                     EXPORTING model_new         TYPE STANDARD TABLE.
ENDCLASS.


CLASS /esrcc/default_dao_badi IMPLEMENTATION.
  METHOD /esrcc/if_dao_badi~determine_data.
    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(time_stamp) ).

    LOOP AT model ASSIGNING FIELD-SYMBOL(<model>).
      ASSIGN COMPONENT 'CREATED_AT' OF STRUCTURE <model> TO FIELD-SYMBOL(<created_at>).
      ASSIGN COMPONENT 'CREATED_BY' OF STRUCTURE <model> TO FIELD-SYMBOL(<created_by>).
      ASSIGN COMPONENT 'LAST_CHANGED_BY' OF STRUCTURE <model> TO FIELD-SYMBOL(<last_changed_by>).
      ASSIGN COMPONENT 'LAST_CHANGED_AT' OF STRUCTURE <model> TO FIELD-SYMBOL(<last_changed_at>).

      IF <created_at> IS ASSIGNED.
        <created_at> = time_stamp.
      ENDIF.
      IF <created_by> IS ASSIGNED.
        <created_by> = sy-uname.
      ENDIF.
      IF <last_changed_at> IS ASSIGNED.
        <last_changed_at> = time_stamp.
      ENDIF.
      IF <last_changed_by> IS ASSIGNED.
        <last_changed_by> = sy-uname.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /esrcc/if_dao_badi~validate_data.
    DATA(db_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
                                 VALUE #( ( xco_cp_abap_repository=>object_name->get_filter(
                                                xco_cp_abap_sql=>constraint->equal( model_name ) ) ) ) )->in(
                                                    xco_cp_abap=>repository )->get( ).

    IF lines( db_table_readers ) = 0.
      RETURN.
    ENDIF.

    FINAL(db_table_reader) = db_table_readers[ 1 ].
    IF db_table_reader IS NOT BOUND.
      RETURN.
    ENDIF.

    FINAL(key_field_list) = db_table_reader->fields->key->get_names( ).
    FINAL(all_fields_list) = db_table_reader->fields->all->get( ).

    FINAL(master_data_store) = _populate_master_data_store( model_name      = model_name
                                                            key_field_list  = key_field_list
                                                            all_fields_list = all_fields_list ).

    _validate_data( EXPORTING key_field_list    = key_field_list
                              all_fields_list   = all_fields_list
                              master_data_store = master_data_store
                              model             = model
                    IMPORTING model_new         = model ).
  ENDMETHOD.

  METHOD _populate_master_data_store.
    DATA: temp_data_table TYPE REF TO data.

    FIELD-SYMBOLS: <temp_data_table> TYPE STANDARD TABLE.

    LOOP AT all_fields_list ASSIGNING FIELD-SYMBOL(<field>).
      IF NOT line_exists( key_field_list[ <field>->name ] ).
        CONTINUE.
      ENDIF.

      " Get the relative name of the field
      FINAL(relative_name) = <field>->content( )->get_type( )->get_data_element( )->name.

      CASE relative_name.
        WHEN '/ESRCC/LEGALENTITY'.
          IF model_name <> '/ESRCC/LE'.
            SELECT legalentity FROM /esrcc/le
              ORDER BY legalentity
              INTO TABLE @FINAL(_valid_legal_entites).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              DATA(table_handler) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_legal_entites ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_legal_entites ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |LEGALENTITY| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTCENTER'.
          IF model_name <> '/ESRCC/CST_OBJCT'.
            SELECT DISTINCT cost_center AS costcenter
              FROM /esrcc/cst_objct
              ORDER BY costcenter
              INTO TABLE @FINAL(_valid_cost_centers).   "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_cost_centers ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_cost_centers ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |COSTCENTER| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTELEMENT'.
          IF model_name <> '/ESRCC/CST_ELMNT'.
            SELECT DISTINCT cost_element AS costelement
              FROM /esrcc/cst_elmnt
              ORDER BY costelement
              INTO TABLE @FINAL(_valid_cost_elements).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_cost_elements ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_cost_elements ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |COSTELEMENT| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SYSID'.
          IF model_name <> '/ESRCC/SYS_INFO'.
            SELECT system_id FROM /esrcc/sys_info
              ORDER BY system_id
              INTO TABLE @FINAL(_valid_system_ids).     "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_system_ids ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_system_ids ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SYSTEM_ID| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/CCODE_DE'.
          IF model_name <> '/ESRCC/LE_CCODE'.
            SELECT DISTINCT ccode FROM /esrcc/le_ccode
              ORDER BY ccode
              INTO TABLE @FINAL(_valid_company_codes).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_company_codes ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_company_codes ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |CCODE| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/BUSINESSDIVISION'.
          IF model_name <> '/ESRCC/BUS_DIV'. " AND field_value IS NOT INITIAL.
            SELECT business_division FROM /esrcc/bus_div
              ORDER BY business_division
              INTO TABLE @FINAL(_valid_business_divisions). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_business_divisions ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_business_divisions ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |BUSINESS_DIVISION| ) INTO TABLE master_data_store.
            ENDIF.

          ENDIF.
        WHEN '/ESRCC/PROFIT_CENTER'.
          IF model_name <> '/ESRCC/PFC'. " AND field_value IS NOT INITIAL.
            SELECT profit_center FROM /esrcc/pfc
              ORDER BY profit_center
              INTO TABLE @FINAL(_valid_profit_centers). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_profit_centers ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_profit_centers ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |PROFIT_CENTER| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVPRODUCT'.
          IF model_name <> '/ESRCC/SRVPRO'.
            SELECT serviceproduct FROM /esrcc/srvpro
              ORDER BY serviceproduct
              INTO TABLE @FINAL(_valid_service_products). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_service_products ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_service_products ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SERVICEPRODUCT| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVTYPE_DE'.
          IF model_name <> '/ESRCC/SRTYPE'.
            SELECT srvtype FROM /esrcc/srtype
              ORDER BY srvtype
              INTO TABLE @FINAL(_valid_service_type).   "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_service_type ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_service_type ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SRVTYPE| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/TG'.
          IF model_name <> '/ESRCC/SRVTG'.
            SELECT transactiongroup FROM /esrcc/srvtg
              ORDER BY transactiongroup
              INTO TABLE @FINAL(_valid_transaction_group). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_transaction_group ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_transaction_group ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |TRANSACTIONGROUP| ) INTO TABLE master_data_store.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD _validate_data.
    FIELD-SYMBOLS: <valid_value_table> TYPE STANDARD TABLE.

    LOOP AT model ASSIGNING FIELD-SYMBOL(<model>).
      " Check if all key fields are filled
      LOOP AT all_fields_list ASSIGNING FIELD-SYMBOL(<field>).
        " Skip fields that are not key fields
        IF NOT line_exists( key_field_list[ <field>->name ] ).
          CONTINUE.
        ENDIF.

        " Get the field value from the model
        ASSIGN COMPONENT <field>->name OF STRUCTURE <model> TO FIELD-SYMBOL(<field_value>).
        IF <field_value> IS NOT ASSIGNED OR <field_value> IS INITIAL.
          CONTINUE.
        ENDIF.

        " Check if the field value exists in the master data store
        FINAL(relative_name) = <field>->content( )->get_type( )->get_data_element( )->name.
        FINAL(master_data_store_index) = line_index( master_data_store[ relative_name = relative_name ] ).

        IF master_data_store_index IS INITIAL.
          " If the field is not in the master data store, it might be a fixed value field
          " Check if the field has fixed values defined in the data element
          FINAL(fixed_values) = <field>->content( )->get_type( )->get_data_element( )->content( )->get_data_type( )->get_domain( )->fixed_values->all->get( ).
          IF lines( fixed_values ) = 0.
            CONTINUE.
          ENDIF.

          " Check if the field value exists in the fixed values
          LOOP AT fixed_values ASSIGNING FIELD-SYMBOL(<fixed_value>) WHERE table_line->lower_limit = <field_value>.
            DATA(exist) = abap_true.
            EXIT.
          ENDLOOP.
          IF exist IS INITIAL.
            DATA(is_error) = abap_true.
          ELSE.
            CLEAR exist.
          ENDIF.
        ELSE.
          FINAL(master_data) = master_data_store[ master_data_store_index ].
          ASSIGN master_data-valid_data->* TO <valid_value_table>.
          IF NOT line_exists( <valid_value_table>[ (master_data-field_name) = <field_value> ] ).
            exist = abap_false.
            is_error = abap_true.
          ENDIF.
        ENDIF.

        IF is_error IS NOT INITIAL.
          DATA(is_invalid) = abap_true.
          " Log the error for the field
        ENDIF.
      ENDLOOP.
      " If the model is invalid remove the row
      IF is_invalid IS INITIAL.
        APPEND <model> TO model_new.
      ELSE.
        CLEAR is_invalid.
        " Log the invalid row
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
