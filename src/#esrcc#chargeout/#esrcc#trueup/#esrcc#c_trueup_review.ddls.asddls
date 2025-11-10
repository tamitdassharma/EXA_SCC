@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Execution Cockpit'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_TRUEUP'
@Metadata.allowExtensions: true

@UI.presentationVariant: [{ sortOrder: [
                                      { by: 'ryear' },
                                      { by: 'Refpoper' },
                                      { by: 'poper' },
                                      { by: 'sysid' },
                                      { by: 'Legalentity' },
                                      { by: 'ccode' },
                                      { by: 'Costobject' },
                                      { by: 'Costcenter' },
                                      { by: 'Receivingentity' },
                                      { by: 'ReceiverCompanyCode' },
                                      { by: 'ReceiverCostObject' },
                                      { by: 'ReceiverCostCenter' }
                                      ] }]
define root custom entity /ESRCC/C_TRUEUP_REVIEW
{

      @UI.lineItem               : [
      {  position                : 10 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @Consumption.valueHelpDefinition: [{distinctValues: true },{ entity: { name: '/ESRCC/I_RYEAR', element: 'ryear' }}]
      @UI.selectionField         : [{ position: 10 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
  key ryear                      : /esrcc/ryear;

      @UI.lineItem               : [ {
            position             : 20 ,
            importance           : #MEDIUM,
            label                : '',
            cssDefault           :{width: '5rem'}
          } ]
      @UI.selectionField         : [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_POPER', element: 'Poper' }}]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @EndUserText.label         : 'True-up Ref. Period'
  key Refpoper                   : /esrcc/poper;

      @UI.lineItem               : [ {
        position                 : 25 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '5rem'}
      } ]
  key poper                      : /esrcc/poper;

      @UI.lineItem               : [ {
      position                   : 30 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key sysid                      : /esrcc/sysid;

      @UI.lineItem               : [ {
      position                   : 40 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'legalentitydescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntity_F4', element: 'Legalentity' } }]
      @UI.selectionField         : [{ position: 30 }]
      @UI.textArrangement        : #TEXT_LAST
  key Legalentity                : /esrcc/legalentity;

      @UI.lineItem               : [ {
      position                   : 50 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'ccodedescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_PR_F4', element: 'Ccode' }}]
//                                           additionalBinding: [{ element: 'Legalentity', localElement: 'Legalentity' }]}]
      @UI.selectionField         : [{ position: 40 }]
      @UI.textArrangement        : #TEXT_LAST
  key ccode                      : /esrcc/ccode_de;

      @UI.lineItem               : [ {
      position                   : 60 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '10rem'}
      } ]
      @ObjectModel.text.element  : [ 'costobjectdescription' ]
      @UI.selectionField         : [{ position: 50 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @UI.textArrangement        : #TEXT_LAST
  key Costobject                 : /esrcc/costobject_de;

      @UI.lineItem               : [ {
      position                   : 70 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '10rem'}
      } ]
      @ObjectModel.text.element  : [ 'costcenterdescription' ]
      @UI.selectionField         : [{ position: 70 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' }}]
//                                           additionalBinding: [{ element: 'Costobject', localElement: 'Costobject'}]}]
      @UI.textArrangement        : #TEXT_LAST
  key Costcenter                 : /esrcc/costcenter;

      @UI.lineItem               : [ {
      position                   : 80 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'Serviceproductdescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICEPRODUCT_F4', element: 'ServiceProduct' }}]
      //                                       additionalBinding: [{ element: 'OECD', localElement: 'OECD' }]}]
      @UI.selectionField         : [{ position: 80 }]
      @UI.dataPoint              : { qualifier: 'srvprd' }
      @UI.textArrangement        : #TEXT_LAST
  key ServiceProduct             : /esrcc/srvproduct;

      @UI.lineItem               : [ {
      position                   : 90 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key ReceiverSysId              : /esrcc/recsysid;

      @UI.lineItem               : [ {
        position                 : 100,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'receivingentitydescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RECEIVINGENTITY_F4', element: 'Receivingentity' } }]
      @UI.selectionField         : [{ position: 100 }]
      @UI.textArrangement        : #TEXT_LAST
  key Receivingentity            : /esrcc/receivingntity;

      @UI.lineItem               : [ {
        position                 : 110 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'RecCcodedescription' ]
      @UI.selectionField         : [{ position: 110 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_REC_F4', element: 'Ccode' }}]
//                                           additionalBinding: [{ element: 'Legalentity', localElement: 'Receivingentity' }]}]
      @UI.textArrangement        : #TEXT_LAST
  key ReceiverCompanyCode        : /esrcc/recccode_de;

      @UI.lineItem               : [ {
        position                 : 120 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '10rem'}
      } ]
      @ObjectModel.text.element  : [ 'RecCostObjectdescription' ]
      @UI.selectionField         : [{ position: 120 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @UI.textArrangement        : #TEXT_LAST
  key ReceiverCostObject         : /esrcc/reccostobject_de;

      @UI.lineItem               : [ {
        position                 : 130 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '10rem'}
      } ]
      @ObjectModel.text.element  : [ 'RecCostCenterdescription' ]
      @UI.selectionField         : [{ position: 130 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_RECEIVER_F4', element: 'Costcenter' }}]
//                                           additionalBinding: [{ element: 'Costobject', localElement: 'ReceiverCostObject'}]}]
      @UI.textArrangement        : #TEXT_LAST
  key ReceiverCostCenter         : /esrcc/reccostcenter;

      @UI.lineItem               : [ {
        position                 : 999 ,
        importance               : #MEDIUM,
        label                    : '',
        hidden                   : true
      } ]
      @UI.selectionField         : [{ position: 900 }]
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
      @EndUserText.label         : 'Currency Type'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SENDERCURR', element: 'Currencytype' }}]
      @Consumption.filter.defaultValue: 'L'
      @UI.textArrangement        : #TEXT_LAST
  key Currencytype               : /esrcc/sendercurr;

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Currency', element: 'Currency' }} ]
      @EndUserText.label         : 'Currency'
      Currency                   : /esrcc/localcurr;

      @UI.lineItem               : [ {
        position                 : 200 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @EndUserText.label         : 'Charge-Out Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      StdTotalChargeoutAmount    : abap.curr(23,2);
      @UI.lineItem               : [ {
        position                 : 210 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @EndUserText.label         : 'Recal. Charge-Out Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      RecalTotalChargeoutAmount  : abap.curr(23,2);
      @UI.lineItem               : [ {
        position                 : 220 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @EndUserText.label         : 'True-up Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      DelTotalChargeoutAmount    : abap.curr(23,2);
      @UI.lineItem               : [ {
        position                 : 230 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @EndUserText.label         : 'Mark-up'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      StdTotalMarkup             : abap.curr(23,2);

      @UI.lineItem               : [ {
        position                 : 240 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @EndUserText.label         : 'Recal. Mark-up'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      RecalTotalMarkup           : abap.curr(23,2);

      @UI.lineItem               : [ {
        position                 : 250 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @EndUserText.label         : 'True-up Mark-up'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      DelTotalMarkup             : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 260 ,
       importance                : #MEDIUM,
       label                     : '',
       cssDefault                :{width: '15rem'}
      } ]
      @EndUserText.label         : 'Total Cost'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      StdTotalCostbase           : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 270 ,
       importance                : #MEDIUM,
       label                     : '',
       cssDefault                :{width: '15rem'}
      } ]
      @EndUserText.label         : 'Recal. Total Cost'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      RecalTotalCostbase         : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 280 ,
       importance                : #MEDIUM,
       label                     : '',
       cssDefault                :{width: '15rem'}
      } ]
      @EndUserText.label         : 'True-up Total Cost'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default       : #SUM
      DelTotalCostbase           : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 200 ,
       importance                : #MEDIUM,
       cssDefault                :{width: '7rem'}
      } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_TRUEUPTYPE', element: 'Trueuptype' }}]
      @ObjectModel.text.element  : [ 'trueuptypedescription' ]
      @UI.textArrangement        : #TEXT_ONLY
      Trueuptype                 : /esrcc/trueuptype;
      @UI.lineItem               : [ {
       position                  : 999 ,
       importance                : #MEDIUM
      } ]
      //      @UI.hidden                 : true
      RecCountry                 : land1;
      @UI.lineItem               : [ {
       position                  : 999 ,
       importance                : #MEDIUM
      } ]
      //      @UI.hidden                 : true
      Country                    : land1;
      @UI.hidden                 : true
      legalentitydescription     : /esrcc/description;
      @UI.hidden                 : true
      ccodedescription           : /esrcc/description;
      @UI.hidden                 : true
      costobjectdescription      : /esrcc/description;
      @UI.hidden                 : true
      costcenterdescription      : /esrcc/description;
      @UI.hidden                 : true
      Serviceproductdescription  : /esrcc/description;
      @UI.hidden                 : true
      receivingentitydescription : /esrcc/description;
      @UI.hidden                 : true
      RecCcodedescription        : /esrcc/description;
      @UI.hidden                 : true
      RecCostObjectdescription   : /esrcc/description;
      @UI.hidden                 : true
      RecCostCenterdescription   : /esrcc/description;
      @UI.hidden                 : true
      trueuptypedescription      : /esrcc/description;

}
