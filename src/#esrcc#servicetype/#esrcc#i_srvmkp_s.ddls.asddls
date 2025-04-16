@EndUserText.label: 'Service Markup Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SrvMkp_S
  as select from I_Language
    left outer join /ESRCC/SRVMKP on 0 = 0
  composition [0..*] of /ESRCC/I_SrvMkp as _ServiceMarkup
{
  key 1 as SingletonID,
  _ServiceMarkup,
  max( /ESRCC/SRVMKP.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
