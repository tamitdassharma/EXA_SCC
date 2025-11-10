@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Royalty Base Value'

define root view entity /ESRCC/I_RoyaltyBaseValue
  as select from /esrcc/roybasval
  association [1..1] to /ESRCC/I_COSCEN_NOAUTH_F4 as _CostCenter     on  _CostCenter.CostObjectUuid = $projection.CostObjectUuid
  association [0..1] to /ESRCC/I_RoyaltyBaseKeyF4 as _RoyaltyBaseKey on  _RoyaltyBaseKey.RoyaltyBaseKey = $projection.RoyaltyBaseKey
  association [0..1] to /ESRCC/I_License_F4       as _license        on  _license.License = $projection.License

  association        to I_UnitOfMeasureText       as _UomText        on  _UomText.UnitOfMeasure_E = $projection.Uom
                                                                     and _UomText.Language        = $session.system_language
  association [0..1] to I_CurrencyText            as _CurrencyText   on  _CurrencyText.Currency = $projection.Currency
                                                                     and _CurrencyText.Language = $session.system_language
{
  key uuid                   as Uuid,
      ryear                  as Ryear,
      poper                  as Poper,
      fplv                   as Fplv,
      royalty_base_key       as RoyaltyBaseKey,
      @Semantics.amount.currencyCode: 'Currency'
      amountvalue            as AmountValue,
      @Semantics.quantity.unitOfMeasure: 'uom'
      unitvalue              as UnitValue,
      uom                    as Uom,
      currency               as Currency,
      cost_object_uuid       as CostObjectUuid,
      license                as License,
      valid_on               as ValidOn,

//      _CostCenter.Sysid,
//      _CostCenter.LegalEntity,
//      _CostCenter.CompanyCode,
//      _CostCenter.Costobject as CostObject,
//      _CostCenter.Costcenter as CostCenter,
      
      cast( _CostCenter.Sysid       as /esrcc/licensee_sysid preserving type )       as Sysid,
      cast( _CostCenter.LegalEntity as /esrcc/licensee_legalentity preserving type ) as LegalEntity,
      cast( _CostCenter.CompanyCode as /esrcc/licensee_ccode preserving type )       as CompanyCode,
      cast( _CostCenter.Costobject  as /esrcc/licensee_costobject preserving type )  as CostObject,
      cast( _CostCenter.Costcenter  as /esrcc/licensee_costcenter preserving type )  as CostCenter,
      

      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,

      _CostCenter,
      _license,
      _RoyaltyBaseKey,
      _UomText,
      _CurrencyText
}
