
CLASS /esrcc/template_helper DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES:
      /esrcc/if_template_helper.

    CLASS-METHODS:
      create RETURNING VALUE(instance) TYPE REF TO /esrcc/if_template_helper.

  PRIVATE SECTION.
    TYPES:
      _tables_metada_type TYPE STANDARD TABLE OF /esrcc/if_template_helper~table_metadata WITH EMPTY KEY.

    CLASS-DATA:
      _tables_metadata TYPE _tables_metada_type.

    DATA:
      _table_metadata        TYPE /esrcc/if_template_helper~table_metadata,
      _excel_structured_data TYPE REF TO data,
      _enrichment_exit       TYPE REF TO /esrcc/file_upload_utility.

    CLASS-METHODS:
      _register_tables_metadata RETURNING VALUE(tables_metadata) TYPE _tables_metada_type.

    METHODS:
      _extract_table_components IMPORTING table_name        TYPE sxco_ad_object_name
                                RETURNING VALUE(components) TYPE cl_abap_structdescr=>component_table,

      _upload_stewardship          EXPORTING records TYPE i,
      _upload_stwrdshp_srvprod     EXPORTING records TYPE i,
      _upload_stwrdshp_srvprod_rec EXPORTING records TYPE i,
      _upload_indirect_allocation  EXPORTING records TYPE i,
      _upload_consumption          EXPORTING records TYPE i,
      _upload_chargeout_config     EXPORTING records TYPE i,
      _upload_cst_elmnt_charac     EXPORTING records TYPE i,
      _upload_cost_object          EXPORTING records TYPE i,
      _upload_cost_object_desc     EXPORTING records TYPE i,
      _upload_cost_element         EXPORTING records TYPE i,
      _upload_cost_element_desc    EXPORTING records TYPE i,
      _upload_service_capacity     EXPORTING records TYPE i,
      _upload_charge_out_rule      EXPORTING records TYPE i,
      _upload_charge_out_rule_desc EXPORTING records TYPE i,
      _upload_alloc_keys_weight    EXPORTING records TYPE i,
      _upload_service_markup       EXPORTING records TYPE i.
ENDCLASS.



CLASS /ESRCC/TEMPLATE_HELPER IMPLEMENTATION.


  METHOD /esrcc/if_template_helper~check_alias_registered.
    TRY.
        _table_metadata = VALUE #( _tables_metadata[ alias = alias ] OPTIONAL ).
        IF _table_metadata IS NOT INITIAL.
          registered = abap_true.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.


  METHOD /esrcc/if_template_helper~check_table_registered.
    TRY.
        _table_metadata = VALUE #( _tables_metadata[ name = name ] OPTIONAL ).
        IF _table_metadata IS NOT INITIAL.
          registered = abap_true.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.


  METHOD /esrcc/if_template_helper~get_table_alias.
    alias = _table_metadata-alias.
  ENDMETHOD.


  METHOD /esrcc/if_template_helper~get_table_name.
    table_name = _table_metadata-name.
  ENDMETHOD.


  METHOD /esrcc/if_template_helper~upload_template_data.
    _excel_structured_data = excel_structured_data.

    TRY.
        GET BADI _enrichment_exit FILTERS table_name = _table_metadata-name.
      CATCH cx_badi_not_implemented cx_badi_unknown_error cx_badi_initial_reference cx_sy_dyn_call_illegal_method
        INTO FINAL(raised_badi_exception). " TODO: variable is assigned but never used (ABAP cleaner)
    ENDTRY.

    CALL METHOD (_table_metadata-method)
      IMPORTING records = records.
  ENDMETHOD.


  METHOD create.
    instance = NEW /esrcc/template_helper( ).
    _tables_metadata = _register_tables_metadata( ).
  ENDMETHOD.


  METHOD _register_tables_metadata.
    TYPES:
      tables_metadata_type TYPE STANDARD TABLE OF /esrcc/if_template_helper~table_metadata WITH EMPTY KEY.

    APPEND LINES OF VALUE tables_metadata_type( " Stewardship
                                                ( name    = '/ESRCC/STEWRDSHP'
                                                  alias   = '/ESRCC/SWDSP_TMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_OBJCT' ) )
                                                  method  = '_UPLOAD_STEWARDSHIP' )
                                                " Stewardship Service Product
                                                ( name    = '/ESRCC/STWD_SP'
                                                  alias   = '/ESRCC/SWDPRDTMP'
                                                  parents = VALUE #( ( '/ESRCC/STEWRDSHP' ) )
                                                  method  = '_UPLOAD_STWRDSHP_SRVPROD' )
                                                " Stewardship Service Product Receiver
                                                ( name    = '/ESRCC/STWDSPREC'
                                                  alias   = '/ESRCC/SWDRECTMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_OBJCT' )
                                                                     ( '/ESRCC/STEWRDSHP' )
                                                                     ( '/ESRCC/STWD_SP' ) )
                                                  method  = '_UPLOAD_STWRDSHP_SRVPROD_REC' )
                                                " Indirect Allocation Key Values
                                                ( name    = '/ESRCC/INDTALLOC'
                                                  alias   = '/ESRCC/INDALCTMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_OBJCT' ) )
                                                  method  = '_UPLOAD_INDIRECT_ALLOCATION' )
                                                " Allocation Service Consumption
                                                ( name    = '/ESRCC/CONSUMPTN'
                                                  alias   = '/ESRCC/CNSMTNTMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_OBJCT' ) )
                                                  method  = '_UPLOAD_CONSUMPTION' )
                                                " Charge out configuration
                                                ( name    = '/ESRCC/CHARGEOUT'
                                                  alias   = '/ESRCC/CHGOUTTMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_CHARGEOUT_CONFIG' )
                                                " Cost element characteristic
                                                ( name    = '/ESRCC/CSTELMTCH'
                                                  alias   = '/ESRCC/CSTMTCTMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_ELMNT' ) )
                                                  method  = '_UPLOAD_CST_ELMNT_CHARAC'  )
                                                " Cost Object
                                                ( name    = '/ESRCC/CST_OBJCT'
                                                  alias   = '/ESRCC/CSTOBJTMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_COST_OBJECT' )
                                                " Cost Object Description
                                                ( name    = '/ESRCC/CST_OBJTT'
                                                  alias   = '/ESRCC/CSOBJTTMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_OBJCT' ) )
                                                  method  = '_UPLOAD_COST_OBJECT_DESC' )
                                                " Cost Element
                                                ( name    = '/ESRCC/CST_ELMNT'
                                                  alias   = '/ESRCC/CSTELETMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_COST_ELEMENT' )
                                                " Cost Element Description
                                                ( name    = '/ESRCC/CST_ELMTT'
                                                  alias   = '/ESRCC/CSTELTTMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_ELMNT' ) )
                                                  method  = '_UPLOAD_COST_ELEMENT_DESC' )
                                                " Service Capacity
                                                ( name    = '/ESRCC/SRV_CPCTY'
                                                  alias   = '/ESRCC/CPCTY_TMP'
                                                  parents = VALUE #( ( '/ESRCC/CST_OBJCT' ) )
                                                  method  = '_UPLOAD_SERVICE_CAPACITY' )
                                                " Charge-out Rule
                                                ( name    = '/ESRCC/CO_RULE'
                                                  alias   = '/ESRCC/CORULETMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_CHARGE_OUT_RULE' )
                                                " Charge-out Rule Description
                                                ( name    = '/ESRCC/CO_RULET'
                                                  alias   = '/ESRCC/CORULTTMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_CHARGE_OUT_RULE_DESC' )
                                                " Weightage of allocation keys
                                                ( name    = '/ESRCC/ALOC_WGT'
                                                  alias   = '/ESRCC/ALCWGTTMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_ALLOC_KEYS_WEIGHT' )
                                                " Service Markup
                                                ( name    = '/ESRCC/SRVMKP'
                                                  alias   = '/ESRCC/SRVMKPTMP'
                                                  parents = VALUE #( ( ) )
                                                  method  = '_UPLOAD_SERVICE_MARKUP' ) )
           TO tables_metadata.
  ENDMETHOD.


  METHOD _upload_chargeout_config.
    TYPES:
      chargeout_db_type TYPE STANDARD TABLE OF /esrcc/chargeout WITH DEFAULT KEY.

    DATA:
      line               TYPE /esrcc/chgouttmp,
      chargeout_template TYPE STANDARD TABLE OF /esrcc/chgouttmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(components) = _extract_table_components( '/ESRCC/CHGOUTTMP' ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        TRY.
            FINAL(component) = VALUE #( components[ column_index + 1 ] OPTIONAL ).
            DATA(text) = VALUE string( ).
            FINAL(dec_notation) = VALUE xsdboolean( ).
            FINAL(date_frmt) = VALUE xsdboolean( ).
            CALL BADI _enrichment_exit->convert_standard_data_type
              EXPORTING component        = component
                        decimal_notation = dec_notation
                        date_format      = date_frmt
              CHANGING  cell_value       = <sheet_cell_value>
                        message          = text.
            IF text IS NOT INITIAL.
              CLEAR: line.
              EXIT.
            ENDIF.
          CATCH cx_root INTO FINAL(exception). " TODO: variable is assigned but never used (ABAP cleaner)
        ENDTRY.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO chargeout_template.
    ENDLOOP.

    DELETE chargeout_template WHERE serviceproduct IS INITIAL OR validfrom IS INITIAL.
    SORT chargeout_template BY serviceproduct
                               validfrom.
    DELETE ADJACENT DUPLICATES FROM chargeout_template COMPARING serviceproduct validfrom.

    IF lines( chargeout_template ) = 0.
      RETURN.
    ENDIF.

    SELECT uuid,
           serviceproduct,
           validfrom,
           created_by,
           created_at
      FROM /esrcc/chargeout
      FOR ALL ENTRIES IN @chargeout_template
      WHERE serviceproduct = @chargeout_template-serviceproduct
        AND validfrom      = @chargeout_template-validfrom
      INTO TABLE @FINAL(chargeouts).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    TRY.
        MODIFY /esrcc/chargeout FROM TABLE @(
            VALUE chargeout_db_type(
                      FOR <chargeout> IN chargeout_template
                      LET chargeout = VALUE #( chargeouts[ serviceproduct = <chargeout>-serviceproduct
                                                           validfrom      = <chargeout>-validfrom ] OPTIONAL ) IN
                      ( VALUE #( BASE CORRESPONDING #( <chargeout> )
                                 client          = sy-mandt
                                 uuid            = COND #( WHEN chargeout-uuid IS INITIAL
                                                           THEN cl_system_uuid=>create_uuid_x16_static( )
                                                           ELSE chargeout-uuid )
                                 created_by      = COND #( WHEN chargeout-created_by IS INITIAL
                                                           THEN cl_abap_context_info=>get_user_technical_name( )
                                                           ELSE chargeout-created_by )
                                 created_at      = COND #( WHEN chargeout-created_at IS INITIAL
                                                           THEN timestamp
                                                           ELSE chargeout-created_at )
                                 last_changed_by = cl_abap_context_info=>get_user_technical_name( )
                                 last_changed_at = timestamp                                           ) ) ) ).
        IF sy-subrc = 0.
          records = sy-dbcnt.
        ENDIF.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD _upload_consumption.
    TYPES:
      consumption_db_type TYPE STANDARD TABLE OF /esrcc/consumptn WITH DEFAULT KEY.

    DATA:
      line                 TYPE /esrcc/cnsmtntmp,
      consumption_template TYPE STANDARD TABLE OF /esrcc/cnsmtntmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(app_logger) = /esrcc/cl_application_logs=>get_instance( ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO consumption_template.
    ENDLOOP.

    DELETE consumption_template WHERE    sysid        IS INITIAL OR legal_entity    IS INITIAL
                                      OR company_code IS INITIAL OR cost_object     IS INITIAL
                                      OR cost_center  IS INITIAL OR service_product IS INITIAL.
    SORT consumption_template BY sysid
                                 legal_entity
                                 company_code
                                 cost_object
                                 cost_center
                                 service_product
                                 ryear
                                 poper
                                 fplv
                                 provider_sysid
                                 provider_legal_entity
                                 provider_company_code
                                 provider_cost_object
                                 provider_cost_center.
    DELETE ADJACENT DUPLICATES FROM consumption_template
           COMPARING sysid legal_entity company_code cost_object cost_center service_product ryear poper fplv provider_sysid provider_legal_entity provider_company_code provider_cost_object provider_cost_center.
    IF lines( consumption_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @consumption_template
      WHERE sysid        = @consumption_template-sysid
        AND legal_entity = @consumption_template-legal_entity
        AND company_code = @consumption_template-company_code
        AND cost_object  = @consumption_template-cost_object
        AND cost_center  = @consumption_template-cost_center
      INTO TABLE @FINAL(cost_objects).

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @consumption_template
      WHERE sysid        = @consumption_template-provider_sysid
        AND legal_entity = @consumption_template-provider_legal_entity
        AND company_code = @consumption_template-provider_company_code
        AND cost_object  = @consumption_template-provider_cost_object
        AND cost_center  = @consumption_template-provider_cost_center
      INTO TABLE @FINAL(providers).

    SELECT
      FROM /esrcc/srvpro AS product
             INNER JOIN
               @consumption_template AS template ON product~serviceproduct = template~service_product
      FIELDS product~serviceproduct
      INTO TABLE @FINAL(products).

    SELECT direct_allocation_uuid,
           object~cost_object_uuid,
           object~sysid,
           object~legal_entity,
           object~company_code,
           object~cost_object,
           object~cost_center,
           consumption~service_product,
           consumption~ryear,
           consumption~poper,
           consumption~fplv,
           provider~cost_object_uuid   AS provider_cost_object_uuid,
           provider~sysid              AS provider_system_id,
           provider~legal_entity       AS provider_legal_entity,
           provider~company_code       AS provider_company_code,
           provider~cost_object        AS provider_cost_object,
           provider~cost_center        AS provider_cost_center,
           consumption~created_by,
           consumption~created_at
      FROM /esrcc/consumptn AS consumption
             INNER JOIN
               /esrcc/cst_objct AS object ON object~cost_object_uuid = consumption~cost_object_uuid
                 INNER JOIN
                   /esrcc/cst_objct AS provider ON provider~cost_object_uuid = consumption~provider_cost_object_uuid
                     INNER JOIN
                       @consumption_template AS template ON  template~sysid                 = object~sysid
                                                         AND template~legal_entity          = object~legal_entity
                                                         AND template~company_code          = object~company_code
                                                         AND template~cost_object           = object~cost_object
                                                         AND template~cost_center           = object~cost_center
                                                         AND template~service_product       = consumption~service_product
                                                         AND template~ryear                 = consumption~ryear
                                                         AND template~poper                 = consumption~poper
                                                         AND template~fplv                  = consumption~fplv
                                                         AND template~provider_sysid        = provider~sysid
                                                         AND template~provider_legal_entity = provider~legal_entity
                                                         AND template~company_code          = provider~company_code
                                                         AND template~cost_object           = provider~cost_object
                                                         AND template~cost_center           = provider~cost_center
      INTO TABLE @FINAL(consumptions).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    DATA(consumption_db) = VALUE consumption_db_type( ).
    LOOP AT consumption_template ASSIGNING FIELD-SYMBOL(<consumption>).
      FINAL(consumption)      = VALUE #( consumptions[ sysid                 = <consumption>-sysid
                                                       legal_entity          = <consumption>-legal_entity
                                                       company_code          = <consumption>-company_code
                                                       cost_object           = <consumption>-cost_object
                                                       cost_center           = <consumption>-cost_center
                                                       service_product       = <consumption>-service_product
                                                       ryear                 = <consumption>-ryear
                                                       poper                 = <consumption>-poper
                                                       fplv                  = <consumption>-fplv
                                                       provider_system_id    = <consumption>-provider_sysid
                                                       provider_legal_entity = <consumption>-provider_legal_entity
                                                       provider_company_code = <consumption>-provider_company_code
                                                       provider_cost_object  = <consumption>-provider_cost_object
                                                       provider_cost_center  = <consumption>-provider_cost_center ] OPTIONAL ).

      FINAL(cost_object_uuid) = VALUE #( cost_objects[ sysid        = <consumption>-sysid
                                                       legal_entity = <consumption>-legal_entity
                                                       company_code = <consumption>-company_code
                                                       cost_object  = <consumption>-cost_object
                                                       cost_center  = <consumption>-cost_center ]-cost_object_uuid OPTIONAL ).
      FINAL(provider_cost_object_uuid) = VALUE #( providers[
                                                      sysid        = <consumption>-provider_sysid
                                                      legal_entity = <consumption>-provider_legal_entity
                                                      company_code = <consumption>-provider_company_code
                                                      cost_object  = <consumption>-provider_cost_object
                                                      cost_center  = <consumption>-provider_cost_center ]-cost_object_uuid OPTIONAL ).

      FINAL(service_product) = VALUE #( products[ serviceproduct = <consumption>-service_product ]-serviceproduct OPTIONAL ).
      IF cost_object_uuid IS INITIAL.
