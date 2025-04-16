CLASS /esrcc/cl_file_upload_logger DEFINITION PUBLIC FINAL CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES /esrcc/if_file_upload_logger .

    CLASS-METHODS:
      get_instance RETURNING VALUE(instance) TYPE REF TO /esrcc/if_file_upload_logger.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:
      _logger               TYPE REF TO /esrcc/cL_file_upload_logger,
      _unique_key           TYPE sysuuid_c32,
      _sequence             TYPE /esrcc/fu_logs-sequence,
      _file_upload_messages TYPE SORTED TABLE OF /esrcc/fu_logs WITH UNIQUE KEY primary_key COMPONENTS msg_ref_id upload_id
                                                          WITH NON-UNIQUE SORTED KEY text COMPONENTS message_text
                                                          WITH NON-UNIQUE SORTED KEY check_message COMPONENTS message_id message_number.
ENDCLASS.



CLASS /ESRCC/CL_FILE_UPLOAD_LOGGER IMPLEMENTATION.


  METHOD /esrcc/if_file_upload_logger~add_message.
    TRY.
        IF NOT line_exists( _file_upload_messages[ KEY text message_text = message-message_text ] ).
          _sequence += 1.
          IF message-message_text IS INITIAL.
            MESSAGE ID message-message_id TYPE message-message_type NUMBER message-message_number
              WITH message-message_v1 message-message_v2 message-message_v3 message-message_v4 INTO DATA(message_text).
          ELSE.
            message_text = message-message_text.
          ENDIF.
          APPEND VALUE #( client         = sy-mandt
                          msg_ref_id     = cl_system_uuid=>create_uuid_c32_static( )
                          Upload_id      = _unique_key
                          sequence       = _sequence
                          message_id     = message-message_id
                          message_number = message-message_number
                          message_type   = message-message_type
                          message_text   = message_text
                          message_v1     = message-message_v1
                          message_v2     = message-message_v2
                          message_v3     = message-message_v3
                          message_v4     = message-message_v4  ) TO _file_upload_messages.
        ENDIF.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD /esrcc/if_file_upload_logger~check_error_message_present.
    is_error_found = COND #( WHEN line_exists( _file_upload_messages[ upload_id    = _unique_key "#EC CI_SORTSEQ
                                                                      message_type = 'E' ] )
                             THEN abap_true ).
  ENDMETHOD.


  METHOD /esrcc/if_file_upload_logger~finalize.
    IF line_exists( _file_upload_messages[ message_type = 'E' ] ). "#EC CI_SORTSEQ
      _sequence += 1.
      " Excel file has the above error(s). Correct and re-upload.
      MESSAGE e007(/ESRCC/file_upload) INTO FINAL(message).
      TRY.
          APPEND VALUE #( client         = sy-mandt
                          msg_ref_id     = cl_system_uuid=>create_uuid_c32_static( )
                          upload_id      = _unique_key
                          sequence       = _sequence
                          message_id     = '/ESRCC/FILE_UPLOAD'
                          message_number = '007'
                          message_type   = 'E'
                          message_text   = message  ) TO _file_upload_messages.
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.
    ENDIF.
    INSERT /esrcc/fu_logs FROM TABLE @_file_upload_messages.
  ENDMETHOD.


  METHOD /esrcc/if_file_upload_logger~get_logger_id.
    logger_id = _unique_key.
  ENDMETHOD.


  METHOD get_instance.
    IF _logger IS NOT BOUND.
      TRY.
          _logger = NEW /esrcc/cl_file_upload_logger( ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
                                                        " TODO: variable is assigned but never used (ABAP cleaner)
                                                        IMPORTING time_stamp = FINAL(timestamp)
                                                                  date       = FINAL(date)
                                                                  time       = FINAL(time) ).

          _unique_key = |{ sy-uname }{ date }{ time }|.
          _sequence += 1.
          " File upload process completed with the following information.
          MESSAGE i001(/ESRCC/file_upload) INTO FINAL(message).
          APPEND VALUE #( client         = sy-mandt
                          msg_ref_id     = cl_system_uuid=>create_uuid_c32_static( )
                          upload_id      = _unique_key
                          sequence       = _sequence
                          message_id     = '/ESRCC/FILE_UPLOAD'
                          message_number = '001'
                          message_type   = 'I'
                          message_text   = message  ) TO _file_upload_messages.
        CATCH cx_uuid_error.
          " handle exception
      ENDTRY.
    ENDIF.
    instance = _logger.
  ENDMETHOD.
ENDCLASS.
