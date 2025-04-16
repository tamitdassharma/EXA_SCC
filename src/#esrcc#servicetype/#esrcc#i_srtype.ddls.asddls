@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Type'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrType
  as select from /esrcc/srtype
  association to parent /ESRCC/I_SrType_S   as _ServiceTypeAll on $projection.SingletonID = _ServiceTypeAll.SingletonID
  composition [0..*] of /ESRCC/I_SrTypeText as _ServiceTypeText
{
  key srvtype               as Srvtype,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _ServiceTypeAll,
      _ServiceTypeText

}
