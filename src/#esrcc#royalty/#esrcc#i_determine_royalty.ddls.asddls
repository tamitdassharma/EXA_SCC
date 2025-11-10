@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST,#UNION]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Determine Royalty Calculation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_DETERMINE_ROYALTY
  as select from /ESRCC/I_RoyaltyBaseValue as basevalue
  association [0..1] to /ESRCC/I_LicMap             as licmap      on  licmap.LicenseeSysid       = basevalue.Sysid
                                                                   and licmap.LicenseeCompanyCode = basevalue.CompanyCode
                                                                   and licmap.LicenseeLegalEntity = basevalue.LegalEntity
                                                                   and licmap.LicenseeCostObject  = basevalue.CostObject
                                                                   and licmap.LicenseeCostCenter  = basevalue.CostCenter
                                                                   and licmap.License             = basevalue.License
                                                                   and licmap.Active              = 'X'
  association [0..1] to /ESRCC/I_License            as license     on  basevalue.License =  license.License
                                                                   and license.ValidFrom <= basevalue.ValidOn
                                                                   and license.ValidTo   >= basevalue.ValidOn
                                                                   
  association [0..1] to /ESRCC/I_ROYALTYSTATUS      as _status     on  'N' = _status.Status
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _licenseele on  _licenseele.Legalentity = basevalue.LegalEntity
  association [0..1] to /ESRCC/I_RoyaltyBaseVersion as baseversion on  baseversion.RoyaltyBaseVersion = basevalue.Fplv
{
  basevalue.Ryear,
  basevalue.Poper,
  basevalue.Fplv,
  basevalue.RoyaltyBaseKey,
  basevalue.Sysid                              as LicenseeSysid,
  basevalue.LegalEntity                        as LicenseeLegalEntity,
  basevalue.CompanyCode                        as LicenseeCCode,
  basevalue.CostObject                         as LicenseeCostObject,
  basevalue.CostCenter                         as LicenseeCostCenter,
  licmap.Active,
  licmap.LicensorSysid,
  licmap.LicensorLegalEntity,
  licmap.LicensorCompanyCode                   as LicensorCCode,
  licmap.LicensorCostObject,
  licmap.LicensorCostCenter,
  basevalue.License,
  license.LicenseTyp,
  licmap.ErpSalesOrder,
  licmap.AgreementId,
  @Semantics.amount.currencyCode: 'Currency'
  basevalue.AmountValue,
  @Semantics.quantity.unitOfMeasure: 'Uom'
  basevalue.UnitValue,
  basevalue.Uom,
  basevalue.Currency,
  license._ComputationRule.RoyaltyComputationMethod,
  license._ComputationRule.Value               as paramvalue,
  @Semantics.amount.currencyCode: 'paramcurrency'
  license._ComputationRule.AmountValue         as paramamount,
  license._ComputationRule.Currency            as paramcurrency,
  case when licmap.InvoiceCurrency is initial then
  basevalue.Currency
  else
  licmap.InvoiceCurrency end                   as invoicecurrency,
  baseversion.text                             as BaseVersionDescription,
  'N'                                          as status,
  licmap._licensorle.Country                   as LicensorCountry,
  _licenseele.Country                          as LicenseeCountry,
  licmap._LicenseText.Description              as LicenseDescription,
  license._LicenseTypeText.Description         as LicenseTypeDescription,
  licmap._Licensor.SysidDescription            as LicensorSysidDescription,
  licmap._Licensor.CompanyCodeDescription      as LicensorCompanyCodeDescription,
  licmap._Licensor.LegalEntityDescription      as LicensorLegalEntityDescription,
  licmap._Licensor.CostObjectDescription       as LicensorCostObjectDescription,
  licmap._Licensor.Description                 as LicensorCostCenterDescription,
  basevalue._CostCenter.SysidDescription       as LicenseeSysidDescription,
  basevalue._CostCenter.CompanyCodeDescription as LicenseeCompanyCodeDescription,
  basevalue._CostCenter.LegalEntityDescription as LicenseeLegalEntityDescription,
  basevalue._CostCenter.CostObjectDescription  as LicenseeCostObjectDescription,
  basevalue._CostCenter.Description            as LicenseeCostCenterDescription,
  license._ComputationRule.RoyaltyComputationMethodDesc,
  basevalue._RoyaltyBaseKey.Description        as RoyaltyBaseKeyDescription,
  _status.text                                 as statusDescription,
  0                                            as statuscriticallity
}      
