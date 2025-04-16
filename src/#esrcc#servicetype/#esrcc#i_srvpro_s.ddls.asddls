@EndUserText.label: 'Service Product Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SrvPro_S
  as select from I_Language
    left outer join /ESRCC/SRVPRO on 0 = 0
  composition [0..*] of /ESRCC/I_SrvPro as _ServiceProduct
{
  key 1 as SingletonID,
  _ServiceProduct,
  max( /ESRCC/SRVPRO.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
