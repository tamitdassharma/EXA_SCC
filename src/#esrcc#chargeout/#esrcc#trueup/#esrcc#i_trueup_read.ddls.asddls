@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'True-up Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_TRUEUP_READ
  as select from /ESRCC/I_TRUEUP_DATA

  association [0..1] to /ESRCC/I_LEGALENTITY_F4      as _legalentity        on  _legalentity.Legalentity = $projection.Legalentity

  association [0..1] to /ESRCC/I_COMPANYCODES_F4     as _ccode              on  _ccode.Ccode       = $projection.Ccode
                                                                            and _ccode.Sysid       = $projection.Sysid
                                                                            and _ccode.Legalentity = $projection.Legalentity

  association [0..1] to /ESRCC/I_COSTOBJECTS         as _costobject         on  _costobject.Costobject = $projection.Costobject

  association [0..1] to /ESRCC/I_COSCEN_F4           as _costcenter         on  _costcenter.LegalEntity = $projection.Legalentity
                                                                            and _costcenter.CompanyCode = $projection.Ccode
                                                                            and _costcenter.Costcenter  = $projection.Costcenter
                                                                            and _costcenter.Sysid       = $projection.Sysid
                                                                            and _costcenter.Costobject  = $projection.Costobject

  association [0..1] to /ESRCC/I_COSTDATASET         as _costdataset        on  _costdataset.costdataset = $projection.Fplv

  association [0..1] to /ESRCC/I_PROFITCENTER_F4     as _profitcenter       on  _profitcenter.ProfitCenter = $projection.Profitcenter

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4      as _businessdiv        on  _businessdiv.BusinessDivision = $projection.Businessdivision

  association [0..1] to /ESRCC/I_FunctionalArea_F4   as _functionalarea     on  _functionalarea.FunctionalArea = $projection.Functionalarea

  association [0..1] to /ESRCC/I_STATUS              as _status             on  _status.Status = $projection.Status

  association [0..1] to I_CountryText                as _legalCountryText   on  _legalCountryText.Country  = $projection.country
                                                                            and _legalCountryText.Language = $session.system_language

  association [0..1] to /ESRCC/I_INVPROCESSTYPE      as _Processtype        on  _Processtype.ChargeoutType = $projection.ChargeoutType

  association [0..1] to /ESRCC/I_CURR                as _Currencytype       on  _Currencytype.Currencytype = $projection.CurrencyType

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as _serviceproduct     on  _serviceproduct.ServiceProduct = $projection.Serviceproduct

  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as _srvtyp             on  _srvtyp.ServiceType = $projection.Servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as _srvtransactiongroup on  _srvtransactiongroup.Transactiongroup = $projection.Transactiongroup

  association [0..1] to /ESRCC/I_CHGOUT              as _method              on  _method.Chargeout = $projection.Chargeout
  
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4         as _rcventity             on  _rcventity.Receivingentity = $projection.Receivingentity

  association [0..1] to /ESRCC/I_COMPANYCODES_F4            as _recccode              on  _recccode.Ccode       = $projection.Receivercompanycode
                                                                                     and  _recccode.Sysid       = $projection.Receiversysid
                                                                                     and  _recccode.Legalentity = $projection.Receivingentity
  
  association [0..1] to /ESRCC/I_COSTOBJECTS         as _reccostobject         on  _reccostobject.Costobject = $projection.Receivercostobject
  
  association [0..1] to /ESRCC/I_COSCEN_F4                  as _reccostcenter         on  _reccostcenter.Costcenter  = $projection.Receivercostcenter
                                                                                     and  _reccostcenter.Sysid       = $projection.Receiversysid
                                                                                     and  _reccostcenter.Costobject  = $projection.Receivercostobject
                                                                                     and  _reccostcenter.CompanyCode = $projection.Receivercompanycode
                                                                                     and  _reccostcenter.LegalEntity = $projection.Receivingentity

  association [0..1] to I_CountryText                       as _ReceivingCountryText on  _ReceivingCountryText.Country  = $projection.receivingcountry
                                                                                     and _ReceivingCountryText.Language = $session.system_language

  association [0..1] to /ESRCC/I_INVOICESTATUS              as _InvoiceStatus        on  _InvoiceStatus.InvoiceStatus = $projection.Invoicestatus
{
  key Uuid,
  key CcUuid,
  key SrvUuid,
  key CurrencyType,
      Ryear,
      Poper,
      Recalrefpoper,
      Fplv,
      Sysid,
      Legalentity,
      Ccode,
      Costobject,
      Costcenter,
      Functionalarea,
      Businessdivision,
      Profitcenter,
      Serviceproduct,
      Servicetype,
      Transactiongroup,
      Chargeout,
      Receiversysid,
      Receivingentity,
      Receivercompanycode,
      Receivercostobject,
      Receivercostcenter,
      'T'                                 as ChargeoutType,      
      case when CurrencyType = 'I' then
      Invoicingcurrency
      else
      Currency end as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      case when CurrencyType = 'I' and Currency <> Invoicingcurrency then
      currency_conversion( client => $session.client,
                           amount => cast(Amount as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => Invoicingcurrency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else
      cast(Amount as abap.curr(23,2)) end as TrueupAmount,
      Status,
      Exchdate,
      Invoiceuuid,
      Invoicenumber,
      Invoicestatus,
      Invoicingcurrency,
      Erpsalesorder,
      Contractid,
      Postingdate,
      Postingperiod,
      Erpflag,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,

      //     Associations
      _legalentity.Country,
      _legalentity,
      _ccode,
      _costobject,
      _costcenter,
      _costdataset,
      _profitcenter,
      _businessdiv,
      _functionalarea,
      _status,
      _legalCountryText,
      _Processtype,
      _Currencytype,
      _serviceproduct,
      _srvtyp,
      _srvtransactiongroup,
      _method,
      _rcventity,
      _rcventity.Country as receivingcountry,
      _recccode,
      _reccostcenter,
      _reccostobject,
      _ReceivingCountryText,
      _InvoiceStatus
}
