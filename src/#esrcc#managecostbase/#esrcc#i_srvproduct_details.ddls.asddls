@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ad-hoc Service Chargeout Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_SRVPRODUCT_DETAILS 
as select from /esrcc/chargeout as _chargeout
      
    association [0..1] to /esrcc/srvpro as srvpro
     on srvpro.serviceproduct = $projection.Serviceproduct
     
    association [0..1] to /esrcc/srvprot  as srvprot 
        on   $projection.Serviceproduct = srvprot.serviceproduct
       and srvprot.spras         = $session.system_language 
     
    association [0..1] to /esrcc/co_rule as rule
      on rule.rule_id = $projection.chargeoutruleid
      and rule.workflow_status = 'F'
      
    association [0..1] to /esrcc/co_rulet as rulet
      on rulet.rule_id = $projection.chargeoutruleid
      and rulet.spras = $session.system_language

{
    key _chargeout.serviceproduct as Serviceproduct,
    key _chargeout.validfrom,
    _chargeout.validto,
    srvpro.servicetype as Servicetype,
    srvpro.transactiongroup as Transactiongroup,
    srvpro.ip_owner as IpOwner,
    srvpro.oecdtpg as Oecdtpg,
    srvprot.description as serviceproductdescription,
    rule.chargeout_method,
    rule.key_version,
//    rule.cost_version,
    rule.adhoc_allocation_key,
    rulet.description as ruledescription,
  //allocation
    _chargeout.chargeout_rule_id as chargeoutruleid
    
//  //associations
//    rule,
//    rulet
    
}where rule.chargeout_method = 'A'
