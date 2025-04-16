@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transaction Group'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_TRANSACTIONGROUP_F4
  as select from /esrcc/srvtg as srvtg
  association [0..1] to /esrcc/tgt as srvtgt on  srvtg.transactiongroup = srvtgt.transactiongroup
                                             and srvtgt.spras           = $session.system_language
{
      @ObjectModel.text: { element: ['Description'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_SEPARATE
  key srvtg.transactiongroup as Transactiongroup,
      
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      srvtgt.description      as Description
}
