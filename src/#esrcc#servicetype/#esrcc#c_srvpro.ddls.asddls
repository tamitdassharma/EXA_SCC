@EndUserText.label: 'Service Product - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvPro
  as projection on /ESRCC/I_SrvPro
{
  key Serviceproduct,
      @ObjectModel.text.element: ['ServiceTypeDescription']
      Servicetype,
      @ObjectModel.text.element: ['TransGroupDescription']
      Transactiongroup,
      @ObjectModel.text.element: [ 'OecdDescription' ]
      OecdTpg,
      IpOwner,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ServiceType.Description      as ServiceTypeDescription,
      @Semantics.text: true
      _TransactionGroup.Description as TransGroupDescription,
      @Semantics.text: true
      _OECD.text                    as OecdDescription,

      _ServiceProductAll  : redirected to parent /ESRCC/C_SrvPro_S,
      _ServiceProductText : redirected to composition child /ESRCC/C_SrvProText,
      _ServiceProductText.Description : localized
}
