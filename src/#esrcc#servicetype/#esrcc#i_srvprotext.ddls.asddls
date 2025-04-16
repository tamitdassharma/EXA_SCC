@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Product Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_SrvProText
  as select from /esrcc/srvprot
  association [1..1] to /ESRCC/I_SrvPro_S      as _ServiceProductAll on  $projection.SingletonID = _ServiceProductAll.SingletonID
  association        to parent /ESRCC/I_SrvPro as _ServiceProduct    on  $projection.Serviceproduct = _ServiceProduct.Serviceproduct
  association [0..*] to I_LanguageText         as _LanguageText      on  $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key serviceproduct        as Serviceproduct,
      @Semantics.text: true
      description           as Description,
      @Semantics.text: true
      activities            as Activities,
      @Semantics.text: true
      benefit               as Benefit,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _ServiceProductAll,
      _ServiceProduct,
      _LanguageText

}
