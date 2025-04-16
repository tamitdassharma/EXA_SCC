@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Products Share'

define view entity /ESRCC/I_STW_SERVICEPRODUCT
  as select from /ESRCC/I_Stewardship as stw
   association [0..*] to /esrcc/stwd_sp as stw_sp
    on stw_sp.stewardship_uuid = $projection.StewardshipUuid
{
  key stw.CostObjectUuid,
  key stw.StewardshipUuid,  
  key stw_sp.service_product_uuid as ServiceProductUuid,
      stw.ValidFrom,
      stw.Validto,
      stw.stewardship, 
      stw.Sysid,
      stw.CompanyCode,
      stw.LegalEntity,
      stw.CostObject,
      stw.CostCenter,
      stw.chain_id,
      stw.chain_sequence,
      stw.ProfitCenter,
      stw.FunctionalArea,
      stw.BusinessDivision,
      stw.BillingFrequency,
      
      stw_sp.valid_from as SpValidFrom,
      stw_sp.valid_to as SpValidto,
      stw_sp.contract_id as ContractId,
      stw_sp.erp_sales_order as ErpSalesOrder,
      stw_sp.service_product as ServiceProduct,
      stw_sp.share_of_cost as ShareOfCost,
      
      CostCenterDescription,
      SysidDescription,
      CostObjectDescription,
      CompanyCodeDescription,
      LegalEntityDescription
}
