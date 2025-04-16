@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Chargeout'

@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CHARGEOUTRECEIVED
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
  association [0..1] to /ESRCC/I_RECEIVERCURR as _CurrencyTypeText on _CurrencyTypeText.Currencytype = $projection.Currencytype

{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
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
      else cast(TotalChargeout as abap.curr(23,2)) end                              as TotalChargeoutAmount,

      case Currencytype
      when 'L' then
      ReceiverCurrency
      when 'I' then
      InvoicingCurrency
      else
      _ServiceCost._CostCenterCost.Currency end                                     as Currency,
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


