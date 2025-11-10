@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Royalty Calculation'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_LICENSE_CAL'
@Metadata.allowExtensions: true

@UI.presentationVariant: [{ sortOrder: [
                                      { by: 'ryear' },
                                      { by: 'poper' },
                                      { by: 'fplv' },
                                      { by: 'licensorsysid' },
                                      { by: 'licensorlegalentity' },
                                      { by: 'licensorccode' },
                                      { by: 'licensorcostobject' },
                                      { by: 'licensorcostcenter' },
                                      { by: 'licenseesysid' },
                                      { by: 'licenseelegalentity' },
                                      { by: 'licenseeccode' },
                                      { by: 'licenseecostobject' },
                                      { by: 'licenseecostcenter' }
                                      ] }]
define root custom entity /ESRCC/C_LICENCSE_CAL
{
      
      @UI.lineItem                   : [
//      { type                         : #FOR_ACTION,  dataAction: 'Calculate' , label: 'Calculate Royalty' , position: 1, invocationGrouping: #CHANGE_SET },
//      { type                         : #FOR_ACTION,  dataAction: 'Submit' , label: 'Submit' , position: 2, invocationGrouping: #CHANGE_SET },
      { type                         : #FOR_ACTION,  dataAction: 'Reopen' , label: 'Re-Open' , position: 4, invocationGrouping: #CHANGE_SET },
      { type                         : #FOR_ACTION,  dataAction: 'Finalize' , label: 'Finalize' , position: 3, invocationGrouping: #CHANGE_SET },

      {  position                    : 10 ,
      importance                     : #MEDIUM,
      label                          : '',
      cssDefault                     :{width: '5rem'}
      } ]
      @Consumption.valueHelpDefinition:[{distinctValues: true },{ entity: { name: '/ESRCC/I_RYEAR', element: 'ryear' }}]
      @UI.selectionField             : [{ position: 10 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory  : true
  key ryear                          : /esrcc/ryear;

      @UI.lineItem                   : [ {
            position                 : 20 ,
            importance               : #MEDIUM,
            label                    : '',
            cssDefault               :{width: '5rem'}
          } ]
      @UI.selectionField             : [{ position: 20 }]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_POPER', element: 'Poper' }}]
      @Consumption.filter.mandatory  : false
  key poper                          : /esrcc/poper;

      @UI.lineItem                   : [ {
        position                     : 25 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @ObjectModel.text.element      : [ 'BaseVersionDescription' ]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_RoyaltyBaseVersion', element: 'RoyaltyBaseVersion' }, useForValidation: true } ]
      @UI.selectionField             : [{ position: 25 }]
      @UI.textArrangement            : #TEXT_LAST
  key fplv                           : /esrcc/royaltybase_version;

      @UI.lineItem                   : [ {
      position                       : 30 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key licensorsysid                  : /esrcc/licensor_sysid;

      @UI.lineItem                   : [ {
      position                       : 40 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @ObjectModel.text.element      : [ 'LicensorLegalEntityDescription' ]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'LegalEntity' },
//                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
//                                                           { localElement: 'LicensorCCode', element: 'CompanyCode' },
//                                                           { localElement: 'LicensorCostObject', element: 'Costobject' },
//                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' },
                                           useForValidation: true }]
      @UI.selectionField             : [{ position: 30 }]
      @UI.textArrangement            : #TEXT_LAST
  key licensorlegalentity            : /esrcc/licensor_legalentity;

      @UI.lineItem                   : [ {
      position                       : 50 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @ObjectModel.text.element      : [ 'LicensorCompanyCodeDescription' ]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'CompanyCode' },
//                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
//                                                           { localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
//                                                           { localElement: 'LicensorCostObject', element: 'Costobject' },
//                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_CompanyCodes_F4', element: 'Ccode' },
                                           useForValidation: true }]
      @UI.selectionField             : [{ position: 40 }]
      @UI.textArrangement            : #TEXT_LAST
  key licensorccode                  : /esrcc/licensor_ccode;

      @UI.lineItem                   : [ {
      position                       : 60 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @ObjectModel.text.element      : [ 'licensorcostobjectdescription' ]
      @UI.selectionField             : [{ position: 50 }]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costobject' },
//                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
//                                                           { localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
//                                                           { localElement: 'LicensorCCode', element: 'CompanyCode' },
//                                                           { localElement: 'LicensorCostCenter', element: 'Costcenter', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' },
                                           useForValidation: true }]
      @UI.textArrangement            : #TEXT_LAST
  key licensorcostobject             : /esrcc/licensor_costobject;

      @UI.lineItem                   : [ {
      position                       : 70 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @ObjectModel.text.element      : [ 'licensorcostcenterdescription' ]
      @UI.selectionField             : [{ position: 70 }]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
//                                       additionalBinding: [{ localElement: 'LicensorSysid', element: 'Sysid' },
//                                                           { localElement: 'LicensorLegalEntity', element: 'LegalEntity' },
//                                                           { localElement: 'LicensorCCode', element: 'CompanyCode' },
//                                                           { localElement: 'LicensorCostCenter', element: 'Costobject', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                           useForValidation: true }]
      @UI.textArrangement            : #TEXT_LAST
  key licensorcostcenter             : /esrcc/licensor_costcenter;

      @UI.lineItem                   : [ {
      position                       : 80 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @ObjectModel.text.element      : [ 'licensedescription' ]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_LICENSE_F4', element: 'License' }}]
            //                                       additionalBinding: [{ element: 'OECD', localElement: 'OECD' }]}]
      @UI.selectionField             : [{ position: 80 }]

      @UI.textArrangement            : #TEXT_LAST
  key license                        : /esrcc/licenseid;

      @UI.lineItem                   : [ {
      position                       : 90 ,
      importance                     : #MEDIUM,
      label                          : ''
      } ]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key licenseesysid                  : /esrcc/licensee_sysid;

      @UI.lineItem                   : [ {
        position                     : 100,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @ObjectModel.text.element      : [ 'LicenseeLegalEntityDescription' ]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'LegalEntity' },
//                                       additionalBinding: [{ localElement: 'LicenseeSysid', element: 'Sysid' },
//                                                           { localElement: 'LicenseeCostObject', element: 'Costobject' },
//                                                           { localElement: 'LicenseeCCode', element: 'CompanyCode' },
//                                                           { localElement: 'LicenseeCostCenter', element: 'Costcenter', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' },
                                           useForValidation: true }]
      @UI.selectionField             : [{ position: 100 }]
      @UI.textArrangement            : #TEXT_LAST
  key licenseelegalentity            : /esrcc/licensee_legalentity;

      @UI.lineItem                   : [ {
        position                     : 110 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @ObjectModel.text.element      : [ 'LicenseeCompanyCodeDescription' ]
      @UI.selectionField             : [{ position: 110 }]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'CompanyCode' },
//                                       additionalBinding: [{ localElement: 'LicenseeSysid', element: 'Sysid' },
//                                                           { localElement: 'LicenseeLegalEntity', element: 'LegalEntity' },
//                                                           { localElement: 'LicenseeCostObject', element: 'Costobject' },
//                                                           { localElement: 'LicenseeCostCenter', element: 'Costcenter', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_CompanyCodes_F4', element: 'Ccode' },
                                           useForValidation: true }]
      @UI.textArrangement            : #TEXT_LAST
  key licenseeccode                  : /esrcc/licensee_ccode;

      @UI.lineItem                   : [ {
        position                     : 120 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @ObjectModel.text.element      : [ 'licenseeCostObjectdescription' ]
      @UI.selectionField             : [{ position: 120 }]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costobject' },
//                                       additionalBinding: [{ localElement: 'LicenseeSysid', element: 'Sysid' },
//                                                           { localElement: 'LicenseeLegalEntity', element: 'LegalEntity' },
//                                                           { localElement: 'LicenseeCCode', element: 'CompanyCode' },
//                                                           { localElement: 'LicenseeCostCenter', element: 'Costcenter', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' },
                                           useForValidation: true }]
      @UI.textArrangement            : #TEXT_LAST
  key licenseecostobject             : /esrcc/licensee_costobject;

      @UI.lineItem                   : [ {
        position                     : 130 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @ObjectModel.text.element      : [ 'licenseeCostCenterdescription' ]
      @UI.selectionField             : [{ position: 130 }]
//      @Consumption.valueHelpDefinition:[{ entity: {  name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
//                                       additionalBinding: [{ localElement: 'LicenseeSysid', element: 'Sysid' },
//                                                           { localElement: 'LicenseeLegalEntity', element: 'LegalEntity' },
//                                                           { localElement: 'LicenseeCCode', element: 'CompanyCode' },
//                                                           { localElement: 'LicenseeCostCenter', element: 'Costobject', usage: #RESULT }],
//                                       useForValidation: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                           useForValidation: true }]
      @UI.textArrangement            : #TEXT_LAST
  key licenseecostcenter             : /esrcc/licensee_costcenter;

      @UI.lineItem                   : [ {
       position                      : 135 ,
       importance                    : #MEDIUM,
       label                         : ''
      } ]
      @ObjectModel.text.element      : [ 'LicenseTypeDescription' ]
      @UI.selectionField             : [{ position: 85 }]
//      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_LICENSE_F4', element: 'LicenseType' },
//                                               additionalBinding: [{ element: 'License', localElement: 'license' }]}]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LicenseType_F4', element: 'LicenseType' },
                                           useForValidation: true }]

      @UI.textArrangement            : #TEXT_LAST
      licensetyp                     : /esrcc/licensetype;

      @UI.lineItem                   : [ {
        position                     : 140 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      erpsalesorder                  : /esrcc/erpsalesorder;

      @UI.lineItem                   : [ {
        position                     : 150 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      agreementid                    : /esrcc/license_agreement_id;



      @UI.lineItem                   : [ {
        position                     : 170 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @ObjectModel.text.element      : [ 'RoyaltyBaseKeyDescription' ]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_RoyaltyBaseKeyF4', element: 'RoyaltyBaseKey' }, useForValidation: true } ]
      @UI.selectionField             : [{ position: 210 }]
      @UI.textArrangement            : #TEXT_LAST
      royaltybasekey                 : /esrcc/royaltybasekeys;



      @UI.lineItem                   : [ {
            position                 : 180 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @Semantics.amount.currencyCode: 'currency'    
      amountvalue                    : /esrcc/base_value_amount;
      
       @UI.lineItem                   : [ {
            position                 : 180 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @Semantics.quantity.unitOfMeasure: 'uom'   
      unitvalue                      : /esrcc/base_value_unit;

      @UI.lineItem                   : [ {
            position                 : 190 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @UI.hidden: true
      uom                            : /esrcc/uom;

      @UI.lineItem                   : [ {
            position                 : 200 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @EndUserText.label             : 'Currency'
      @UI.hidden: true
      currency                       : /esrcc/localcurr;

      @UI.lineItem                   : [ {
        position                     : 205 ,
        importance                   : #MEDIUM,
        label                        : ''
      } ]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_ROYALTYCOMPMETHOD', element: 'RoyaltyComputationMethod' }, useForValidation: true } ]
      @UI.selectionField             : [{ position: 220 }]
      @ObjectModel.text.element      : [ 'RoyaltyComputationMethodDesc' ]
      @UI.textArrangement            : #TEXT_ONLY
      royaltycomputationmethod       : /esrcc/royaltycomputationmeth;
      
      @UI.lineItem                   : [ {
            position                 : 210 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]         
      paramvalue                     : /esrcc/key_value;
      
      @UI.lineItem                   : [ {
            position                 : 210 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]      
      @Semantics.amount.currencyCode: 'paramcurrency'    
      paramamount                    : /esrcc/base_key_value;

      @UI.lineItem                   : [ {
            position                 : 215 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @EndUserText.label             : 'Royalty Computation Currency'
      @EndUserText.quickInfo         : 'Royalty Computation Currency'
      @UI.hidden: true
      paramcurrency                  : /esrcc/localcurr;

      @UI.lineItem                   : [ {
            position                 : 220 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @EndUserText.label             : 'Charge-Out Amount (Invoicing Currency)'
      @Semantics.amount.currencyCode : 'invoicecurrency'      
      chargeoutamount                : /esrcc/base_key_value;

      @UI.lineItem                   : [ {
            position                 : 230 ,
            importance               : #MEDIUM,
            label                    : '',
            criticality              : 'statuscriticallity'
          } ]
      @ObjectModel.text.element      : [ 'statusDescription' ]
      @UI.selectionField             : [{ position: 200 }]
      @Consumption.valueHelpDefinition:[{ entity: { name: '/ESRCC/I_ROYALTYSTATUS', element: 'Status' }}]
      @UI.textArrangement            : #TEXT_ONLY
      status                         : /esrcc/royaltystatus;

      @UI.lineItem                   : [ {
            position                 : 240 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      workflowid                     : /esrcc/workflowid;

      @UI.lineItem                   : [ {
            position                 : 400 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @Semantics.user.createdBy: true
      created_by                     : abp_creation_user;
      @UI.lineItem                   : [ {
            position                 : 410 ,
            importance               : #MEDIUM,
            label                    : ''
          } ]
      @Semantics.systemDateTime.createdAt: true
      created_at                     : abp_creation_tstmpl;
      @UI.lineItem                   : [ {
                position             : 420 ,
                importance           : #MEDIUM,
                label                : ''
              } ]
      @Semantics.user.lastChangedBy: true
      last_changed_by                : abp_lastchange_user;
      @UI.lineItem                   : [ {
                position             : 430 ,
                importance           : #MEDIUM,
                label                : ''
              } ]
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                : abp_lastchange_tstmpl;     
      @UI.lineItem                   : [ {
       position                      : 998 ,
       importance                    : #MEDIUM
      } ]
      @EndUserText.label: 'Licensor Country'  
      LicensorCountry                : land1;
      @UI.lineItem                   : [ {
       position                      : 999 ,
       importance                    : #MEDIUM
      } ]
      @EndUserText.label: 'Licensee Country'                 
      LicenseeCountry                : land1;
      
      @UI.lineItem                   : [ {
      position                       : 999 ,
      importance                     : #LOW,
      label                          : ''
      } ]
      @EndUserText.label: 'Royalty UUID'
      uuid                           : sysuuid_x16;

      @UI.hidden                     : true
      invoicecurrency                : /esrcc/localcurr;
      @UI.hidden                     : true
      LicenseDescription             : /esrcc/description;
      @UI.hidden                     : true
      LicensorSysidDescription       : /esrcc/description;
      @UI.hidden                     : true
      LicensorCompanyCodeDescription : /esrcc/description;
      @UI.hidden                     : true
      LicensorLegalEntityDescription : /esrcc/description;
      @UI.hidden                     : true
      LicensorCostObjectDescription  : /esrcc/description;
      @UI.hidden                     : true
      LicensorCostCenterDescription  : /esrcc/description;
      @UI.hidden                     : true
      LicenseeSysidDescription       : /esrcc/description;
      @UI.hidden                     : true
      LicenseeCompanyCodeDescription : /esrcc/description;
      @UI.hidden                     : true
      LicenseeLegalEntityDescription : /esrcc/description;
      @UI.hidden                     : true
      LicenseeCostObjectDescription  : /esrcc/description;
      @UI.hidden                     : true
      LicenseeCostCenterDescription  : /esrcc/description;
      @UI.hidden
      RoyaltyComputationMethodDesc   : /esrcc/description;
      @UI.hidden
      RoyaltyBaseKeyDescription      : /esrcc/description;
      @UI.hidden
      LicenseTypeDescription         : /esrcc/description;
      @UI.hidden
      statusDescription              : /esrcc/description;
      @UI.hidden
      statuscriticallity             : int1;
      @UI.hidden
      BaseVersionDescription         : /esrcc/description;


}
