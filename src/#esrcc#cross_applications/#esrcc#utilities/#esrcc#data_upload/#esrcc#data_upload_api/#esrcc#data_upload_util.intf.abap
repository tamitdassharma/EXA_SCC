INTERFACE /esrcc/data_upload_util PUBLIC .
  CONSTANTS:
    message_class TYPE symsgid VALUE '/ESRCC/DATA_UPLOAD'.

  METHODS:
    upload_data IMPORTING application     TYPE /esrcc/application
                          sub_application TYPE /esrcc/sub_application
                          table_name      TYPE tabname
                          created_by      TYPE abp_creation_user
                          upload_uiid     TYPE sysuuid_x16
                          datastream      TYPE /esrcc/data_stream.

ENDINTERFACE.
