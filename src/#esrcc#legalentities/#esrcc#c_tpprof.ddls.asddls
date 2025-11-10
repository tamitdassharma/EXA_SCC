@EndUserText.label: 'Maintain TP Profile'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_TpProf
  as projection on /ESRCC/I_TpProf
{
  key Tpprofile,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _TpProfileAll : redirected to parent /ESRCC/C_TpProf_S,
  _TpProfileText : redirected to composition child /ESRCC/C_TpProfText,
  _TpProfileText.Description : localized
  
}
