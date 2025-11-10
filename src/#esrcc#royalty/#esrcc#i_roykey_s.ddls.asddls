@EndUserText.label: 'Royalty Base Keys Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_RoyKey_S
  as select from I_Language
    left outer join /ESRCC/ROYKEY on 0 = 0
  composition [0..*] of /ESRCC/I_RoyKey as _RoyaltyKey
{
  key 1 as SingletonID,
  _RoyaltyKey,
  max( /ESRCC/ROYKEY.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
