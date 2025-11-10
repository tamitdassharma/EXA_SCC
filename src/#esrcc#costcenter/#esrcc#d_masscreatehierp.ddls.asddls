@EndUserText.label: 'Mass Create (Based on Hierarchy Data)'

define root abstract entity /ESRCC/D_MassCreateHierP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_MassCreateOption', element: 'MOption' },
                                       useForValidation: true }]
  options : /esrcc/mass_create_option;
}
