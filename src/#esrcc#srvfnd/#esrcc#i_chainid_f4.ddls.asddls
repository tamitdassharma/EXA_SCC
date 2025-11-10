@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chain ID'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.presentationVariant: [{ sortOrder: [{direction: #DESC, by: 'ChainId'}] }]
define view entity /ESRCC/I_CHAINID_F4
  as select distinct from /esrcc/stewrdshp
{
  key chain_id as ChainId
}
