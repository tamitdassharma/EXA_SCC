@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@EndUserText.label: 'Allocation Values'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /ESRCC/C_ALLOCATIONVALUES
  as projection on /ESRCC/I_ALLOCATIONVALUES
{
  key uuid,
  parentuuid,
  ryear,
  @ObjectModel.text.element: [ 'AllocationKeyDescription' ]
  allockey,
  allocationperiod,
  refperiod,
  refpoper,
  @DefaultAggregation: #SUM
  reckpivalue,

  @Semantics.text: true
  _AllocationKeyText.AllocationKeyDescription,
  /* Associations */
  _indkpishare : redirected to parent /ESRCC/C_ALLOCATIONSHARE
}
