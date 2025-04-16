@EndUserText.label: 'Group Configuration Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_GroupConfig_S
  as select from    I_Language
    left outer join /esrcc/group on 0 = 0
  composition [0..1] of /ESRCC/I_GroupConfig as _GroupConfig
{
  key 1                                          as SingletonID,
      _GroupConfig,
      max( /esrcc/group.last_changed_at )        as LastChangedAtMax,
      cast( '' as sxco_transport)                as TransportRequestID,
      cast( 'X' as abap_boolean preserving type) as HideTransport
}
where
  I_Language.Language = $session.system_language
