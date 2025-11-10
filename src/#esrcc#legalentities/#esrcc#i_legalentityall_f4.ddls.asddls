@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Legal Entity'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity /ESRCC/I_LegalEntityAll_F4
  as select from /esrcc/le
  association [0..1] to /esrcc/le_t         as _Text         on  _Text.legalentity = $projection.Legalentity
                                                             and _Text.spras       = $session.system_language
  association [0..1] to /ESRCC/I_REGION     as _Region       on  _Region.Region = $projection.Region
  association [0..1] to /ESRCC/I_ROLE       as _Role         on  _Role.Role = $projection.Role
  association [0..1] to /ESRCC/I_ENTITYTYPE as _EntityType   on  _EntityType.Entitytype = $projection.Entitytype
  association [0..1] to I_CurrencyText      as _CurrencyText on  _CurrencyText.Currency = $projection.LocalCurr
                                                             and _CurrencyText.Language = $session.system_language
  association [0..1] to I_CountryText       as _CountryText  on  _CountryText.Country  = $projection.Country
                                                             and _CountryText.Language = $session.system_language
  association [0..1] to /ESRCC/I_TPPROFILE  as _tpprofile    on  _tpprofile.TpProfile  = $projection.TpProfile
                                                             
{
      @ObjectModel.text.element: ['Description']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #HIGH }
  key legalentity       as Legalentity,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_ENTITYTYPE', element: 'Entitytype' } }]
      @ObjectModel.text.element: ['EntitytypeDesc']
      @UI.textArrangement: #TEXT_LAST
      entitytype        as Entitytype,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_Role', element: 'Role' } }]
      @ObjectModel.text.element: ['RoleDesc']
      @UI.textArrangement: #TEXT_LAST
      role              as Role,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_TPPROFILE', element: 'TpProfile' } }]
      @ObjectModel.text.element: ['TpProfileDesc']
      @UI.textArrangement: #TEXT_LAST
      /esrcc/le.tpprofile as TpProfile,

      @ObjectModel.text.element: [ 'CurrencyName' ]
      @Consumption.filter.hidden: true
      @UI.textArrangement: #TEXT_LAST
      local_curr        as LocalCurr,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_REGION', element: 'Region' } }]
      @ObjectModel.text.element: ['RegionDesc']
      @UI.textArrangement: #TEXT_LAST
      region            as Region,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Country', element: 'Country' }, useForValidation: true } ]
      @ObjectModel.text.element: [ 'CountryName' ]
      @EndUserText.label: 'Country'
      @UI.textArrangement: #TEXT_LAST
      country           as Country,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9, ranking: #MEDIUM }
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Text.description as Description,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Region.text      as RegionDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Role.text        as RoleDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _tpprofile.text   as TpProfileDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _EntityType.text  as EntitytypeDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _CountryText.CountryName,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _CurrencyText.CurrencyName,

      _CountryText,
      _CurrencyText
}
