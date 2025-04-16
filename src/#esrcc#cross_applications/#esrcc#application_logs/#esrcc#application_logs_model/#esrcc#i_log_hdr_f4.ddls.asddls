@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Application Logs'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_LOG_HDR_F4
  as select from /esrcc/log_hdr
  association [0..1] to /ESRCC/I_APPLICATION           as _AppText         on  _AppText.Application = $projection.Application
  association [0..1] to /ESRCC/I_SUB_APPLICATION       as _SubAppText      on  _SubAppText.SubApplication = $projection.SubApplication
  association [0..*] to /ESRCC/I_SystemInformationText as _SystemIdText    on  _SystemIdText.SystemId = $projection.SystemId
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText       on  _CcodeText.Sysid = $projection.SystemId
                                                                           and _CcodeText.Ccode = $projection.CompanyCode
  association [0..1] to /ESRCC/I_LegalEntityAll_F4     as _LegalEntityText on  _LegalEntityText.Legalentity = $projection.LegalEntity
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key log_header_uuid              as LogHeaderUuid,

      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['ApplicationDescription']
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/ESRCC/I_APPLICATION', element: 'Application' }, useForValidation: true }]
      application                  as Application,

      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['SubApplicationDescription']
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/ESRCC/I_SUB_APPLICATION', element: 'SubApplication' }, useForValidation: true }]
      sub_application              as SubApplication,

      run_number                   as RunNumber,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      reporting_year               as ReportingYear,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      period_from                  as PeriodFrom,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      period_to                    as PeriodTo,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      planning_version             as PlanningVersion,

      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.association: '_SystemIdText'
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/ESRCC/I_SystemInformation_F4', element: 'Systemid' },
                                           useForValidation: true }]
      system_id                    as SystemId,

      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['CompanyCodeDescription']
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                           additionalBinding: [{ element: 'Sysid', localElement: 'SystemId' }],
                                           useForValidation: true }]
      company_code                 as CompanyCode,

      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['LegalEntityDescription']
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' },
                                           useForValidation: true }]
      legal_entity                 as LegalEntity,

      @Consumption.filter.hidden: true
      created_by                   as CreatedBy,

      @Consumption.filter.hidden: true
      _AppText.text                as ApplicationDescription,
      @Consumption.filter.hidden: true
      _SubAppText.text             as SubApplicationDescription,
      @Consumption.filter.hidden: true
      _CcodeText.ccodedescription  as CompanyCodeDescription,
      @Consumption.filter.hidden: true
      _LegalEntityText.Description as LegalEntityDescription,

      _SystemIdText
}
