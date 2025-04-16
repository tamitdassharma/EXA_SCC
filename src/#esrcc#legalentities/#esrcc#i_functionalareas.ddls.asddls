@EndUserText.label: 'Functional Area'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_FunctionalAreas
  as select from /esrcc/fnc_area
  association to parent /ESRCC/I_FunctionalAreas_S   as _FunctionalAreasAll on $projection.SingletonID = _FunctionalAreasAll.SingletonID
  composition [0..*] of /ESRCC/I_FunctionalAreasText as _FunctionalAreasText
{
  key functional_area       as FunctionalArea,
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
      _FunctionalAreasAll,
      _FunctionalAreasText

}