*        app_logger->add_message( log_message    = VALUE #( message_id     = /esrcc/if_file_upload_handler=>message_class
*                                                           message_type   = 'E'
*                                                           message_number = 020 )
*                                 invalid_record = <consumption> ).

      ELSEIF provider_cost_object_uuid IS INITIAL.
*        app_logger->add_message( log_message    = VALUE #( message_id     = /esrcc/if_file_upload_handler=>message_class
*                                                           message_type   = 'E'
*                                                           message_number = 019 )
*                                 invalid_record = <consumption> ).
      ELSEIF <consumption>-uom IS INITIAL.
*        app_logger->add_message( log_message    = VALUE #( message_id     = /esrcc/if_file_upload_handler=>message_class
*                                                           message_type   = 'E'
*                                                           message_number = 023 )
*                                 invalid_record = <consumption> ).
      ELSEIF service_product IS INITIAL.
*        app_logger->add_message( log_message    = VALUE #( message_id     = /esrcc/if_file_upload_handler=>message_class
*                                                           message_type   = 'E'
*                                                           message_number = 024 )
*                                 invalid_record = <consumption> ).
      ELSE.
        TRY.
            APPEND VALUE #( BASE CORRESPONDING #( <consumption> )
                            client                    = sy-mandt
                            direct_allocation_uuid    = COND #( WHEN consumption-direct_allocation_uuid IS INITIAL
                                                                THEN cl_system_uuid=>create_uuid_x16_static( )
                                                                ELSE consumption-direct_allocation_uuid )
                            cost_object_uuid          = cost_object_uuid
                            provider_cost_object_uuid = provider_cost_object_uuid
                            created_by                = COND #( WHEN consumption-created_by IS INITIAL
                                                                THEN cl_abap_context_info=>get_user_technical_name( )
                                                                ELSE consumption-created_by )
                            created_at                = COND #( WHEN consumption-created_at IS INITIAL
                                                                THEN timestamp
                                                                ELSE consumption-created_at )
                            last_changed_by           = cl_abap_context_info=>get_user_technical_name( )
                            last_changed_at           = timestamp                                           ) TO consumption_db.
          CATCH cx_uuid_error.
            " handle exception
        ENDTRY.
      ENDIF.
    ENDLOOP.
