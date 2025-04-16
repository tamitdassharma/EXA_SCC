@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Cost Share Union View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ServiceProductData 
as select from /esrcc/srv_share
{
    key srv_uuid as UUID,
    key cc_uuid as ParentUUID,
    key 'L' as Currencytype,
    serviceproduct as Serviceproduct,    
    servicetype as Servicetype,
    transactiongroup as Transactiongroup,
    chargeout as Chargeout,
    costshare as Costshare,
    contractid as ContractId,
    capacity_version as CapacityVersion,
    consumption_version as ConsumptionVersion,
    key_version as KeyVersion,
    planning as Planning,
    planninguom as PlanningUom,
//    uom as Uom,
    status as Status,
    workflowid as Workflowid,  
    commentid as CommentId,  
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
union
select from /esrcc/srv_share
{
    key srv_uuid as UUID,
    key cc_uuid as ParentUUID,
    key 'I' as Currencytype,
    serviceproduct as Serviceproduct,    
    servicetype as Servicetype,
    transactiongroup as Transactiongroup,
    chargeout as Chargeout,
    costshare as Costshare,
    contractid as ContractId,
    capacity_version as CapacityVersion,
    consumption_version as ConsumptionVersion,
    key_version as KeyVersion,
    planning as Planning,
    planninguom as PlanningUom,
//    uom as Uom,
    status as Status,
    workflowid as Workflowid, 
    commentid as CommentId,    
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
union
select from /esrcc/srv_share
{
    key srv_uuid as UUID,
    key cc_uuid as ParentUUID,
    key 'G' as Currencytype,
    serviceproduct as Serviceproduct,   
    servicetype as Servicetype,
    transactiongroup as Transactiongroup,
    chargeout as Chargeout,
    costshare as Costshare,
    contractid as ContractId,
    capacity_version as CapacityVersion,
    consumption_version as ConsumptionVersion,
    key_version as KeyVersion,
    planning as Planning,
    planninguom as PlanningUom,
//    uom as Uom,
    status as Status,
    workflowid as Workflowid,
    commentid as CommentId, 
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
