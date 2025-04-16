@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Cross Charging File Upload Logs'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_FileUploadLogs
  as select from /esrcc/fu_logs
{
  key msg_ref_id     as MsgRefId,
  key upload_id      as UploadId,
      sequence       as Sequence,
      message_id     as MessageId,
      message_number as MessageNumber,
      message_type   as MessageType,
      message_text   as MessageText,
      message_v1     as MessageV1,
      message_v2     as MessageV2,
      message_v3     as MessageV3,
      message_v4     as MessageV4

}
