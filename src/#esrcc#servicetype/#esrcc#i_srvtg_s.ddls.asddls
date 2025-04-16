@EndUserText.label: 'Service Transaction Group Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SrvTg_S
  as select from I_Language
    left outer join /ESRCC/SRVTG on 0 = 0
  composition [0..*] of /ESRCC/I_SrvTg as _TransactionGrp
{
  key 1 as SingletonID,
  _TransactionGrp,
  max( /ESRCC/SRVTG.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
