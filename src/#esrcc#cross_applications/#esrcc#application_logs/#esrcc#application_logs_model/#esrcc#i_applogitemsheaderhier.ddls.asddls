@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'App Logs Items Hdr Hierarchy interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_AppLogItemsHeaderHier
  as select from /esrcc/log_item
  association to parent /ESRCC/I_ApplicationLogsHier  as _log_header on $projection.parent_hid = _log_header.hid
  composition [1..*] of /ESRCC/I_AppLogItemsChildHier as _log_items_child
{
  key log_uuid                        as hid,
      log_header_uuid                 as parent_hid,
      1                               as hier_level,
      cast('exapand' as abap.char(8)) as drilldown_state,
      parent_log_uuid                 as ParentLogUuid,
      serial_number                   as SerialNumber,
      message_id                      as MessageId,
      message_number                  as MessageNumber,
      case message_type
        when 'I' then 'Information'
        when 'E' then 'Error'
        when 'W' then 'Warning'
        when 'S' then 'Success'
        else 'None'
      end                             as MessageType,
      case message_type
        when 'I' then 5
        when 'E' then 1
        when 'W' then 2
        when 'S' then 3
        else 0
      end                             as MessageTypeCriticality,
      message_v1                      as MessageV1,
      message_v2                      as MessageV2,
      message_v3                      as MessageV3,
      message_v4                      as MessageV4,
      created_at                      as CreatedAt,
      is_parent                       as IsParent,
      log_header_uuid                 as RootUUID,
      _log_items_child,
      _log_header
}
where
  parent_log_uuid is initial
