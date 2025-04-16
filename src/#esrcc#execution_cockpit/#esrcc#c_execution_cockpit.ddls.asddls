@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Execution Cockpit'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_EXECUTIONCOCKPIT'
@Metadata.allowExtensions: true
define root custom entity /ESRCC/C_EXECUTION_COCKPIT
{
      @UI.lineItem           : [
                     { type  : #FOR_ACTION, dataAction: 'performcostbase', label: 'Perform Cost Base & Stewardship', position: 35, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'performchargeout', label: 'Perform Charge-Out', position: 40, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'performstewardship', label: 'Perform Service Cost Share & Markup', position: 20, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'Finalizecostbase', label: 'Finalize Cost Base', position: 10, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'Finalizestewardship', label: 'Finalize Stewardship & Cost Share', position: 30, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'Finalizechargeout', label: 'Finalize Charge-Out', position: 50, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'reopencostbase', label: 'Re-Open Cost Base', position: 60, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'reopenstewardship', label: 'Re-Open Stewardship & Cost Share', position: 70, invocationGrouping: #CHANGE_SET},
                     { type  : #FOR_ACTION, dataAction: 'reopenchargeout', label: 'Re-Open Charge-Out', position: 80, invocationGrouping: #CHANGE_SET},
                     { position: 10, hidden: true}]
      @UI.selectionField     : [{ position: 70 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTDATASET', element: 'costdataset' } }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @UI.textArrangement    : #TEXT_ONLY
  key fplv                   : /esrcc/costdataset_de;

      @UI.hidden             : true
  key sysid                  : /esrcc/sysid;

      @UI.lineItem           : [{ position: 11, hidden: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RYEAR', element: 'ryear' }}]
      @UI.selectionField     : [{ position: 10 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
  key ryear                  : /esrcc/ryear;

      @UI.lineItem           : [{ position: 10 }]
      @UI.hidden             : true
  key nodeid                 : abap.char(100);

      @UI.lineItem           : [{ position: 40, hidden: true }]
      @UI.selectionField     : [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntity_F4', element: 'Legalentity' } }]
      @ObjectModel.text.element: [ 'legalentitydescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key Legalentity            : /esrcc/legalentity;

      @UI.lineItem           : [{ position: 41, hidden: true  }]
      @UI.selectionField     : [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_PR_F4', element: 'Ccode' },
                                       additionalBinding: [{ element: 'Legalentity', localElement: 'Legalentity' }] }]
      @ObjectModel.text.element: [ 'ccodedescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key ccode                  : /esrcc/ccode_de;

      @UI.lineItem           : [{ position: 42, hidden: true  }]

      @UI.selectionField     : [{ position: 40  }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key Costobject             : /esrcc/costobject_de;

      @UI.lineItem           : [{ position: 50, hidden: true  }]
      @UI.selectionField     : [{ position: 50 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                            additionalBinding: [{ element: 'Costobject', localElement: 'Costobject'}]}]
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key Costcenter             : /esrcc/costcenter;



      @UI.lineItem           : [{ position: 60, hidden: true  }]
      @UI.selectionField     : [{ position: 60 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICEPRODUCT_F4', element: 'ServiceProduct' },
                                          additionalBinding: [{ element: 'OECD', localElement: 'oecd' }] }]
      @ObjectModel.text.element: [ 'serviceproductdescr' ]
      @UI.textArrangement    : #TEXT_LAST
  key ServiceProduct         : /esrcc/srvproduct;

      @Consumption.filter.selectionType: #SINGLE
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BILLINGFREQ', element: 'Billingfreq' } }]
      @UI.selectionField     : [{ position: 80 }]
      @Consumption.filter.mandatory: true
      @UI.textArrangement    : #TEXT_FIRST
  key Billingfreq            : /esrcc/billfrequency;

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BILLINGFREQUENCY_F4', element: 'Billingperiod' },
                                          additionalBinding: [{ element: 'Billingfreq', localElement: 'Billingfreq' }] }]
      @Consumption.filter.selectionType: #SINGLE
      @UI.selectionField     : [{ position: 90 }]
      @Consumption.filter.mandatory: true
      @UI.textArrangement    : #TEXT_LAST
      @EndUserText.label     : 'Billing Period'
  key Billingperiod          : /esrcc/billperiod;

      @UI.lineItem           : [{ position: 50, hidden: true  }]
      @UI.selectionField     : [{ position: 55 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_OECD', element: 'OECD' }}]
      @UI.textArrangement    : #TEXT_LAST
      oecd                   : /esrcc/oecdtpg_de;

      @UI.lineItem           : [{ position: 70, criticality: 'costbasecriticallity', criticalityRepresentation: #WITHOUT_ICON }]
      @EndUserText.label     : 'Cost Base & Stewardship'
      @ObjectModel.text.element: [ 'costbasestatusdescr' ]
      @UI.textArrangement    : #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECSTATUS', element: 'Status' } }]
      @UI.hidden             : true
      Costbase_status        : /esrcc/process_status_de;

      @UI.lineItem           : [{ position: 80, criticality: 'stewardshipcriticality', criticalityRepresentation: #WITHOUT_ICON  }]

      @EndUserText.label     : 'Service Cost Share & Markup'
      @ObjectModel.text.element: [ 'stewardshipstatusdescr' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECSTATUS', element: 'Status' } }]
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      Stewardship_status     : /esrcc/process_status_de;

      @UI.lineItem           : [{ position: 90, criticality: 'chargeoutcriticality', criticalityRepresentation: #WITHOUT_ICON  }]
      @EndUserText.label     : 'Charge-Out to Receivers'
      @ObjectModel.text.element: [ 'chargeoutstatusdescr' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECSTATUS', element: 'Status' } }]
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      Chargeout_status       : /esrcc/process_status_de;

      @UI.lineItem           : [{ position: 100, hidden: true }]
      @EndUserText.label     : 'year end adjustment'
      @UI.hidden             : true
      ye_status              : /esrcc/process_status_de;

      @UI.hidden             : true
      legalentitydescription : /esrcc/description;
      @UI.hidden             : true
      ccodedescription       : /esrcc/description;
      @UI.hidden             : true
      costobjectdescription  : /esrcc/description;
      @UI.hidden             : true
      costcenterdescription  : /esrcc/description;
      @UI.hidden             : true
      serviceproductdescr    : /esrcc/description;
      @UI.hidden             : true
      costbasestatusdescr    : /esrcc/status_description;
      @UI.hidden             : true
      stewardshipstatusdescr : /esrcc/status_description;
      @UI.hidden             : true
      chargeoutstatusdescr   : /esrcc/status_description;
      @UI.hidden             : true
      legalcountry           : land1;
      @UI.hidden             : true
      costbasecriticallity   : abap.char(1);
      @UI.hidden             : true
      stewardshipcriticality : abap.char(1);
      @UI.hidden             : true
      chargeoutcriticality   : abap.char(1);
      @UI.hidden             : true
      parentnodeid           : abap.char(100);
      @UI.hidden             : true
      HierarchyLevel         : abap.numc(1);
      @UI.hidden             : true
      Drillstate             : abap.char(20);
      @UI.hidden             : true
      description            : abap.char(256);
      @UI.hidden             : true
      selectionallowed       : abap_boolean;
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECUTIONACTIONS', element: 'Action' }}]
      @Consumption.filter.hidden: true
      @UI.textArrangement    : #TEXT_ONLY
      @UI.selectionField     : [{ position: 70 }]
      @Consumption.filter.selectionType: #SINGLE
      action                 : /esrcc/actions;
      @UI.hidden             : true
      messagecostbase        : abap.char( 225 );
      @UI.hidden             : true
      messageservice         : abap.char( 225 );
      @UI.hidden             : true
      messagechargeout       : abap.char( 225 );
      @UI.hidden             : true
      messagetypecostbase    : abap.char( 1 );
      @UI.hidden             : true
      messagetypeservice     : abap.char( 1 );
      @UI.hidden             : true
      messagetypechargeout   : abap.char( 1 );
      @UI.hidden             : true
      chain_id               : /esrcc/chain_id;
      @UI.hidden             : true
      chain_sequence         : /esrcc/chain_sequence;
      @UI.hidden             : true
      costbaselogid          : sysuuid_c32;
      @UI.hidden             : true
      serviceproductlogid    : sysuuid_c32;
      @UI.hidden             : true
      chargeoutlogid         : sysuuid_c32;
      
}
