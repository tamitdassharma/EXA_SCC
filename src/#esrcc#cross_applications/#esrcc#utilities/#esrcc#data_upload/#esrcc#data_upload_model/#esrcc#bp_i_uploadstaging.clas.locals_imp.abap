CLASS lhc_UploadStaging DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR UploadStaging RESULT result.

    METHODS setfilename FOR DETERMINE ON MODIFY
      IMPORTING keys FOR UploadStaging~setfilename.

    METHODS uploadfields FOR DETERMINE ON SAVE
      IMPORTING keys FOR UploadStaging~uploadfields.

    METHODS validate_create FOR VALIDATE ON SAVE
      IMPORTING keys FOR UploadStaging~validate_create.

ENDCLASS.

CLASS lhc_UploadStaging IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD setfilename.
    READ ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
         ENTITY uploadstaging
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(uploaddata)
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED FINAL(read_failed).

    ASSIGN uploaddata[ 1 ] TO FIELD-SYMBOL(<uploaddata>).
    IF NOT ( sy-subrc = 0 AND <uploaddata>-TemporaryFileName IS INITIAL ).
      RETURN.
    ENDIF.
    <uploaddata>-TemporaryFileName = SWITCH #( <uploaddata>-SubApplication
                                               WHEN 'FLI' THEN |Cost Base Line Items|
                                               WHEN 'FPD' THEN |Service Capacities|
                                               WHEN 'FAB' THEN |Allocation Base Keys|
                                               WHEN 'FCD' THEN |Service Consumptions|
                                               WHEN 'FBC' THEN <uploaddata>-TableName ).
    <uploaddata>-TemporaryMimetype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
    MODIFY ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
           ENTITY UploadStaging
           UPDATE FIELDS ( TemporaryFileName TemporaryMimetype )
           WITH VALUE #( " UploadUIID = <uploaddata>-UploadUIID
                         (
*                %is_draft   = <uploaddata>-%is_draft
                           %tky              = <uploaddata>-%tky
                           TemporaryFileName = <uploaddata>-TemporaryFileName
                           TemporaryMimetype = <uploaddata>-TemporaryMimetype ) )
               " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED FINAL(rep)
           " TODO: variable is assigned but never used (ABAP cleaner)
           FAILED FINAL(fa)
           " TODO: variable is assigned but never used (ABAP cleaner)
           MAPPED FINAL(ma).
  ENDMETHOD.

  METHOD uploadfields.
    READ ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
         ENTITY uploadstaging
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT FINAL(uploaddata)
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED FINAL(read_failed).

    ASSIGN uploaddata[ 1 ] TO FIELD-SYMBOL(<uploaddata>).
    IF sy-subrc = 0 AND <uploaddata>-filename IS NOT INITIAL AND <uploaddata>-datastream IS NOT INITIAL.
      IF <uploaddata>-SubApplication = 'FBC' AND <uploaddata>-TableName IS INITIAL.
      ELSE.
        DATA(uploader) = /esrcc/data_upload=>create( ).

        uploader->upload_data(
          application     = 'FUP'
          sub_application = <uploaddata>-SubApplication
          table_name      = <uploaddata>-TableName
          created_by      = <uploaddata>-createdby
          upload_uiid     = <uploaddata>-uploaduuid
          datastream      = <uploaddata>-datastream
        ).

      ENDIF.
    ENDIF.

    MODIFY ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
           ENTITY UploadStaging
           UPDATE FIELDS ( status )
           WITH VALUE #( ( UploadUUID = <uploaddata>-UploadUUID
                           Status     = 'C' ) ).
  ENDMETHOD.

  METHOD validate_create.
    READ ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
         ENTITY uploadstaging
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT FINAL(uploaddata)
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED FINAL(read_failed).

    ASSIGN uploaddata[ 1 ] TO FIELD-SYMBOL(<uploaddata>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF <uploaddata>-SubApplication = 'FBC' AND <uploaddata>-TableName IS INITIAL.
      APPEND VALUE #( %tky = <uploadData>-%tky
                      %msg = new_message( id       = '/ESRCC/DATAUPLOAD'
                                          number   = '000'
                                          v1       = <uploadData>-Application
                                          v2       = <uploadData>-CreatedBy
                                          severity = if_abap_behv_message=>severity-error ) )
             TO reported-uploadstaging.
      APPEND VALUE #( %tky = <uploadData>-%tky ) TO
                      failed-uploadstaging.
    ELSEIF <uploaddata>-filename IS NOT INITIAL.
      SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
        FROM /esrcc/upld_stg
        WHERE application     = @<uploaddata>-Application
          AND sub_application = @<uploaddata>-SubApplication
        " TODO: variable is assigned but never used (ABAP cleaner)
          AND status          = 'I'
        INTO @FINAL(_currentuploadeddata).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = <uploadData>-%tky
                        %msg = new_message( id       = '/ESRCC/DATAUPLOAD'
                                            number   = '000'
                                            v1       = <uploadData>-Application
                                            v2       = <uploadData>-CreatedBy
                                            severity = if_abap_behv_message=>severity-error ) )
               TO reported-uploadstaging.
        APPEND VALUE #( %tky = <uploadData>-%tky ) TO
                        failed-uploadstaging.
      ENDIF.
    ELSEIF <uploaddata>-filename IS INITIAL.
      APPEND VALUE #( %tky = <uploaddata>-%tky
                      %msg = new_message( id       = '/ESRCC/DATAUPLOAD'
                                          number   = '001'
                                          severity = if_abap_behv_message=>severity-error ) )
             TO reported-uploadstaging.
      APPEND VALUE #( %tky = <uploaddata>-%tky ) TO
                      failed-uploadstaging.
    ELSEIF <uploaddata>-application IS INITIAL OR <uploaddata>-SubApplication IS INITIAL.
      APPEND VALUE #( %tky = <uploaddata>-%tky
                      %msg = new_message( id       = '/ESRCC/DATAUPLOAD'
                                          number   = '002'
                                          severity = if_abap_behv_message=>severity-error ) )
             TO reported-uploadstaging.
      APPEND VALUE #( %tky = <uploaddata>-%tky ) TO
                      failed-uploadstaging.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