*    DATA(consumption_db) = VALUE consumption_db_type(
*        FOR <consumption> IN consumption_template
*        LET consumption               = VALUE #( consumptions[
*                                                     sysid                 = <consumption>-sysid
*                                                     legal_entity          = <consumption>-legal_entity
*                                                     company_code          = <consumption>-company_code
*                                                     cost_object           = <consumption>-cost_object
*                                                     cost_center           = <consumption>-cost_center
*                                                     service_product       = <consumption>-service_product
*                                                     ryear                 = <consumption>-ryear
*                                                     poper                 = <consumption>-poper
*                                                     fplv                  = <consumption>-fplv
*                                                     provider_system_id    = <consumption>-provider_sysid
*                                                     provider_legal_entity = <consumption>-provider_legal_entity
*                                                     provider_company_code = <consumption>-provider_company_code
*                                                     provider_cost_object  = <consumption>-provider_cost_object
*                                                     provider_cost_center  = <consumption>-provider_cost_center ] OPTIONAL )
*            cost_object_uuid          = VALUE #( cost_objects[
*                                                     sysid        = <consumption>-sysid
*                                                     legal_entity = <consumption>-legal_entity
*                                                     company_code = <consumption>-company_code
*                                                     cost_object  = <consumption>-cost_object
*                                                     cost_center  = <consumption>-cost_center ]-cost_object_uuid OPTIONAL )
*            provider_cost_object_uuid = VALUE #( providers[
*                                                     sysid        = <consumption>-provider_sysid
*                                                     legal_entity = <consumption>-provider_legal_entity
*                                                     company_code = <consumption>-provider_company_code
*                                                     cost_object  = <consumption>-provider_cost_object
*                                                     cost_center  = <consumption>-provider_cost_center ]-cost_object_uuid OPTIONAL ) IN
*        ( VALUE #( BASE CORRESPONDING #( <consumption> )
*                   client                    = sy-mandt
*                   direct_allocation_uuid    = COND #( WHEN consumption-direct_allocation_uuid IS INITIAL
*                                                       THEN cl_system_uuid=>create_uuid_x16_static( )
*                                                       ELSE consumption-direct_allocation_uuid )
*                   cost_object_uuid          = cost_object_uuid
*                   provider_cost_object_uuid = provider_cost_object_uuid
*                   created_by                = COND #( WHEN consumption-created_by IS INITIAL
*                                                       THEN cl_abap_context_info=>get_user_technical_name( )
*                                                       ELSE consumption-created_by )
*                   created_at                = COND #( WHEN consumption-created_at IS INITIAL
*                                                       THEN timestamp
*                                                       ELSE consumption-created_at )
*                   last_changed_by           = cl_abap_context_info=>get_user_technical_name( )
*                   last_changed_at           = timestamp                                           ) ) ).
*
*    DELETE consumption_db WHERE cost_object_uuid IS INITIAL OR provider_cost_object_uuid IS INITIAL.
    MODIFY /esrcc/consumptn FROM TABLE @consumption_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
    app_logger->save_header_and_messages( ).
  ENDMETHOD.


  METHOD _upload_cost_element.
    TYPES:
      element_db_type TYPE STANDARD TABLE OF /esrcc/cst_elmnt WITH DEFAULT KEY.

    DATA:
      line             TYPE /esrcc/csteletmp,
      element_template TYPE STANDARD TABLE OF /esrcc/csteletmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO element_template.
    ENDLOOP.

    DELETE element_template WHERE    sysid        IS INITIAL OR legal_entity IS INITIAL
                                  OR company_code IS INITIAL OR cost_element IS INITIAL.
    SORT element_template BY sysid
                             legal_entity
                             company_code
                             cost_element.
    DELETE ADJACENT DUPLICATES FROM element_template COMPARING sysid legal_entity company_code cost_element.
    IF lines( element_template ) = 0.
      RETURN.
    ENDIF.

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).
    SELECT cost_element_uuid,
           sysid,
           legal_entity,
           company_code,
           cost_element,
           created_by,
           created_at
      FROM /esrcc/cst_elmnt
      FOR ALL ENTRIES IN @element_template
      WHERE sysid        = @element_template-sysid
        AND legal_entity = @element_template-legal_entity
        AND company_code = @element_template-company_code
        AND cost_element = @element_template-cost_element
      INTO TABLE @FINAL(cost_elements).

    TRY.
        MODIFY /esrcc/cst_elmnt FROM TABLE @(
            VALUE element_db_type(
                      FOR <element> IN element_template
                      LET cost_element = VALUE #( cost_elements[ sysid        = <element>-sysid
                                                                 legal_entity = <element>-legal_entity
                                                                 company_code = <element>-company_code
                                                                 cost_element = <element>-cost_element ] OPTIONAL ) IN
                      ( VALUE #( BASE CORRESPONDING #( <element> )
                                 client            = sy-mandt
                                 cost_element_uuid = COND #( WHEN cost_element-cost_element_uuid IS INITIAL
                                                             THEN cl_system_uuid=>create_uuid_x16_static( )
                                                             ELSE cost_element-cost_element_uuid )
                                 created_by        = COND #( WHEN cost_element-created_by IS INITIAL
                                                             THEN cl_abap_context_info=>get_user_technical_name( )
                                                             ELSE cost_element-created_by )
                                 created_at        = COND #( WHEN cost_element-created_at IS INITIAL
                                                             THEN timestamp
                                                             ELSE cost_element-created_at )
                                 last_changed_by   = cl_abap_context_info=>get_user_technical_name( )
                                 last_changed_at   = timestamp                                           ) ) ) ).
        IF sy-subrc = 0.
          records = sy-dbcnt.
        ENDIF.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD _upload_cost_element_desc.
    TYPES:
      description_db_type TYPE STANDARD TABLE OF /esrcc/cst_elmtt WITH DEFAULT KEY.

    DATA:
      line                 TYPE /esrcc/cstelttmp,
      description_template TYPE STANDARD TABLE OF /esrcc/cstelttmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO description_template.
    ENDLOOP.

    DELETE description_template WHERE    sysid        IS INITIAL OR legal_entity IS INITIAL
                                      OR company_code IS INITIAL OR cost_element IS INITIAL
                                      OR spras        IS INITIAL.
    SORT description_template BY sysid
                                 legal_entity
                                 company_code
                                 cost_element
                                 spras.
    DELETE ADJACENT DUPLICATES FROM description_template COMPARING sysid legal_entity company_code cost_element spras.

    IF lines( description_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_element_uuid, sysid, legal_entity, company_code, cost_element
      FROM /esrcc/cst_elmnt
      FOR ALL ENTRIES IN @description_template
      WHERE sysid        = @description_template-sysid
        AND legal_entity = @description_template-legal_entity
        AND company_code = @description_template-company_code
        AND cost_element = @description_template-cost_element
      INTO TABLE @FINAL(cost_elements).

    DATA(description_db) = VALUE description_db_type(
        FOR <description> IN description_template
        ( VALUE #(
              BASE CORRESPONDING #( <description> )
              client            = sy-mandt
              cost_element_uuid = VALUE #( cost_elements[ sysid        = <description>-sysid
                                                          legal_entity = <description>-legal_entity
                                                          company_code = <description>-company_code
                                                          cost_element = <description>-cost_element ]-cost_element_uuid OPTIONAL ) ) ) ).

    DELETE description_db WHERE cost_element_uuid IS INITIAL.
    MODIFY /esrcc/cst_elmtt FROM TABLE @description_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_cost_object.
    TYPES:
      object_db_type TYPE STANDARD TABLE OF /esrcc/cst_objct WITH DEFAULT KEY.

    DATA:
      line            TYPE /esrcc/cstobjtmp,
      object_template TYPE STANDARD TABLE OF /esrcc/cstobjtmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO object_template.
    ENDLOOP.

    DELETE object_template WHERE    sysid        IS INITIAL OR legal_entity IS INITIAL
                                 OR company_code IS INITIAL OR cost_object  IS INITIAL
                                 OR cost_center  IS INITIAL.
    SORT object_template BY sysid
                            legal_entity
                            company_code
                            cost_object
                            cost_center.
    DELETE ADJACENT DUPLICATES FROM object_template COMPARING sysid legal_entity company_code cost_object cost_center.

    IF lines( object_template ) = 0.
      RETURN.
    ENDIF.

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    SELECT cost_object_uuid,
           sysid,
           legal_entity,
           company_code,
           cost_object,
           cost_center,
           created_by,
           created_at
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @object_template
      WHERE sysid        = @object_template-sysid
        AND legal_entity = @object_template-legal_entity
        AND company_code = @object_template-company_code
        AND cost_object  = @object_template-cost_object
        AND cost_center  = @object_template-cost_center
      INTO TABLE @FINAL(cost_objects).

    TRY.
        MODIFY /esrcc/cst_objct FROM TABLE @(
            VALUE object_db_type(
                      FOR <object> IN object_template
                      LET cost_object = VALUE #( cost_objects[ sysid        = <object>-sysid
                                                               legal_entity = <object>-legal_entity
                                                               company_code = <object>-company_code
                                                               cost_object  = <object>-cost_object
                                                               cost_center  = <object>-cost_center ] OPTIONAL ) IN
                      ( VALUE #( BASE CORRESPONDING #( <object> )
                                 client           = sy-mandt
                                 cost_object_uuid = COND #( WHEN cost_object-cost_object_uuid IS INITIAL
                                                            THEN cl_system_uuid=>create_uuid_x16_static( )
                                                            ELSE cost_object-cost_object_uuid )
                                 created_by       = COND #( WHEN cost_object-created_by IS INITIAL
                                                            THEN cl_abap_context_info=>get_user_technical_name( )
                                                            ELSE cost_object-created_by )
                                 created_at       = COND #( WHEN cost_object-created_at IS INITIAL
                                                            THEN timestamp
                                                            ELSE cost_object-created_at )
                                 last_changed_by  = cl_abap_context_info=>get_user_technical_name( )
                                 last_changed_at  = timestamp                                           ) ) ) ).
        IF sy-subrc = 0.
          records = sy-dbcnt.
        ENDIF.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD _upload_cost_object_desc.
    TYPES:
      description_db_type TYPE STANDARD TABLE OF /esrcc/cst_objtt WITH DEFAULT KEY.

    DATA:
      line                 TYPE /esrcc/csobjttmp,
      description_template TYPE STANDARD TABLE OF /esrcc/csobjttmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO description_template.
    ENDLOOP.

    DELETE description_template WHERE    sysid        IS INITIAL OR legal_entity IS INITIAL
                                      OR company_code IS INITIAL OR cost_object  IS INITIAL
                                      OR cost_center  IS INITIAL OR spras        IS INITIAL.
    SORT description_template BY sysid
                                 legal_entity
                                 company_code
                                 cost_object
                                 cost_center
                                 spras.
    DELETE ADJACENT DUPLICATES FROM description_template COMPARING sysid legal_entity company_code cost_object cost_center spras.

    IF lines( description_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @description_template
      WHERE sysid        = @description_template-sysid
        AND legal_entity = @description_template-legal_entity
        AND company_code = @description_template-company_code
        AND cost_object  = @description_template-cost_object
        AND cost_center  = @description_template-cost_center
      INTO TABLE @FINAL(cost_objects).

    DATA(description_db) = VALUE description_db_type(
        FOR <description> IN description_template
        ( VALUE #(
              BASE CORRESPONDING #( <description> )
              client           = sy-mandt
              cost_object_uuid = VALUE #( cost_objects[ sysid        = <description>-sysid
                                                        legal_entity = <description>-legal_entity
                                                        company_code = <description>-company_code
                                                        cost_object  = <description>-cost_object
                                                        cost_center  = <description>-cost_center ]-cost_object_uuid OPTIONAL ) ) ) ).

    DELETE description_db WHERE cost_object_uuid IS INITIAL.
    MODIFY /esrcc/cst_objtt FROM TABLE @description_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_cst_elmnt_charac.
    TYPES:
      characteristic_db_type TYPE STANDARD TABLE OF /esrcc/cstelmtch WITH DEFAULT KEY.

    DATA:
      line                    TYPE /esrcc/cstmtctmp,
      characteristic_template TYPE STANDARD TABLE OF /esrcc/cstmtctmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(components) = _extract_table_components( '/ESRCC/CSTMTCTMP' ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        TRY.
            FINAL(component) = VALUE #( components[ column_index + 1 ] OPTIONAL ).
            DATA(text) = VALUE string( ).
            FINAL(dec_notation) = VALUE xsdboolean( ).
            FINAL(date_frmt) = VALUE xsdboolean( ).
            CALL BADI _enrichment_exit->convert_standard_data_type
              EXPORTING component        = component
                        decimal_notation = dec_notation
                        date_format      = date_frmt
              CHANGING  cell_value       = <sheet_cell_value>
                        message          = text.
            IF text IS NOT INITIAL.
              CLEAR: line.
              EXIT.
            ENDIF.
          CATCH cx_root INTO FINAL(exception). " TODO: variable is assigned but never used (ABAP cleaner)
        ENDTRY.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO characteristic_template.
    ENDLOOP.

    DELETE characteristic_template WHERE    sysid        IS INITIAL OR legal_entity IS INITIAL
                                         OR company_code IS INITIAL OR cost_element IS INITIAL OR valid_from IS INITIAL.
    SORT characteristic_template BY sysid
                                    legal_entity
                                    company_code
                                    cost_element
                                    valid_from.
    DELETE ADJACENT DUPLICATES FROM characteristic_template
           COMPARING sysid legal_entity company_code cost_element valid_from.
    IF lines( characteristic_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_element_uuid, sysid, legal_entity, company_code, cost_element
      FROM /esrcc/cst_elmnt
      FOR ALL ENTRIES IN @characteristic_template
      WHERE sysid        = @characteristic_template-sysid
        AND legal_entity = @characteristic_template-legal_entity
        AND company_code = @characteristic_template-company_code
        AND cost_element = @characteristic_template-cost_element
      INTO TABLE @FINAL(cost_elements).

    SELECT cst_elmnt_char_uuid,
           cost_element~sysid,
           cost_element~legal_entity,
           cost_element~company_code,
           cost_element~cost_element,
           characteristic~valid_from,
           characteristic~created_by,
           characteristic~created_at
      FROM /esrcc/cstelmtch AS characteristic
             INNER JOIN
               /esrcc/cst_elmnt AS cost_element ON cost_element~cost_element_uuid = characteristic~cost_element_uuid
                 INNER JOIN
                   @characteristic_template AS template ON  template~sysid        = cost_element~sysid
                                                        AND template~legal_entity = cost_element~legal_entity
                                                        AND template~company_code = cost_element~company_code
                                                        AND template~cost_element = cost_element~cost_element
                                                        AND template~valid_from   = characteristic~valid_from
      INTO TABLE @FINAL(characteristics).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    TRY.
        DATA(characteristic_db) = VALUE characteristic_db_type(
            FOR <characteristic> IN characteristic_template
            LET characteristic    = VALUE #( characteristics[ sysid        = <characteristic>-sysid
                                                              legal_entity = <characteristic>-legal_entity
                                                              company_code = <characteristic>-company_code
                                                              cost_element = <characteristic>-cost_element
                                                              valid_from   = <characteristic>-valid_from ] OPTIONAL )
                cost_element_uuid = VALUE #( cost_elements[
                                                 sysid        = <characteristic>-sysid
                                                 legal_entity = <characteristic>-legal_entity
                                                 company_code = <characteristic>-company_code
                                                 cost_element = <characteristic>-cost_element ]-cost_element_uuid OPTIONAL ) IN
            ( VALUE #( BASE CORRESPONDING #( <characteristic> )
                       client              = sy-mandt
                       cst_elmnt_char_uuid = COND #( WHEN characteristic-cst_elmnt_char_uuid IS INITIAL
                                                     THEN cl_system_uuid=>create_uuid_x16_static( )
                                                     ELSE characteristic-cst_elmnt_char_uuid )
                       cost_element_uuid   = cost_element_uuid
                       created_by          = COND #( WHEN characteristic-created_by IS INITIAL
                                                     THEN cl_abap_context_info=>get_user_technical_name( )
                                                     ELSE characteristic-created_by )
                       created_at          = COND #( WHEN characteristic-created_at IS INITIAL
                                                     THEN timestamp
                                                     ELSE characteristic-created_at )
                       last_changed_by     = cl_abap_context_info=>get_user_technical_name( )
                       last_changed_at     = timestamp ) ) ).
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.

    DELETE characteristic_db WHERE cost_element_uuid IS INITIAL.
    MODIFY /esrcc/cstelmtch FROM TABLE @characteristic_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_indirect_allocation.
    TYPES:
      allocation_db_type TYPE STANDARD TABLE OF /esrcc/indtalloc WITH DEFAULT KEY.

    DATA:
      line                TYPE /esrcc/indalctmp,
      allocation_template TYPE STANDARD TABLE OF /esrcc/indalctmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(app_logger) = /esrcc/cl_application_logs=>get_instance( ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO allocation_template.
    ENDLOOP.

    DELETE allocation_template WHERE    sysid        IS INITIAL OR legal_entity IS INITIAL
                                     OR company_code IS INITIAL OR cost_object  IS INITIAL
                                     OR cost_center  IS INITIAL.
    SORT allocation_template BY sysid
                                legal_entity
                                company_code
                                cost_object
                                cost_center
                                ryear
                                poper
                                allocation_key
                                fplv.
    DELETE ADJACENT DUPLICATES FROM allocation_template COMPARING sysid legal_entity company_code cost_object cost_center ryear poper allocation_key fplv.
    IF lines( allocation_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @allocation_template
      WHERE sysid        = @allocation_template-sysid
        AND legal_entity = @allocation_template-legal_entity
        AND company_code = @allocation_template-company_code
        AND cost_object  = @allocation_template-cost_object
        AND cost_center  = @allocation_template-cost_center
      INTO TABLE @FINAL(cost_objects).

    SELECT indirect_allocation_uuid,
           objects~cost_object_uuid,
           objects~sysid,
           objects~legal_entity,
           objects~company_code,
           objects~cost_object,
           objects~cost_center,
           allocation~ryear,
           allocation~poper,
           allocation~allocation_key,
           allocation~fplv,
           allocation~created_by,
           allocation~created_at
      FROM /esrcc/indtalloc AS allocation
             INNER JOIN
               /esrcc/cst_objct AS objects ON allocation~cost_object_uuid = objects~cost_object_uuid
                 INNER JOIN
                   @allocation_template AS template ON  template~sysid          = objects~sysid
                                                    AND template~legal_entity   = objects~legal_entity
                                                    AND template~company_code   = objects~company_code
                                                    AND template~cost_object    = objects~cost_object
                                                    AND template~cost_center    = objects~cost_center
                                                    AND template~ryear          = allocation~ryear
                                                    AND template~poper          = allocation~poper
                                                    AND template~allocation_key = allocation~allocation_key
                                                    AND template~fplv           = allocation~fplv
      INTO TABLE @FINAL(allocations).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    DATA(allocatoin_db) = VALUE allocation_db_type( ).
    LOOP AT allocation_template ASSIGNING FIELD-SYMBOL(<allocation>).
      FINAL(allocation)       = VALUE #( allocations[ sysid          = <allocation>-sysid
                                                      legal_entity   = <allocation>-legal_entity
                                                      company_code   = <allocation>-company_code
                                                      cost_object    = <allocation>-cost_object
                                                      cost_center    = <allocation>-cost_center
                                                      ryear          = <allocation>-ryear
                                                      poper          = <allocation>-poper
                                                      allocation_key = <allocation>-allocation_key
                                                      fplv           = <allocation>-fplv ] OPTIONAL ).
      FINAL(cost_object_uuid) = VALUE #( cost_objects[ sysid        = <allocation>-sysid
                                                       legal_entity = <allocation>-legal_entity
                                                       company_code = <allocation>-company_code
                                                       cost_object  = <allocation>-cost_object
                                                       cost_center  = <allocation>-cost_center ]-cost_object_uuid OPTIONAL ).
      IF cost_object_uuid IS INITIAL.
