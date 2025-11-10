@EndUserText.label: 'License Type'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LicType
  as select from /esrcc/lictype
  association to parent /ESRCC/I_LicType_S as _LicenseTypeAll on $projection.SingletonID = _LicenseTypeAll.SingletonID
  composition [0..*] of /ESRCC/I_LicTypeText as _LicenseTypeText
{
  key license_type as LicenseType,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _LicenseTypeAll,
  _LicenseTypeText
  
}
