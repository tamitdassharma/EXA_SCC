@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation KPI Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_INDKPISHARE 
as select from /ESRCC/I_CHARGEOUT_INDWGHT as weightage

association [0..1] to /ESRCC/I_CHARGEOUT_INDKPISUM as indkpisum
                  on weightage.Fplv = indkpisum.fplv
                 and weightage.Ryear = indkpisum.ryear 
                 and weightage.Poper = indkpisum.poper
                 and weightage.Sysid = indkpisum.sysid
                 and weightage.Ccode = indkpisum.ccode
                 and weightage.Legalentity = indkpisum.legalentity
                 and weightage.Costobject = indkpisum.costobject
                 and weightage.Costcenter = indkpisum.costcenter
                 and weightage.serviceproduct = indkpisum.serviceproduct
                 and weightage.KeyVersion = indkpisum.KeyVersion                             
                 and weightage.Allockey = indkpisum.Allockey
//                 and weightage.AllocType = indkpisum.AllocType
                 and weightage.AllocationPeriod = indkpisum.AllocationPeriod
                 and weightage.RefPeriod = indkpisum.RefPeriod
                 

association [0..*] to /ESRCC/I_INDALLOC as TOTALINDALLOC
                  on weightage.Fplv = TOTALINDALLOC.fplv
                 and weightage.Ryear = TOTALINDALLOC.ryear 
                 and weightage.Poper = TOTALINDALLOC.poper
                 and weightage.Sysid = TOTALINDALLOC.sysid
                 and weightage.Ccode = TOTALINDALLOC.ccode
                 and weightage.Legalentity = TOTALINDALLOC.legalentity
                 and weightage.Costobject = TOTALINDALLOC.costobject
                 and weightage.Costcenter = TOTALINDALLOC.costcenter
                 and weightage.serviceproduct = TOTALINDALLOC.serviceproduct
                 and weightage.ReceiverSysId = TOTALINDALLOC.ReceiverSysId
                 and weightage.ReceiverCompanyCode = TOTALINDALLOC.ReceiverCompanyCode
                 and weightage.ReceivingEntity = TOTALINDALLOC.ReceivingEntity
                 and weightage.ReceiverCostObject = TOTALINDALLOC.ReceiverCostObject
                 and weightage.ReceiverCostCenter = TOTALINDALLOC.ReceiverCostCenter
                 and weightage.KeyVersion = TOTALINDALLOC.KeyVersion                             
                 and weightage.Allockey = TOTALINDALLOC.Allockey
//                 and weightage.AllocType = TOTALINDALLOC.AllocType
                 and weightage.AllocationPeriod = TOTALINDALLOC.AllocationPeriod
                 and weightage.RefPeriod = TOTALINDALLOC.RefPeriod
                
                 
{
 key Fplv,
 key Ryear,
 key Poper,
 key Sysid,
 key Ccode,
 key Legalentity,
 key Costobject,
 key Costcenter,
 key serviceproduct,
 key ReceiverSysId,
 key ReceiverCompanyCode,
 key ReceivingEntity,
 key ReceiverCostObject,
 key ReceiverCostCenter,
 key KeyVersion,
 key Allockey,
// key AllocType,
 key AllocationPeriod,
 key RefPeriod,
 key weightage.Weightage,
 TOTALINDALLOC.reckpivalue,
 indkpisum.totalreckpi,
 cast(case when indkpisum.totalreckpi <> 0 then
 ( TOTALINDALLOC.reckpivalue / indkpisum.totalreckpi ) else 0 end as abap.dec(10,8))  as initialreckpishare ,
    
 cast(case when indkpisum.totalreckpi <> 0 then
 ( TOTALINDALLOC.reckpivalue / indkpisum.totalreckpi ) * ( weightage.Weightage / 100 ) else 0 end as abap.dec(10,8)) as reckpishare
    
}


