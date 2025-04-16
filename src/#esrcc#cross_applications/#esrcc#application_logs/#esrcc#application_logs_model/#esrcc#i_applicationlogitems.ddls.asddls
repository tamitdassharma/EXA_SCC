@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Application Logs Items Interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ApplicationLogItems
  as select from /esrcc/log_item
  association to parent /ESRCC/I_ApplicationLogs as _log_header on $projection.LogHeaderUuid = _log_header.LogHeaderUUID
{
  key log_uuid        as LogUuid,
      log_header_uuid as LogHeaderUuid,
      parent_log_uuid as ParentLogUuid,
      message_id      as MessageId,
      message_number  as MessageNumber,
      case message_type
        when 'I' then 'Information'
        when 'E' then 'Error'
        when 'w' then 'Warning'
        when 'S' then 'Success'
        else ''
      end             as MessageType,
      case message_type
        when 'I' then 5
        when 'E' then 1
        when 'w' then 2
        when 'S' then 3
        else 0
      end             as MessageTypeCriticality,
      message_v1      as MessageV1,
      message_v2      as MessageV2,
      message_v3      as MessageV3,
      message_v4      as MessageV4,
      created_at      as CreatedAt,
      is_parent       as IsParent,
      _log_header
}
