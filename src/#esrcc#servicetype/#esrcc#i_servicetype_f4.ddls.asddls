@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Type'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_SERVICETYPE_F4
  as select from /esrcc/srtype as srvtyp
  association [0..1] to /esrcc/srvtypet as srvtypet on  srvtyp.srvtype = srvtypet.srvtype
                                                    and srvtypet.spras = $session.system_language
{
      @ObjectModel.text: { element: ['Description'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @UI.textArrangement: #TEXT_SEPARATE
  key srvtyp.srvtype       as ServiceType,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      srvtypet.description as Description
}
