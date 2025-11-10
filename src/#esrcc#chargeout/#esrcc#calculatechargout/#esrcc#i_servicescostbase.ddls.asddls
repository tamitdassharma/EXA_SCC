@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-out Details by Service Provider'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ServicesCostbase 
as select from /esrcc/cb_stw as costbase
                                        
association [0..*] to /esrcc/srv_share as services
    on   costbase.cc_uuid = services.cc_uuid

{
    key costbase.cc_uuid,
    key services.srv_uuid,
    costbase.fplv as Fplv,
    costbase.ryear as Ryear,
    costbase.poper as Poper,
    costbase.sysid as Sysid,
    costbase.legalentity as Legalentity,
    costbase.ccode as Ccode,
    costbase.costobject as Costobject,
    costbase.costcenter as Costcenter,
    services.serviceproduct as ServiceProduct,
    services.consumption_version,
    services.key_version,
    services.planninguom as PlanningUoM,
    services.chargeout,
    validon
}
