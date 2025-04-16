@EndUserText.label: 'Other information Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LeOthers_S
  as select from I_Language
    left outer join /ESRCC/LE_OTHERS on 0 = 0
  composition [0..*] of /ESRCC/I_LeOthers as _OtherInformation
{
  key 1 as SingletonID,
  _OtherInformation,
  max( /ESRCC/LE_OTHERS.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
