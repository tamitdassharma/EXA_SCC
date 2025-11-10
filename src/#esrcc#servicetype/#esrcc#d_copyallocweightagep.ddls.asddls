@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyAllocWeightageP
{
  @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_ALLOCATION_KEY_F4', element: 'Allocationkey' },
                                        useForValidation: true } ]
  AllocationKey : /esrcc/allockey;
}
