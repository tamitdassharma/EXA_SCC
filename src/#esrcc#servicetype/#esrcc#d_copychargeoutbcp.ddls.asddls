@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyChargeoutBCP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICEPRODUCT_F4', element: 'ServiceProduct' },
                                       useForValidation: true }]
  Serviceproduct : /esrcc/srvproduct;

  Validfrom      : /esrcc/validfrom;

  Validto        : /esrcc/validto;
}
