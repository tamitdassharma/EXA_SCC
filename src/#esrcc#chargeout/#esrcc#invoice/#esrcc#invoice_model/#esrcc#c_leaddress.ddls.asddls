@EndUserText.label: 'Legal Entity Address - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LeAddress
  as projection on /ESRCC/I_LeAddress
{
      @ObjectModel.text.element: ['LegalEntityDescription']
  key LegalEntity,
      CustomerNumber,
      ContactPerson,
      Street1,
      Street2,
      City,
      Zip,
      State,
      Country,
      Telephone,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LegalEntityText.Description as LegalEntityDescription,
      _LeAddressAll : redirected to parent /ESRCC/C_LeAddress_S

}
