@EndUserText.label: 'Cost Object Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CstObjctText
  as projection on /ESRCC/I_CstObjctText
{
      @ObjectModel.text.element: [ 'LanguageName' ]
      @Consumption.valueHelpDefinition: [ {
        entity: {
          name: 'I_Language',
          element: 'Language'
        }
      } ]
  key Spras,
  key CostObjectUuid,
      Description,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LanguageText.LanguageName : localized,
      _CostObject    : redirected to parent /ESRCC/C_CstObjct,
      _CostObjectAll : redirected to /ESRCC/C_CstObjct_S

}
