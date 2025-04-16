@EndUserText.label: 'Group Configuration'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_GroupConfig
  as select from    I_Language
    left outer join /esrcc/group as grp on grp.id = 1
  association        to parent /ESRCC/I_GroupConfig_S as _GroupConfigAll on  $projection.Id = _GroupConfigAll.SingletonID
  association [0..1] to I_CurrencyText                as _CurrencyText   on  _CurrencyText.Currency = $projection.GroupCurrency
                                                                         and _CurrencyText.Language = $session.system_language
  association [0..1] to /ESRCC/I_SIGN_FOR_VALUE       as _CostSignText   on  _CostSignText.Sign = $projection.CostSign
{
  key coalesce(grp.id, 1)       as Id,
      grp.group_currency        as GroupCurrency,
      grp.cost_sign             as CostSign,
      grp.conversion_rate_type  as ConversionRateType,
      @Semantics.user.createdBy: true
      grp.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      grp.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      grp.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      grp.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      grp.local_last_changed_at as LocalLastChangedAt,
      1                         as SingletonID,
      _GroupConfigAll,
      _CurrencyText,
      _CostSignText
}
where
  I_Language.Language = $session.system_language
