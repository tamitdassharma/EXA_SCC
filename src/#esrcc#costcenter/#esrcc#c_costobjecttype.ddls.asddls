@EndUserText.label: 'Cost Object Type - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostObjectType
  as projection on /ESRCC/I_CostObjectType
{
  key CostObject,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _CostObjectTypeAll  : redirected to parent /ESRCC/C_CostObjectType_S,
      _CostObjectTypeText : redirected to composition child /ESRCC/C_CostObjectTypeText,
      _CostObjectTypeText.Description : localized

}
