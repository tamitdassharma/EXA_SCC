@EndUserText.label: 'Business Division Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_BusDivText
  as select from /esrcc/bus_divt
  association [1..1] to /ESRCC/I_BusDiv_S      as _BusinessDivisionAll on $projection.SingletonID = _BusinessDivisionAll.SingletonID
  association        to parent /ESRCC/I_BusDiv as _BusinessDivision    on $projection.BusinessDivision = _BusinessDivision.BusinessDivision
  association [0..*] to I_LanguageText         as _LanguageText        on $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key business_division     as BusinessDivision,
      @Semantics.text: true
      description           as Description,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _BusinessDivisionAll,
      _BusinessDivision,
      _LanguageText

}
