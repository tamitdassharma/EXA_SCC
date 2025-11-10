@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Receiver Company Code'
@Search.searchable: true

define view entity /ESRCC/I_COMPANYCODES_REC_F4
  as select from /ESRCC/I_COMPANYCODES_F4 as ccode
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _ReceivingEntity on _ReceivingEntity.Receivingentity = ccode.Legalentity
{
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key cast( Sysid as /esrcc/recsysid )             as Sysid,

      @ObjectModel.text.element: ['CcodeDescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key cast( Ccode as /esrcc/recccode_de )          as Ccode,

      @ObjectModel.text.element: ['LegalentityDescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' } }]
      cast( Legalentity as /esrcc/receivingntity ) as Legalentity,

      Controllingarea,
      ccodedescription                             as CcodeDescription,
      LegalentityDescription,
      SysidDescription
}
where
  _ReceivingEntity.Receivingentity is not null
