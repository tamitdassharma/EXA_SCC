@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity /ESRCC/I_INDALLOC
as select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
            on indwght.ReceiverSysId = periodindalloc.ReceiverSysId
           and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
           and indwght.ReceivingEntity = periodindalloc.ReceivingEntity
           and indwght.ReceiverCostObject = periodindalloc.ReceiverCostObject
           and indwght.ReceiverCostCenter = periodindalloc.ReceiverCostCenter
           and indwght.Ryear           = periodindalloc.Ryear
           and indwght.Allockey        = periodindalloc.AllocationKey
           and indwght.KeyVersion      = periodindalloc.Fplv
           and indwght.Poper           >= periodindalloc.Poper

                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      sum(periodindalloc.value) as reckpivalue

} where AllocationPeriod = '01'  /*YTD*/
group by
Fplv,
Ryear,
Poper,
Sysid,
Ccode,
Legalentity,
Costobject,
Costcenter,
serviceproduct,
indwght.ReceiverSysId,
indwght.ReceiverCompanyCode,
indwght.ReceivingEntity,
indwght.ReceiverCostObject,
indwght.ReceiverCostCenter,
KeyVersion,
Allockey,
//AllocType,
AllocationPeriod,
RefPeriod
  
union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
        on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
       and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
       and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
       and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
       and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
       and indwght.Ryear               = periodindalloc.Ryear
       and indwght.Allockey            = periodindalloc.AllocationKey
       and indwght.KeyVersion          = periodindalloc.Fplv
       and indwght.Poper               = periodindalloc.Poper
                                                         
                                                          
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '02'   /*current Month*/

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
               on indwght.ReceiverSysId        = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.Ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv                                                          
               and indwght.RefPeriod          >= periodindalloc.Poper
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      sum(periodindalloc.value) as reckpivalue

} where AllocationPeriod = '03'  /*No. Of months*/
group by
Fplv,
Ryear,
Poper,
Sysid,
Ccode,
Legalentity,
Costobject,
Costcenter,
serviceproduct,
indwght.ReceiverSysId,
indwght.ReceiverCompanyCode,
indwght.ReceivingEntity,
indwght.ReceiverCostObject,
indwght.ReceiverCostCenter,
KeyVersion,
Allockey,
//AllocType,
AllocationPeriod,
RefPeriod

union 

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
            on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
           and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
           and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
           and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
           and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
           and indwght.Ryear               = periodindalloc.Ryear
           and indwght.Allockey            = periodindalloc.AllocationKey
           and indwght.KeyVersion          = periodindalloc.Fplv                                                                                                                                                                   
           and indwght.Poper              >= periodindalloc.Poper  
           and periodindalloc.Poper        > indwght.fromRefperiod                           
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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      sum(periodindalloc.value) as reckpivalue

} where AllocationPeriod = '04' /*Last months*/
group by
Fplv,
Ryear,
Poper,
Sysid,
Ccode,
Legalentity,
Costobject,
Costcenter,
serviceproduct,
indwght.ReceiverSysId,
indwght.ReceiverCompanyCode,
indwght.ReceivingEntity,
indwght.ReceiverCostObject,
indwght.ReceiverCostCenter,
KeyVersion,
Allockey,
//AllocType,
AllocationPeriod,
RefPeriod

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
                on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.Ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv
               and indwght.Poper               > periodindalloc.Poper  
               and periodindalloc.Poper       >= indwght.fromRefperiod    
                                                          
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '05'   /*previous Month*/


union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
               on indwght.ReceiverSysId        = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.Ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv
               and indwght.RefPeriod           = periodindalloc.Poper
                                                          
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '06'   /*Reference Month*/




