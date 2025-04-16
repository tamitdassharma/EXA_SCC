@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Invoice Charge-out'
define root view entity /ESRCC/I_CHGINVOICE
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
  association [0..1] to /ESRCC/I_SENDERCURR as _CurrencyTypeText on _CurrencyTypeText.Currencytype = $projection.Currencytype
{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
      _ServiceCost._CostCenterCost.Sysid,
      _ServiceCost._CostCenterCost.Ccode,
      _ServiceCost._CostCenterCost.Legalentity,
      _ServiceCost._CostCenterCost.Costobject,
      _ServiceCost._CostCenterCost.Costcenter,
      ReceiverSysId,
      ReceiverCompanyCode,
      Receivingentity,
      ReceiverCostObject,
      ReceiverCostCenter,
      case Currencytype
      when 'I' then
       InvoicingCurrency
      else
      Currency end                                                                  as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'I' and Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                         amount => cast(TransferPrice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => InvoicingCurrency,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(TransferPrice as abap.curr(23,2)) end                               as TransferPrice,
      Reckpi,
      ConsumptionUom,
      Reckpishare,
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'I' and Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                         amount => cast(TotalChargeout as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => InvoicingCurrency,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(TotalChargeout as abap.curr(23,2)) end                              as TotalChargeout,
      InvoiceUUID,
      InvoiceNumber,
      InvoiceStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      InvoiceNumber                                                                 as Filename,
      case ReceiverChargeout.InvoiceStatus
        when '02' then 'application/pdf'
        when '03' then 'application/pdf'
        else '' end                                                                 as Mimetype,
      Country                                                                       as receivingentitycountry,
      _CurrencyTypeText,
      @Semantics.text: true
      ccodedescription                                                              as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription                                                         as RecCostCenterdescription,
      @Semantics.text: true
      costobjectdescription                                                         as RecCostObjectdescription,
      @Semantics.text: true
      invoicestatusdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ProcessTypedescription,
      //    _association_name // Make association public
      //  status color
      case ReceiverChargeout.InvoiceStatus
         when '01' then 0
         when '02' then 2
         when '03' then 3
         else
         0
        end                                                                         as invoicestatuscriticallity,
      _ReceivingCountryText,
      _ServiceCost
//      _ServiceCost._CostCenterCost._legalCountryText
}
where
      Status         =  'F'
  and Receivingentity <> 'REST'    
  and TotalChargeout <> 0