*        app_logger->add_message( log_message    = VALUE #( message_id     = /esrcc/if_file_upload_handler=>message_class
*                                                           message_type   = 'E'
*                                                           message_number = 018 )
*                                 invalid_record = <allocation> ).

      ELSEIF <allocation>-currency IS INITIAL.
*        app_logger->add_message( log_message    = VALUE #( message_id     = /esrcc/if_file_upload_handler=>message_class
*                                                           message_type   = 'E'
*                                                           message_number = 021 )
*                                 invalid_record = <allocation> ).
      ELSE.
        /esrcc/cl_utility_core=>curr_external_to_internal( EXPORTING currency        = <allocation>-currency
                                                                     amount_external = <allocation>-value
                                                           IMPORTING amount_internal = <allocation>-value ).
        TRY.
            APPEND VALUE #( BASE CORRESPONDING #( <allocation> )
                            client                   = sy-mandt
                            indirect_allocation_uuid = COND #( WHEN allocation-indirect_allocation_uuid IS INITIAL
                                                               THEN cl_system_uuid=>create_uuid_x16_static( )
                                                               ELSE allocation-indirect_allocation_uuid )
                            cost_object_uuid         = cost_object_uuid
                            created_by               = COND #( WHEN allocation-created_by IS INITIAL
                                                               THEN cl_abap_context_info=>get_user_technical_name( )
                                                               ELSE allocation-created_by )
                            created_at               = COND #( WHEN allocation-created_at IS INITIAL
                                                               THEN timestamp
                                                               ELSE allocation-created_at )
                            last_changed_by          = cl_abap_context_info=>get_user_technical_name( )
                            last_changed_at          = timestamp                                           ) TO allocatoin_db.
          CATCH cx_uuid_error.
            " handle exception
        ENDTRY.
      ENDIF.

    ENDLOOP.

