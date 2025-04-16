@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

define view entity /ESRCC/C_WfUsrM
  as projection on /ESRCC/I_WfUsrM
{
  key Usergroup,
  key Userid,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      _UserGroup    : redirected to parent /ESRCC/C_WfUsrG,
      _UserGroupAll : redirected to /ESRCC/C_WfUsrG_S
}
