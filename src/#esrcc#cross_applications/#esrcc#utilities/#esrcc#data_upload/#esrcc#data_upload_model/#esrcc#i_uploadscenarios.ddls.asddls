@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Upload Scenarios'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity /ESRCC/I_UploadScenarios
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                   p_domain_name : '/ESRCC/UPLOAD_SCENARIOS')

{
      @ObjectModel.text.element: [ 'text' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @UI.textArrangement: #TEXT_ONLY
  key value_low as SubApplication,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Semantics.text: true
      text
}

where language = $session.system_language