*    DATA(allocatoin_db) = VALUE allocation_db_type(
*        FOR <allocation> IN allocation_template
*        LET allocation       = VALUE #( allocations[ sysid          = <allocation>-sysid
*                                                     legal_entity   = <allocation>-legal_entity
*                                                     company_code   = <allocation>-company_code
*                                                     cost_object    = <allocation>-cost_object
*                                                     cost_center    = <allocation>-cost_center
*                                                     ryear          = <allocation>-ryear
*                                                     poper          = <allocation>-poper
*                                                     allocation_key = <allocation>-allocation_key
*                                                     fplv           = <allocation>-fplv ] OPTIONAL )
*            cost_object_uuid = VALUE #( cost_objects[ sysid        = <allocation>-sysid
*                                                      legal_entity = <allocation>-legal_entity
*                                                      company_code = <allocation>-company_code
*                                                      cost_object  = <allocation>-cost_object
*                                                      cost_center  = <allocation>-cost_center ]-cost_object_uuid OPTIONAL )                                                                    IN
*        ( VALUE #( BASE CORRESPONDING #( <allocation> )
*                   client                   = sy-mandt
*                   indirect_allocation_uuid = COND #( WHEN allocation-indirect_allocation_uuid IS INITIAL
*                                                      THEN cl_system_uuid=>create_uuid_x16_static( )
*                                                      ELSE allocation-indirect_allocation_uuid )
*                   cost_object_uuid         = cost_object_uuid
*                   created_by               = COND #( WHEN allocation-created_by IS INITIAL
*                                                      THEN cl_abap_context_info=>get_user_technical_name( )
*                                                      ELSE allocation-created_by )
*                   created_at               = COND #( WHEN allocation-created_at IS INITIAL
*                                                      THEN timestamp
*                                                      ELSE allocation-created_at )
*                   last_changed_by          = cl_abap_context_info=>get_user_technical_name( )
*                   last_changed_at          = timestamp                                           ) ) ).
*
*    DELETE allocatoin_db WHERE cost_object_uuid IS INITIAL.
    MODIFY /esrcc/indtalloc FROM TABLE @allocatoin_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
    app_logger->save_header_and_messages( ).
  ENDMETHOD.


  METHOD _upload_service_capacity.
    TYPES:
      capoacity_db_type TYPE STANDARD TABLE OF /esrcc/srv_cpcty WITH DEFAULT KEY.

    DATA:
      line              TYPE /esrcc/cpcty_tmp,
      capacity_template TYPE STANDARD TABLE OF /esrcc/cpcty_tmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO capacity_template.
    ENDLOOP.

    DELETE capacity_template WHERE    sysid        IS INITIAL OR legal_entity    IS INITIAL
                                   OR company_code IS INITIAL OR cost_object     IS INITIAL
                                   OR cost_center  IS INITIAL OR service_product IS INITIAL.
    SORT capacity_template BY sysid
                              legal_entity
                              company_code
                              cost_object
                              cost_center
                              service_product
                              ryear
                              poper
                              fplv.
    DELETE ADJACENT DUPLICATES FROM capacity_template
           COMPARING sysid legal_entity company_code cost_object cost_center service_product ryear poper fplv.
    IF lines( capacity_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @capacity_template
      WHERE sysid        = @capacity_template-sysid
        AND legal_entity = @capacity_template-legal_entity
        AND company_code = @capacity_template-company_code
        AND cost_object  = @capacity_template-cost_object
        AND cost_center  = @capacity_template-cost_center
      INTO TABLE @FINAL(cost_objects).

    SELECT serviceproduct AS service_product
      FROM /esrcc/srvpro
      FOR ALL ENTRIES IN @capacity_template
      WHERE serviceproduct = @capacity_template-service_product
      INTO TABLE @FINAL(service_products).

    SELECT capacity_uuid,
           object~cost_object_uuid,
           object~sysid,
           object~legal_entity,
           object~company_code,
           object~cost_object,
           object~cost_center,
           capacity~service_product,
           capacity~ryear,
           capacity~poper,
           capacity~fplv,
           capacity~created_by,
           capacity~created_at
      FROM /esrcc/srv_cpcty AS capacity
             INNER JOIN
               /esrcc/cst_objct AS object ON object~cost_object_uuid = capacity~cost_object_uuid
                 INNER JOIN
                   @capacity_template AS template ON  template~sysid           = object~sysid
                                                  AND template~legal_entity    = object~legal_entity
                                                  AND template~company_code    = object~company_code
                                                  AND template~cost_object     = object~cost_object
                                                  AND template~cost_center     = object~cost_center
                                                  AND template~service_product = capacity~service_product
                                                  AND template~ryear           = capacity~ryear
                                                  AND template~poper           = capacity~poper
                                                  AND template~fplv            = capacity~fplv
      INTO TABLE @FINAL(capacities).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    TRY.
        DATA(capacity_db) = VALUE capoacity_db_type(
            FOR <capacity> IN capacity_template
            LET capacity         = VALUE #( capacities[ sysid           = <capacity>-sysid
                                                        legal_entity    = <capacity>-legal_entity
                                                        company_code    = <capacity>-company_code
                                                        cost_object     = <capacity>-cost_object
                                                        cost_center     = <capacity>-cost_center
                                                        service_product = <capacity>-service_product
                                                        ryear           = <capacity>-ryear
                                                        poper           = <capacity>-poper
                                                        fplv            = <capacity>-fplv ] OPTIONAL )
                service_product  = VALUE #( service_products[
                                                service_product = <capacity>-service_product ]-service_product OPTIONAL )
                cost_object_uuid = VALUE #( cost_objects[ sysid        = <capacity>-sysid
                                                          legal_entity = <capacity>-legal_entity
                                                          company_code = <capacity>-company_code
                                                          cost_object  = <capacity>-cost_object
                                                          cost_center  = <capacity>-cost_center ]-cost_object_uuid OPTIONAL )                                                  IN
            ( VALUE #( BASE CORRESPONDING #( <capacity> )
                       client           = sy-mandt
                       capacity_uuid    = COND #( WHEN capacity-capacity_uuid IS INITIAL
                                                  THEN cl_system_uuid=>create_uuid_x16_static( )
                                                  ELSE capacity-capacity_uuid )
                       service_product  = service_product
                       cost_object_uuid = cost_object_uuid
                       created_by       = COND #( WHEN capacity-created_by IS INITIAL
                                                  THEN cl_abap_context_info=>get_user_technical_name( )
                                                  ELSE capacity-created_by )
                       created_at       = COND #( WHEN capacity-created_at IS INITIAL
                                                  THEN timestamp
                                                  ELSE capacity-created_at )
                       last_changed_by  = cl_abap_context_info=>get_user_technical_name( )
                       last_changed_at  = timestamp                                           ) ) ).
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.

    DELETE capacity_db WHERE cost_object_uuid IS INITIAL OR service_product IS INITIAL.
    MODIFY /esrcc/srv_cpcty FROM TABLE @capacity_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_stewardship.
    TYPES:
      stewardship_db_type TYPE STANDARD TABLE OF /esrcc/stewrdshp WITH DEFAULT KEY.

    DATA:
      line                  TYPE /esrcc/swdsp_tmp,
      stewardships_template TYPE STANDARD TABLE OF /esrcc/swdsp_tmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(components) = _extract_table_components( '/ESRCC/SWDSP_TMP' ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        TRY.
            FINAL(component) = VALUE #( components[ column_index + 1 ] OPTIONAL ).
            DATA(text) = VALUE string( ).
            FINAL(dec_notation) = VALUE xsdboolean( ).
            FINAL(date_frmt) = VALUE xsdboolean( ).
            CALL BADI _enrichment_exit->convert_standard_data_type
              EXPORTING component        = component
                        decimal_notation = dec_notation
                        date_format      = date_frmt
              CHANGING  cell_value       = <sheet_cell_value>
                        message          = text.
            IF text IS NOT INITIAL.
              CLEAR: line.
              EXIT.
            ENDIF.
          CATCH cx_root INTO FINAL(exception). " TODO: variable is assigned but never used (ABAP cleaner)
        ENDTRY.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO stewardships_template.
    ENDLOOP.

    DELETE stewardships_template WHERE    sysid       IS INITIAL OR legal_entity IS INITIAL OR company_code IS INITIAL
                                       OR cost_object IS INITIAL OR cost_center  IS INITIAL OR valid_from   IS INITIAL.
    SORT stewardships_template BY sysid
                                  legal_entity
                                  company_code
                                  cost_object
                                  cost_center
                                  valid_from.
    DELETE ADJACENT DUPLICATES FROM stewardships_template COMPARING sysid legal_entity company_code cost_object cost_center valid_from.
    IF lines( stewardships_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @stewardships_template
      WHERE sysid        = @stewardships_template-sysid
        AND legal_entity = @stewardships_template-legal_entity
        AND company_code = @stewardships_template-company_code
        AND cost_object  = @stewardships_template-cost_object
        AND cost_center  = @stewardships_template-cost_center
      INTO TABLE @FINAL(cost_objects).

    SELECT stewardship_uuid,
           object~sysid,
           object~legal_entity,
           object~company_code,
           object~cost_object,
           object~cost_center,
           stewardship~valid_from,
           stewardship~workflow_status,
           stewardship~created_by,
           stewardship~created_at
      FROM /esrcc/stewrdshp AS stewardship
             INNER JOIN
               /esrcc/cst_objct AS object ON object~cost_object_uuid = stewardship~cost_object_uuid
                 INNER JOIN
                   @stewardships_template AS template ON  template~sysid        = object~sysid
                                                      AND template~legal_entity = object~legal_entity
                                                      AND template~company_code = object~company_code
                                                      AND template~cost_object  = object~cost_object
                                                      AND template~cost_center  = object~cost_center
                                                      AND template~valid_from   = stewardship~valid_from
      INTO TABLE @FINAL(stewardships).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    TRY.
        DATA(stewardships_db) = VALUE stewardship_db_type(
            FOR <stewardship> IN stewardships_template
            LET stewardship      = VALUE #( stewardships[ sysid        = <stewardship>-sysid
                                                          legal_entity = <stewardship>-legal_entity
                                                          company_code = <stewardship>-company_code
                                                          cost_object  = <stewardship>-cost_object
                                                          cost_center  = <stewardship>-cost_center
                                                          valid_from   = <stewardship>-valid_from ] OPTIONAL )
                cost_object_uuid = VALUE #( cost_objects[ sysid        = <stewardship>-sysid
                                                          legal_entity = <stewardship>-legal_entity
                                                          company_code = <stewardship>-company_code
                                                          cost_object  = <stewardship>-cost_object
                                                          cost_center  = <stewardship>-cost_center ]-cost_object_uuid OPTIONAL ) IN
            ( VALUE #( BASE CORRESPONDING #( <stewardship> )
                       client           = sy-mandt
                       stewardship_uuid = COND #( WHEN stewardship-stewardship_uuid IS INITIAL
                                                  THEN cl_system_uuid=>create_uuid_x16_static( )
                                                  ELSE stewardship-stewardship_uuid )
                       workflow_status  = COND #( WHEN stewardship-workflow_status IS INITIAL
                                                  THEN 'A'
                                                  ELSE stewardship-workflow_status )
                       cost_object_uuid = cost_object_uuid
                       created_by       = COND #( WHEN stewardship-created_by IS INITIAL
                                                  THEN cl_abap_context_info=>get_user_technical_name( )
                                                  ELSE stewardship-created_by )
                       created_at       = COND #( WHEN stewardship-created_at IS INITIAL
                                                  THEN timestamp
                                                  ELSE stewardship-created_at )
                       last_changed_by  = cl_abap_context_info=>get_user_technical_name( )
                       last_changed_at  = timestamp                                           ) ) ).
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.

    DELETE stewardships_db WHERE cost_object_uuid IS INITIAL OR workflow_status <> 'A'.
    MODIFY /esrcc/stewrdshp FROM TABLE @stewardships_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_stwrdshp_srvprod.
    TYPES:
      service_product_db_type TYPE STANDARD TABLE OF /esrcc/stwd_sp WITH DEFAULT KEY.

    DATA:
      line                     TYPE /esrcc/swdprdtmp,
      service_product_template TYPE STANDARD TABLE OF /esrcc/swdprdtmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(components) = _extract_table_components( '/ESRCC/SWDPRDTMP' ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        TRY.
            FINAL(component) = VALUE #( components[ column_index + 1 ] OPTIONAL ).
            DATA(text) = VALUE string( ).
            FINAL(dec_notation) = VALUE xsdboolean( ).
            FINAL(date_frmt) = VALUE xsdboolean( ).
            CALL BADI _enrichment_exit->convert_standard_data_type
              EXPORTING component        = component
                        decimal_notation = dec_notation
                        date_format      = date_frmt
              CHANGING  cell_value       = <sheet_cell_value>
                        message          = text.
            IF text IS NOT INITIAL.
              CLEAR: line.
              EXIT.
            ENDIF.
          CATCH cx_root INTO FINAL(exception). " TODO: variable is assigned but never used (ABAP cleaner)
        ENDTRY.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO service_product_template.
    ENDLOOP.

    DELETE service_product_template WHERE    sysid       IS INITIAL OR legal_entity IS INITIAL OR company_code   IS INITIAL
                                          OR cost_object IS INITIAL OR cost_center  IS INITIAL OR swd_valid_from IS INITIAL OR service_product IS INITIAL OR valid_from IS INITIAL.
    SORT service_product_template BY sysid
                                     legal_entity
                                     company_code
                                     cost_object
                                     cost_center
                                     swd_valid_from
                                     service_product
                                     valid_from.
    DELETE ADJACENT DUPLICATES FROM service_product_template COMPARING sysid legal_entity company_code cost_object cost_center swd_valid_from service_product valid_from.
    IF lines( service_product_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_objects~sysid,
           cost_objects~legal_entity,
           cost_objects~company_code,
           cost_objects~cost_object,
           cost_objects~cost_center,
           stewardships~stewardship_uuid,
           stewardships~valid_from,
           stewardships~workflow_status
      FROM /esrcc/cst_objct AS cost_objects
             INNER JOIN
               /esrcc/stewrdshp AS stewardships ON cost_objects~cost_object_uuid = stewardships~cost_object_uuid
                 INNER JOIN
                   @service_product_template AS service_products ON  cost_objects~sysid        = service_products~sysid
                                                                 AND cost_objects~legal_entity = service_products~legal_entity
                                                                 AND cost_objects~company_code = service_products~company_code
                                                                 AND cost_objects~cost_object  = service_products~cost_object
                                                                 AND cost_objects~cost_center  = service_products~cost_center
                                                                 AND stewardships~valid_from   = service_products~swd_valid_from
      INTO TABLE @FINAL(stewardships).

    SELECT service_product_uuid,
           object~sysid,
           object~legal_entity,
           object~company_code,
           object~cost_object,
           object~cost_center,
           stewardship~valid_from  AS swd_valid_from,
           product~service_product,
           product~valid_from,
           product~created_by,
           product~created_at
      FROM /esrcc/stwd_sp AS product
             INNER JOIN
               /esrcc/stewrdshp AS stewardship ON stewardship~stewardship_uuid = product~stewardship_uuid
                 INNER JOIN
                   /esrcc/cst_objct AS object ON object~cost_object_uuid = stewardship~cost_object_uuid
                     INNER JOIN
                       @service_product_template AS template ON  template~sysid           = object~sysid
                                                             AND template~legal_entity    = object~legal_entity
                                                             AND template~company_code    = object~company_code
                                                             AND template~cost_object     = object~cost_object
                                                             AND template~cost_center     = object~cost_center
                                                             AND template~swd_valid_from  = stewardship~valid_from
                                                             AND template~service_product = product~service_product
                                                             AND template~valid_from      = product~valid_from
      INTO TABLE @FINAL(products).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    TRY.
        DATA(service_product_db) = VALUE service_product_db_type(
            FOR <service_product> IN service_product_template
            LET service_product = VALUE #( products[ sysid           = <service_product>-sysid
                                                     legal_entity    = <service_product>-legal_entity
                                                     company_code    = <service_product>-company_code
                                                     cost_object     = <service_product>-cost_object
                                                     cost_center     = <service_product>-cost_center
                                                     swd_valid_from  = <service_product>-swd_valid_from
                                                     service_product = <service_product>-service_product
                                                     valid_from      = <service_product>-valid_from ] OPTIONAL )
                stewardship     = VALUE #( stewardships[ sysid        = <service_product>-sysid
                                                         legal_entity = <service_product>-legal_entity
                                                         company_code = <service_product>-company_code
                                                         cost_object  = <service_product>-cost_object
                                                         cost_center  = <service_product>-cost_center
                                                         valid_from   = <service_product>-swd_valid_from ] OPTIONAL ) IN
            ( VALUE #( BASE CORRESPONDING #( <service_product> )
                       client               = COND #( WHEN stewardship-workflow_status = 'A' THEN sy-mandt )
                       service_product_uuid = COND #( WHEN service_product-service_product_uuid IS INITIAL
                                                      THEN cl_system_uuid=>create_uuid_x16_static( )
                                                      ELSE service_product-service_product_uuid )
                       stewardship_uuid     = stewardship-stewardship_uuid
                       created_by           = COND #( WHEN service_product-created_by IS INITIAL
                                                      THEN cl_abap_context_info=>get_user_technical_name( )
                                                      ELSE service_product-created_by )
                       created_at           = COND #( WHEN service_product-created_at IS INITIAL
                                                      THEN timestamp
                                                      ELSE service_product-created_at )
                       last_changed_by      = cl_abap_context_info=>get_user_technical_name( )
                       last_changed_at      = timestamp                                   ) ) ).
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.

    DELETE service_product_db WHERE stewardship_uuid IS INITIAL OR service_product_uuid IS INITIAL OR client IS INITIAL.
    MODIFY /esrcc/stwd_sp FROM TABLE @service_product_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_stwrdshp_srvprod_rec.
    TYPES:
      receiver_db_type TYPE STANDARD TABLE OF /esrcc/stwdsprec WITH DEFAULT KEY.

    DATA:
      line              TYPE /esrcc/swdrectmp,
      receiver_template TYPE STANDARD TABLE OF /esrcc/swdrectmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(components) = _extract_table_components( '/ESRCC/SWDRECTMP' ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        TRY.
            FINAL(component) = VALUE #( components[ column_index + 1 ] OPTIONAL ).
            DATA(text) = VALUE string( ).
            FINAL(dec_notation) = VALUE xsdboolean( ).
            FINAL(date_frmt) = VALUE xsdboolean( ).
            CALL BADI _enrichment_exit->convert_standard_data_type
              EXPORTING component        = component
                        decimal_notation = dec_notation
                        date_format      = date_frmt
              CHANGING  cell_value       = <sheet_cell_value>
                        message          = text.
            IF text IS NOT INITIAL.
              CLEAR: line.
              EXIT.
            ENDIF.
          CATCH cx_root INTO FINAL(exception). " TODO: variable is assigned but never used (ABAP cleaner)
        ENDTRY.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO receiver_template.
    ENDLOOP.

    DELETE receiver_template WHERE    sysid                 IS INITIAL OR legal_entity          IS INITIAL
                                   OR company_code          IS INITIAL OR cost_object           IS INITIAL
                                   OR cost_center           IS INITIAL OR swd_valid_from        IS INITIAL
                                   OR service_product       IS INITIAL OR receiver_sysid        IS INITIAL
                                   OR receiver_legal_entity IS INITIAL OR receiver_company_code IS INITIAL
                                   OR receiver_cost_object  IS INITIAL OR receiver_cost_center  IS INITIAL.
    SORT receiver_template BY sysid
                              legal_entity
                              company_code
                              cost_object
                              cost_center
                              swd_valid_from
                              service_product
                              receiver_sysid
                              receiver_legal_entity
                              receiver_company_code
                              receiver_cost_object
                              receiver_cost_center.
    DELETE ADJACENT DUPLICATES FROM receiver_template
           COMPARING sysid legal_entity company_code cost_object cost_center swd_valid_from service_product
           receiver_sysid receiver_legal_entity receiver_company_code
           receiver_cost_object receiver_cost_center.
    IF lines( receiver_template ) = 0.
      RETURN.
    ENDIF.

    SELECT cost_objects~sysid,
           cost_objects~legal_entity,
           cost_objects~company_code,
           cost_objects~cost_object,
           cost_objects~cost_center,
           stewardships~stewardship_uuid,
           stewardships~valid_from          AS swd_valid_from,
           stewardships~workflow_status,
           service_products~service_product
      FROM /esrcc/cst_objct AS cost_objects
             INNER JOIN
               /esrcc/stewrdshp AS stewardships ON cost_objects~cost_object_uuid = stewardships~cost_object_uuid
                 INNER JOIN
                   /esrcc/stwd_sp AS service_products ON stewardships~stewardship_uuid = service_products~stewardship_uuid
                     INNER JOIN
                       @receiver_template AS receiver ON  cost_objects~sysid               = receiver~sysid
                                                      AND cost_objects~legal_entity        = receiver~legal_entity
                                                      AND cost_objects~company_code        = receiver~company_code
                                                      AND cost_objects~cost_object         = receiver~cost_object
                                                      AND cost_objects~cost_center         = receiver~cost_center
                                                      AND stewardships~valid_from          = receiver~swd_valid_from
                                                      AND service_products~service_product = receiver~service_product
      INTO TABLE @FINAL(service_products).

    SELECT cost_object_uuid, sysid, legal_entity, company_code, cost_object, cost_center
      FROM /esrcc/cst_objct
      FOR ALL ENTRIES IN @receiver_template
      WHERE sysid        = @receiver_template-receiver_sysid
        AND legal_entity = @receiver_template-receiver_legal_entity
        AND company_code = @receiver_template-receiver_company_code
        AND cost_object  = @receiver_template-receiver_cost_object
        AND cost_center  = @receiver_template-receiver_cost_center
      INTO TABLE @FINAL(receiver_cost_objects).

    SELECT DISTINCT serv_prod_rec_uuid,
                    object~sysid,
                    object~legal_entity,
                    object~company_code,
                    object~cost_object,
                    object~cost_center,
                    stewardship~valid_from       AS swd_valid_from,
*                    stewardship~workflow_status,
                    product~service_product,
                    receiver_object~sysid        AS receiver_sysid,
                    receiver_object~legal_entity AS receiver_legal_entity,
                    receiver_object~company_code AS receiver_company_code,
                    receiver_object~cost_object  AS receiver_cost_object,
                    receiver_object~cost_center  AS receiver_cost_center,
                    receiver~created_by,
                    receiver~created_at
      FROM /esrcc/stwd_sp AS product
             INNER JOIN
               /esrcc/stewrdshp AS stewardship ON stewardship~stewardship_uuid = product~stewardship_uuid
                 INNER JOIN
                   /esrcc/cst_objct AS object ON object~cost_object_uuid = stewardship~cost_object_uuid
                     INNER JOIN
                       /esrcc/stwdsprec AS receiver ON  stewardship~stewardship_uuid = receiver~stewardship_uuid
                                                    AND product~service_product      = receiver~service_product
                         INNER JOIN
                           /esrcc/cst_objct AS receiver_object ON receiver_object~cost_object_uuid = receiver~cost_object_uuid
                             INNER JOIN
                               @receiver_template AS template ON  template~sysid                 = object~sysid
                                                              AND template~legal_entity          = object~legal_entity
                                                              AND template~company_code          = object~company_code
                                                              AND template~cost_object           = object~cost_object
                                                              AND template~cost_center           = object~cost_center
                                                              AND template~swd_valid_from        = stewardship~valid_from
                                                              AND template~service_product       = product~service_product
                                                              AND template~receiver_sysid        = receiver_object~sysid
                                                              AND template~receiver_legal_entity = receiver_object~legal_entity
                                                              AND template~receiver_company_code = receiver_object~company_code
                                                              AND template~receiver_cost_object  = receiver_object~cost_object
                                                              AND template~receiver_cost_center  = receiver_object~cost_center
      INTO TABLE @FINAL(receivers).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    TRY.
        DATA(receiver_db) = VALUE receiver_db_type(
            FOR <receiver> IN receiver_template
            LET receiver         = VALUE #( receivers[ sysid                 = <receiver>-sysid
                                                       legal_entity          = <receiver>-legal_entity
                                                       company_code          = <receiver>-company_code
                                                       cost_object           = <receiver>-cost_object
                                                       cost_center           = <receiver>-cost_center
                                                       swd_valid_from        = <receiver>-swd_valid_from
                                                       service_product       = <receiver>-service_product
                                                       receiver_sysid        = <receiver>-receiver_sysid
                                                       receiver_legal_entity = <receiver>-receiver_legal_entity
                                                       receiver_company_code = <receiver>-receiver_company_code
                                                       receiver_cost_object  = <receiver>-receiver_cost_object
                                                       receiver_cost_center  = <receiver>-receiver_cost_center ] OPTIONAL )
