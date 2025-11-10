@EndUserText.label: 'Maintain Hierarchy'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Hier1
  as projection on /ESRCC/I_Hier1
{
  key Hierarchy,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _HierarchyAll : redirected to parent /ESRCC/C_Hier1_S,
  _HierarchyText : redirected to composition child /ESRCC/C_Hier1Text,
  _HierarchyText.Description : localized
  
}
