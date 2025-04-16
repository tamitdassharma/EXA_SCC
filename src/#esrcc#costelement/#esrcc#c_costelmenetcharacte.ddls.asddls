@EndUserText.label: 'Cost element characteristics - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostElmenetCharacte
  as projection on /ESRCC/I_CostElmenetCharacte
{
  key CstElmntCharUuid,
      ValidFrom,
      ValidTo,
      @ObjectModel.text.element: ['CostTypeDescription']
      CostType,
      @ObjectModel.text.element: ['PostingTypeDescription']
      PostingType,
      @ObjectModel.text.element: ['CostIndDescription']
      CostIndicator,
      @ObjectModel.text.element: ['UsageTypeDescription']
      UsageType,
      @ObjectModel.text.element: ['ReasonDescription']
      ReasonId,
      @ObjectModel.text.element: ['ValueSourceDescription']
      ValueSource,
      CostElementUuid,
      @ObjectModel.text.element: ['SysidDescription']
      Sysid,
      @ObjectModel.text.element: ['LegalEntityDescription']
      LegalEntity,
      @ObjectModel.text.element: ['CompanyCodeDescription']
      CompanyCode,
      @ObjectModel.text.element: ['CostElementDescription']
      Costelement,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _CostTypeText.text                  as CostTypeDescription,
      @Semantics.text: true
      _PostingTypeText.text               as PostingTypeDescription,
      @Semantics.text: true
      _CostIndText.text                   as CostIndDescription,
      @Semantics.text: true
      _UsageTypeText.text                 as UsageTypeDescription,
      @Semantics.text: true
      _ReasonText.reasondescription       as ReasonDescription,
      @Semantics.text: true
      _ValueSourceText.text               as ValueSourceDescription,
      @Semantics.text: true
      _CostElement.SysidDescription,
      @Semantics.text: true
      _CostElement.LegalEntityDescription,
      @Semantics.text: true
      _CostElement.CompanyCodeDescription,
      @Semantics.text: true
      _CostElement.costelementdescription as CostElementDescription,

      _CostElementCharAll : redirected to parent /ESRCC/C_CostElmenetCharacte_S

}
