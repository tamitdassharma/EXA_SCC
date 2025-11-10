@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chargout to Receivers Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define root view entity /ESRCC/I_CHG_RECSHARE_TRUEUP
  as select from /ESRCC/I_CHG_RECEIVERS_TRUEUP as chargeoutreckpi
  
  association [0..1] to /ESRCC/I_INDTOTALKPISHARE_TRUP as _chargeoutreckpisum     
            on  _chargeoutreckpisum.fplv               = $projection.fplv
           and _chargeoutreckpisum.ryear               = $projection.ryear
           and _chargeoutreckpisum.poper               = $projection.poper
           and _chargeoutreckpisum.sysid               = $projection.sysid
           and _chargeoutreckpisum.legalentity         = $projection.legalentity
           and _chargeoutreckpisum.ccode               = $projection.ccode
           and _chargeoutreckpisum.costobject          = $projection.costobject
           and _chargeoutreckpisum.costcenter          = $projection.costcenter
           and _chargeoutreckpisum.serviceproduct      = $projection.serviceproduct
           and _chargeoutreckpisum.ReceiverSysId       = $projection.ReceiverSysId
           and _chargeoutreckpisum.ReceiverCompanyCode = $projection.ReceiverCompanyCode
           and _chargeoutreckpisum.ReceivingEntity     = $projection.ReceivingEntity
           and _chargeoutreckpisum.ReceiverCostObject  = $projection.ReceiverCostObject
           and _chargeoutreckpisum.ReceiverCostCenter  = $projection.ReceiverCostCenter
           and chargeoutreckpi.chargeout =  'I'

  association [0..1] to /ESRCC/I_DIRALOCCONSUMPTN  as _diralloc    
            on _diralloc.ServiceProduct      =  $projection.serviceproduct
           and _diralloc.Sysid               =  $projection.ReceiverSysId
           and _diralloc.ReceivingCompany    =  $projection.ReceiverCompanyCode
           and _diralloc.ReceivingEntity     =  $projection.ReceivingEntity
           and _diralloc.Costobject          =  $projection.ReceiverCostObject
           and _diralloc.Costcenter          =  $projection.ReceiverCostCenter                                                                           
           and _diralloc.ProviderSysid       =  $projection.sysid
           and _diralloc.ProviderCompany     =  $projection.ccode
           and _diralloc.ProviderEntity      =  $projection.legalentity
           and _diralloc.ProviderCostobject  =  $projection.costobject
           and _diralloc.ProviderCostcenter  =  $projection.costcenter                         
           and _diralloc.Ryear               =  $projection.ryear
           and _diralloc.Poper               =  $projection.poper
           and _diralloc.Fplv                =  $projection.consumption_version
           and chargeoutreckpi.chargeout     =  'D'
           
  association [0..*] to /esrcc/srvmkp as mkup
           on mkup.serviceproduct = $projection.serviceproduct
           and mkup.workflow_status = 'F'
          and $projection.validon between mkup.validfrom and mkup.validto

{   
//  key cc_uuid,
//  key srv_uuid,
  key ryear,
  key poper,
  key fplv,
  key sysid,
  key chargeoutreckpi.legalentity,
  key chargeoutreckpi.ccode,
  key chargeoutreckpi.costobject,
  key chargeoutreckpi.costcenter,
  key chargeoutreckpi.serviceproduct,
  key chargeoutreckpi.ReceiverSysId,
  key chargeoutreckpi.ReceiverCompanyCode,
  key chargeoutreckpi.ReceivingEntity,
  key chargeoutreckpi.ReceiverCostObject,
  key chargeoutreckpi.ReceiverCostCenter,
      validon, 
      InvoicingCurrency,        
      chargeout,
      consumption_version,
      key_version,
      PlanningUoM,
      _diralloc.Uom as consumptionuom,
      @Semantics.quantity.unitOfMeasure: 'consumptionuom'
      cast(case when chargeout = 'I' then
       0 
      else
      _diralloc.Consumption  
      end as abap.quan( 23, 2))       as reckpi,

      case when chargeout = 'I' then
      round(_chargeoutreckpisum.totalreckpishare * 100, 3)
      else
       0
      end                             as reckpishare,
      
// receiver calculations with markup
      case when chargeoutreckpi.legalentity <> chargeoutreckpi.ReceivingEntity then
      mkup.origcost       
      else
      mkup.intra_origcost
      end as valueaddmarkup,
      
      case when chargeoutreckpi.legalentity <> chargeoutreckpi.ReceivingEntity then
      mkup.passcost     
      else
      mkup.intra_passcost
      end as passthrumarkup,
      ErpSalesOrder,
      ContractId        

}
