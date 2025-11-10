@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyExecutionStatusP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_APPLICATION_TYPE', element: 'ApplicationType' } }]
  application : /esrcc/application_type_de;

  status      : /esrcc/process_status_de;
}
