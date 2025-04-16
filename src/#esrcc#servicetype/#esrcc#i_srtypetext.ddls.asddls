@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Type Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_SrTypeText
  as select from /ESRCC/SRVTYPET
  association [1..1] to /ESRCC/I_SrType_S as _ServiceTypeAll on $projection.SingletonID = _ServiceTypeAll.SingletonID
  association to parent /ESRCC/I_SrType as _ServiceType on $projection.Srvtype = _ServiceType.Srvtype
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key SRVTYPE as Srvtype,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _ServiceTypeAll,
  _ServiceType,
  _LanguageText
  
}
