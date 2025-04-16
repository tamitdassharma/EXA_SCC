*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

INTERFACE upload_data_to_db.
  METHODS: refine_data IMPORTING table_name        TYPE tabname
                                 table_components  TYPE cl_abap_structdescr=>component_table
                                 uploaded_data     TYPE REF TO data
                       RETURNING VALUE(is_refined) TYPE abap_boolean,

    update_data_to_db.
ENDINTERFACE.


CLASS upload_data_to_db_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES upload_data_to_db.

    CLASS-METHODS:
      create IMPORTING logger          TYPE REF TO /esrcc/if_application_logs
             RETURNING VALUE(instance) TYPE REF TO upload_data_to_db.

  PRIVATE SECTION.
    CLASS-DATA:
      _application_logger TYPE REF TO /esrcc/if_application_logs.

    TYPES:
      BEGIN OF _master_data,
        relative_name TYPE string,
        valid_data    TYPE REF TO data,
        field_Name    TYPE string,
      END OF _master_data,

      _master_data_list TYPE SORTED TABLE OF _master_data WITH UNIQUE KEY relative_name,

      BEGIN OF _line_item,
        ryear       TYPE /esrcc/ryear,
        poper       TYPE poper,
        fplv        TYPE /esrcc/costdataset_de,
        sysid       TYPE /esrcc/sysid,
        legalentity TYPE /esrcc/legalentity,
        ccode       TYPE /esrcc/ccode_de,
        costobject  TYPE /esrcc/costobject_de,
        costcenter  TYPE /esrcc/costcenter,
        status      TYPE /esrcc/status_de,
      END OF _line_item,

      _line_items TYPE STANDARD TABLE OF _line_item WITH EMPTY KEY,

      BEGIN OF cost_element_mapping_type,
        sysid        TYPE /esrcc/sysid,
        legalentity  TYPE /esrcc/legalentity,
        ccode        TYPE /esrcc/ccode_de,
        costelement  TYPE /esrcc/costelement,
        valid_from   TYPE datn,
        costtype     TYPE /esrcc/costtype_de,
        postingtype  TYPE /esrcc/postingtype_de,
        costind      TYPE /esrcc/costind_de,
        usagetype    TYPE /esrcc/usage,
        valid_to     TYPE datn,
        reason_id    TYPE /esrcc/reasonid,
        value_source TYPE /esrcc/ce_value_source,
      END OF cost_element_mapping_type,

      _cost_elements_mapping_type TYPE STANDARD TABLE OF cost_element_mapping_type WITH EMPTY KEY,

      BEGIN OF _cost_object_type,
        sysid             TYPE /esrcc/sysid,
        legalentity       TYPE /esrcc/legalentity,
        company_code      TYPE /esrcc/ccode_de,
        cost_object       TYPE /esrcc/costobject_de,
        cost_center       TYPE /esrcc/costcenter,
        functional_area   TYPE /esrcc/functional_area,
        profit_center     TYPE /esrcc/profit_center,
        business_division TYPE /esrcc/businessdivision,
      END OF _cosT_OBJECT_TYPE,

      _cost_objects_type TYPE STANDARD TABLE OF _cost_object_type WITH EMPTY KEY.


    DATA:
      _refined_table         TYPE REF TO data,
      _db_table_reader       TYPE REF TO if_xco_database_table,
      _time_stamp            TYPE timestampl,
      _date                  TYPE datn,
      _time                  TYPE timn,
      _group_configuration   TYPE /esrcc/group,
      _cost_elements_mapping TYPE _cost_elements_mapping_type,
      _cost_objects_mapping  TYPE _cost_objects_type,
      _master_data_store     TYPE _master_data_list,
      _key_field_list        TYPE sxco_t_ad_field_names,
      _all_fields_list       TYPE sxco_t_dbt_fields,
      BEGIN OF _table_information,
        name       TYPE tabname,
        components TYPE cl_abap_structdescr=>component_table,
      END OF _table_information.

    METHODS:
      _set_table_info IMPORTING table_name       TYPE tabname
                                table_components TYPE cl_abap_structdescr=>component_table,

      _prepare_master_data IMPORTING table_data TYPE STANDARD TABLE,
      _populate_db_table_reader,

      _validate_row IMPORTING parent_msg_id         TYPE sysuuid_c32
                              row_data              TYPE any
                    RETURNING VALUE(is_valid_entry) TYPE abap_boolean,

      _determine_additional_values IMPORTING parent_msg_id        TYPE sysuuid_c32
                                   CHANGING  row_data             TYPE any
                                   RETURNING VALUE(is_successful) TYPE abap_boolean.
