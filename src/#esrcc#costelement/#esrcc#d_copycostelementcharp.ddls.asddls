@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyCostElementCharP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTELEMENT_F4', element: 'Sysid' },
                                       additionalBinding: [{ element: 'LegalEntity', localElement: 'LegalEntity' },
                                                           { element: 'CompanyCode', localElement: 'CompanyCode' },
                                                           { element: 'Costelement', localElement: 'Costelement' },
                                                           { element: 'Uuid', localElement: 'CostElementUuid', usage: #RESULT }],
                                       useForValidation: true }]
  Sysid           : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTELEMENT_F4', element: 'LegalEntity' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'CompanyCode', localElement: 'CompanyCode' },
                                                           { element: 'Costelement', localElement: 'Costelement' },
                                                           { element: 'Uuid', localElement: 'CostElementUuid', usage: #RESULT }],
                                       useForValidation: true }]
  LegalEntity     : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTELEMENT_F4', element: 'CompanyCode' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'LegalEntity', localElement: 'LegalEntity' },
                                                           { element: 'Costelement', localElement: 'Costelement' },
                                                           { element: 'Uuid', localElement: 'CostElementUuid', usage: #RESULT }],
                                       useForValidation: true }]
  CompanyCode     : /esrcc/ccode_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTELEMENT_F4', element: 'Costelement' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid'},
                                                           { element: 'LegalEntity', localElement: 'LegalEntity' },
                                                           { element: 'CompanyCode', localElement: 'CompanyCode' },
                                                           { element: 'Uuid', localElement: 'CostElementUuid', usage: #RESULT }],
                                       useForValidation: true }]
  Costelement     : /esrcc/costelement;
  ValidFrom       : /esrcc/validfrom;
  ValidTo         : /esrcc/validto;

  @UI.hidden      : true
  @EndUserText.label: 'Cost Element UUID'
  CostElementUuid : sysuuid_x16;
}
