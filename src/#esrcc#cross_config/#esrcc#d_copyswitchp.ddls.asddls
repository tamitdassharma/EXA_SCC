@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopySwitchP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_APPLICATION_TYPE', element: 'ApplicationType'} }]
  Application : /esrcc/application;
  SwitchName  : /esrcc/switch_name;
}
