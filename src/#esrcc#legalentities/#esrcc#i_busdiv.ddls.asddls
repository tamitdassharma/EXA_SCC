@EndUserText.label: 'Business Division'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_BusDiv
  as select from /esrcc/bus_div
  association to parent /ESRCC/I_BusDiv_S   as _BusinessDivisionAll on $projection.SingletonID = _BusinessDivisionAll.SingletonID
  composition [0..*] of /ESRCC/I_BusDivText as _BusinessDivisioText
{
  key business_division     as BusinessDivision,
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
      _BusinessDivisionAll,
      _BusinessDivisioText

}
