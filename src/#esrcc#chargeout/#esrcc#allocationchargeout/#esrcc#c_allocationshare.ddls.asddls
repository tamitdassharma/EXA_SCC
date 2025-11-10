@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@EndUserText.label: 'Indirect Allocation KPI Share'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'fplv', 'ryear', 'poper', 'sysid', 'legalentity', 'costobject', 'costcenter']
define root view entity /ESRCC/C_ALLOCATIONSHARE
  provider contract transactional_query
  as projection on /ESRCC/I_ALLOCATIONSHARE
{
  key AlocUUID,
      ReceiverUUID,    
      @ObjectModel.text.element: [ 'costdatasetdescription' ]
      Fplv,
      Ryear,
      Poper,
      RefPoper,
      Sysid,
      @ObjectModel.text.element: [ 'ccodedescription' ]
      Ccode,
      @ObjectModel.text.element: [ 'legalentitydescription' ]
      Legalentity,
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      Costobject,
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      Costcenter,
      @ObjectModel.text.element: [ 'serviceproductdescription' ]
      Serviceproduct,
      @ObjectModel.text.element: [ 'RecCcodedescription' ]
      ReceiverCompanyCode,
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
      Receivingentity,
      @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
      ReceiverCostObject,
      @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
      ReceiverCostCenter,
      @ObjectModel.text.element: [ 'ProcessTypedescription' ]
      ProcessType,
      @ObjectModel.text.element: [ 'KeyVersionDescription' ]
      keyversion,
      @ObjectModel.text.element: [ 'AllocationKeyDescription' ]
      allockey,
      @ObjectModel.filter.enabled: false
      @ObjectModel.text.element: [ 'AllocationPeriodDescription' ]
      allocationperiod,
      @ObjectModel.filter.enabled: false
      refperiod,
      @ObjectModel.filter.enabled: false
      weightage,
      @DefaultAggregation: #SUM
      reckpivalue,
      totalreckpishare,
      @DefaultAggregation: #SUM
      reckpishare,
      @ObjectModel.text.element: [ 'oecdDescription' ]
      OECD,
      @Semantics.text: true
      oecdDescription,
      @Semantics.text: true
      legalentitydescription,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      RecCostObjectdescription,
      @Semantics.text: true
      RecCostCenterdescription,
      @Semantics.text: true
      Serviceproductdescription,
      @Semantics.text: true
      ProcessTypedescription,
      @ObjectModel.text.element: [ 'legalcountryname' ]
      legalentitycountry,
      @ObjectModel.text.element: [ 'receivingcountryname' ]
      receivingcountry,

//      _legalentity.LocalCurr       as legalentitycurrecy,
//      _receivingentity.LocalCurr   as receivingentitycurrency,
//      _legalentity.Region          as legalentityregion,
//      _receivingentity.Region      as receivingentityregion,
      @Semantics.text: true
      costdatasetdescription,
      @Semantics.text: true
      _KeyVersionText.text         as KeyVersionDescription,
      @Semantics.text: true
      _AllocKeyText.AllocationKeyDescription,
      @Semantics.text: true
      _AllocPeriodText.text        as AllocationPeriodDescription,
      @Semantics.text: true
      legalcountryname,
      @Semantics.text: true
      ReceivingCountryName,

      /* Associations */
      _ReceiverAllocation : redirected to composition child /ESRCC/C_ALLOCATIONVALUES

}