*            stewardship_uuid = VALUE #( service_products[ sysid          = <receiver>-sysid
*                                                          legal_entity   = <receiver>-legal_entity
*                                                          company_code   = <receiver>-company_code
*                                                          cost_object    = <receiver>-cost_object
*                                                          cost_center    = <receiver>-cost_center
*                                                          swd_valid_from = <receiver>-swd_valid_from ]-stewardship_uuid OPTIONAL )
                service_product  = VALUE #( service_products[ sysid           = <receiver>-sysid
                                                              legal_entity    = <receiver>-legal_entity
                                                              company_code    = <receiver>-company_code
                                                              cost_object     = <receiver>-cost_object
                                                              cost_center     = <receiver>-cost_center
                                                              swd_valid_from  = <receiver>-swd_valid_from
                                                              service_product = <receiver>-service_product ] OPTIONAL )
                cost_object_uuid = VALUE #( receiver_cost_objects[
                                                sysid        = <receiver>-receiver_sysid
                                                legal_entity = <receiver>-receiver_legal_entity
                                                company_code = <receiver>-receiver_company_code
                                                cost_object  = <receiver>-receiver_cost_object
                                                cost_center  = <receiver>-receiver_cost_center ]-cost_object_uuid OPTIONAL ) IN
            ( VALUE #( BASE CORRESPONDING #( <receiver> )
                       client             = COND #( WHEN service_product-workflow_status = 'A' THEN sy-mandt )
                       serv_prod_rec_uuid = COND #( WHEN receiver-serv_prod_rec_uuid IS INITIAL
                                                    THEN cl_system_uuid=>create_uuid_x16_static( )
                                                    ELSE receiver-serv_prod_rec_uuid )
                       stewardship_uuid   = service_product-stewardship_uuid
                       service_product    = service_product-service_product
                       cost_object_uuid   = cost_object_uuid
                       created_by         = COND #( WHEN receiver-created_by IS INITIAL
                                                    THEN cl_abap_context_info=>get_user_technical_name( )
                                                    ELSE receiver-created_by )
                       created_at         = COND #( WHEN receiver-created_at IS INITIAL
                                                    THEN timestamp
                                                    ELSE receiver-created_at )
                       last_changed_by    = cl_abap_context_info=>get_user_technical_name( )
                       last_changed_at    = timestamp                                   ) ) ).
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.

    DELETE receiver_db WHERE stewardship_uuid IS INITIAL OR service_product IS INITIAL OR cost_object_uuid IS INITIAL OR client IS INITIAL.
    MODIFY /esrcc/stwdsprec FROM TABLE @receiver_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _extract_table_components.
    DATA:
      structure_descriptor TYPE REF TO cl_abap_typedescr.

    cl_abap_structdescr=>describe_by_name( EXPORTING  p_name         = table_name
                                           RECEIVING  p_descr_ref    = structure_descriptor
                                           EXCEPTIONS type_not_found = 1
                                                      OTHERS         = 2 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    components = CAST cl_abap_structdescr( structure_descriptor )->get_components( ).
    DELETE components WHERE name IS INITIAL.
  ENDMETHOD.


  METHOD _upload_alloc_keys_weight.
    TYPES:
      alloc_keyw_wgt_db_type TYPE STANDARD TABLE OF /esrcc/aloc_wgt WITH DEFAULT KEY.

    DATA:
      line                   TYPE /esrcc/alcwgttmp,
      alloc_key_wgt_template TYPE STANDARD TABLE OF /esrcc/alcwgttmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO alloc_key_wgt_template.
    ENDLOOP.

    IF lines( alloc_key_wgt_template ) = 0.
      RETURN.
    ENDIF.

    SELECT
      FROM /esrcc/co_rule AS rule
             LEFT JOIN
               /esrcc/aloc_wgt AS weightage ON weightage~rule_id = rule~rule_id
                 INNER JOIN
                   @alloc_key_wgt_template AS template ON  rule~rule_id             = template~rule_id
                                                       AND weightage~allocation_key = template~allocation_key
      FIELDS rule~rule_id,
             weightage~allocation_key,
             rule~workflow_status,
             weightage~created_by,
             weightage~created_at
      INTO TABLE @FINAL(weightages).

    SELECT
      FROM /esrcc/co_rule AS rule
             INNER JOIN
               @alloc_key_wgt_template AS template ON rule~rule_id = template~rule_id
      FIELDS DISTINCT rule~rule_id,
                      rule~workflow_status
      INTO TABLE @FINAL(rules).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    DATA(weightage_db) = VALUE alloc_keyw_wgt_db_type(
        FOR <weightage> IN alloc_key_wgt_template
        LET weightage = VALUE #( weightages[ rule_id        = <weightage>-rule_id
                                             allocation_key = <weightage>-allocation_key ] OPTIONAL )
            rule      = VALUE #( rules[ rule_id = <weightage>-rule_id ] OPTIONAL ) IN
        ( VALUE #( BASE CORRESPONDING #( <weightage> )
                   client          = COND #( WHEN rule-workflow_status = 'A' THEN sy-mandt )
                   created_by      = COND #( WHEN weightage-created_by IS INITIAL
                                             THEN cl_abap_context_info=>get_user_technical_name( )
                                             ELSE weightage-created_by )
                   created_at      = COND #( WHEN weightage-created_at IS INITIAL
                                             THEN timestamp
                                             ELSE weightage-created_at )
                   last_changed_by = cl_abap_context_info=>get_user_technical_name( )
                   last_changed_at = timestamp                                     ) ) ).

    DELETE weightage_db WHERE client IS INITIAL OR rule_id IS INITIAL OR allocation_key IS INITIAL.
    MODIFY /esrcc/aloc_wgt FROM TABLE @weightage_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_charge_out_rule.
    TYPES:
      co_rule_db_type TYPE STANDARD TABLE OF /esrcc/co_rule WITH DEFAULT KEY.

    DATA:
      line             TYPE /esrcc/coruletmp,
      co_rule_template TYPE STANDARD TABLE OF /esrcc/coruletmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO co_rule_template.
    ENDLOOP.

    IF lines( co_rule_template ) = 0.
      RETURN.
    ENDIF.

    SELECT
      FROM /esrcc/co_rule AS charge_out_rule
             INNER JOIN
               @co_rule_template AS template ON template~rule_id = charge_out_rule~rule_id
      FIELDS charge_out_rule~rule_id,
             charge_out_rule~workflow_status,
             created_by,
             created_at
      INTO TABLE @FINAL(co_rules).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    DATA(co_rule_db) = VALUE co_rule_db_type(
        FOR <co_rule> IN co_rule_template
        LET co_rule = VALUE #( co_rules[ rule_id = <co_rule>-rule_id ] OPTIONAL ) IN
        ( VALUE #( BASE CORRESPONDING #( <co_rule> )
                   client          = COND #( WHEN co_rule-workflow_status = 'A' THEN sy-mandt )
                   rule_id         = COND #( WHEN co_rule-rule_id IS INITIAL
                                             THEN <co_rule>-rule_id
                                             ELSE co_rule-rule_id )
                   workflow_status = COND #( WHEN co_rule-workflow_status IS INITIAL
                                             THEN 'A'
                                             ELSE co_rule-workflow_status )
                   created_by      = COND #( WHEN co_rule-created_by IS INITIAL
                                             THEN cl_abap_context_info=>get_user_technical_name( )
                                             ELSE co_rule-created_by )
                   created_at      = COND #( WHEN co_rule-created_at IS INITIAL
                                             THEN timestamp
                                             ELSE co_rule-created_at )
                   last_changed_by = cl_abap_context_info=>get_user_technical_name( )
                   last_changed_at = timestamp                                           ) ) ).

    DELETE co_rule_db WHERE workflow_status <> 'A'.
    MODIFY /esrcc/co_rule FROM TABLE @co_rule_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_charge_out_rule_desc.
    TYPES:
      co_rule_desc_db_type TYPE STANDARD TABLE OF /esrcc/co_rulet WITH DEFAULT KEY.

    DATA:
      line                  TYPE /esrcc/corulttmp,
      co_rule_desc_template TYPE STANDARD TABLE OF /esrcc/corulttmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO co_rule_desc_template.
    ENDLOOP.

    IF lines( co_rule_desc_template ) = 0.
      RETURN.
    ENDIF.

    SELECT
      FROM /esrcc/co_rule AS rule " ON description~rule_id = rule~rule_id
             INNER JOIN
               @co_rule_desc_template AS template ON rule~rule_id = template~rule_id
      FIELDS DISTINCT rule~rule_id,
                      workflow_status
