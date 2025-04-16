@EndUserText.label: 'Functional areas - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_FunctionalAreas
  as projection on /ESRCC/I_FunctionalAreas
{
  key FunctionalArea,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _FunctionalAreasAll  : redirected to parent /ESRCC/C_FunctionalAreas_S,
      _FunctionalAreasText : redirected to composition child /ESRCC/C_FunctionalAreasText,
      _FunctionalAreasText.Description : localized

}
