@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyLeCcodeP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' }, useForValidation: true }]
  Sysid : /esrcc/sysid;
  
  Ccode : /esrcc/ccode_de;
}
