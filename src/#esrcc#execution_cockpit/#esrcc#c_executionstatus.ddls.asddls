@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Execution Cockpit Status - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_ExecutionStatus
  as projection on /ESRCC/I_ExecutionStatus
{
      @ObjectModel.text.element: ['ApplicationDescription']
  key Application,
  key Status,
      @ObjectModel.text.element: ['ColorCodeDescription']
      Color,
      @Semantics.text: true
      _ApplicationText.text as ApplicationDescription,
      @Semantics.text: true
      _ColorCodeText.text   as ColorCodeDescription,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _ExecutionStatusAll  : redirected to parent /ESRCC/C_ExecutionStatus_S,
      _ExecutionStatusText : redirected to composition child /ESRCC/C_ExecutionStatusText,
      _ExecutionStatusText.Description : localized

}