*             description~spras
      INTO TABLE @FINAL(descriptions).

    DATA(co_rule_desc_db) = VALUE co_rule_desc_db_type(
        FOR <co_rule_desc> IN co_rule_desc_template
        LET co_rule_desc = VALUE #( descriptions[ rule_id = <co_rule_desc>-rule_id ] OPTIONAL ) IN
        ( VALUE #( BASE CORRESPONDING #( <co_rule_desc> )
                   client  = COND #( WHEN co_rule_desc-workflow_status = 'A' THEN sy-mandt )
                   rule_id = COND #( WHEN co_rule_desc-rule_id IS INITIAL
                                     THEN <co_rule_desc>-rule_id
                                     ELSE co_rule_desc-rule_id )  ) ) ).

    DELETE co_rule_desc_db WHERE client IS INITIAL.
    MODIFY /esrcc/co_rulet FROM TABLE @co_rule_desc_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.


  METHOD _upload_service_markup.
    TYPES:
      service_markup_type TYPE STANDARD TABLE OF /esrcc/srvmkp WITH DEFAULT KEY.

    DATA:
      line                    TYPE /esrcc/srvmkptmp,
      service_markup_template TYPE STANDARD TABLE OF /esrcc/srvmkptmp WITH DEFAULT KEY.

    FIELD-SYMBOLS:
      <excel_structured_data> TYPE STANDARD TABLE,
      <row>                   TYPE any.

    ASSIGN _excel_structured_data->* TO <excel_structured_data>.

    FINAL(components) = _extract_table_components( '/ESRCC/SRVMKPTMP' ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(row_index) = 1.
    LOOP AT <excel_structured_data> ASSIGNING <row> FROM 2.
      row_index += 1.

      DATA(column_index) = 0.
      DO.
        column_index += 1.

        ASSIGN COMPONENT column_index OF STRUCTURE <row> TO FIELD-SYMBOL(<sheet_cell_value>).
        IF <sheet_cell_value> IS NOT ASSIGNED.
          EXIT.
        ENDIF.

        ASSIGN COMPONENT column_index + 1 OF STRUCTURE line TO FIELD-SYMBOL(<line_cell_value>).
        IF <line_cell_value> IS NOT ASSIGNED.
          UNASSIGN:
             <sheet_cell_value>,
             <line_cell_value>.
          CONTINUE.
        ENDIF.

        TRY.
            FINAL(component) = VALUE #( components[ column_index + 1 ] OPTIONAL ).
            DATA(text) = VALUE string( ).
            FINAL(dec_notation) = VALUE xsdboolean( ).
            FINAL(date_frmt) = VALUE xsdboolean( ).
            CALL BADI _enrichment_exit->convert_standard_data_type
              EXPORTING component        = component
                        decimal_notation = dec_notation
                        date_format      = date_frmt
              CHANGING  cell_value       = <sheet_cell_value>
                        message          = text.
            IF text IS NOT INITIAL.
              CLEAR: line.
              EXIT.
            ENDIF.
          CATCH cx_root INTO FINAL(exception). " TODO: variable is assigned but never used (ABAP cleaner)
        ENDTRY.

        <line_cell_value> = <sheet_cell_value>.

        UNASSIGN:
              <sheet_cell_value>,
              <line_cell_value>.
      ENDDO.
      APPEND line TO service_markup_template.
    ENDLOOP.

    IF lines( service_markup_template ) = 0.
      RETURN.
    ENDIF.

    SELECT
      FROM /esrcc/srvmkp AS service_markup
             INNER JOIN
               @service_markup_template AS template ON  template~serviceproduct = service_markup~serviceproduct
                                                    AND template~validfrom      = service_markup~validfrom
      FIELDS service_markup~serviceproduct,
             service_markup~validfrom,
             workflow_status,
             created_by,
             created_at
      INTO TABLE @FINAL(service_markups).

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).

    DATA(markup_db) = VALUE service_markup_type(
        FOR <markup> IN service_markup_template
        LET markup = VALUE #( service_markups[ serviceproduct = <markup>-serviceproduct
                                               validfrom      = <markup>-validfrom ] OPTIONAL ) IN
        ( VALUE #( BASE CORRESPONDING #( <markup> )
                   client          = sy-mandt
                   workflow_status = COND #( WHEN markup-workflow_status IS INITIAL OR markup-workflow_status = 'A'
                                             THEN 'A'
                                             ELSE markup-workflow_status )
                   created_by      = COND #( WHEN markup-created_by IS INITIAL
                                             THEN cl_abap_context_info=>get_user_technical_name( )
                                             ELSE markup-created_by )
                   created_at      = COND #( WHEN markup-created_at IS INITIAL
                                             THEN timestamp
                                             ELSE markup-created_at )
                   last_changed_by = cl_abap_context_info=>get_user_technical_name( )
                   last_changed_at = timestamp                                     ) ) ).

    DELETE markup_db WHERE workflow_status <> 'A'.
    MODIFY /esrcc/srvmkp FROM TABLE @markup_db.
    IF sy-subrc = 0.
      records = sy-dbcnt.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
