@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Ad-hoc Service Chargeout Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ADHOCSERVICE
  as select from /ESRCC/I_SRVPRODUCT_DETAILS as srvpro

  association [0..1] to /ESRCC/I_ALLOCKEYS as allockeys on allockeys.Allockey = $projection.adhoc_allocation_key
{
  key Serviceproduct,
  key validfrom,
      validto,
      Servicetype,
      Transactiongroup,
      IpOwner,
      Oecdtpg,
      serviceproductdescription,
      chargeout_method,
      key_version,
//      cost_version,
      adhoc_allocation_key,
      @Semantics.text: true
      ruledescription,
      chargeoutruleid,
      allockeys.text as allockeydescription

}

