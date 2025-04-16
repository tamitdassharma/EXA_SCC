@EndUserText.label: 'Legal Entity to Company Code - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LeCcode
  as projection on /ESRCC/I_LeCcode
{
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
  key Ccode,
      @ObjectModel.text.element: ['LegalentityDescription']
      Legalentity,
      Controllingarea,
      Active,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _SystemInfoText.Description as SysidDescription,
      @Semantics.text: true
      _LegalEntity.Description    as LegalentityDescription,
      @ObjectModel.text.element: ['EntitytypeDesc']
      _LegalEntity.Entitytype,
      @Semantics.text: true
      _LegalEntity.EntitytypeDesc,
      @ObjectModel.text.element: ['RoleDesc']
      _LegalEntity.Role,
      @Semantics.text: true
      _LegalEntity.RoleDesc,
      @ObjectModel.text.element: ['LocalCurrDescription']
      _LegalEntity.LocalCurr,
      @ObjectModel.text.element: ['CountryDescription']
      _LegalEntity.Country,
      @ObjectModel.text.element: ['RegionDesc']
      _LegalEntity.Region,
      @Semantics.text: true
      _LegalEntity.RegionDesc,
      @Semantics.text: true
      _LegalEntity.CountryName    as CountryDescription,
      //      CountryDescription,
      @Semantics.text: true
      _LegalEntity.CurrencyName   as LocalCurrDescription,
      //      LocalCurrDescription,
      _LeToCompanyCodeAll : redirected to parent /ESRCC/C_LeCcode_S,
      _CompanyCodeText    : redirected to composition child /ESRCC/C_CcodeText,
      _CompanyCodeText.Description : localized
}
