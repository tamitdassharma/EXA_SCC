//@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Upload Staging'
//@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}

@Metadata.allowExtensions: true
define root view entity /ESRCC/C_UploadStaging
  provider contract transactional_query
  as projection on /ESRCC/I_UploadStaging
{



  key     UploadUUID,
          Application,
          @ObjectModel.text.element: [ 'applicationtext' ]



          SubApplication,
          @Semantics.largeObject: {
                  mimeType: 'MimeType',
                  fileName: 'Filename',
                  contentDispositionPreference: #INLINE }

          DataStream,
          @Semantics.mimeType: true

          MimeType,


          Filename,
          @Semantics.largeObject: {
                 mimeType: 'TemporaryMimetype',
                 fileName: 'TemporaryFileName',
                 contentDispositionPreference: #INLINE
             }
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_DOWNLOAD_TEMPLATE'

  virtual TemporaryDataStream : abap.rawstring(0),
//          @Semantics.mimeType: true

          TemporaryMimetype,

          TemporaryFileName,



          TableName,
          @ObjectModel.text.element: [ 'uploadstatustext' ]


          Status,
          @Semantics.user.createdBy: true

          CreatedBy,

          @Semantics.systemDateTime.createdAt: true
          CreatedAt,

          @Semantics.user.lastChangedBy: true
          LastChangedBy,

          @Semantics.systemDateTime.lastChangedAt: true
          LastChangedAt,
          @Semantics.systemDateTime.localInstanceLastChangedAt: true
          LocalLastChangedAt,

          StatusCriticallity,
          /* Associations */

          _UploadScenarios.text as ApplicationText,

          _UploadStatus.text    as UploadStatusText
}
