@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Manage Cost Base'
define root view entity /ESRCC/C_MANAGECOSTBASE
  provider contract transactional_query
  as projection on /ESRCC/I_MANAGECOSTBASE
{

  key Ryear,
  key Poper,
      @ObjectModel.text.element: [ 'costdatasetdescription' ]
  key Fplv,
  key SysID,
      @ObjectModel.text.element: [ 'legalentitydescription' ]
  key Legalentity,
      @ObjectModel.text.element: [ 'ccodedescription' ]
  key Ccode,
  key Belnr,
      @ObjectModel.filter.enabled: false
  key Buzei,
      @ObjectModel.text.element: [ 'costobjectdescription' ]
  key Costobject,
      @ObjectModel.text.element: [ 'costcenterdescription' ]
  key Costcenter,
      @ObjectModel.text.element: [ 'costelementdescription' ]
  key Costelement,
      @ObjectModel.text.element: [ 'valuesourcedescription' ]
      ValueSource,
      @ObjectModel.text.element: [ 'businessdivdescription' ]
      Businessdivision,
      @ObjectModel.text.element: [ 'profitcenterdescription' ]
      Profitcenter,
      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      Functionalarea,
      @ObjectModel.text.element: [ 'costtypedescription' ]
      Costtype,
      @Semantics.amount.currencyCode: 'Localcurr'
      @ObjectModel.filter.enabled: false
      Hsl,
      Localcurr,
      @Semantics.amount.currencyCode: 'Groupcurr'
      @ObjectModel.filter.enabled: false
      Ksl,
      Groupcurr,
      Vendor,
      @ObjectModel.text.element: [ 'postingtypedescription' ]
      Postingtype,
      @ObjectModel.text.element: [ 'costinddescription' ]
      Costind,
      @ObjectModel.text.element: [ 'usagecaldescription' ]
      Usagecal,
      @ObjectModel.text.element: [ 'reasondescription' ]
      ReasonId,
      @ObjectModel.text.element: [ 'statusdescription' ]
      Status,
      WorkflowId,
      CommentId,
      UniqueId,    
      @Semantics.user.createdBy: true
      CreatedBy,
      @ObjectModel.filter.enabled: false
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @ObjectModel.filter.enabled: false
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      legalentitydescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      costelementdescription,
      @Semantics.text: true
      costtypedescription,
      @Semantics.text: true
      costinddescription,
      @Semantics.text: true
      postingtypedescription,
      @Semantics.text: true
      costdatasetdescription,
      @Semantics.text: true
      usagecaldescription,
      @Semantics.text: true
      reasondescription,
      @Semantics.text: true
      valuesourcedescription,
      @Semantics.text: true
      statusdescription,
      @Semantics.text: true
      businessdivdescription,
      @Semantics.text: true
      ProfitCenterDescription,
      @Semantics.text: true
      FunctionalAreaDescription,
      usagecriticallity,
      statuscriticallity,
      @ObjectModel.text.element: [ 'legalentitycountryname' ]
      country,
      _legalCountryText.CountryName as legalentitycountryname

}
