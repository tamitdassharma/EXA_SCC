@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Read Royalty Calculation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_READ_ROYALTY
  as select from /esrcc/royalcal as royalcal
  association [0..1] to /ESRCC/I_RoyaltyBaseKeyF4   as _RoyaltyBaseKey  on  _RoyaltyBaseKey.RoyaltyBaseKey = royalcal.royaltybasekey
  association [0..1] to /ESRCC/I_License_F4         as _license         on  _license.License = royalcal.license
  association [0..1] to /ESRCC/I_COSCEN_NOAUTH_F4   as _licensor        on  _licensor.Sysid       = royalcal.licensorsysid
                                                                        and _licensor.CompanyCode = royalcal.licensorccode
                                                                        and _licensor.LegalEntity = royalcal.licensorlegalentity
                                                                        and _licensor.Costobject  = royalcal.licensorcostobject
                                                                        and _licensor.Costcenter  = royalcal.licensorcostcenter
  association [0..1] to /ESRCC/I_COSCEN_NOAUTH_F4   as _licensee        on  _licensee.Sysid       = royalcal.licenseesysid
                                                                        and _licensee.CompanyCode = royalcal.licenseeccode
                                                                        and _licensee.LegalEntity = royalcal.licenseelegalentity
                                                                        and _licensee.Costobject  = royalcal.licenseecostobject
                                                                        and _licensee.Costcenter  = royalcal.licenseecostcenter
  association [0..1] to /ESRCC/I_ROYALTYCOMPMETHOD  as _royalcompmethod on  _royalcompmethod.RoyaltyComputationMethod = royalcal.royaltycomputationmethod
  association [0..1] to /ESRCC/I_ROYALTYSTATUS      as _status          on  royalcal.status = _status.Status
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _licensorle      on  _licensorle.Legalentity = royalcal.licensorlegalentity
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _licenseele      on  _licenseele.Legalentity = royalcal.licenseelegalentity
  association [0..1] to /ESRCC/I_RoyaltyBaseVersion as baseversion      on  baseversion.RoyaltyBaseVersion = royalcal.fplv
{
  royalcal.uuid,
  royalcal.ryear,
  royalcal.poper,
  royalcal.fplv,
  royalcal.royaltybasekey,
  royalcal.licenseesysid,
  royalcal.licenseelegalentity,
  royalcal.licenseeccode,
  royalcal.licenseecostobject,
  royalcal.licenseecostcenter,
  royalcal.licensorsysid,
  royalcal.licensorlegalentity,
  royalcal.licensorccode,
  royalcal.licensorcostobject,
  royalcal.licensorcostcenter,
  royalcal.license,
  royalcal.erpsalesorder,
  royalcal.agreementid,
  @Semantics.amount.currencyCode: 'currency'
  royalcal.amountvalue,
  @Semantics.quantity.unitOfMeasure: 'uom'
  royalcal.unitvalue,
  royalcal.uom,
  royalcal.currency,
  royalcal.royaltycomputationmethod,
  royalcal.paramvalue,
  @Semantics.amount.currencyCode: 'paramcurrency'
  royalcal.paramamount,
  royalcal.paramcurrency,
  royalcal.invoicecurrency,
  @Semantics.amount.currencyCode: 'invoicecurrency'
  case royalcal.royaltycomputationmethod
     when 'PB' then     
     currency_conversion( client => $session.client,
                          amount => cast( cast(royalcal.amountvalue as abap.fltp)  * cast(division( royalcal.paramvalue,100,2 ) as abap.fltp) as abap.curr(23,2)),
                          source_currency => royalcal.currency,
                          round => 'X',
                          target_currency => royalcal.invoicecurrency,
                          exchange_rate_date => royalcal.exchdate,
                          error_handling => 'SET_TO_NULL' )
     
     when 'FP' then     
     currency_conversion( client => $session.client,
                          amount => cast( cast(royalcal.unitvalue as abap.fltp) * cast(royalcal.paramamount as abap.fltp) as abap.curr(23,2)),
                          source_currency => royalcal.paramcurrency,
                          round => 'X',
                          target_currency => royalcal.invoicecurrency,
                          exchange_rate_date => royalcal.exchdate,
                          error_handling => 'SET_TO_NULL' )
     
     when 'FA' then
     currency_conversion( client => $session.client,
                          amount => cast(royalcal.paramamount as abap.curr(23,2)),
                          source_currency => royalcal.paramcurrency,
                          round => 'X',
                          target_currency => royalcal.invoicecurrency,
                          exchange_rate_date => royalcal.exchdate,
                          error_handling => 'SET_TO_NULL' )
    
     when 'ME' then
     cast( royalcal.chargeoutamount as abap.curr(23,2))
     else cast( 0 as abap.curr(23,2))
     end                                       as chargeoutamount,
 
  royalcal.status,
  royalcal.workflowid,
  _licensorle.Country              as LicensorCountry,
  _licenseele.Country              as LicenseeCountry,
  _license.LicenseType             as licensetyp,
  _license.Description             as LicenseDescription,
  _license.LicenseTypeDescription,
  _licensor.SysidDescription       as LicensorSysidDescription,
  _licensor.CompanyCodeDescription as LicensorCompanyCodeDescription,
  _licensor.LegalEntityDescription as LicensorLegalEntityDescription,
  _licensor.CostObjectDescription  as LicensorCostObjectDescription,
  _licensor.Description            as LicensorCostCenterDescription,
  _licensee.SysidDescription       as LicenseeSysidDescription,
  _licensee.CompanyCodeDescription as LicenseeCompanyCodeDescription,
  _licensee.LegalEntityDescription as LicenseeLegalEntityDescription,
  _licensee.CostObjectDescription  as LicenseeCostObjectDescription,
  _licensee.Description            as LicenseeCostCenterDescription,
  _royalcompmethod.text            as RoyaltyComputationMethodDesc,
  _RoyaltyBaseKey.Description      as RoyaltyBaseKeyDescription,
  _status.text                     as statusDescription,
  baseversion.text                 as BaseVersionDescription,
  case royalcal.status
     when 'W' then 2
     when 'A' then 3
     when 'F' then 3
     when 'R' then 1
     when 'C' then 3
     else
     0
     end                           as statuscriticallity,
  royalcal.created_by,
  royalcal.created_at,
  royalcal.last_changed_by,
  royalcal.last_changed_at
  
 
}
