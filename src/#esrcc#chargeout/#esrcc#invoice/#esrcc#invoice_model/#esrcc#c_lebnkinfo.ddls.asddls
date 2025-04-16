@EndUserText.label: 'Bank Information - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LeBnkInfo
  as projection on /ESRCC/I_LeBnkInfo
{
      @ObjectModel.text.element: ['LegalEntityDescription']
  key LegalEntity,
      BankAccountNumber,
      BicCode,
      PaymentTerms,
      FreeText,
      ContactPerson,
      AgreementId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LegalEntityText.Description as LegalEntityDescription,
      _BankInformationAll : redirected to parent /ESRCC/C_LeBnkInfo_S

}
