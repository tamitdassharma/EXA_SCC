@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Provider'

@Search.searchable: true
@Analytics.dataCategory: #DIMENSION
define view entity /ESRCC/I_LEGALENTITY_F4
  as select from /ESRCC/I_LegalEntityAll_F4
{

      @ObjectModel.text.element: ['Description']
  key Legalentity,
      Entitytype,
      Role,
      LocalCurr,
      Region,
      Country,

      Description,
      RegionDesc,
      RoleDesc,
      EntitytypeDesc,
      CountryName,
      CurrencyName,

      _CountryText,
      _CurrencyText
}
where
     Role = 'R1'
  or Role = 'R3'
