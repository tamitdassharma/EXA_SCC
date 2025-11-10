@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyLeAddressP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' },
                                       useForValidation: true }]
  LegalEntity : /esrcc/legalentity;
}
