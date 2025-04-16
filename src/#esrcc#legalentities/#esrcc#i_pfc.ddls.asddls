@EndUserText.label: 'Profit Center'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Pfc
  as select from /esrcc/pfc
  association to parent /ESRCC/I_Pfc_S   as _ProfitCenterAll on $projection.SingletonID = _ProfitCenterAll.SingletonID
  composition [0..*] of /ESRCC/I_PfcText as _PfcText
{
  key profit_center         as ProfitCenter,
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
      _ProfitCenterAll,
      _PfcText

}
