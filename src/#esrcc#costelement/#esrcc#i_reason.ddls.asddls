@EndUserText.label: 'Cost Exclusion Inclusion Reason'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Reason
  as select from /esrcc/reason
  association        to parent /ESRCC/I_Reason_S  as _ReasonAll            on $projection.SingletonID = _ReasonAll.SingletonID
  composition [0..*] of /ESRCC/I_ReasonText       as _ReasonText
  association [0..1] to /ESRCC/I_USAGECALCULATION as _CalculationUsageText on _CalculationUsageText.usagecal = $projection.Calculationusage
{
  key reasonid                   as Reasonid,
      calculationusage           as Calculationusage,
      defaultflag                as Defaultflag,
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt,
      1                          as SingletonID,

      _CalculationUsageText,
      _ReasonAll,
      _ReasonText

}
