@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Product Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define root view entity /ESRCC/I_SRVPROTEXT_BENEFITS
  as select from /esrcc/srvprot  
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
      _LanguageText

}where spras = $session.system_language
