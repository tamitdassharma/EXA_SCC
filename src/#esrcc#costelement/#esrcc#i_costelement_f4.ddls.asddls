@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Element'

@Search.searchable: true
define view entity /ESRCC/I_COSTELEMENT_F4
  as select from /esrcc/cst_elmnt
  association [0..1] to /esrcc/cst_elmtt               as _CostelementText on  _CostelementText.cost_element_uuid = $projection.Uuid
                                                                           and _CostelementText.spras             = $session.system_language
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText       on  _CcodeText.Sysid       = $projection.Sysid
                                                                           and _CcodeText.Ccode       = $projection.CompanyCode
                                                                           and _CcodeText.Legalentity = $projection.LegalEntity
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText  on  _SystemInfoText.SystemId = $projection.Sysid
                                                                           and _SystemInfoText.Spras    = $session.system_language
{
      @UI.hidden: true
  key cost_element_uuid                 as Uuid,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Sysid' },
                                       additionalBinding: [{ element: 'Legalentity ', localElement: 'LegalEntity' },
                                                           { element: 'Ccode', localElement: 'CompanyCode'}],
                                       useForValidation: true }]
      sysid                             as Sysid,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Legalentity' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'Ccode', localElement: 'CompanyCode'}],
                                       useForValidation: true }]
      legal_entity                      as LegalEntity,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'Legalentity', localElement: 'LegalEntity'}],
                                       useForValidation: true }]
      company_code                      as CompanyCode,

      @ObjectModel.text.element: ['costelementdescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      cost_element                      as Costelement,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _CostelementText.description      as costelementdescription,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _CcodeText.ccodedescription       as CompanyCodeDescription,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _CcodeText.LegalentityDescription as LegalEntityDescription,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _SystemInfoText.Description       as SysidDescription,

      _SystemInfoText
}
