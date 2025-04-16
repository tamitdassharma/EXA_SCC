@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Product'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_SERVICEPRODUCT_F4
  as select from /esrcc/srvpro as srvpro
  association [0..1] to /esrcc/srvprot               as srvprot           on  srvpro.serviceproduct = srvprot.serviceproduct
                                                                          and srvprot.spras         = $session.system_language
  association        to /ESRCC/I_SERVICETYPE_F4      as _ServiceType      on  $projection.Servicetype = _ServiceType.ServiceType
  association        to /ESRCC/I_TRANSACTIONGROUP_F4 as _TransactionGroup on  $projection.Transactiongroup = _TransactionGroup.Transactiongroup
  association [0..1] to /ESRCC/I_OECD                as _OECD             on  $projection.OECD = _OECD.OECD
{
      @ObjectModel.text: { element: ['Description'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
  key serviceproduct                as ServiceProduct,

      @ObjectModel.text: { element: ['ServicetypeDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICETYPE_F4', element: 'ServiceType' } }]
      servicetype                   as Servicetype,

      @ObjectModel.text: { element: ['TransGrpDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_TRANSACTIONGROUP_F4', element: 'Transactiongroup' } }]
      transactiongroup              as Transactiongroup,

      @ObjectModel.text: { element: ['oecdDescription'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_OECD', element: 'OECD' } }]
      oecdtpg                       as OECD,

      @EndUserText.label: 'IP Owner'
      ip_owner                      as IpOwner,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      srvprot.description           as Description,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _ServiceType.Description      as ServicetypeDescription,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _TransactionGroup.Description as TransGrpDescription,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      @UI.lineItem: [{ hidden: true }]
      _OECD.text                    as oecdDescription
}
