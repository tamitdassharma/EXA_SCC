@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_StwdSpP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICEPRODUCT_F4', element: 'ServiceProduct' }, useForValidation: true }]
  ServiceProduct : /esrcc/srvproduct;

  ValidFrom      : /esrcc/validfrom;

  ValidTo        : /esrcc/validto;
}
