@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stewardship'

define view entity /ESRCC/I_Stewardship
  as select from /esrcc/stewrdshp as stw
   association [0..1] to /ESRCC/I_CstObjct as co
    on co.CostObjectUuid = $projection.CostObjectUuid
 
{
  key cost_object_uuid as CostObjectUuid,
  key stewardship_uuid as StewardshipUuid,  
  key valid_from as ValidFrom,
      valid_to as Validto,
      stewardship,
      chain_id,
      chain_sequence,
      co.Sysid,
      co.CompanyCode,
      co.LegalEntity,
      co.CostObject,
      co.CostCenter,
      co.ProfitCenter,
      co.FunctionalArea,
      co.BusinessDivision,
      co.BillingFrequency,
      @Semantics.text: true
      co._CostObjectText[ Spras = $session.system_language ].Description                as CostCenterDescription,

      @Semantics.text: true
      co._CcodeText._SystemText.Description    as SysidDescription,

      @Semantics.text: true
      co._CcodeText.ccodedescription               as CompanyCodeDescription,

      @Semantics.text: true
      co._CcodeText.LegalentityDescription         as LegalEntityDescription,

      @Semantics.text: true
      co._CostObjTypeText.text                     as CostObjectDescription
      

}
where stw.workflow_status = 'F'
 