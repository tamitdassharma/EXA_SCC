@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity /ESRCC/I_INDALLOCVALUES_TRUEUP
as select from /ESRCC/I_CHG_INDWGHT_TRUEUP as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
            on indwght.ReceiverSysId = periodindalloc.ReceiverSysId
           and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
           and indwght.ReceivingEntity = periodindalloc.ReceivingEntity
           and indwght.ReceiverCostObject = periodindalloc.ReceiverCostObject
           and indwght.ReceiverCostCenter = periodindalloc.ReceiverCostCenter
           and indwght.ryear           = periodindalloc.Ryear
           and indwght.Allockey        = periodindalloc.AllocationKey
           and indwght.KeyVersion      = periodindalloc.Fplv
           and indwght.poper           >= periodindalloc.Poper

                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
  key AllocationPeriod,
  key RefPeriod,
  key periodindalloc.Poper as refpoper,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '01'  /*YTD*/

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
        on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
       and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
       and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
       and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
       and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
       and indwght.ryear               = periodindalloc.Ryear
       and indwght.Allockey            = periodindalloc.AllocationKey
       and indwght.KeyVersion          = periodindalloc.Fplv
       and indwght.poper               = periodindalloc.Poper                                                    
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
  key AllocationPeriod,
  key RefPeriod,
  key periodindalloc.Poper as refpoper,
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
               and indwght.ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv                                                          
               and indwght.RefPeriod          >= periodindalloc.Poper                                                                                      

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
  key AllocationPeriod,
  key RefPeriod,
  key periodindalloc.Poper as refpoper,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '03'  /*No. Of months*/

union 

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

 association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
            on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
           and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
           and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
           and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
           and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
           and indwght.ryear               = periodindalloc.Ryear
           and indwght.Allockey            = periodindalloc.AllocationKey
           and indwght.KeyVersion          = periodindalloc.Fplv                                                                                                                                                                   
           and indwght.poper              >= periodindalloc.Poper  
           and periodindalloc.Poper        > indwght.fromRefperiod                       
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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
  key AllocationPeriod,
  key RefPeriod,
  key periodindalloc.Poper as refpoper,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '04' /*Last months*/

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
                on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv
               and indwght.poper               > periodindalloc.Poper  
               and periodindalloc.Poper       >= indwght.fromRefperiod                           
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
  key AllocationPeriod,
  key RefPeriod,
  key periodindalloc.Poper as refpoper,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '05'   /*preevious Month*/


union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

 association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
               on indwght.ReceiverSysId        = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv
               and indwght.RefPeriod           = periodindalloc.Poper
                                                                                         

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
  key indwght.ReceiverSysId,
  key indwght.ReceiverCompanyCode,
  key indwght.ReceivingEntity,
  key indwght.ReceiverCostObject,
  key indwght.ReceiverCostCenter,
  key KeyVersion,
  key Allockey,
  key AllocationPeriod,
  key RefPeriod,
  key periodindalloc.Poper as refpoper,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '06'   /*Reference Month*/
