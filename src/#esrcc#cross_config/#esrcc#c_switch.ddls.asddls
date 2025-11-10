@EndUserText.label: 'Maintain Switch'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Switch
  as projection on /ESRCC/I_Switch
{
      @ObjectModel.text.element: ['ApplicationDescription']
  key Application,
  key SwitchName,
      Active,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _ApplicationTypeText.text as ApplicationDescription,
      _SwitchAll : redirected to parent /ESRCC/C_Switch_S

}
