@EndUserText.label: 'Legal Entity'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LE
  as select from /esrcc/le
  association        to parent /ESRCC/I_LE_S as _LegalEntityAll on  $projection.SingletonID = _LegalEntityAll.SingletonID
  composition [0..*] of /ESRCC/I_LEText      as _LegalEntityText

  association [0..1] to /ESRCC/I_REGION      as _Region         on  _Region.Region = $projection.Region
  association [0..1] to /ESRCC/I_ROLE        as _Role           on  _Role.Role = $projection.Role
  association [0..1] to /ESRCC/I_ENTITYTYPE  as _EntityType     on  _EntityType.Entitytype = $projection.Entitytype
  association [0..1] to I_CountryText        as _Country        on  _Country.Country  = $projection.Country
                                                                and _Country.Language = $session.system_language
  association [0..1] to I_CurrencyText       as _Currency       on  _Currency.Currency = $projection.LocalCurr
                                                                and _Currency.Language = $session.system_language
  
  association [0..1] to /ESRCC/I_TpProfText  as _TPprofileText  on  _TPprofileText.Tpprofile = $projection.TpProfile
                                                                and _TPprofileText.Spras = $session.system_language
{
  key legalentity           as Legalentity,
      country               as Country,
      local_curr            as LocalCurr,
      entitytype            as Entitytype,
      region                as Region,
      role                  as Role,
      tpprofile             as TpProfile,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _LegalEntityAll,
      _LegalEntityText,
      _TPprofileText,
      _Region,
      _Role,
      _EntityType,
      _Country,
      _Currency
}
