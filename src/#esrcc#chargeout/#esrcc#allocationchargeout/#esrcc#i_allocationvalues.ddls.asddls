@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_ALLOCATIONVALUES
  as select from /esrcc/alcvalues as allocvalues

  association        to parent /ESRCC/I_ALLOCATIONSHARE as _indkpishare       
             on  _indkpishare.AlocUUID = $projection.parentuuid
                                                                              
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4      as _AllocationKeyText 
             on  _AllocationKeyText.Allocationkey = $projection.allockey

{
  key uuid,
  parentuuid,
  ryear,
  allockey,
  allocationperiod,
  refperiod,
  refpoper,
  reckpivalue,

  /*Association*/
  _indkpishare,
  _AllocationKeyText
}
