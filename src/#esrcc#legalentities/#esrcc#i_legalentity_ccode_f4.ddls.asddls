@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Legal Entity to Company Code'

@Search.searchable: true
define view entity /ESRCC/I_LEGALENTITY_CCODE_F4
  as select from /esrcc/le_ccode
  association [0..*] to /ESRCC/I_SystemInformationText as _SysInfoText  on  _SysInfoText.SystemId = $projection.Sysid
  association [0..1] to /ESRCC/I_LegalEntityAll_F4     as _LegalEntity  on  _LegalEntity.Legalentity = $projection.Legalentity
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CompanyCode  on  _CompanyCode.Sysid = $projection.Sysid
                                                                        and _CompanyCode.Ccode = $projection.Ccode
  association [0..*] to I_CurrencyText                 as _CurrencyText on  _CurrencyText.Currency = $projection.localcurr
  association [0..*] to I_CountryText                  as _CountryText  on  _CountryText.Country = $projection.country
{
      @UI: { lineItem: [{ position: 1 }],
             selectionField: [{ position: 1 }],
             textArrangement: #TEXT_LAST }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @ObjectModel.text.association: '_SysInfoText'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key sysid                         as Sysid,

      @UI: { lineItem: [{ position: 3 }],
             selectionField: [{ position: 3 }],
             textArrangement: #TEXT_LAST }
      @ObjectModel.text: { element: ['CcodeDesc'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key ccode                         as Ccode,

      @UI: { lineItem: [{ position: 2 }],
             selectionField: [{ position: 2 }],
             textArrangement: #TEXT_LAST }
      @ObjectModel.text: { element: ['LeDesc'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' } }]
      legalentity                   as Legalentity,

      @Consumption: { filter.hidden: true }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Semantics.text: true
      _LegalEntity.Description      as LeDesc,

      @UI: { lineItem: [{ position: 6 }], textArrangement: #TEXT_LAST }
      @ObjectModel.text.association: '_CountryText'
      @EndUserText.label: 'Country'
      _LegalEntity.Country,

      @UI: { lineItem: [{ position: 4 }],
             textArrangement: #TEXT_LAST }
      @Consumption: { filter.hidden: true }
      @ObjectModel.text: { element: ['EntitytypeDesc'] }
      _LegalEntity.Entitytype,

      @Consumption: { filter.hidden: true }
      @Semantics.text: true
      _LegalEntity.EntitytypeDesc,

      @UI: { lineItem: [{ position: 7 }], textArrangement: #TEXT_LAST }
      @ObjectModel.text.association: '_CurrencyText'
      @Consumption: { filter.hidden: true }
      _LegalEntity.LocalCurr,

      @UI: { lineItem: [{ position: 5 }],
           textArrangement: #TEXT_LAST }
      @Consumption: { filter.hidden: true }
      @ObjectModel.text: { element: ['RegionDesc'] }
      _LegalEntity.Region,

      @Consumption: { filter.hidden: true }
      @Semantics.text: true
      _LegalEntity.RegionDesc,

      @Consumption: { filter.hidden: true }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Semantics.text: true
      _CompanyCode.ccodedescription as CcodeDesc,

      _CurrencyText,
      _CountryText,
      _SysInfoText
}
where
  active = 'X';
