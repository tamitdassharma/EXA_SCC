INTERFACE /esrcc/if_file_upload_logger PUBLIC .
  TYPES:
    BEGIN OF message_type,
      message_id     TYPE symsgid,
      message_number TYPE symsgno,
      message_type   TYPE symsgty,
      message_text   TYPE bapi_msg,
      message_v1     TYPE symsgv,
      message_v2     TYPE symsgv,
      message_v3     TYPE symsgv,
      message_v4     TYPE symsgv,
    END OF message_type.

  METHODS:
    add_message IMPORTING message TYPE message_type,
    check_error_message_present RETURNING VALUE(is_error_found) TYPE xsdboolean,
    get_logger_id RETURNING VALUE(logger_id) TYPE sysuuid_c32,
    finalize.
ENDINTERFACE.
