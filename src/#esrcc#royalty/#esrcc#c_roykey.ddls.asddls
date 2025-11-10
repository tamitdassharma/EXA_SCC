@EndUserText.label: 'Maintain Royalty Base Keys'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RoyKey
  as projection on /ESRCC/I_RoyKey
{
  key RoyaltyBaseKey,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _RoyKeyAll : redirected to parent /ESRCC/C_RoyKey_S,
  _RoyaltyKeyText : redirected to composition child /ESRCC/C_RoyKeyText,
  _RoyaltyKeyText.Description : localized
  
}
