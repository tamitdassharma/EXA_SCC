@EndUserText.label: 'Workflow Manager'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_WF_MANAGER'
@Metadata.allowExtensions: true
define root custom entity /ESRCC/C_WF_MANAGER
{     @UI.lineItem: [ 
      {type: #FOR_ACTION, dataAction: 'approve', label: 'Approve', position: 10, invocationGrouping: #CHANGE_SET }, 
      { type: #FOR_ACTION, dataAction: 'reject', label: 'Reject', position: 10, invocationGrouping: #CHANGE_SET    },
      { position: 10 }]
      @UI.selectionField: [{ position: 100 }]
  key Workflowid     : /esrcc/sww_wiid; 
      @UI.selectionField: [{ position: 10 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_APPLICATION_TYPE', element: 'ApplicationType' }}]    
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
      @UI.textArrangement    : #TEXT_LAST
      @UI.lineItem: [{ hidden: true }]
      application     : /esrcc/application_type_de;
      @UI.selectionField: [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTDATASET', element: 'costdataset' },
                                        additionalBinding: [{ element: 'costdataset', localElement: 'Fplv' }] }]
      @UI.textArrangement    : #TEXT_LAST
      @UI.lineItem: [{ hidden: true }]
      fplv            : /esrcc/costdataset_de;
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RYEAR', element: 'ryear' }}]
      @UI.selectionField     : [{ position: 30 }]
      @Consumption.filter.selectionType: #SINGLE
      @UI.lineItem: [{ hidden: true }]
      ryear           : /esrcc/ryear;
      @UI.lineItem: [{ hidden: true }]
      @UI.selectionField     : [{ position: 60 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BILLINGFREQ', element: 'Billingfreq' } }]
      @UI.textArrangement    : #TEXT_LAST
      billfrequency   : /esrcc/billfrequency;
      @UI.selectionField     : [{ position: 70 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BILLINGFREQUENCY_F4', element: 'Billingperiod' },
                                          additionalBinding: [{ element: 'Billingfreq', localElement: 'Billfrequency' }] }]
      @Consumption.filter.selectionType: #SINGLE
      @UI.textArrangement    : #TEXT_LAST
      @UI.lineItem: [{ hidden: true }]
      billingperiod   : /esrcc/billperiod;
      @UI.lineItem: [ { position: 11 } ]
      @UI.selectionField     : [{ position: 50 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntity_F4', element: 'Legalentity' } }]
      @UI.textArrangement    : #TEXT_LAST
      @ObjectModel.text.element: [ 'legalentitydescription' ]
      legalentity     : /esrcc/legalentity;
      @UI.selectionField     : [{ position: 40 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                       additionalBinding: [{ element: 'Legalentity', localElement: 'Legalentity' }] }]
      @UI.textArrangement    : #TEXT_LAST
      @UI.lineItem: [{ hidden: true }]
      ccode           : /esrcc/ccode_de;
      @UI.hidden: true
      sysid           : /esrcc/sysid;
      @UI.lineItem: [ { position: 12 } ]
      @UI.selectionField     : [{ position: 80  }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      @UI.textArrangement    : #TEXT_ONLY
      costobject      : /esrcc/costobject_de;
      @UI.lineItem: [ { position: 13 } ]
      @UI.selectionField     : [{ position: 90 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                            additionalBinding: [{ element: 'Costobject', localElement: 'Costobject'}]}]
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      @UI.textArrangement    : #TEXT_LAST
      costcenter      : /esrcc/costcenter;
      @UI.lineItem: [{ hidden: true }]
      serviceproduct  : /esrcc/srvproduct;
      @UI.lineItem: [{ hidden: true }]
      receivingentity : /esrcc/receivingntity; 
      @UI.lineItem: [{ position: 20, label: 'Workflow Task Subject' }] 
      subject         : abap.string(0);
      @UI.lineItem: [{ position: 40, label: 'Current Users' }]
      recipients      : abap.string(0);
      @UI.lineItem: [{ position: 30, label: 'Workflow Status', criticality: 'statuscriticality' }]
      workflow_status : abap.char(10);
      @UI.lineItem: [{ position: 50, label: 'Last Action By' }]
      lastchangedby   : abap.string(0);
      @UI.lineItem: [{ position: 60, label: 'Last Action On' }]
      lastchangedon   : abp_lastchange_tstmpl;
      @UI.hidden: true
      statuscriticality : abap.char(1);
      @UI.lineItem: [ { position: 45, label: 'Overview Workflow Steps' } ]
      overviewstep : abap.string(0);
      @UI.lineItem: [ { position: 22, label: 'View Task' } ]
      viewtask : abap.string(0);
      @UI.hidden: true
      legalentitydescription : /esrcc/description;
      @UI.hidden: true
      costobjectdescription  : /esrcc/description;
      @UI.hidden: true
      costcenterdescription  : /esrcc/description;
}
