@EndUserText.label: 'Legal Entity Address Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LeAddress_S
  as select from I_Language
    left outer join /ESRCC/LE_ADDRES on 0 = 0
  composition [0..*] of /ESRCC/I_LeAddress as _LeAddress
{
  key 1 as SingletonID,
  _LeAddress,
  max( /ESRCC/LE_ADDRES.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
