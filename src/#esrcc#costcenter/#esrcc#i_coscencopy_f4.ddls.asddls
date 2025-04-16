@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Object and Number'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_COSCENCOPY_F4
  as select from /esrcc/cst_objct as cst_object
//  association [0..1] to /esrcc/cst_objtt           as _Text                 on  _Text.cost_object_uuid = $projection.CostObjectUuid
//                                                                            and _Text.spras            = $session.system_language
//  association [0..1] to /ESRCC/I_COMPANYCODES_F4   as _CcodeText            on  _CcodeText.Sysid       = $projection.Sysid
//                                                                            and _CcodeText.Ccode       = $projection.CompanyCode
//                                                                            and _CcodeText.Legalentity = $projection.LegalEntity
//  association [0..1] to /ESRCC/I_COSTOBJECTS       as _CostObjTypeText      on  _CostObjTypeText.Costobject = $projection.Costobject
//  association [0..1] to /ESRCC/I_PROFITCENTER_F4   as _ProfitCenterText     on  _ProfitCenterText.ProfitCenter = $projection.ProfitCenter
//  association [0..1] to /ESRCC/I_BUSINESSDIV_F4    as _BusinessDivisionText on  _BusinessDivisionText.BusinessDivision = $projection.BusinessDivision
//  association [0..1] to /ESRCC/I_BILLINGFREQ       as _BillingFreqText      on  _BillingFreqText.Billingfreq = $projection.Billfrequency
//  association [0..1] to /ESRCC/I_FunctionalArea_F4 as _FunctionalAreaText   on  _FunctionalAreaText.FunctionalArea = $projection.FunctionalArea
{
      @UI.hidden: true
  key cost_object_uuid                          as CostObjectUuid,

//      @ObjectModel.text.element: [ 'SysidDescription' ]
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @UI.lineItem: [{ position: 1 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' }}]
//      @Consumption.filter.hidden: true
      sysid                                     as Sysid
//
////      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @UI.lineItem: [{ position: 2 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' }}]
//      legal_entity                              as LegalEntity,
//
////      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @UI.lineItem: [{ position: 3 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' }}]
//      company_code                              as CompanyCode,
//
////      @ObjectModel.text.element: [ 'CostObjectDescription' ]
//      @UI.lineItem: [{ position: 4 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
//      cost_object                               as Costobject,
//
////      @ObjectModel.text.element: [ 'Description' ]
//      @UI.lineItem: [{ position: 5 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      cost_center                               as Costcenter,
//
////      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
//      @UI.lineItem: [{ position: 6 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_FunctionalArea_F4', element: 'FunctionalArea' }}]
//      functional_area                           as FunctionalArea,
//
////      @ObjectModel.text.element: [ 'ProfitCenterDescription' ]
//      @UI.lineItem: [{ position: 7 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_PROFITCENTER_F4', element: 'ProfitCenter' }}]
//      profit_center                             as ProfitCenter,
//
////      @ObjectModel.text.element: [ 'BusinessDivisionDescription' ]
//      @UI.lineItem: [{ position: 8 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BUSINESSDIV_F4', element: 'BusinessDivision' }}]
//      business_division                         as BusinessDivision,
//
////      @ObjectModel.text.element: [ 'BillfrequencyDescription' ]
//      @UI.lineItem: [{ position: 9 }]
//      @UI.textArrangement: #TEXT_LAST
//      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BILLINGFREQ', element: 'Billingfreq' }}]
//      billing_frequency                         as Billfrequency

//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _Text.description                         as Description,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _CcodeText._SystemText.Description        as SysidDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _CcodeText.ccodedescription               as CompanyCodeDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _CcodeText.LegalentityDescription         as LegalEntityDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _CostObjTypeText.text                     as CostObjectDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _ProfitCenterText.profitcenterdescription as ProfitCenterDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _BusinessDivisionText.Description         as BusinessDivisionDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _BillingFreqText.text                     as BillfrequencyDescription,
//
//      @Semantics.text: true
//      @Consumption.filter.hidden: true
//      _FunctionalAreaText.Description           as FunctionalAreaDescription

}
