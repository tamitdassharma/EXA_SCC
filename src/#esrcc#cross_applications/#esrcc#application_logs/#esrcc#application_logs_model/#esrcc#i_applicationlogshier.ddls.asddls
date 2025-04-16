@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy interface for Application Logs'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ApplicationLogsHier
  as select from /esrcc/log_hdr
  composition [1..*] of /ESRCC/I_AppLogItemsHeaderHier as _log_items
{
  key log_header_uuid                as hid,
      ''                             as parent_hid,
      0                              as hier_level,
      cast('expand' as abap.char(8)) as drilldown_state,
      application                    as Application,
      sub_application                as SubApplication,
      ltrim( run_number, ' ')        as RunNumber,
      reporting_year                 as ReportingYear,
      period_from                    as PeriodFrom,
      period_to                      as PeriodTo,
      planning_version               as PlanningVersion,
      legal_entity                   as LegalEntity,
      system_id                      as SystemId,
      company_code                   as CompanyCode,
      created_by                     as CreatedBy,
      created_at                     as CreatedAt,
      log_header_uuid                as RootUUID,
      _log_items
}
