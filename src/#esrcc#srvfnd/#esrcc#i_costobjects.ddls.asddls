@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Maintain Cost Object Types'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_COSTOBJECTS
  as select from /esrcc/cstobjtyp as _costobjectype
   association [0..*] to /esrcc/cstbjtypt as _costobjectypetext
                      on _costobjectypetext.cost_object = _costobjectype.cost_object
                      and _costobjectypetext.spras = $session.system_language
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key _costobjectype.cost_object as Costobject,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      _costobjectypetext.description as text
}

