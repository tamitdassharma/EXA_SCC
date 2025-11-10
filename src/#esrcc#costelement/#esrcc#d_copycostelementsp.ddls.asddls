@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyCostElementsP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Sysid' },
                                       additionalBinding: [{ element: 'Legalentity', localElement: 'LegalEntity' },
                                                           { element: 'Ccode', localElement: 'CompanyCode'}],
                                       useForValidation: true }]
  Sysid       : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Legalentity' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'Ccode', localElement: 'CompanyCode'}],
                                       useForValidation: true }]
  LegalEntity : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'Legalentity', localElement: 'LegalEntity'}],
                                       useForValidation: true }]
  CompanyCode : /esrcc/ccode_de;

  CostElement : /esrcc/costelement;
}
