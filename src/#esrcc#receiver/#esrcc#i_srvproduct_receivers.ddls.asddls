@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Product Receivers'

define view entity /ESRCC/I_SRVPRODUCT_RECEIVERS
  as select from /ESRCC/I_STW_SERVICEPRODUCT as stw_sp
  association [0..*] to /ESRCC/I_StwdSpRec as sp_rec
   on sp_rec.ServiceProduct = $projection.ServiceProduct
  and sp_rec.StewardshipUuid = $projection.StewardshipUuid

{
  key stw_sp.CostObjectUuid          as CostObjectUuid,
  key stw_sp.StewardshipUuid         as StewardshipUuid,
  key stw_sp.ServiceProductUuid      as ServiceProductUuid,
  key sp_rec.ServiceReceiverUuid     as SPReceiverUuid,
  key sp_rec.CostObjectUuid          as ReceiverObjectUUID,
      stw_sp.ValidFrom               as StewardshipValidFrom,
      stw_sp.Validto                 as StewardshipValidTo,
      stw_sp.stewardship             as Stewardship,
      stw_sp.sysid                   as SystemId,
      stw_sp.CompanyCode             as CompanyCode,
      stw_sp.LegalEntity             as LegalEntity,
      stw_sp.CostObject              as CostObject,
      stw_sp.CostCenter              as CostCenter,
      stw_sp.ProfitCenter            as ProfitCenter,
      stw_sp.FunctionalArea          as FunctionalArea,
      stw_sp.BusinessDivision        as BusinessDivision,
      stw_sp.BillingFrequency        as BillingFrequency,

      stw_sp.SpValidFrom             as ServiceValidFrom,
      stw_sp.SpValidto               as ServiceValidTo,
      stw_sp.ContractId              as ContractId,
      stw_sp.ErpSalesOrder           as ErpSalesOrder,
      stw_sp.ServiceProduct          as ServiceProduct,
      stw_sp.ShareOfCost             as ShareOfCost,


      sp_rec._CostObject.Sysid       as ReceiverSysId,
      sp_rec._CostObject.CompanyCode as ReceiverCompanyCode,
      sp_rec._CostObject.LegalEntity as ReceivingEntity,
      sp_rec._CostObject.CostObject  as ReceiverCostObject,
      sp_rec._CostObject.CostCenter  as ReceiverCostCenter,
      sp_rec.Active                  as Active,
      sp_rec.InvoiceCurrency         as InvoicingCurrency
}
