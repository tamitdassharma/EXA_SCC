@EndUserText.label: 'Switch Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Switch_S
  as select from I_Language
    left outer join /ESRCC/SWITCH on 0 = 0
  composition [0..*] of /ESRCC/I_Switch as _Switch
{
  key 1 as SingletonID,
  _Switch,
  max( /ESRCC/SWITCH.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
