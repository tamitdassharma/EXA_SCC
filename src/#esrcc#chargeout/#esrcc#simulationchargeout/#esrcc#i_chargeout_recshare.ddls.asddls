@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chargout to Receivers Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CHARGEOUT_RECSHARE
  as select from /ESRCC/I_CHARGEOUT_RECEIVERS as chargeoutreckpi
  
  association [0..1] to /ESRCC/I_INDTOTALKPISHARE as _chargeoutreckpisum     
            on  _chargeoutreckpisum.Fplv               = $projection.Fplv
           and _chargeoutreckpisum.Ryear               = $projection.Ryear
           and _chargeoutreckpisum.Poper               = $projection.Poper
           and _chargeoutreckpisum.Sysid               = $projection.Sysid
           and _chargeoutreckpisum.Legalentity         = $projection.Legalentity
           and _chargeoutreckpisum.Ccode               = $projection.Ccode
           and _chargeoutreckpisum.Costobject          = $projection.Costobject
           and _chargeoutreckpisum.Costcenter          = $projection.Costcenter
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
           and _diralloc.ProviderSysid       =  $projection.Sysid
           and _diralloc.ProviderCompany     =  $projection.Ccode
           and _diralloc.ProviderEntity      =  $projection.Legalentity
           and _diralloc.ProviderCostobject  =  $projection.Costobject
           and _diralloc.ProviderCostcenter  =  $projection.Costcenter                         
           and _diralloc.Ryear               =  $projection.Ryear
           and _diralloc.Poper               =  $projection.Poper
           and _diralloc.Fplv                =  $projection.consumption_version
           and chargeoutreckpi.chargeout     =  'D'
           
  association [0..*] to /esrcc/srvmkp as mkup
           on mkup.serviceproduct = $projection.serviceproduct
           and mkup.workflow_status = 'F'
          and $projection.validon between mkup.validfrom and mkup.validto

{   
  key cc_uuid,
  key srv_uuid,
  key Ryear,
  key Poper,
  key Fplv,
  key Sysid,
  key chargeoutreckpi.Legalentity,
  key chargeoutreckpi.Ccode,
  key chargeoutreckpi.Costobject,
  key chargeoutreckpi.Costcenter,
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
      case when chargeoutreckpi.Legalentity <> chargeoutreckpi.ReceivingEntity then
      mkup.origcost       
      else
      mkup.intra_origcost
      end as valueaddmarkup,
      
      case when chargeoutreckpi.Legalentity <> chargeoutreckpi.ReceivingEntity then
      mkup.passcost     
      else
      mkup.intra_passcost
      end as passthrumarkup,
      ContractId        

}
