@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Application Logs Interface'
define root view entity /ESRCC/I_ApplicationLogs
  as select from /esrcc/log_hdr
  composition [1..*] of /ESRCC/I_ApplicationLogItems as _log_items 
  association [0..*] to /ESRCC/I_InvalidRecords as _invalid_records on $projection.LogHeaderUUID = _invalid_records.LogHeaderUuid
  //  association [1..*] to DDCDS_CUSTOMER_DOMAIN_VALUE_T as _domain_values on  _domain_values.domain_name = 'SYMSGTY'
  //                                                                        and _domain_values.language    = $session.system_language
  //                                                                        and $projection.MessageType    = _domain_values.value_low
{
  key log_header_uuid           as LogHeaderUUID,
//  key _messages.log_uuid        as LogUUID,
//      _messages.parent_log_uuid as ParentLogUUID,
      application               as Application,
      sub_application           as SubApplication,
      run_number                as RunNumber,
      reporting_year            as ReportingYear,
      period_from               as PeriodFrom,
      period_to                 as PeriodTo,
      planning_version          as PlanningVersion,
      legal_entity              as LegalEntity,
      system_id                 as SystemId,
      company_code              as CompanyCode,
//      _messages.message_id      as MessageID,
//      _messages.message_number  as MessageNumber,
//      case _messages.message_type
//        when 'I' then 'Information'
//        when 'E' then 'Error'
//        when 'w' then 'Warning'
//        when 'S' then 'Success'
//      end                       as MessageType,
//      case _messages.message_type
//        when 'I' then 5
//        when 'E' then 1
//        when 'w' then 2
//        when 'S' then 3
//      end                       as MessageTypeCriticality,
//      _messages.message_v1      as MessageV1,
//      _messages.message_v2      as MessageV2,
//      _messages.message_v3      as MessageV3,
//      _messages.message_v4      as MessageV4,
      created_by                as CreatedBy,
//      _messages.created_at      as CreatedAt,
//      _messages.is_parent       as IsParent,
      _log_items, //Invalid Record Set
      _invalid_records
}
