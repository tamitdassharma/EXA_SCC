@EndUserText.label: 'Maintain TP Profile Text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_TpProfText
  as projection on /ESRCC/I_TpProfText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Tpprofile,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _TpProfile : redirected to parent /ESRCC/C_TpProf,
  _TpProfileAll : redirected to /ESRCC/C_TpProf_S
  
}
