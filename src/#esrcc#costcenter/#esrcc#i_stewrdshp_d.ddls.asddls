@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft Query View'

define view entity /ESRCC/I_Stewrdshp_D
  as select from /esrcc/d_stewrds
{
  key stewardshipuuid               as Stewardshipuuid,
      validfrom                     as Validfrom,
      validto                       as Validto,
      stewardship                   as Stewardship,
      costobjectuuid                as Costobjectuuid,
      chainid                       as Chainid,
      chainsequence                 as Chainsequence,
      workflowid                    as Workflowid,
      workflowstatus                as Workflowstatus,
      commentid                     as CommentId,
      comments                      as Comments,
      sysid                         as Sysid,
      legalentity                   as Legalentity,
      companycode                   as Companycode,
      costobject                    as Costobject,
      costcenter                    as Costcenter,
      createdby                     as Createdby,
      createdat                     as Createdat,
      lastchangedby                 as Lastchangedby,
      lastchangedat                 as Lastchangedat,
      locallastchangedat            as Locallastchangedat,
      singletonid                   as Singletonid,
      workflowstatuscriticality     as Workflowstatuscriticality,
      workflowinternalstatus        as WorkflowInternalStatus,
      draftentitycreationdatetime   as Draftentitycreationdatetime,
      draftentitylastchangedatetime as Draftentitylastchangedatetime,
      draftadministrativedatauuid   as Draftadministrativedatauuid,
      draftentityoperationcode      as Draftentityoperationcode,
      hasactiveentity               as Hasactiveentity,
      draftfieldchanges             as Draftfieldchanges
}
