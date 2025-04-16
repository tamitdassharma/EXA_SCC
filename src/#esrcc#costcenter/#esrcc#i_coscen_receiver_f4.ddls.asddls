@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cost Object and Number (Receivers)'

@Search.searchable: true
define view entity /ESRCC/I_COSCEN_RECEIVER_F4
  as select from /ESRCC/I_COSCEN_F4 as coscen
  association [0..1] to /ESRCC/I_LegalEntityAll_F4 as _LegalEntity on _LegalEntity.Legalentity = coscen.LegalEntity
{

  key CostObjectUuid,

      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.lineItem: [{ position: 1 }]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' }}]
      @Consumption.filter.hidden: true
      cast( Sysid as /esrcc/recsysid )              as Sysid,

      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.lineItem: [{ position: 2 }]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' }}]
      cast( LegalEntity as /esrcc/receivingntity )  as LegalEntity,

      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.lineItem: [{ position: 3 }]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' }}]
      cast( CompanyCode as /esrcc/recccode_de )     as CompanyCode,

      @ObjectModel.text.element: [ 'CostObjectDescription' ]
      @UI.lineItem: [{ position: 4 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      cast( Costobject as /esrcc/reccostobject_de ) as Costobject,

      @ObjectModel.text.element: [ 'Description' ]
      @UI.lineItem: [{ position: 5 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      cast( Costcenter as /esrcc/reccostcenter )    as Costcenter,

      FunctionalArea,
      ProfitCenter,
      BusinessDivision,
      Billfrequency,

      @ObjectModel.text.element: [ 'CurrencyName' ]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.filter.hidden: true
      _LegalEntity.LocalCurr                        as Currency,

      Description,
      SysidDescription,
      CompanyCodeDescription,
      LegalEntityDescription,
      CostObjectDescription,
      ProfitCenterDescription,
      BusinessDivisionDescription,
      BillfrequencyDescription,
      FunctionalAreaDescription,

      @Consumption.filter.hidden: true
      _LegalEntity.CurrencyName
}
where
     _LegalEntity.Role = 'R2'
  or _LegalEntity.Role = 'R3'
  or _LegalEntity.Role = 'R4'
