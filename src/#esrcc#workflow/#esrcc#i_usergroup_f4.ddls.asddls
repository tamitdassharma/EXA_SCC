@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow User Groups'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS

@Search.searchable: true
define view entity /ESRCC/I_UserGroup_F4
  as select from /esrcc/wfusrg
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key usergroup as Usergroup
}
