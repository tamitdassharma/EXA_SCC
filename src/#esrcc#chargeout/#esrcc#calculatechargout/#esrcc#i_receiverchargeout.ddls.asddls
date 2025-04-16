@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Receivers Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ReceiverChargeout
  as select from /ESRCC/I_ReceiverData as reccost
  association        to parent /ESRCC/I_ServiceProductShare as _ServiceCost          on  $projection.ParentUUID   = _ServiceCost.UUID
                                                                                     and $projection.RootUUID     = _ServiceCost.ParentUUID
                                                                                     and $projection.Currencytype = _ServiceCost.Currencytype
  //
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4         as rcventity             on  rcventity.Receivingentity = $projection.Receivingentity

  association [0..1] to /ESRCC/I_COMPANYCODES_F4            as ccode                 on  ccode.Ccode       = $projection.ReceiverCompanyCode
                                                                                     and ccode.Sysid       = $projection.ReceiverSysId
                                                                                     and ccode.Legalentity = $projection.Receivingentity

  association [0..1] to /ESRCC/I_COSCEN_F4                  as costcenter            on  costcenter.Costcenter  = $projection.ReceiverCostCenter
                                                                                     and costcenter.Sysid       = $projection.ReceiverSysId
                                                                                     and costcenter.Costobject  = $projection.ReceiverCostObject
                                                                                     and costcenter.CompanyCode = $projection.ReceiverCompanyCode
                                                                                     and costcenter.LegalEntity = $projection.Receivingentity

  association [0..1] to /ESRCC/I_STATUS                     as status                on  status.Status = reccost.Status

  association [0..1] to I_CountryText                       as _ReceivingCountryText on  _ReceivingCountryText.Country  = $projection.country
                                                                                     and _ReceivingCountryText.Language = $session.system_language

  association [0..1] to I_UnitOfMeasureText                 as _UoM                  on  _UoM.UnitOfMeasure_E = reccost.ConsumptionUom
                                                                                     and _UoM.Language        = $session.system_language

  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION        as _ConsumptionVersion   on  _ConsumptionVersion.ConsumptionVersion = $projection.consumptionversion

  association [0..1] to /ESRCC/I_KEY_VERSION                as _KeyVersion           on  _KeyVersion.KeyVersion = $projection.keyversion

  association [0..1] to /ESRCC/I_INVOICESTATUS              as _InvoiceStatus        on  _InvoiceStatus.InvoiceStatus = $projection.InvoiceStatus

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
      _ServiceCost.Currency,
      InvoicingCurrency,
      Reckpishare,
      Valueaddmarkup,
      Passthrumarkup,
      _ServiceCost.ConsumptionVersion,
      _ServiceCost.KeyVersion,
      _ServiceCost.ContractId,
      // Direct Allocation
      Reckpi,
      ConsumptionUom,
//      Uom,
      case when _ServiceCost.Chargeout = 'D' then
      cast((_ServiceCost.Servicecostperunit + ( Valueaddmarkup / 100) * _ServiceCost.Valueaddcostperunit ) +
      ( _ServiceCost.Passthrucostperunit * (Passthrumarkup / 100) ) as abap.dec(10,2)) else 0 end        as TransferPrice,

      case when _ServiceCost.Chargeout = 'D' then
      cast(( _ServiceCost.Valueaddcostperunit + ( Valueaddmarkup / 100 ) * _ServiceCost.Valueaddcostperunit ) as abap.dec(10,2)) else 0 end as TpValueaddmarkupCostperunit,

      case when _ServiceCost.Chargeout = 'D' then
      cast(( _ServiceCost.Passthrucostperunit + (Passthrumarkup / 100 ) * _ServiceCost.Passthrucostperunit ) as abap.dec(10,2)) else 0 end  as TpPassthrumarkupCostperunit,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast( ( (Reckpishare / 100)   * _ServiceCost.Srvcostshare )  as abap.dec(23,2))
      else
      cast( _ServiceCost.Servicecostperunit * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as RecCostShare,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast( ( (Reckpishare / 100)   * _ServiceCost.Valueaddshare )  as abap.dec(23,2))
      else
      cast( _ServiceCost.Valueaddcostperunit * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as RecValueadded,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast( ( (Reckpishare / 100) * _ServiceCost.Passthroughshare )  as abap.dec(23,2))
      else
      cast( _ServiceCost.Passthrucostperunit * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as RecPassthrough,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast(( ( (Reckpishare / 100) * _ServiceCost.Valueaddshare * (Valueaddmarkup / 100) )  +
             ( (Reckpishare / 100) * _ServiceCost.Passthroughshare * (Passthrumarkup / 100) ) ) as abap.dec(23,2))
      else
      cast(((Valueaddmarkup / 100) * _ServiceCost.Valueaddcostperunit +
            (Passthrumarkup / 100) * _ServiceCost.Passthrucostperunit ) * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as TotalRecMarkup,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast(( (Reckpishare / 100) * _ServiceCost.Valueaddshare * (Valueaddmarkup / 100) ) as abap.dec(23,2))
      else
      cast( ((Valueaddmarkup / 100) * _ServiceCost.Valueaddcostperunit ) * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as RecValueaddMarkup,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast(( (Reckpishare / 100) * _ServiceCost.Passthroughshare * (Passthrumarkup / 100) ) as abap.dec(23,2))
      else
      cast( ( _ServiceCost.Passthrucostperunit * (Passthrumarkup / 100) ) * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as RecPassthroughMarkup,

      case when _ServiceCost.Chargeout = 'I' or _ServiceCost.Chargeout = 'A' then
      cast( ( (Reckpishare / 100 ) * _ServiceCost.Srvcostshare ) + ( ( (Reckpishare / 100) * _ServiceCost.Valueaddshare * ( Valueaddmarkup / 100 ) )  +
             ( (Reckpishare / 100 ) * _ServiceCost.Passthroughshare * (Passthrumarkup / 100 ) ) )  as abap.dec(23,2))
      else
      cast( (_ServiceCost.Servicecostperunit + ( (Valueaddmarkup / 100) * _ServiceCost.Valueaddcostperunit ) +
      ( _ServiceCost.Passthrucostperunit * (Passthrumarkup / 100) ) ) * (cast(case when ConsumptionUom <> _ServiceCost.PlanningUom then
                                    0
                                  else
                                  Reckpi end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                                                                                                as TotalChargeout,

      reccost.Status,
      Workflowid,
      reccost.CommentId,
      Exchdate,
      rcventity.Country,
      rcventity.LocalCurr                                                                                as ReceiverCurrency,
      rcventity.Region                                                                                   as ReceiverRegion,
      rcventity.RegionDesc                                                                               as ReceiverRegionDesc,
      ccode.ccodedescription,
      costcenter.CostObjectDescription                                                                   as costobjectdescription,
      costcenter.Description                                                                             as costcenterdescription,
      rcventity.Description                                                                              as receivingentitydescription,
      status.text                                                                                        as statusdescription,

      case reccost.Status
       when 'D' then 2
       when 'W' then 2
       when 'A' then 3
       when 'F' then 3
       when 'R' then 1
       when 'C' then 1
       else
       0
      end                                                                                                as statuscriticallity,
      InvoiceUUID,
      InvoiceNumber,
      InvoiceStatus,
      _InvoiceStatus.text                                                                                as invoicestatusdescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,

      //association
      _ConsumptionVersion,
      _KeyVersion,
      _ReceivingCountryText,
      _UoM,
      _ServiceCost
}
