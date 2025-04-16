@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft Query View'

define view entity /ESRCC/I_LeCcode_D
  as select from /esrcc/d_le_ccod
{
  key sysid                         as Sysid,
  key ccode                         as Ccode,
      legalentity                   as Legalentity,
      controllingarea               as Controllingarea,
      active                        as Active,
      localcurrdescription          as Localcurrdescription,
      countrydescription            as Countrydescription,
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
