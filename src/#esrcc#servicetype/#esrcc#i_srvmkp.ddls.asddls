@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Service Markup'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvMkp
  as select from /esrcc/srvmkp
  association        to parent /ESRCC/I_SrvMkp_S   as _ServiceMarkupAll   on $projection.SingletonID = _ServiceMarkupAll.SingletonID
  association [1..1] to /ESRCC/I_SERVICEPRODUCT_F4 as _ProductText        on _ProductText.ServiceProduct = $projection.Serviceproduct
  association [1..1] to /ESRCC/I_STATUS            as _WorkflowStatusText on _WorkflowStatusText.Status = $projection.WorkflowStatus
{
  key serviceproduct                as Serviceproduct,
  key validfrom                     as Validfrom,
      origcost                      as Origcost,
      passcost                      as Passcost,
      intra_origcost                as IntraOrigcost,
      intra_passcost                as IntraPasscost,
      validto                       as Validto,
      workflow_id                   as WorkflowId,
      workflow_status               as WorkflowStatus,
      comment_id                    as CommentId,
      @Semantics.user.createdBy: true
      created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at         as LocalLastChangedAt,
      1                             as SingletonID,

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
      end                           as WorkflowStatusCriticality,
      cast('' as /esrcc/status_de ) as WorkflowInternalStatus,
      cast('' as /esrcc/comment )   as Comments,

      _ServiceMarkupAll,
      _ProductText,
      _WorkflowStatusText
}
