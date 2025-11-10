@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyBillingFrequencyP
{
  @Consumption.valueHelpDefinition: [{entity: { name: '/ESRCC/I_BILLINGFREQ', element: 'Billingfreq'} }]
  billingfreq  : /esrcc/billfrequency;

  @Consumption.valueHelpDefinition: [{entity: { name: '/ESRCC/I_BILLINGPERIOD', element: 'Billingperiod'} }]
  billingvalue : /esrcc/billperiod;

  poper        : poper;
}
