@EndUserText.label: 'Cost Object Type Host Mapping'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostObjectTypeMapping
  as projection on /ESRCC/I_CostObjectTypeMapping
{
  key ObjectType,
  key SourceCostObjectType,
      Active,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _ExtractionObjectAll : redirected to /ESRCC/C_ExtObj_S,
      _ExtractionObject    : redirected to parent /ESRCC/C_ExtObj
}
