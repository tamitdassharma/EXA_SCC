@EndUserText.label: 'Stewardship'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_STEWARDSHIPCONFIG
  as select from /esrcc/stewrdshp

  association [1..1] to /ESRCC/I_CstObjct    as _CostObject         on _CostObject.CostObjectUuid = $projection.CostObjectUuid

  association [1..1] to /ESRCC/I_STATUS      as _WorkflowStatusText on _WorkflowStatusText.Status = $projection.WorkflowStatus

  association [0..*] to /esrcc/stwd_sp       as _stwdsp             on _stwdsp.stewardship_uuid = $projection.StewardshipUuid
                                                                   and _stwdsp.valid_from <= $projection.Validto
                                                                   and _stwdsp.valid_from >= $projection.ValidFrom
  
  association [0..*] to /esrcc/stwdsprec     as _stwdsprec          on _stwdsprec.service_product_uuid = $projection.ServiceProductUuid
 
  association [0..*] to /ESRCC/I_SrvPro      as _SrvPro             on _SrvPro.Serviceproduct = $projection.ServiceProduct                                                                  

  association [0..*] to /ESRCC/I_SrvMkp      as _SrvMarkup          on _SrvMarkup.Serviceproduct = $projection.ServiceProduct
                                                                    and _SrvMarkup.Validfrom <= $projection.SpValidto
                                                                    and _SrvMarkup.Validfrom >= $projection.SpValidFrom

  association [0..*] to /ESRCC/I_ChargeoutBc as _SrvRule            on _SrvRule.Serviceproduct = $projection.ServiceProduct
                                                                    and _SrvRule.Validfrom <= $projection.SpValidto
                                                                    and _SrvRule.Validfrom >= $projection.SpValidFrom
  
  association [0..*] to /ESRCC/I_Chgtrup as _TruRule            on _TruRule.Serviceproduct = $projection.ServiceProduct
                                                               and _TruRule.Validfrom <= $projection.SpValidto
                                                               and _TruRule.Validfrom >= $projection.SpValidFrom

{
      //  key StewardshipUuid,
  key stewardship_uuid                                     as StewardshipUuid,
  key _stwdsp.service_product_uuid                         as ServiceProductUuid,
  

      valid_from                                           as ValidFrom,
      valid_to                                             as Validto,
      stewardship                                          as Stewardship,
      cost_object_uuid                                     as CostObjectUuid,
      chain_id                                             as ChainId,
      chain_sequence                                       as ChainSequence,
      workflow_id                                          as WorkflowId,
      workflow_status                                      as WorkflowStatus,
       case workflow_status
      -- Red
        when 'R' then 1
        when 'E' then 1

      -- Yellow
        when 'D' then 2
        when 'W' then 2
        when 'P' then 2
        when 'J' then 2
        when 'L' then 2

      -- Green
        when 'A' then 3
        when 'F' then 3
        else 0
      end                         as WorkflowStatusCriticality,
//      comment_id                                           as CommentId,
      _CostObject.Sysid,
      _CostObject.LegalEntity,
      _CostObject.CompanyCode,
      _CostObject.CostObject,
      _CostObject.CostCenter,
      _CostObject.BusinessDivision,
      _CostObject.FunctionalArea,
      _CostObject.ProfitCenter,
      _CostObject.Hierarchy1,
      _CostObject.Hierarchy2,
      _CostObject.Hierarchy3,
      _CostObject.Hierarchy4,

      _stwdsp.service_product                              as ServiceProduct,
      _stwdsp.share_of_cost                                as ShareOfCost,
      _stwdsp.valid_from                                   as SpValidFrom,
      _stwdsp.valid_to                                     as SpValidto,
 
//      WorkflowStatusCriticality,
//      WorkflowInternalStatus,

      _CostObject,
      _stwdsprec,

      _SrvMarkup,
      _SrvRule,
      _TruRule,
      _SrvPro

}
