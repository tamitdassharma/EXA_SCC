@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Mark-up'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_SERVICEMARKUP 
as select from /esrcc/srvmkp as srvmkup      
{
    key serviceproduct as Serviceproduct,
    key validfrom as markupvalidfrom,
    validto as markupvalidto,
   
    intra_origcost,
    intra_passcost,
    origcost,
    passcost
}where workflow_status = 'F'
