@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Data Upload Staging Interface'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define root view entity /ESRCC/I_UploadStaging
  as select from /esrcc/upld_stg as _upload_staging

  association [0..1] to /ESRCC/I_UploadScenarios as _UploadScenarios on _UploadScenarios.SubApplication = $projection.SubApplication
  association [0..1] to /ESRCC/I_UploadStatuses  as _UploadStatus    on _UploadStatus.Status = $projection.Status
  association [0..1] to /ESRCC/I_UploadTables    as _UploadTables    on _UploadTables.tableName = $projection.TableName

{
  key upload_uuid                                                         as UploadUUID,

      'FUP'                                                               as Application,
      sub_application                                                     as SubApplication,

      @Semantics.largeObject: {
                 mimeType: 'MimeType',
                 fileName: 'Filename',
      //              acceptableMimeTypes: [ 'text/csv' ],
                 contentDispositionPreference: #INLINE
             }
      data_stream                                                         as DataStream,

      @Semantics.mimeType: true
      mime_type                                                           as MimeType,

      filename                                                            as Filename,
      table_name                                                          as TableName,
      status                                                              as Status,

      @Semantics.user.createdBy: true
      created_by                                                          as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at                                                          as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by                                                     as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                                     as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                                               as LocalLastChangedAt,

      case _upload_staging.status
        when 'I' then 2
        when 'C' then 3
        when 'E' then 1
        when 'W' then 2
        else
        0
       end                                                                as StatusCriticallity,

      case sub_application
        when 'FLI' then 'Cost Base Line Items'
        when 'FPD' then 'Service Capacities'
        when 'FAB' then 'Allocation Base Keys'
        when 'FCD' then 'Service Consumptions'
        else ' '
      end                                                                 as TemporaryFileName,

      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' as TemporaryMimetype,

      // asccosiations
      _UploadScenarios,
      _UploadStatus,

      @ObjectModel.filter.enabled: false
      @ObjectModel.sort.enabled: false
      _UploadTables
}
