@EndUserText.label: 'Licensor Licensee Mapping'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LicMap
  as select from /esrcc/lic_map
  association        to parent /ESRCC/I_LicMap_S  as _LicenseeAll     on  $projection.SingletonID = _LicenseeAll.SingletonID
  association [0..1] to /ESRCC/I_License_F4       as _LicenseText     on  _LicenseText.License = $projection.License
  association [0..1] to /ESRCC/I_COSCEN_NOAUTH_F4 as _Licensor        on  _Licensor.CostObjectUuid = $projection.LicensorCostObjectUuid
  association [0..1] to /ESRCC/I_COSCEN_NOAUTH_F4 as _Licensee        on  _Licensee.CostObjectUuid = $projection.LicenseeCostObjectUuid
  association [0..1] to I_CurrencyText            as _InvoiceCurrency on  _InvoiceCurrency.Currency = $projection.InvoiceCurrency
                                                                      and _InvoiceCurrency.Language = $session.system_language
  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _licensorle on  _licensorle.Legalentity = $projection.LicensorLegalEntity
{
  key uuid                                                                         as Uuid,
      license                                                                      as License,
      active                                                                       as Active,
      licensor_cost_object_uuid                                                    as LicensorCostObjectUuid,
      licensee_cost_object_uuid                                                    as LicenseeCostObjectUuid,
      erp_sales_order                                                              as ErpSalesOrder,
      agreement_id                                                                 as AgreementId,
      invoice_currency                                                             as InvoiceCurrency,
      @Semantics.user.createdBy: true
      created_by                                                                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                                                   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                                                              as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                                              as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                                                        as LocalLastChangedAt,
      1                                                                            as SingletonID,

      cast( _Licensor.Sysid as /esrcc/licensor_sysid preserving type )             as LicensorSysid,
      cast( _Licensor.LegalEntity as /esrcc/licensor_legalentity preserving type ) as LicensorLegalEntity,
      cast( _Licensor.CompanyCode as /esrcc/licensor_ccode preserving type )       as LicensorCompanyCode,
      cast( _Licensor.Costobject as /esrcc/licensor_costobject preserving type )   as LicensorCostObject,
      cast( _Licensor.Costcenter as /esrcc/licensor_costcenter preserving type )   as LicensorCostCenter,

      cast( _Licensee.Sysid as /esrcc/licensee_sysid preserving type )             as LicenseeSysid,
      cast( _Licensee.LegalEntity as /esrcc/licensee_legalentity preserving type ) as LicenseeLegalEntity,
      cast( _Licensee.CompanyCode as /esrcc/licensee_ccode preserving type )       as LicenseeCompanyCode,
      cast( _Licensee.Costobject as /esrcc/licensee_costobject preserving type )   as LicenseeCostObject,
      cast( _Licensee.Costcenter as /esrcc/licensee_costcenter preserving type )   as LicenseeCostCenter,

      _LicenseeAll,
      _LicenseText,
      _Licensor,
      _Licensee,
      _InvoiceCurrency,
      _licensorle
}
