@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Allocation Key Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_AllocationKeyText
  as select from /esrcc/allockeyt
  association [1..1] to /ESRCC/I_AllocationKey_S      as _AllocationKeyAll on  $projection.SingletonID = _AllocationKeyAll.SingletonID
  association        to parent /ESRCC/I_AllocationKey as _AllocationKey    on  $projection.Allocationkey = _AllocationKey.Allocationkey
  association [0..*] to I_LanguageText                as _LanguageText     on  $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key allocationkey         as Allocationkey,
      @Semantics.text: true
      description           as Description,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _AllocationKeyAll,
      _AllocationKey,
      _LanguageText

}
