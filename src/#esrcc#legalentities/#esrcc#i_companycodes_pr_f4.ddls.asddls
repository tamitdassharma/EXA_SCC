@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code (Provider)'
@Search.searchable: true

define view entity /ESRCC/I_COMPANYCODES_PR_F4
  as select from /ESRCC/I_COMPANYCODES_F4 as ccode
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as _LegalEntity on _LegalEntity.Legalentity = ccode.Legalentity
{
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key cast( Sysid as /esrcc/provider_sysid )        as Sysid,

      @ObjectModel.text.element: ['ccodedescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key cast( Ccode as /esrcc/provider_ccode )        as Ccode,

      @ObjectModel.text.element: ['LegalentityDescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' } }]
      cast( Legalentity as /esrcc/provider_entity ) as Legalentity,
      
      Controllingarea,
      ccodedescription,
      LegalentityDescription,
      SysidDescription
}
where
  _LegalEntity.Legalentity is not null
