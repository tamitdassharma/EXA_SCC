@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'True-up Open Task'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_TRUEUP_OPENTASK'
@Metadata.allowExtensions: true
define root custom entity /ESRCC/C_TRUEUP_OPENTASK
{

      @UI.lineItem               : [
      {  position                : 10 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @ObjectModel.filter.enabled: false
  key ryear                      : /esrcc/ryear;

      @UI.lineItem               : [ {
            position             : 20 ,
            importance           : #MEDIUM,
            label                : '',
            cssDefault           :{width: '5rem'}
          } ]
      @ObjectModel.filter.enabled: false
      @EndUserText.label         : 'True-up Ref. Period'
  key Refpoper                   : /esrcc/poper;

      @UI.lineItem               : [ {
        position                 : 25 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '5rem'}
      } ]
      @ObjectModel.filter.enabled: false
  key poper                      : /esrcc/poper;

      @UI.lineItem               : [ {
      position                   : 30 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @ObjectModel.filter.enabled: false
  key sysid                      : /esrcc/sysid;

      @UI.lineItem               : [ {
      position                   : 40 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '20rem'}
      } ]
      @ObjectModel.text.element  : [ 'legalentitydescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key Legalentity                : /esrcc/legalentity;

      @UI.lineItem               : [ {
      position                   : 50 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'ccodedescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key ccode                      : /esrcc/ccode_de;

      @UI.lineItem               : [ {
      position                   : 60 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @ObjectModel.text.element  : [ 'costobjectdescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key Costobject                 : /esrcc/costobject_de;

      @UI.lineItem               : [ {
      position                   : 70 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @ObjectModel.text.element  : [ 'costcenterdescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key Costcenter                 : /esrcc/costcenter;

      @UI.lineItem               : [ {
      position                   : 80 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '15rem'}
      } ]
      @ObjectModel.text.element  : [ 'Serviceproductdescription' ]
      @ObjectModel.filter.enabled: false
      @UI.dataPoint              : { qualifier: 'srvprd' }
      @UI.textArrangement        : #TEXT_LAST
  key ServiceProduct             : /esrcc/srvproduct;

      @UI.lineItem               : [ {
      position                   : 90 ,
      importance                 : #MEDIUM,
      label                      : '',
      cssDefault                 :{width: '5rem'}
      } ]
      @ObjectModel.filter.enabled: false
  key ReceiverSysId              : /esrcc/recsysid;

      @UI.lineItem               : [ {
        position                 : 100,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '20rem'}
      } ]
      @ObjectModel.text.element  : [ 'receivingentitydescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key Receivingentity            : /esrcc/receivingntity;

      @UI.lineItem               : [ {
        position                 : 110 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '5rem'}
      } ]
      @ObjectModel.text.element  : [ 'RecCcodedescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key ReceiverCompanyCode        : /esrcc/recccode_de;

      @UI.lineItem               : [ {
        position                 : 120 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '5rem'}
      } ]
      @ObjectModel.text.element  : [ 'RecCostObjectdescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key ReceiverCostObject         : /esrcc/reccostobject_de;

      @UI.lineItem               : [ {
        position                 : 130 ,
        importance               : #MEDIUM,
        label                    : '',
        cssDefault               :{width: '5rem'}
      } ]
      @ObjectModel.text.element  : [ 'RecCostCenterdescription' ]
      @ObjectModel.filter.enabled: false
      @UI.textArrangement        : #TEXT_LAST
  key ReceiverCostCenter         : /esrcc/reccostcenter;

      @UI.lineItem               : [ {
        position                 : 999 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      @UI.selectionField         : [{ position: 900 }]
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
      @EndUserText.label         : 'Currency Type'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SENDERCURR', element: 'Currencytype' }}]
      @Consumption.filter.defaultValue: 'L'      
      @UI.textArrangement        : #TEXT_LAST
  key Currencytype               : /esrcc/sendercurr;
      
      @ObjectModel.filter.enabled: false
      @EndUserText.label         : 'Currency'
      Currency                   : /esrcc/localcurr;

      @UI.lineItem               : [ {
        position                 : 200 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      
      @EndUserText.label         : 'Charge-Out Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      StdTotalChargeoutAmount    : abap.curr(23,2);
      @UI.lineItem               : [ {
        position                 : 210 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      
      @EndUserText.label         : 'Recal. Charge-Out Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      RecalTotalChargeoutAmount  : abap.curr(23,2);
      @UI.lineItem               : [ {
        position                 : 220 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
     
      @EndUserText.label         : 'True-up Charge-Out Amount'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      DelTotalChargeoutAmount    : abap.curr(23,2);
      @UI.lineItem               : [ {
        position                 : 230 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      
      @EndUserText.label         : 'Mark-up'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      StdTotalMarkup             : abap.curr(23,2);

      @UI.lineItem               : [ {
        position                 : 240 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      
      @EndUserText.label         : 'Recal. Mark-up'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      RecalTotalMarkup           : abap.curr(23,2);

      @UI.lineItem               : [ {
        position                 : 250 ,
        importance               : #MEDIUM,
        label                    : ''
      } ]
      
      @EndUserText.label         : 'True-up Mark-up'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      DelTotalMarkup             : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 260 ,
       importance                : #MEDIUM,
       label                     : '',
       cssDefault                :{width: '15rem'}
      } ]
      
      @EndUserText.label         : 'Total Cost'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      StdTotalCostbase           : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 270 ,
       importance                : #MEDIUM,
       label                     : '',
       cssDefault                :{width: '15rem'}
      } ]
      
      @EndUserText.label         : 'Recal. Total Cost'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      RecalTotalCostbase         : abap.curr(23,2);

      @UI.lineItem               : [ {
       position                  : 280 ,
       importance                : #MEDIUM,
       label                     : '',
       cssDefault                :{width: '15rem'}
      } ]
      
      @EndUserText.label         : 'True-up Total Cost'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      DelTotalCostbase           : abap.curr(23,2);
      
      @UI.lineItem               : [ {
       position                  : 200 ,
       importance                : #MEDIUM
      } ]
      @ObjectModel.filter.enabled: false
      @ObjectModel.text.element  : [ 'trueuptypedescription' ]
      @UI.textArrangement        : #TEXT_ONLY
      Trueuptype                 : /esrcc/trueuptype;
      @ObjectModel.filter.enabled: false
      @UI.lineItem               : [ {
       position                  : 999 ,
       importance                : #LOW
      } ]
      RecCountry                 : land1;
      @ObjectModel.filter.enabled: false
      @UI.lineItem               : [ {
       position                  : 999 ,
       importance                : #LOW
      } ]
      Country                    : land1;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      legalentitydescription     : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      ccodedescription           : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      costobjectdescription      : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      costcenterdescription      : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      Serviceproductdescription  : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      receivingentitydescription : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      RecCcodedescription        : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      RecCostObjectdescription   : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      RecCostCenterdescription   : /esrcc/description;
      @ObjectModel.filter.enabled: false
      @UI.hidden                 : true
      trueuptypedescription      : /esrcc/description;
      @UI.lineItem               : [ {
       position                  : 140 ,
       importance                : #MEDIUM,
       label                     : ''       
      } ]
      @EndUserText.label: 'Workflow ID'
      @Consumption.filter.hidden: true
      @UI.selectionField: [{ position: 10  }]
      Workflowid                 : /esrcc/workflowid;

}
