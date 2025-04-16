CLASS /esrcc/data_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .


  PUBLIC SECTION.
    INTERFACES /esrcc/data_upload_util.

    CLASS-METHODS:
      create RETURNING VALUE(instance) TYPE REF TO /esrcc/data_upload_util.

  PRIVATE SECTION.
    DATA:
      _application_logger TYPE REF TO /esrcc/if_application_logs,
      _upload_staging     TYPE /esrcc/upld_stg.

    METHODS:
      _initiate_logging IMPORTING !application    TYPE /esrcc/application
                                  sub_application TYPE /esrcc/sub_application,

      _finalize_logging,
      _set_upload_staging_info IMPORTING upload_staging_info TYPE /esrcc/upld_stg,
      _upload_data_to_model.
ENDCLASS.



CLASS /esrcc/data_upload IMPLEMENTATION.


  METHOD /esrcc/data_upload_util~upload_data.
    " Initiate the logging mechanism
    _initiate_logging( application     = application
                       sub_application = sub_application ).

    " Set the upload information
    _set_upload_staging_info( upload_staging_info = VALUE #( upload_uuid     = upload_uiid
                                                             data_stream     = datastream
                                                             created_by      = created_by
                                                             application     = application
                                                             sub_application = sub_application
                                                             table_name      = table_name ) ).

    " Upload the dato to the respective model
    TRY.
        _upload_data_to_model( ).
      CATCH cx_sy_conversion_no_number INTO FINAL(exception).
        FINAL(leading_msg_id) = _application_logger->add_message(
                                    log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                                           message_type   = sy-abcde+4(1)
                                                           message_number = 018 ) ).
        _application_logger->add_text_to_message( log_message_id   = /esrcc/data_upload_util=>message_class
                                                  log_message_type = sy-abcde+4(1)
                                                  log_message_text = exception->get_longtext( )
                                                  log_parent_uuid  = leading_msg_id ).
    ENDTRY.

    " Finalize the logging mechanism
    _finalize_logging( ).

  ENDMETHOD.

  METHOD create.
    instance = NEW /esrcc/data_upload( ).
  ENDMETHOD.

  METHOD _finalize_logging.
    _application_logger->save_header_and_messages( ).
  ENDMETHOD.

  METHOD _initiate_logging.
    _application_logger = /esrcc/cl_application_logs=>create_instance( deter_save = abap_true ).
    _application_logger->set_log_header_info( log_header = VALUE #( application     = application
                                                                    sub_application = sub_application ) ).

  ENDMETHOD.

  METHOD _set_upload_staging_info.
    _upload_staging = CORRESPONDING #( upload_staging_info ).
  ENDMETHOD.

  METHOD _upload_data_to_model.
    DATA dynamic_table TYPE REF TO data.

    DATA(table_name) = SWITCH tabname( _upload_staging-sub_application
                                        WHEN 'FLI' THEN '/ESRCC/CB_LI_TMP'
                                        WHEN 'FCD' THEN '/ESRCC/CONSUMPTN'
                                        WHEN 'FAB' THEN '/ESRCC/INDTALLOC'
                                        WHEN 'FPD' THEN '/ESRCC/SRV_CPCTY'
                                        WHEN 'FBC' THEN _upload_staging-table_name ).

    IF table_name IS INITIAL.
      RETURN.
    ENDIF.

    FINAL(template_helper) = /esrcc/template_helper=>create( ).
    IF template_helper->check_table_registered( table_name ).
      DATA(template_table_name) = template_helper->get_table_alias( ).
    ELSE.
      template_table_name = table_name.
    ENDIF.

    DATA(components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( template_table_name ) )->get_components( ).
    DELETE components WHERE name = 'CLIENT'.
    FINAL(non_permitted_types) = |XPIbs8Faey|.
    FINAL(dynamic_table_handler) = cl_abap_tabledescr=>create(
        cl_abap_structdescr=>get( VALUE #( FOR <component> IN components
                                           ( VALUE #(
                                                 BASE CORRESPONDING #( <component> )
                                                 type = COND #( WHEN <component>-type->type_kind CA non_permitted_types
                                                                THEN cl_abap_elemdescr=>get_string( )
                                                                ELSE <component>-type ) ) ) ) ) ).

    CREATE DATA dynamic_table TYPE HANDLE dynamic_table_handler.

    FINAL(raw_data_reader) = xco_cp_xlsx=>document->for_file_content( _upload_staging-data_stream )->read_access( ).
    FINAL(first_worksheet_reader) = raw_data_reader->get_workbook( )->worksheet->at_position( 1 ).
    first_worksheet_reader->select( xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( )
              )->row_stream(
              )->operation->write_to( dynamic_table
              )->if_xco_xlsx_ra_operation~execute( ).

    FINAL(upload_handler) = upload_data_to_db_handler=>create( _application_logger ).
    table_name = COND #( WHEN table_name = '/ESRCC/CB_LI_TMP' THEN '/ESRCC/CB_LI' ELSE table_name ).
    IF template_helper->check_table_registered( table_name ).
        DATA(records) = template_helper->upload_template_data( excel_structured_data = dynamic_table ).
      IF records > 0.
        DATA(db_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
                             VALUE #( ( xco_cp_abap_repository=>object_name->get_filter(
                                            xco_cp_abap_sql=>constraint->equal( table_name ) ) ) ) )->in(
                                                xco_cp_abap=>repository )->get( ).

        IF lines( db_table_readers ) > 0.
          DATA(db_table_reader) = db_table_readers[ 1 ].
        ENDIF.

        DATA(table_description) = db_table_reader->content(  )->get_short_description(  ).
        " Data from Excel file has been uploaded successfully for table &1.
        _application_logger->add_message( VALUE #(
            message_id     = /esrcc/data_upload_util=>message_class
            message_type   = sy-abcde+18(1)
            message_number = 005
            message_v1     = records
            message_v2     = COND #( WHEN table_description IS INITIAL THEN table_name ELSE table_description ) ) ).

      ELSE.
        " Excel file is empty or not compatible with the table selected.
        _application_logger->add_message( VALUE #(
          message_id     = /esrcc/data_upload_util=>message_class
          message_type   = sy-abcde+4(1)
          message_number = 004 ) ).
      ENDIF.
    ELSEIF upload_handler->refine_data( table_name       = table_name
                                    table_components = components
                                    uploaded_data    = dynamic_table ).

      upload_handler->update_data_to_db( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
