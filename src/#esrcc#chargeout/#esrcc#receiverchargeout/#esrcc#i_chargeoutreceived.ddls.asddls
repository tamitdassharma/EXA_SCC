@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Charge-Out'

@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CHARGEOUTRECEIVED
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
  association [0..1] to /ESRCC/I_RECEIVERCURR as _CurrencyTypeText 
                     on _CurrencyTypeText.Currencytype = $projection.Currencytype 
  
  association [0..1] to /ESRCC/I_TRUEUP as _trueup
                      on _trueup.RootUUID            = $projection.RootUUID
                     and _trueup.ParentUUID          = $projection.ParentUUID                    
                     and _trueup.Receiversysid       = $projection.ReceiverSysId
                     and _trueup.Receivercompanycode = $projection.ReceiverCompanyCode
                     and _trueup.Receivingentity     = $projection.Receivingentity
                     and _trueup.Receivercostobject  = $projection.ReceiverCostObject
                     and _trueup.Receivercostcenter  = $projection.ReceiverCostCenter                   

{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
      _ServiceCost._CostCenterCost.Fplv as Fplv,
      _ServiceCost._CostCenterCost.Ryear as Ryear,
      _ServiceCost._CostCenterCost.Poper as Poper,
      _ServiceCost._CostCenterCost.Sysid as Sysid,      
      _ServiceCost._CostCenterCost.Legalentity as Legalentity,      
      _ServiceCost._CostCenterCost.Ccode as Ccode,      
      _ServiceCost._CostCenterCost.Costobject as Costobject,      
      _ServiceCost._CostCenterCost.Costcenter as Costcenter,  
       _ServiceCost._CostCenterCost.Profitcenter,
        _ServiceCost._CostCenterCost.Businessdivision,
         _ServiceCost._CostCenterCost.FunctionalArea,    
      _ServiceCost._CostCenterCost.ProcessType,      
      _ServiceCost.Serviceproduct as Serviceproduct,
      ReceiverSysId,
      ReceiverCompanyCode,
      Receivingentity,
      ReceiverCostObject,
      ReceiverCostCenter,
      Status,      
      @Semantics.amount.currencyCode: 'Currency'
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalRecMarkup as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else
      cast(TotalRecMarkup as abap.curr(23,2))
      end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalRecMarkup as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else
      cast(TotalRecMarkup as abap.curr(23,2))
      end
      else
      cast(TotalRecMarkup as abap.curr(23,2))  end                                  as TotalMarkup,

      @Semantics.amount.currencyCode: 'Currency'
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecCostShare as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else
      cast(RecCostShare as abap.curr(23,2))
      end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecCostShare as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(RecCostShare as abap.curr(23,2)) end
      else
      cast(RecCostShare as abap.curr(23,2)) end                                     as TotalCostbase,

      @Semantics.amount.currencyCode: 'Currency'
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecValueadded as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(RecValueadded as abap.curr(23,2)) end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecValueadded as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(RecValueadded as abap.curr(23,2)) end
      else cast(RecValueadded as abap.curr(23,2)) end                               as TotalValueAdd,

      @Semantics.amount.currencyCode: 'Currency'
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecPassthrough as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(RecPassthrough as abap.curr(23,2)) end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(RecPassthrough as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(RecPassthrough as abap.curr(23,2)) end
      else cast(RecPassthrough as abap.curr(23,2)) end                              as TotalPassthrough,

      @Semantics.amount.currencyCode: 'Currency'
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(TotalChargeout as abap.curr(23,2)) end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(TotalChargeout as abap.curr(23,2)) end
      else cast(TotalChargeout as abap.curr(23,2)) end                              as ChargeoutAmount,
      
      @Semantics.amount.currencyCode: 'Currency'
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast( _trueup.AmountL as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast(_trueup.AmountL as abap.curr(23,2)) end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(_trueup.AmountL as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(_trueup.AmountL as abap.curr(23,2)) end
      else cast(_trueup.AmountG as abap.curr(23,2)) end                              as TotalTrueupAmount,
           
      @Semantics.amount.currencyCode: 'Currency'
      case when _trueup.AmountL is not initial then
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast((TotalChargeout + cast(_trueup.AmountL as abap.dec(23,2))) as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast((TotalChargeout + cast(_trueup.AmountL as abap.dec(23,2))) as abap.curr(23,2)) end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast((TotalChargeout + cast(_trueup.AmountL as abap.dec(23,2))) as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast((TotalChargeout + cast(_trueup.AmountL as abap.dec(23,2)) ) as abap.curr(23,2)) end
      else cast(( TotalChargeout + cast(_trueup.AmountG as abap.dec(23,2)) ) as abap.curr(23,2)) end       
      else
      case Currencytype
      when 'L' then
      case when Currency <> ReceiverCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => ReceiverCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast(TotalChargeout  as abap.curr(23,2)) end
      when 'I' then
      case when Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => InvoicingCurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast(TotalChargeout as abap.curr(23,2)) end
      else cast(TotalChargeout as abap.curr(23,2)) end       
      end as TotalChargeoutAmount,

      case Currencytype
      when 'L' then
      ReceiverCurrency
      when 'I' then
      InvoicingCurrency
      else
      _ServiceCost._CostCenterCost.Currency end                                     as Currency,
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
      _CurrencyTypeText,
      _ReceivingCountryText,
      _ServiceCost        
}


