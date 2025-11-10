@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'True-up Amounts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TRUEUP as select from /esrcc/trueup
{
    key cc_uuid as RootUUID,
    key srv_uuid as ParentUUID,
    key receiversysid as Receiversysid,
    key receivingentity as Receivingentity,
    key receivercompanycode as Receivercompanycode,
    key receivercostobject as Receivercostobject,
    key receivercostcenter as Receivercostcenter,
    ryear as Ryear,
    poper as Poper,
    sysid as Sysid,
    legalentity as Legalentity,
    ccode as Ccode,
    costobject as Costobject,
    costcenter as Costcenter,
    serviceproduct as Serviceproduct,
    
    localcurr as Localcurr,
    groupcurr as Groupcurr,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(amount_l) as AmountL,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(amount_g) as AmountG
//    erpflag as Erpflag,
}
group by
cc_uuid,
srv_uuid,
ryear,
poper,
sysid,
legalentity,
ccode,
costobject,
costcenter,
serviceproduct,
receiversysid,
receivingentity,
receivercompanycode,
receivercostobject,
receivercostcenter,
localcurr,
groupcurr
