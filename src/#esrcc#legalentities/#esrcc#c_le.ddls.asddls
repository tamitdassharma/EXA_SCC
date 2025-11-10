@EndUserText.label: 'Legal Entity - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LE
  as projection on /ESRCC/I_LE
{
  key Legalentity,
      @ObjectModel.text.element: ['CountryDesc']
      Country,
      @ObjectModel.text.element: ['LocalCurrDesc']
      LocalCurr,
      @ObjectModel.text.element: ['EntitytypeDesc']
      Entitytype,
      @ObjectModel.text.element: ['RegionDesc']
      Region,
      @ObjectModel.text.element: ['RoleDesc']
      Role,
      @ObjectModel.text.element: ['TpProfileDesc']
      TpProfile,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _EntityType.text       as EntitytypeDesc,
      @Semantics.text: true
      _Region.text           as RegionDesc,
      @Semantics.text: true
      _Role.text             as RoleDesc,
      @Semantics.text: true
      _Country.CountryName   as CountryDesc,
      @Semantics.text: true
      _Currency.CurrencyName as LocalCurrDesc,
      @Semantics.text: true
      _TPprofileText.Description as TpProfileDesc,

      _LegalEntityAll  : redirected to parent /ESRCC/C_LE_S,
      _LegalEntityText : redirected to composition child /ESRCC/C_LEText,
      _LegalEntityText.Description : localized
}
