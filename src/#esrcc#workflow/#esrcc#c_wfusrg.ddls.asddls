@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'User Group for Work Flow - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_WfUsrG
  as projection on /ESRCC/I_WfUsrG
{
  key Usergroup,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _UserGroupAll : redirected to parent /ESRCC/C_WfUsrG_S,
      _UserMapping  : redirected to composition child /ESRCC/C_WfUsrM
}
