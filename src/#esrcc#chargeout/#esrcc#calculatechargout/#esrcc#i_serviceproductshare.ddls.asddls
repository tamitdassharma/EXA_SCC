@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Final Charge Out Amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_ServiceProductShare
  as select from /ESRCC/I_ServiceProductData as srvcost

  composition [0..*] of /ESRCC/I_ReceiverChargeout            as _ReceiverCost

  association        to parent /ESRCC/I_CostBaseStewardship as _CostCenterCost on  $projection.ParentUUID   = _CostCenterCost.UUID                                                                               
                                                                               and $projection.Currencytype  = _CostCenterCost.Currencytype   

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as serviceproduct         on  serviceproduct.ServiceProduct = $projection.Serviceproduct

  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as srvtyp                 on  srvtyp.ServiceType = $projection.Servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as srvtransactiongroup    on  srvtransactiongroup.Transactiongroup = $projection.Transactiongroup
  
  association [0..1] to /ESRCC/I_STATUS as status
  on status.Status = $projection.Status
  
  association [0..1] to /ESRCC/I_CHGOUT as method
  on method.Chargeout = $projection.Chargeout
  
  association [0..1] to I_UnitOfMeasureText as _UoM
  on _UoM.UnitOfMeasure_E = srvcost.PlanningUom
  and _UoM.Language = $session.system_language 
  
  association [0..1] to /ESRCC/I_CURR as _CurrencyTypeText
  on _CurrencyTypeText.Currencytype = $projection.Currencytype
  
  association [0..1] to /ESRCC/I_CAPACITY_VERSION as _CapacityVersion
  on _CapacityVersion.CapacityVersion = $projection.CapacityVersion
  
{
    key UUID,
    key ParentUUID,
    key srvcost.Currencytype,    
    srvcost.Serviceproduct as Serviceproduct,    
    srvcost.Servicetype as Servicetype,
    srvcost.Transactiongroup as Transactiongroup, 
    CapacityVersion, 
    serviceproduct.OECD, 
    Costshare,  
    ContractId,        
    _CostCenterCost.Currency,
    Chargeout,
    Planning,
    PlanningUom,
    ConsumptionVersion,
    KeyVersion,
// Cost Share calculations
    cast(( Costshare / 100 ) * (_CostCenterCost.Origtotalcost - ( ( _CostCenterCost.Stewardship / 100 ) * _CostCenterCost.Origtotalcost )) +
        ( Costshare / 100 ) * (_CostCenterCost.Passtotalcost - ( ( _CostCenterCost.Stewardship / 100 ) * _CostCenterCost.Passtotalcost )) as abap.dec(23,2)) as Srvcostshare,
    cast(( Costshare / 100 ) * (_CostCenterCost.Origtotalcost - ( ( _CostCenterCost.Stewardship / 100 ) * _CostCenterCost.Origtotalcost )) as abap.dec(23,2)) as Valueaddshare,
    cast(( Costshare / 100 ) * (_CostCenterCost.Passtotalcost - ( ( _CostCenterCost.Stewardship / 100 ) * _CostCenterCost.Passtotalcost )) as abap.dec(23,2)) as Passthroughshare,

// Cost Share price per unit calculation for direct chargeout case
    cast(case when Chargeout = 'D' and  Planning <> 0 then
     ( ( Costshare / 100 ) * _CostCenterCost.Remainingcostbase ) / Planning                                      
    else
    0 end as abap.dec(10,2)) as Servicecostperunit,
    
    cast(case when Chargeout = 'D' and  Planning <> 0 then
    ( ( ( Costshare / 100 ) * (_CostCenterCost.Origtotalcost - ( ( _CostCenterCost.Stewardship / 100 ) * _CostCenterCost.Origtotalcost )) ) / Planning ) 
    else
    0 end as abap.dec(10,2)) as Valueaddcostperunit,
    
    cast(case when Chargeout = 'D' and  Planning <> 0 then
    ( ( ( Costshare / 100 ) * (_CostCenterCost.Passtotalcost - ( ( _CostCenterCost.Stewardship / 100 ) * _CostCenterCost.Passtotalcost )) ) / Planning ) 
    else
    0 end as abap.dec(10,2)) as Passthrucostperunit,

// Additonal Attributes   
    srvcost.Status,
    Workflowid,
    CommentId,
    cast(case Chargeout
      when 'D' then 'X' 
      when 'I' then ''
      else  '' end as abap_boolean preserving type) as hidedirectalloc,
      
      case srvcost.Status 
         when 'D' then 2
         when 'W' then 2
         when 'A' then 3
         when 'F' then 3
         when 'R' then 1 
         when 'C' then 1 
         else
         0
        end as statuscriticallity,
      serviceproduct.Description                         as Serviceproductdescription,
      srvtyp.Description                                 as Servicetypedescription,
      srvtransactiongroup.Description                    as Transactiongroupdescription,
      status.text as statusdescription,
      method.text as chargeoutdescription,
      serviceproduct.oecdDescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,
      //association
      _CostCenterCost,
      _ReceiverCost,
      _UoM,
      _CurrencyTypeText,
      _CapacityVersion

}
