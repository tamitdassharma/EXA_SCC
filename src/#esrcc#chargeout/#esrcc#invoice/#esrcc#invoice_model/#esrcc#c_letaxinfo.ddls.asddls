@EndUserText.label: 'Tax Information - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LeTaxInfo
  as projection on /ESRCC/I_LeTaxInfo
{
@ObjectModel.text.element: ['LegalEntityDescription']
  key LegalEntity,
      VatNumber,
      TaxRegistationNumber,
      TaxPercentage,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LegalEntityText.Description as LegalEntityDescription,
      _TaxInformationAll : redirected to parent /ESRCC/C_LeTaxInfo_S

}
