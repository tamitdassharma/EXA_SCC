INTERFACE /esrcc/if_application_logs PUBLIC.
  TYPES:
    messages_type    TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY,
    message_ids_type TYPE STANDARD TABLE OF sysuuid_c32 WITH EMPTY KEY.

  METHODS:
    get_log_header_id   RETURNING VALUE(log_header_uuid) TYPE sysuuid_c32,
    get_log_header_info RETURNING VALUE(log_header)      TYPE /esrcc/log_hdr,
    set_log_header_info IMPORTING log_header             TYPE /esrcc/log_hdr,
    add_messages        IMPORTING log_messages           TYPE messages_type,
    add_message         IMPORTING log_message             TYPE /esrcc/log_item
                                  invalid_record          TYPE any OPTIONAL
                        RETURNING VALUE(leading_msg_uuid) TYPE sysuuid_c32,
    add_text_to_message IMPORTING log_message_id          TYPE symsgid
                                  log_message_type        TYPE symsgty
                                  log_message_number      TYPE symsgno DEFAULT '000'
                                  log_message_text        TYPE string
                                  log_parent_uuid         TYPE sysuuid_c32 OPTIONAL,
    read_messages       RETURNING VALUE(messages) TYPE messages_type,
    map_invalid_record_to_messages IMPORTING invalid_record TYPE ANY
                                             message_ids TYPE message_ids_type,
    save_header,
    save_messages,
    clear_messages,
    clear_header,
    save_header_and_messages.
ENDINTERFACE.
