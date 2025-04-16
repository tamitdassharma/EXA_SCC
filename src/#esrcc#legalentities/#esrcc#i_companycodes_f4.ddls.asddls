@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code'
@Search.searchable: true

define view entity /ESRCC/I_COMPANYCODES_F4
  as select from /esrcc/le_ccode as ccode
  association [0..1] to /esrcc/le_t                    as _Text       on  _Text.legalentity = $projection.Legalentity
                                                                      and _Text.spras       = $session.system_language
  association [0..1] to /esrcc/ccodet                  as ccodet      on  ccode.sysid  = ccodet.sysid
                                                                      and ccode.ccode  = ccodet.ccode
                                                                      and ccodet.spras = $session.system_language
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemText on  _SystemText.SystemId = $projection.Sysid
                                                                      and _SystemText.Spras    = $session.system_language
{
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key sysid                   as Sysid,

      @ObjectModel.text.element: ['ccodedescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key ccode                   as Ccode,

      @ObjectModel.text.element: ['LegalentityDescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' } }]
      legalentity             as Legalentity,

      @Consumption.filter.hidden: true
      controllingarea         as Controllingarea,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      ccodet.description      as ccodedescription,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Text.description       as LegalentityDescription,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _SystemText.Description as SysidDescription,

      _Text,
      _SystemText
}
