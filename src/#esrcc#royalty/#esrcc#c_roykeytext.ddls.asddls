@EndUserText.label: 'Maintain Royalty Base Keys Text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RoyKeyText
  as projection on /ESRCC/I_RoyKeyText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key RoyaltyBaseKey,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _RoyaltyKey : redirected to parent /ESRCC/C_RoyKey,
  _RoyKeyAll : redirected to /ESRCC/C_RoyKey_S
  
}
