@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyWfSwitchP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_APPLICATION_TYPE', element: 'ApplicationType'} }]
  Application : /esrcc/application_type_de;
}
