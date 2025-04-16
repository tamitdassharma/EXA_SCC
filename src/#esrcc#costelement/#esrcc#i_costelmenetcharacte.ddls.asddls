@EndUserText.label: 'Cost element characteristics'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CostElmenetCharacte
  as select from /esrcc/cstelmtch
  association        to parent /ESRCC/I_CostElmenetCharacte_S as _CostElementCharAll on $projection.SingletonID = _CostElementCharAll.SingletonID
  association [0..1] to /ESRCC/I_COSTTYPE                     as _CostTypeText       on _CostTypeText.Costtype = $projection.CostType
  association [0..1] to /ESRCC/I_POSTINGTYPE                  as _PostingTypeText    on _PostingTypeText.Postingtype = $projection.PostingType
  association [0..1] to /ESRCC/I_COSTIND                      as _CostIndText        on _CostIndText.costind = $projection.CostIndicator
  association [0..1] to /ESRCC/I_USAGECALCULATION             as _UsageTypeText      on _UsageTypeText.usagecal = $projection.UsageType
  association [0..1] to /ESRCC/I_REASON_F4                    as _ReasonText         on _ReasonText.Reasonid = $projection.ReasonId
  association [0..1] to /ESRCC/I_VALUESOURCE                  as _ValueSourceText    on _ValueSourceText.ValueSource = $projection.ValueSource
  association [0..1] to /ESRCC/I_COSTELEMENT_F4               as _CostElement        on _CostElement.Uuid = $projection.CostElementUuid
{
  key cst_elmnt_char_uuid   as CstElmntCharUuid,
      valid_from            as ValidFrom,
      valid_to              as ValidTo,
      cost_type             as CostType,
      posting_type          as PostingType,
      cost_indicator        as CostIndicator,
      usage_type            as UsageType,
      reason_id             as ReasonId,
      value_source          as ValueSource,
      cost_element_uuid     as CostElementUuid,
      _CostElement.Sysid,
      _CostElement.LegalEntity,
      _CostElement.CompanyCode,
      _CostElement.Costelement,
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

      _CostElementCharAll,
      _CostTypeText,
      _PostingTypeText,
      _CostIndText,
      _UsageTypeText,
      _ReasonText,
      _ValueSourceText,
      _CostElement

}