ENDCLASS.


CLASS upload_data_to_db_handler IMPLEMENTATION.
  METHOD create.
    instance = NEW upload_data_to_db_handler( ).
    _application_logger = logger.
  ENDMETHOD.

  METHOD upload_data_to_db~refine_data.
    DATA actual_table TYPE REF TO data.

    FIELD-SYMBOLS <table>        TYPE STANDARD TABLE.
    FIELD-SYMBOLS <actual_table> TYPE STANDARD TABLE.

    ASSIGN uploaded_data->* TO <table>.
    DELETE <table> INDEX 1.

    IF lines( <table> ) = 0.
      " Message: Excel file is empty or not compatible with the table selected.
      _application_logger->add_message(
          log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                 message_type   = 'E'
                                 message_number = 004 ) ).
      RETURN.
    ENDIF.

    CREATE DATA actual_table TYPE STANDARD TABLE OF (table_name).
    ASSIGN actual_table->* TO <actual_table>.

    <actual_table> = CORRESPONDING #( <table> ).

    IF lines( <actual_table> ) = 0.
      " Message: Excel file is empty or not compatible with the table selected.
      _application_logger->add_message(
          log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                 message_type   = 'E'
                                 message_number = 004 ) ).
      RETURN.
    ENDIF.

    _set_table_info( table_name       = table_name
                     table_components = table_components ).

    _populate_db_table_reader( ).

    _prepare_master_data( <actual_table> ).

    FINAL(worksheet_processing_msg_id) = _application_logger->add_message(
        log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                               message_type   = 'I'
                               message_number = 011
                               is_parent      = abap_true ) ).

    CREATE DATA _refined_table TYPE STANDARD TABLE OF (table_name).
    ASSIGN _refined_table->* TO <table>.

    LOOP AT <actual_table> ASSIGNING FIELD-SYMBOL(<data_row>).
      IF NOT _validate_row( parent_msg_id = worksheet_processing_msg_id
                            row_data      = <data_row> ).
        CONTINUE.
      ENDIF.

      IF _determine_additional_values( EXPORTING parent_msg_id = worksheet_processing_msg_id
                                       CHANGING  row_data      = <data_row> ).
        APPEND <data_row> TO <table>.
      ENDIF.
    ENDLOOP.

    _application_logger->add_message( log_message = VALUE #(
                                          message_id     = /esrcc/data_upload_util=>message_class
                                          message_type   = 'I'
                                          message_number = 012 ) ).
    IF <table> IS ASSIGNED AND lines( <table> ) <> 0.
      is_refined = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD upload_data_to_db~update_data_to_db.
    FIELD-SYMBOLS <refined_table> TYPE STANDARD TABLE.

    IF _refined_table IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN _refined_table->* TO <refined_table>.
    IF <refined_table> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF lines( <refined_table> ) = 0.
      RETURN.
    ENDIF.

    MODIFY (_table_information-name) FROM TABLE @<refined_table>.
    IF sy-subrc = 0.
      " Message: Number of records updated.
      FINAL(no_of_records) = sy-dbcnt.
      IF _db_table_reader IS BOUND.
        FINAL(table_technical_name) = _db_table_reader->name.
        FINAL(description) = _db_table_reader->content( )->get_short_description( ).
      ENDIF.
      _application_logger->add_message(
          log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                 message_type   = 'I'
                                 message_number = 005
                                 message_v1     = no_of_records
                                 message_v2     = |{ description } ({ table_technical_name })| ) ).
    ENDIF.
  ENDMETHOD.

  METHOD _set_table_info.
    _table_information = VALUE #( name       = table_name
                                  components = table_components ).
  ENDMETHOD.

  METHOD _prepare_master_data.
    DATA temp_data_table TYPE REF TO data.

    FIELD-SYMBOLS <temp_data_table> TYPE STANDARD TABLE.

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = _time_stamp
                                                            date       = _date
                                                            time       = _time ).

    IF _table_information-name = '/ESRCC/CB_LI'.
      FINAL(cost_bases) = CORRESPONDING _line_items( table_data ).
      SELECT DISTINCT ryear, poper, fplv, sysid, legalentity, ccode, costobject, costcenter, status
        FROM /esrcc/cb_li
        FOR ALL ENTRIES IN @cost_bases
        WHERE ryear       = @cost_bases-ryear
          AND poper       = @cost_bases-poper       AND fplv  = @cost_bases-fplv  AND sysid      = @cost_bases-sysid
          AND legalentity = @cost_bases-legalentity AND ccode = @cost_bases-ccode AND costobject = @cost_bases-costobject
          AND costcenter  = @cost_bases-costcenter
        INTO TABLE @FINAL(_finalized_cost_bases).
      IF sy-subrc = 0.
        DATA(table_handler) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _finalized_cost_bases ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _finalized_cost_bases ).
        INSERT VALUE #( relative_name = '/ESRCC/CB_LI'
                        valid_data    = temp_data_table ) INTO TABLE _master_data_store.
      ENDIF.

      SELECT sysid,
          legal_entity        AS legalentity,
          company_code        AS ccode,
          header~cost_element AS costelement,
          valid_from,
          cost_type           AS costtype,
          posting_type        AS postingtype,
          cost_indicator      AS costind,
          usage_type          AS usagetype,
          valid_to,
          reason_id,
          value_source
     FROM /esrcc/cst_elmnt AS header
            INNER JOIN
              /esrcc/cstelmtch AS matching ON matching~cost_element_uuid = header~cost_element_uuid
     INTO CORRESPONDING FIELDS OF TABLE @_cost_elements_mapping. "#EC CI_NOWHERE

      SELECT sysid,                                     "#EC CI_NOWHERE
            legal_entity,
            company_code,
            cost_object,
            cost_center,
            functional_area,
            profit_center,
            business_division
            FROM /esrcc/cst_objct
            INTO TABLE @_cost_objects_mapping.

      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ENDIF.

    " Build the list of key fields
    IF _db_table_reader IS BOUND.
      _key_field_list = _db_table_reader->fields->key->get_names( ).
      _all_fields_list = _db_table_reader->fields->all->get( ).
    ENDIF.

    LOOP AT _table_information-components ASSIGNING FIELD-SYMBOL(<component>).

      FINAL(relative_name) = <component>-type->get_relative_name( ).
      CASE relative_name.
        WHEN '/ESRCC/LEGALENTITY'.
          IF _table_information-name <> '/ESRCC/LE'.
            SELECT LegalEntity FROM /esrcc/le
              ORDER BY LegalEntity
              INTO TABLE @FINAL(_valid_legal_entites).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_legal_entites ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_legal_entites ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |LEGALENTITY| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTCENTER'.
          IF _table_information-name <> '/ESRCC/CST_OBJCT'.
            SELECT DISTINCT cost_center AS costcenter FROM /esrcc/cst_objct
              ORDER BY costcenter
              INTO TABLE @FINAL(_valid_cost_centers).   "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_cost_centers ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_cost_centers ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |COSTCENTER| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTELEMENT'.
          IF _table_information-name <> '/ESRCC/CST_ELMNT'.
            SELECT DISTINCT Cost_Element AS costelement FROM /esrcc/cst_elmnt
              ORDER BY CostElement
              INTO TABLE @FINAL(_valid_cost_elements).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_cost_elements ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_cost_elements ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |COSTELEMENT| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SYSID'.
          IF _table_information-name <> '/ESRCC/SYS_INFO'.
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
                              field_name    = |SYSTEM_ID| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/CCODE_DE'.
          IF _table_information-name <> '/ESRCC/LE_CCODE'.
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
                              field_name    = |CCODE| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/BUSINESSDIVISION'.
          IF _table_information-name <> '/ESRCC/BUS_DIV'. " AND field_value IS NOT INITIAL.
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
                              field_name    = |BUSINESS_DIVISION| ) INTO TABLE _master_data_store.
            ENDIF.

          ENDIF.
        WHEN '/ESRCC/PROFIT_CENTER'.
          IF _table_information-name <> '/ESRCC/PFC'. " AND field_value IS NOT INITIAL.
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
                              field_name    = |PROFIT_CENTER| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVPRODUCT'.
          IF _table_information-name <> '/ESRCC/SRVPRO'.
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
                              field_name    = |SERVICEPRODUCT| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVTYPE_DE'.
          IF _table_information-name <> '/ESRCC/SRTYPE'.
            SELECT srvtype FROM /esrcc/srtype
                ORDER BY srvtype
                INTO TABLE @FINAL(_valid_service_type). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_service_type ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_service_type ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SRVTYPE| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/TG'.
          IF _table_information-name <> '/ESRCC/SRVTG'.
            SELECT transactiongroup FROM /esrcc/srvtg
                ORDER BY transactiongroup
                INTO TABLE @FINAL(_valid_transaction_group).
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_transaction_group ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_transaction_group ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |TRANSACTIONGROUP| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD _validate_row.
    FIELD-SYMBOLS: <finalized_cost_bases> TYPE _line_items,
                   <valid_value_table>    TYPE STANDARD TABLE.

    DATA(list_of_message_ids) = VALUE /esrcc/if_application_logs=>message_ids_type( ).

    is_valid_entry = abap_true.

    IF _table_information-name = '/ESRCC/CB_LI'.

      FINAL(finalized_cost_bases) = VALUE #( _master_data_store[ relative_name = '/ESRCC/CB_LI' ]-valid_data OPTIONAL ).
      ASSIGN finalized_cost_bases->* TO <finalized_cost_bases>.

      ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO FIELD-SYMBOL(<ryear>).
      ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO FIELD-SYMBOL(<poper>).
      ASSIGN COMPONENT 'FPLV' OF STRUCTURE row_data TO FIELD-SYMBOL(<fplv>).
      ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO FIELD-SYMBOL(<sysid>).
      ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO FIELD-SYMBOL(<legalentity>).
      ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO FIELD-SYMBOL(<ccode>).
      ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE row_data TO FIELD-SYMBOL(<costobject>).
      ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<costcenter>).

      IF     <ryear>       IS ASSIGNED
         AND <poper>       IS ASSIGNED
         AND <fplv>        IS ASSIGNED
         AND <sysid>       IS ASSIGNED
         AND <legalentity> IS ASSIGNED
         AND <ccode>       IS ASSIGNED
         AND <costobject>  IS ASSIGNED
         AND <costcenter>  IS ASSIGNED.

        IF <finalized_cost_bases> IS ASSIGNED AND line_exists( <finalized_cost_bases>[ ryear       = <ryear>
                                                                                       poper       = <poper>
                                                                                       fplv        = <fplv>
                                                                                       sysid       = <sysid>
                                                                                       legalentity = <legalentity>
                                                                                       ccode       = <ccode>
                                                                                       costobject  = <costobject>
                                                                                       costcenter  = <costcenter>
                                                                                       status      = 'F'  ] ).
          is_valid_entry = abap_false.
          _application_logger->add_message(
              log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                        message_type    = 'E'
                                        message_number  = 016
                                        parent_log_uuid = parent_msg_id )
              invalid_record = row_data ).
          RETURN.
        ENDIF.
      ENDIF.

      ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO FIELD-SYMBOL(<hsl>).
      IF <hsl> IS ASSIGNED AND ( <hsl> IS INITIAL OR <hsl> = 0 ).
        " Message: Invalid value for &1. Please check configuration or domain values.
        DATA(message_id) = _application_logger->add_message(
                               log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                      message_type    = 'W'
                                                      message_number  = 015
                                                      parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.

      ENDIF.
    ENDIF.

    LOOP AT _table_information-components ASSIGNING FIELD-SYMBOL(<component>).

      ASSIGN COMPONENT <component>-name OF STRUCTURE row_data TO FIELD-SYMBOL(<field_value>).
      IF <field_value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF <component>-name = 'LOCALCURR' AND <field_value> IS INITIAL.
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = 'E'
                                                message_number  = 021
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        CONTINUE.
      ENDIF.

      IF _table_information-name = '/ESRCC/SRV_CPCTY' AND <component>-name = 'UOM' AND <field_value> IS INITIAL.
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = 'E'
                                                message_number  = 023
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        CONTINUE.
      ENDIF.

      IF NOT line_exists( _key_field_list[ table_line = <component>-name ] ) AND <field_value> IS INITIAL.
        CONTINUE.
      ENDIF.

      FINAL(relative_name) = <component>-type->get_relative_name( ).
      FINAL(master_data_store_index) = line_index( _master_data_store[ relative_name = relative_name ] ).

      IF master_data_store_index IS INITIAL.
        " Check domain
        IF <field_value> IS INITIAL.
          CONTINUE.
        ENDIF.
        FINAL(fixed_values) = CAST cl_abap_elemdescr( <component>-type )->get_ddic_fixed_values( ).
        IF lines( fixed_values ) = 0.
          CONTINUE.
        ENDIF.
        IF NOT line_exists( fixed_values[ low = <field_value> ] ).
          is_valid_entry = abap_false.
          DATA(is_error) = abap_true.
        ENDIF.
      ELSE.
        FINAL(master_data_store) = _master_data_store[ master_data_store_index ].
        ASSIGN master_data_store-valid_data->* TO <valid_value_table>.
        IF NOT line_exists( <valid_value_table>[ (master_data_store-field_name) = <field_value> ] ).
          is_valid_entry = abap_false.
          is_error = abap_true.
        ENDIF.
      ENDIF.
      IF is_error = abap_true.
        " Message: Invalid value for &1. Please check configuration or domain values.
        FINAL(field_description) = _all_fields_list[
                                       table_line->name = <component>-name ]->content( )->get_short_description( ).
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = 'E'
                                                message_number  = 014
                                                message_v1      = |{ field_description } ({ <component>-name })|
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        CLEAR is_error.
      ENDIF.
    ENDLOOP.

    DELETE list_of_message_ids WHERE table_line IS INITIAL.
    _application_logger->map_invalid_record_to_messages( invalid_record = row_data
                                                         message_ids    = list_of_message_ids ).
  ENDMETHOD.

  METHOD _determine_additional_values.
    is_successful = abap_true.
    ASSIGN COMPONENT 'CREATED_AT' OF STRUCTURE row_data TO FIELD-SYMBOL(<created_at>).
    ASSIGN COMPONENT 'CREATED_BY' OF STRUCTURE row_data TO FIELD-SYMBOL(<created_by>).
    ASSIGN COMPONENT 'LAST_CHANGED_BY' OF STRUCTURE row_data TO FIELD-SYMBOL(<last_changed_by>).
    ASSIGN COMPONENT 'LAST_CHANGED_AT' OF STRUCTURE row_data TO FIELD-SYMBOL(<last_changed_at>).

    IF <created_at> IS ASSIGNED.
      <created_at> = _time_stamp.
    ENDIF.
    IF <created_by> IS ASSIGNED.
      <created_by> = sy-uname.
    ENDIF.
    IF <last_changed_at> IS ASSIGNED.
      <last_changed_at> = _time_stamp.
    ENDIF.
    IF <last_changed_by> IS ASSIGNED.
      <last_changed_by> = sy-uname.
    ENDIF.

    IF _table_information-name <> '/ESRCC/CB_LI'.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO FIELD-SYMBOL(<system_id>).
    ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO FIELD-SYMBOL(<ryear>).
    ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO FIELD-SYMBOL(<poper>).
    ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO FIELD-SYMBOL(<legal_entity>).
    ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO FIELD-SYMBOL(<company_code>).
    ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_object>).
    ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_center>).
    ASSIGN COMPONENT 'COSTELEMENT' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_element>).

    IF <system_id> IS NOT ASSIGNED OR <system_id> IS INITIAL OR
       <ryear> IS NOT ASSIGNED OR <ryear> IS INITIAL OR
       <poper> IS NOT ASSIGNED OR <poper> IS INITIAL OR
       <legal_entity> IS NOT ASSIGNED OR <legal_entity> IS INITIAL OR
      <company_code> IS NOT ASSIGNED OR <company_code> IS INITIAL OR
      <cost_object> IS NOT ASSIGNED OR <cost_object> IS INITIAL OR
      <cost_center> IS NOT ASSIGNED OR <cost_center> IS INITIAL OR
      <cost_element> IS NOT ASSIGNED OR <cost_element> IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM @_cost_objects_mapping AS objects WHERE sysid = @<system_id> AND legalentity = @<legal_entity>
       AND company_code = @<company_code> AND  cost_object = @<cost_object> AND cost_center = @<cost_center>
       INTO @DATA(cost_object_mapping).
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'FUNCTIONALAREA' OF STRUCTURE row_data TO FIELD-SYMBOL(<functional_area>).
      IF <functional_area> IS ASSIGNED.
        <functional_area> = cost_object_mapping-functional_area.
        UNASSIGN <functional_area>.
      ENDIF.

      ASSIGN COMPONENT 'BUSINESSDIVISION' OF STRUCTURE row_data TO FIELD-SYMBOL(<business_division>).
      IF <business_division> IS ASSIGNED.
        <business_division> = cost_object_mapping-business_division.
        UNASSIGN <business_division>.
      ENDIF.


      ASSIGN COMPONENT 'PROFITCENTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<profit_center>).
      IF <profit_center> IS ASSIGNED.
        <profit_center> = cost_object_mapping-profit_center.
        UNASSIGN <profit_center>.
      ENDIF.
    ELSE.
      is_successful = abap_false.
      _application_logger->add_message(
          log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                    message_type    = 'E'
                                    message_number  = 025
                                    parent_log_uuid = parent_msg_id )
          invalid_record = row_data ).
    ENDIF.


    FINAL(valid_on) = |{ <ryear> }{ <poper>+1 }01|.
    SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
      WHERE legalentity  = @<legal_entity>
        AND ccode        = @<company_code> AND costelement = @<cost_element> AND valid_from <= @valid_on
        AND valid_to    >= @valid_on
      INTO @FINAL(mapping_information).
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'COSTTYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_type>).
      IF <cost_type> IS ASSIGNED.
        <cost_type> = mapping_information-costtype.
      ENDIF.
      ASSIGN COMPONENT 'COSTIND' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_indicator>).
      IF <cost_indicator> IS ASSIGNED.
        <cost_indicator> = mapping_information-costind.
      ENDIF.
      ASSIGN COMPONENT 'USAGECAL' OF STRUCTURE row_data TO FIELD-SYMBOL(<usage_type>).
      IF <usage_type> IS ASSIGNED.
        <usage_type> = COND #( WHEN mapping_information-usagetype IS INITIAL
                               THEN 'I'
                               ELSE mapping_information-usagetype ).
      ENDIF.
      ASSIGN COMPONENT 'REASONID' OF STRUCTURE row_data TO FIELD-SYMBOL(<reason_id>).
      IF <reason_id> IS ASSIGNED.
        <reason_id> = mapping_information-reason_id.
        UNASSIGN <reason_id>.
      ENDIF.

      ASSIGN COMPONENT 'VALUE_SOURCE' OF STRUCTURE row_data TO FIELD-SYMBOL(<value_source>).
      IF <value_source> IS ASSIGNED.
        <value_source> = mapping_information-value_source.
        UNASSIGN <value_source>.
      ENDIF.
    ELSE.
      is_successful = abap_false.
      _application_logger->add_message(
          log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                    message_type    = 'E'
                                    message_number  = 017
                                    parent_log_uuid = parent_msg_id )
          invalid_record = row_data ).
    ENDIF.

    ASSIGN COMPONENT 'STATUS' OF STRUCTURE row_data TO FIELD-SYMBOL(<status>).
    IF <status> IS ASSIGNED.
      <status> = 'U'.
    ENDIF.

    ASSIGN COMPONENT 'POSTINGTYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<posting_type>).
    ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO FIELD-SYMBOL(<local_amount>).
    IF <posting_type> IS NOT ASSIGNED OR <local_amount> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    <posting_type> = COND /esrcc/postingtype_de( WHEN _group_configuration-cost_sign = '+'
                                                 THEN COND #( WHEN <local_amount> < 0 THEN |INCOME| ELSE |EXPENSE| )
                                                 ELSE COND #( WHEN <local_amount> < 0 THEN |EXPENSE| ELSE |INCOME| ) ).

    ASSIGN COMPONENT 'KSL' OF STRUCTURE row_data TO FIELD-SYMBOL(<group_amount>).
    IF <group_amount> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF <local_amount> = 0.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT 'LOCALCURR' OF STRUCTURE row_data TO FIELD-SYMBOL(<local_currency>).
    IF <local_currency> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    FINAL(last_date) = /esrcc/cl_utility_core=>get_last_day_of_month( date = |{ <ryear> }{ <poper>+1 }01| ).

    TRY.
        cl_exchange_rates=>convert_to_foreign_currency( EXPORTING date             = last_date
                                                                  foreign_currency = _group_configuration-group_currency
                                                                  local_amount     = <local_amount>
                                                                  local_currency   = <local_currency>
                                                        IMPORTING foreign_amount   = <group_amount> ).
      CATCH cx_exchange_rates INTO FINAL(ex_exchange_rates).
        " handle exception
        " TODO: variable is assigned but never used (ABAP cleaner)
        FINAL(text) = ex_exchange_rates->get_text( ).
    ENDTRY.

    ASSIGN COMPONENT 'GROUPCURR' OF STRUCTURE row_data TO FIELD-SYMBOL(<group_currency>).
    IF <group_currency> IS ASSIGNED.
      <group_currency> = _group_configuration-group_currency.
    ENDIF.
  ENDMETHOD.

  METHOD _populate_db_table_reader.
    IF _table_information-name IS INITIAL.
      RETURN.
    ENDIF.

    DATA(db_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
                                 VALUE #( ( xco_cp_abap_repository=>object_name->get_filter(
                                                xco_cp_abap_sql=>constraint->equal( _table_information-name ) ) ) ) )->in(
                                                    xco_cp_abap=>repository )->get( ).

    IF lines( db_table_readers ) > 0.
      _db_table_reader = db_table_readers[ 1 ].
    ENDIF.
  ENDMETHOD.
ENDCLASS.
