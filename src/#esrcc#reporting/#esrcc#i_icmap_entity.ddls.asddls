@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Charge-Out Receiver'
@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_ICMAP_ENTITY
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
  
  association [0..1] to /ESRCC/I_TRUEUP as _trueup
                      on _trueup.RootUUID            = $projection.RootUUID
                     and _trueup.ParentUUID          = $projection.ParentUUID                    
                     and _trueup.Receiversysid       = $projection.ReceiverSysId
                     and _trueup.Receivercompanycode = $projection.ReceiverCompanyCode
                     and _trueup.Receivingentity     = $projection.Receivingentity
                     and _trueup.Receivercostobject  = $projection.ReceiverCostObject
                     and _trueup.Receivercostcenter  = $projection.ReceiverCostCenter  
{

  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
      _ServiceCost._CostCenterCost.Fplv,
      _ServiceCost._CostCenterCost.Ryear,
      _ServiceCost._CostCenterCost.Poper,
      cast( _ServiceCost._CostCenterCost.Sysid as /esrcc/provider_sysid )                                             as Sysid,
      cast( _ServiceCost._CostCenterCost.Legalentity as /esrcc/provider_entity )                                      as Legalentity,
      cast( _ServiceCost._CostCenterCost.Ccode as /esrcc/provider_ccode )                                             as Ccode,
      cast( _ServiceCost._CostCenterCost.Costobject as /esrcc/provider_costobject )                                   as Costobject,
      cast( _ServiceCost._CostCenterCost.Costcenter as /esrcc/provider_costcenter )                                   as Costcenter,
      _ServiceCost._CostCenterCost.ProcessType,
      _ServiceCost.Serviceproduct,
      ReceiverSysId,
      ReceiverCompanyCode,
      Receivingentity,
      ReceiverCostObject,
      ReceiverCostCenter,
      ConsumptionUom                                                                                                  as Uom,
      _ServiceCost._CostCenterCost.Businessdivision,
      _ServiceCost._CostCenterCost.FunctionalArea,
      _ServiceCost._CostCenterCost.Profitcenter,
      _ServiceCost._CostCenterCost.Controllingarea,
      _ServiceCost.Servicetype,
      _ServiceCost.Transactiongroup,
      _ServiceCost.Chargeout,
      ContractId,
      ErpSalesOrder,
      Currency,
      Reckpi,
      Reckpishare,
      case when _trueup.AmountG is not initial then
      TotalChargeout + cast( _trueup.AmountG as abap.dec(23,2))
      else TotalChargeout 
      end as TotalChargeout,
      cast( _trueup.AmountG as abap.dec(23,2)) as TotalTrueupAmount,
      TotalChargeout as StdChargeout,
      TotalRecMarkup,
      RecValueaddMarkup,
      RecPassthroughMarkup,
      RecCostShare,
      RecValueadded,
      RecPassthrough,
      _ServiceCost._CostCenterCost.Stewardship,
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) as abap.dec(23,5))                as RecIncludedCost,
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) - RecCostShare as abap.dec(23,5)) as RecStewardship,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast(( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost as abap.dec(23,5))
      else 0 end                                                                                                      as RecExcludedCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) +
      (( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.VirtualCost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecVirtualTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) +
      (( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost ) as abap.dec(23,5))
      -
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.VirtualCost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecERPTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Origtotalcost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecOrigTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Passtotalcost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecPassTotalCost,

      Status,
      _ServiceCost._CostCenterCost.ChainId,
      _ServiceCost.OECD,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.legalentitydescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costobjectdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costcenterdescription,
      @Semantics.text: true
      _ServiceCost.Serviceproductdescription,
      @Semantics.text: true
      _ServiceCost.Transactiongroupdescription,
      @Semantics.text: true
      _ServiceCost.Servicetypedescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ccodedescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.functionalareadescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.businessdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.profitcenterdescription,
      @Semantics.text: true
      _ServiceCost.oecdDescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costdatasetdescription,
      @Semantics.text: true
      ccodedescription                                                                                                as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription                                                                                           as RecCostCenterdescription,
      @Semantics.text: true
      costobjectdescription                                                                                           as RecCostObjectdescription,
      @Semantics.text: true
      statusdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ProcessTypedescription,
      _ServiceCost._CostCenterCost.Country                                                                            as legalentitycountry,
      Country                                                                                                         as receivingentitycountry,
      _ServiceCost._CostCenterCost.LocalCurr                                                                          as legalentitycurrecy,
      ReceiverCurrency,
      _ServiceCost._CostCenterCost.Region                                                                             as legalentityregion,
      _ServiceCost._CostCenterCost.RegionDesc                                                                         as LegalEntityRegionDesc,
      ReceiverRegion,
      ReceiverRegionDesc,
      //Associations
      _ServiceCost._CostCenterCost._legalCountryText,
      _ReceivingCountryText
}
where
      Currencytype   =  'G'
  
