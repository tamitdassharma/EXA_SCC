@EndUserText.label: 'Cost Object - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CstObjct
  as projection on /ESRCC/I_CstObjct
{
  key CostObjectUuid,
      @ObjectModel.text.element: [ 'SysidDescription' ]
      Sysid,
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      LegalEntity,
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      CompanyCode,
      @ObjectModel.text.element: [ 'CostObjectDescription' ]
      CostObject,
      CostCenter,
      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      FunctionalArea,
      @ObjectModel.text.element: [ 'ProfitCenterDescription' ]
      ProfitCenter,
      @ObjectModel.text.element: [ 'BusinessDivisionDescription' ]
      BusinessDivision,
      @ObjectModel.text.element: [ 'BillingFrequencyDescription' ]
      BillingFrequency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _SysidText.description                    as SysidDescription,
      @Semantics.text: true
      _CcodeText.ccodedescription               as CompanyCodeDescription,
      @Semantics.text: true
      _CcodeText.LegalentityDescription         as LegalEntityDescription,
      @Semantics.text: true
      _CostObjTypeText.text                     as CostObjectDescription,
      @Semantics.text: true
      _FunctionalAreaText.Description           as FunctionalAreaDescription,
      @Semantics.text: true
      _ProfitCenterText.profitcenterdescription as ProfitCenterDescription,
      @Semantics.text: true
      _BusinessDivisionText.Description         as BusinessDivisionDescription,
      @Semantics.text: true
      _BillingFreqText.text                     as BillingFrequencyDescription,

      _CostObjectAll  : redirected to parent /ESRCC/C_CstObjct_S,
      _CostObjectText : redirected to composition child /ESRCC/C_CstObjctText,
      _CostObjectText.Description : localized

}
