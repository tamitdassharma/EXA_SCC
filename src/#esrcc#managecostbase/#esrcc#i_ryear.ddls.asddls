@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Year'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{direction: #DESC, by: 'ryear'}] }]
define root view entity /ESRCC/I_RYEAR
  as select distinct from /esrcc/cb_li 
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key ryear
}
