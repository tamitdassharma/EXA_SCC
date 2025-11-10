@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyLicMapP
{
  @UI.textArrangement    : #TEXT_LAST
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Sysid' },
                                       additionalBinding: [{ localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'LicensorCompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'LicensorCostObject', element: 'Costobject' },
                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter' },
                                                           { localElement: 'LicensorCostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  LicensorSysid          : /esrcc/licensor_sysid;

  @UI.textArrangement    : #TEXT_LAST
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'LegalEntity' },
                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
                                                           { localElement: 'LicensorCompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'LicensorCostObject', element: 'Costobject' },
                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter' },
                                                           { localElement: 'LicensorCostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  LicensorLegalEntity    : /esrcc/licensor_legalentity;

  @UI.textArrangement    : #TEXT_LAST
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'CompanyCode' },
                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
                                                           { localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'LicensorCostObject', element: 'Costobject' },
                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter' },
                                                           { localElement: 'LicensorCostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  LicensorCompanyCode    : /esrcc/licensor_ccode;

  @UI.textArrangement    : #TEXT_LAST
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costobject' },
                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
                                                           { localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'LicensorCompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter' },
                                                           { localElement: 'LicensorCostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  LicensorCostObject     : /esrcc/licensor_costobject;

  @UI.textArrangement    : #TEXT_LAST
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
                                                           { localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'LicensorCompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'LicensorCostObject', element: 'Costobject' },
                                                           { localElement: 'LicensorCostObjectUuid', element: 'CostObjectUuid', usage: #RESULT }],
                                       useForValidation: true }]
  LicensorCostCenter     : /esrcc/licensor_costcenter;

  @UI.textArrangement    : #TEXT_LAST
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_License_F4', element: 'License' }, useForValidation: true }]
  License                : /esrcc/licenseid;

  @UI.hidden             : true
  LicensorCostObjectUuid : sysuuid_x16;
}
