@EndUserText.label: 'Hierarchy Definition'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_HierDef
  as select from /esrcc/hier_def
  association        to parent /ESRCC/I_HierDef_S      as _HierDefAll         on  $projection.SingletonID = _HierDefAll.SingletonID
  association [0..1] to /esrcc/hier1_t                 as _Hierarchy1Text     on  _Hierarchy1Text.hierarchy = $projection.Hierarchy1
                                                                              and _Hierarchy1Text.spras     = $session.system_language
  association [0..1] to /esrcc/hier2_t                 as _Hierarchy2Text     on  _Hierarchy2Text.hierarchy = $projection.Hierarchy2
                                                                              and _Hierarchy2Text.spras     = $session.system_language
  association [0..1] to /esrcc/hier3_t                 as _Hierarchy3Text     on  _Hierarchy3Text.hierarchy = $projection.Hierarchy3
                                                                              and _Hierarchy3Text.spras     = $session.system_language
  association [0..1] to /esrcc/hier4_t                 as _Hierarchy4Text     on  _Hierarchy4Text.hierarchy = $projection.Hierarchy4
                                                                              and _Hierarchy4Text.spras     = $session.system_language
  association [0..1] to /ESRCC/I_CoRuleText            as _RuleText           on  _RuleText.RuleId = $projection.RuleId
                                                                              and _RuleText.Spras  = $session.system_language
  association [0..1] to /ESRCC/I_STATUS                as _WorkflowStatusText on  _WorkflowStatusText.Status = $projection.WorkflowStatus
  association [0..1] to /ESRCC/I_CurrencyDerivationTyp as _CurrencyTypeText   on  _CurrencyTypeText.CurrencyType = $projection.CurrencyDerivationType
{
  key hierarchy1                  as Hierarchy1,
  key hierarchy2                  as Hierarchy2,
  key hierarchy3                  as Hierarchy3,
  key hierarchy4                  as Hierarchy4,
  key valid_from                  as ValidFrom,
      valid_to                    as ValidTo,
      rule_id                     as RuleId,
      srv_prd_def                 as SrvPrdDef,
      srv_rec_def                 as SrvRecDef,
      stewardship                 as Stewardship,
      chain_id                    as ChainId,
      currency_derivation_type    as CurrencyDerivationType,
      is_hub                      as IsHub,
      workflow_id                 as WorkflowId,
      workflow_status             as WorkflowStatus,
      comment_id                  as CommentId,

      case workflow_status
      -- Red
        when 'R' then 1
        when 'E' then 1
        when 'O' then 1

      -- Yellow
        when 'D' then 2
        when 'W' then 2
        when 'P' then 2
        when 'J' then 2
        when 'L' then 2

      -- Green
        when 'A' then 3
        when 'F' then 3
        else 0
      end                         as WorkflowStatusCriticality,
      ''                          as WorkflowInternalStatus,
      cast('' as /esrcc/comment ) as Comments,

      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by             as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at             as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at       as LocalLastChangedAt,
      1                           as SingletonID,
      _HierDefAll,

      _Hierarchy1Text,
      _Hierarchy2Text,
      _Hierarchy3Text,
      _Hierarchy4Text,
      _RuleText,
      _WorkflowStatusText,
      _CurrencyTypeText

}
