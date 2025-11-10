@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Chargeout'

//@Analytics.dataCategory: #CUBE
define view entity /ESRCC/I_TRUP_ANALYSIS
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout

{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
      _ServiceCost._CostCenterCost.Fplv,
      _ServiceCost._CostCenterCost.Ryear,
      _ServiceCost._CostCenterCost.Poper,
      _ServiceCost._CostCenterCost.RefPoper,
      _ServiceCost._CostCenterCost.Sysid,      
      _ServiceCost._CostCenterCost.Legalentity,      
      _ServiceCost._CostCenterCost.Ccode,      
      _ServiceCost._CostCenterCost.Costobject,      
      _ServiceCost._CostCenterCost.Costcenter,      
      _ServiceCost._CostCenterCost.ProcessType, 
      _ServiceCost._CostCenterCost.Profitcenter,
      _ServiceCost._CostCenterCost.Businessdivision,
      _ServiceCost._CostCenterCost.FunctionalArea,
      _ServiceCost.Servicetype,  
      _ServiceCost.Transactiongroup, 
      _ServiceCost.OECD, 
      _ServiceCost.Chargeout,       
      _ServiceCost.Serviceproduct,
      ReceiverSysId,
      ReceiverCompanyCode,
      Receivingentity,
      ReceiverCostObject,
      ReceiverCostCenter,
      InvoicingCurrency,     
      
      @Semantics.amount.currencyCode: 'Currency'          
      case Currencytype
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalRecMarkup as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      end
      else
      cast(TotalRecMarkup as abap.curr(23,2))  end  as TotalMarkup,
                                        
      
      @Semantics.amount.currencyCode: 'Currency'         
      case Currencytype
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecCostShare as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      end
      else
      cast(RecCostShare as abap.curr(23,2)) end as TotalCostbase,
                                        
      
      @Semantics.amount.currencyCode: 'Currency'         
      case Currencytype
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      end
      else cast(TotalChargeout as abap.curr(23,2)) end  as TotalChargeoutAmount,    
                            
      
      case Currencytype
      when 'I' then
      InvoicingCurrency
      else
      _ServiceCost._CostCenterCost.Currency end                                     as Currency,
      Exchdate,     
      ContractId,
      ErpSalesOrder,
      @Semantics.text: true
      ccodedescription                                                              as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription                                                         as RecCostCenterdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ProcessTypedescription,
      @Semantics.text: true
      costobjectdescription                                                         as RecCostObjectdescription,
      @Semantics.text: true
      statusdescription,
      Country                                                                       as RecCountry,
//      _CurrencyTypeText,
//      _ReceivingCountryText.,
      _ServiceCost._CostCenterCost.ccodedescription,
      _ServiceCost._CostCenterCost.legalentitydescription,
      _ServiceCost._CostCenterCost.costobjectdescription,
      _ServiceCost._CostCenterCost.costcenterdescription,
      _ServiceCost._CostCenterCost.Country,
      
      _ServiceCost.Serviceproductdescription         
}  


