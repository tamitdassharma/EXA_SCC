@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Invoice Charge-out'
@Metadata.ignorePropagatedAnnotations: true
define root view entity /ESRCC/I_CHGINVOICE
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
  association [0..1] to /ESRCC/I_SENDERCURR     as _CurrencyTypeText on _CurrencyTypeText.Currencytype = $projection.Currencytype
  association [0..1] to /ESRCC/I_INVPROCESSTYPE as _chargeouttype    on _chargeouttype.ChargeoutType = $projection.Chargeamountytpe
{
  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
  key _ServiceCost._CostCenterCost.ProcessType                   as Chargeamountytpe,
      _ServiceCost._CostCenterCost.Ryear,
      _ServiceCost._CostCenterCost.Poper,
      cast('' as /esrcc/poper) as Recalrefpoper,
      _ServiceCost._CostCenterCost.Fplv,
      _ServiceCost._CostCenterCost.Sysid,
      _ServiceCost._CostCenterCost.Ccode,
      _ServiceCost._CostCenterCost.Legalentity,
      _ServiceCost._CostCenterCost.Costobject,
      _ServiceCost._CostCenterCost.Costcenter,
      _ServiceCost._CostCenterCost.Profitcenter,
      _ServiceCost._CostCenterCost.Businessdivision,
      _ServiceCost._CostCenterCost.FunctionalArea,
      //      _ServiceCost._CostCenterCost.ProcessType,
      _ServiceCost.Serviceproduct,
      _ServiceCost.Servicetype,
      _ServiceCost.Transactiongroup,
      _ServiceCost.Chargeout,
      ReceiverSysId,
      ReceiverCompanyCode,
      Receivingentity,
      ReceiverCostObject,
      ReceiverCostCenter,
      ContractId,
      ErpSalesOrder,
      PostingDate,
      PostingPeriod,
      ErpFlag,
      case Currencytype
      when 'I' then
       InvoicingCurrency
      else
      Currency end                                               as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'I' and Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                         amount => cast(TransferPrice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => InvoicingCurrency,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(TransferPrice as abap.curr(23,2)) end            as TransferPrice,
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
      else cast(TotalChargeout as abap.curr(23,2)) end           as TotalChargeout,
      InvoiceUUID,
      InvoiceNumber,
      InvoiceStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      InvoiceNumber                                              as Filename,
      case ReceiverChargeout.InvoiceStatus
        when '02' then 'application/pdf'
        when '03' then 'application/pdf'
        else '' end                                              as Mimetype,

      @Semantics.text: true
      _ServiceCost._CostCenterCost.legalentitydescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costobjectdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costcenterdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.profitcenterdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.businessdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.functionalareadescription,
      @Semantics.text: true
      _ServiceCost.Serviceproductdescription,
      @Semantics.text: true
      _ServiceCost.Transactiongroupdescription,
      @Semantics.text: true
      _ServiceCost.Servicetypedescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ccodedescription,
      @Semantics.text: true
      _ServiceCost.oecdDescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costdatasetdescription,
      _ServiceCost._CostCenterCost.Country                       as legalentitycountry,
      _ServiceCost._CostCenterCost._legalCountryText.CountryName as legalentitycountryname,

      Country                                                    as receivingentitycountry,
      _CurrencyTypeText,
      @Semantics.text: true
      ccodedescription                                           as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription                                      as RecCostCenterdescription,
      @Semantics.text: true
      costobjectdescription                                      as RecCostObjectdescription,
      @Semantics.text: true
      invoicestatusdescription,
      //      @Semantics.text: true

      //    _association_name // Make association public
      //  status color
      case ReceiverChargeout.InvoiceStatus
         when '01' then 0
         when '02' then 2
         when '03' then 3
         else
         0
        end                                                      as invoicestatuscriticallity,
       
      _ReceivingCountryText,
      //      _ServiceCost,

      _chargeouttype,
      _ServiceCost.chargeoutdescription
      //      _ServiceCost._CostCenterCost._legalCountryText
}
where
      Status                                   =  'F'
  and Receivingentity                          <> 'REST'
  and TotalChargeout                           <> 0
  and _ServiceCost._CostCenterCost.ProcessType <> 'R'

union

// select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
select from /ESRCC/I_TRUEUP_READ as trueup
association [0..1] to /ESRCC/I_SENDERCURR     as _CurrencyTypeText on _CurrencyTypeText.Currencytype = $projection.CurrencyType
association [0..1] to /ESRCC/I_INVPROCESSTYPE as _chargeouttype    on _chargeouttype.ChargeoutType = $projection.Chargeamountytpe
{
  key Uuid,
  key SrvUuid                                              as ParentUUID,
  key CcUuid                                               as RootUUID,
  key CurrencyType,
  key ChargeoutType                                        as Chargeamountytpe,
      Ryear,
      Poper,
      Recalrefpoper,
      Fplv,
      Sysid,
      Ccode,
      Legalentity,
      Costobject,
      Costcenter,
      Profitcenter,
      Businessdivision,
      Functionalarea,
      Serviceproduct,
      Servicetype,
      Transactiongroup,
      Chargeout,
      Receiversysid,
      Receivercompanycode,
      Receivingentity,
      Receivercostobject,
      Receivercostcenter,
      Contractid,
      Erpsalesorder,
      Postingdate,
      Postingperiod,
      Erpflag,
      Currency,
//      @Semantics.amount.currencyCode: 'Currency'
      cast(0 as abap.curr(23,2))                           as TransferPrice,
      0                                                    as Reckpi,
      cast('' as abap.unit(3)) as ConsumptionUom,
      0                                                    as Reckpishare,
//      @Semantics.amount.currencyCode: 'Currency'
      TrueupAmount                                         as TotalChargeout,
      Invoiceuuid,
      Invoicenumber,
      Invoicestatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      Invoicenumber                                        as Filename,
      case Invoicestatus
        when '02' then 'application/pdf'
        when '03' then 'application/pdf'
        else '' end                                        as Mimetype,

      //      @Semantics.text: true
      _legalentity.Description                             as legalentitydescription,
      //      @Semantics.text: true
      _costobject.text                                     as costobjectdescription,
      //      @Semantics.text: true
      _costcenter.Description                              as costcenterdescription,
      //      @Semantics.text: true
      _profitcenter.profitcenterdescription,
      //      @Semantics.text: true
      _businessdiv.Description                             as businessdescription,
      //      @Semantics.text: true
      _functionalarea.Description                          as functionalareadescription,
      //      @Semantics.text: true
      _serviceproduct.Description                          as Serviceproductdescription,
      //      @Semantics.text: true
      _srvtransactiongroup.Description                     as Transactiongroupdescription,
      //      @Semantics.text: true
      _srvtyp.Description                                  as Servicetypedescription,
      //      @Semantics.text: true
      _ccode.ccodedescription,
      //      @Semantics.text: true
      ''                                                   as oecdDescription,
      //      @Semantics.text: true
      _costdataset.text                                    as costdatasetdescription,
      _legalCountryText.Country                            as legalentitycountry,
      _legalCountryText.CountryName                        as legalentitycountryname,

      receivingcountry                                     as receivingentitycountry,
      _CurrencyTypeText,
      //      @Semantics.text: true
      _recccode.ccodedescription                           as RecCcodedescription,
      //      @Semantics.text: true
      _rcventity.Description                               as receivingentitydescription,
      //      @Semantics.text: true
      _reccostcenter.Description                           as RecCostCenterdescription,
      //      @Semantics.text: true
      _reccostobject.text                                  as RecCostObjectdescription,
      //      @Semantics.text: true
      _InvoiceStatus.text                                  as invoicestatusdescription,

      case Invoicestatus
         when '01' then 0
         when '02' then 2
         when '03' then 3
         else
         0
        end                                                as invoicestatuscriticallity,
      _ReceivingCountryText,
      _chargeouttype,
      _method.text                                         as chargeoutdescription
      //      _ServiceCost._CostCenterCost._legalCountryText
}
where
      Status          =  'F'
  and Receivingentity <> 'REST'
  and TrueupAmount    <> 0
