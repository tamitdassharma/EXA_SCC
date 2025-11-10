@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation KPI Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHG_INDKPISHARE_TRUP 
as select from /ESRCC/I_CHG_INDWGHT_TRUEUP as weightage

association [0..1] to /ESRCC/I_CHG_INDKPISUM_TRUEUP as indkpisum
                  on weightage.fplv = indkpisum.fplv
                 and weightage.ryear = indkpisum.ryear 
                 and weightage.poper = indkpisum.poper
                 and weightage.sysid = indkpisum.sysid
                 and weightage.ccode = indkpisum.ccode
                 and weightage.legalentity = indkpisum.legalentity
                 and weightage.costobject = indkpisum.costobject
                 and weightage.costcenter = indkpisum.costcenter
                 and weightage.serviceproduct = indkpisum.serviceproduct
                 and weightage.KeyVersion = indkpisum.KeyVersion                             
                 and weightage.Allockey = indkpisum.Allockey
//                 and weightage.AllocType = indkpisum.AllocType
                 and weightage.AllocationPeriod = indkpisum.AllocationPeriod
                 and weightage.RefPeriod = indkpisum.RefPeriod
                 

association [0..*] to /ESRCC/I_INDALLOC_TRUEUP as TOTALINDALLOC
                  on weightage.fplv = TOTALINDALLOC.fplv
                 and weightage.ryear = TOTALINDALLOC.ryear 
                 and weightage.poper = TOTALINDALLOC.poper
                 and weightage.sysid = TOTALINDALLOC.sysid
                 and weightage.ccode = TOTALINDALLOC.ccode
                 and weightage.legalentity = TOTALINDALLOC.legalentity
                 and weightage.costobject = TOTALINDALLOC.costobject
                 and weightage.costcenter = TOTALINDALLOC.costcenter
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
 key fplv,
 key ryear,
 key poper,
 key sysid,
 key ccode,
 key legalentity,
 key costobject,
 key costcenter,
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


