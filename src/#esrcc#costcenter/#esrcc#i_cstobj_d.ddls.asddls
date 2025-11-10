@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft Query View'
define view entity /ESRCC/I_CstObj_D
  as select from /esrcc/d_cstobj
{
  key costobjectuuid                as Costobjectuuid,
      sysid                         as Sysid,
      legalentity                   as Legalentity,
      companycode                   as Companycode,
      costobject                    as Costobject,
      costcenter                    as Costcenter,
      active                        as Active,
      functionalarea                as Functionalarea,
      profitcenter                  as Profitcenter,
      businessdivision              as Businessdivision,
      hierarchy1                    as Hierarchy1,
      hierarchy2                    as Hierarchy2,
      hierarchy3                    as Hierarchy3,
      hierarchy4                    as Hierarchy4,
      billingfrequency              as Billingfrequency,
      createdby                     as Createdby,
      createdat                     as Createdat,
      lastchangedby                 as Lastchangedby,
      lastchangedat                 as Lastchangedat,
      locallastchangedat            as Locallastchangedat,
      singletonid                   as Singletonid,
      draftentitycreationdatetime   as Draftentitycreationdatetime,
      draftentitylastchangedatetime as Draftentitylastchangedatetime,
      draftadministrativedatauuid   as Draftadministrativedatauuid,
      draftentityoperationcode      as Draftentityoperationcode,
      hasactiveentity               as Hasactiveentity,
      draftfieldchanges             as Draftfieldchanges
}
