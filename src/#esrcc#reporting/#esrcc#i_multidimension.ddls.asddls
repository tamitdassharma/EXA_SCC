@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Charge Out Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}}
@Analytics.dataCategory: #CUBE

define view entity /ESRCC/I_MultiDimension
  as select from /ESRCC/I_CHG_ANALYTICS as ReceiverShare
  
  association  [0..1] to /ESRCC/I_RYEAR as _ryear on _ryear.ryear = $projection.Ryear 
  
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as _legalentity on _legalentity.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _receivingentity
  on _receivingentity.Receivingentity = $projection.Receivingentity
  
  association [0..1] to /ESRCC/I_COSNUMBER_F4 as _costcenter
  on _costcenter.Costcenter = ReceiverShare.Costcenter
  
  association [0..1] to /ESRCC/I_PROFITCENTER_F4 as _profitcenter
  on _profitcenter.ProfitCenter = $projection.Profitcenter
  
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4 as _businessdiv
  on _businessdiv.BusinessDivision = $projection.Businessdivision
  
  association [0..1] to /ESRCC/I_SERVICEPRD_F4   as _serviceproduct         
  on _serviceproduct.ServiceProduct = $projection.Serviceproduct
  
  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as _srvtyp                
  on  _srvtyp.ServiceType = $projection.Servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as _srvtransactiongroup    
  on  _srvtransactiongroup.Transactiongroup = ReceiverShare.Transactiongroup
{

      /** DIMENSIONS **/
      @ObjectModel.foreignKey.association: '_ryear'
  key Ryear,
  key Poper,
  key Fplv,
  key Sysid,
      @ObjectModel.foreignKey.association: '_legalentity'
  key Legalentity,
  key Ccode,
  key Costobject,
      @ObjectModel.foreignKey.association: '_costcenter'
  key Costcenter,
      @ObjectModel.foreignKey.association: '_serviceproduct'
  key Serviceproduct,
      @ObjectModel.foreignKey.association: '_receivingentity'
  key Receivingentity,  
      @EndUserText.label: 'System ID (Receiver)'   
  key ReceiverSysId,
      @EndUserText.label: 'Cost Object Type (Receiver)'
  key ReceiverCostObject,
      @EndUserText.label: 'Cost Object Number (Receiver)'
  key ReceiverCostCenter,
      @ObjectModel.foreignKey.association: '_srvtyp'
      Servicetype,
      @ObjectModel.foreignKey.association: '_srvtransactiongroup'
      Transactiongroup,
      ContractId,
//      localcurr,
//      groupcurr, 
      Currency,   
      FunctionalArea,
      @ObjectModel.foreignKey.association: '_businessdiv'
      Businessdivision,
      @ObjectModel.foreignKey.association: '_profitcenter'
      ReceiverShare.Profitcenter,
      Controllingarea,      
      Chargeout,

      /** Additional Fields**/
      Reckpi,
      Reckpishare,

      /** MEASURES **/
      @EndUserText.label: 'Total Cost (Initial)'
      @DefaultAggregation: #SUM
      cast( RecTotalCost as abap.dec(23,2)) as RecTotalCost,
      
      @EndUserText.label: 'Total Included Cost'
      @DefaultAggregation: #SUM
      cast( RecIncludedCost as abap.dec(23,2)) as RecIncludedCost,

      @EndUserText.label: 'Excluded Cost'
      @DefaultAggregation: #SUM
      cast( RecExcludedCost as abap.dec(23,2)) as RecExcludedCost,

      @EndUserText.label: 'Thereof Value-Add'
      @DefaultAggregation: #SUM
      cast( RecOrigTotalCost as abap.dec(23,2)) as RecOrigTotalCost,

      @EndUserText.label: 'Thereof Pass-Through'
      @DefaultAggregation: #SUM
      cast( RecPassTotalCost as abap.dec(23,2)) as RecPassTotalCost,
      
      @EndUserText.label: 'Total Stewardship'
      @DefaultAggregation: #SUM
      cast( RecStewardship as abap.dec(23,2)) as RecStewardship,      

      @EndUserText.label: 'Total Service Cost'
      @DefaultAggregation: #SUM
      cast( RecCostShare as abap.dec(23,2)) as RecCostShare,

      @EndUserText.label: 'Thereof Value-Add Service Cost'
      @DefaultAggregation: #SUM
      cast( RecValueadded as abap.dec(23,2)) as RecValueadded,

      @EndUserText.label: 'Thereof Pass-Through Service Cost'
      @DefaultAggregation: #SUM
      cast( RecPassthrough as abap.dec(23,2)) as RecPassthrough,
      
      @EndUserText.label: 'Total Mark-up'
      @DefaultAggregation: #SUM
      cast( TotalRecMarkup as abap.dec(23,2)) as TotalRecMarkup,
      
      @EndUserText.label: 'Thereof Value-Add Mark-up'
      @DefaultAggregation: #SUM
      cast( RecValueaddMarkup as abap.dec(23,2)) as RecValueaddMarkup,

      @EndUserText.label: 'Thereof Pass-Through Mark-up'
      @DefaultAggregation: #SUM
      cast( RecPassthroughMarkup as abap.dec(23,2)) as RecPassthroughMarkup,
      
      @EndUserText.label: 'Charge-Out Amount'
      @DefaultAggregation: #SUM
      cast( StdChargeout as abap.dec(23,2)) as TotalStdChargeout,
      
      @EndUserText.label: 'Total True-up Amount'
      @DefaultAggregation: #SUM
      cast( TotalTrueupAmount as abap.dec(23,2)) as TotalTrueupAmount,
      
      @EndUserText.label: 'Total Charge-Out Amount'
      @DefaultAggregation: #SUM
      cast( TotalChargeout as abap.dec(23,2)) as TotalChargeout,
      
      _ryear,
      _legalentity,
      _receivingentity,
      _costcenter,
      _serviceproduct,
      _profitcenter,
      _businessdiv,
      _srvtyp,
      _srvtransactiongroup
    
}where ProcessType <> 'R'
