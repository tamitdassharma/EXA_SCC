@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Indirect Allocation KPI Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_ALLOCATIONSHARE
  as select from /esrcc/alocshare as alocshare

  association [0..*] to /ESRCC/I_ReceiverChargeout as receivercharegout on  receivercharegout.UUID         = alocshare.parentuuid
                                                                        and receivercharegout.Currencytype = 'L'
  composition [0..*] of /ESRCC/I_ALLOCATIONVALUES  as _ReceiverAllocation

  association [0..1] to /ESRCC/I_KEY_VERSION       as _KeyVersionText   on  _KeyVersionText.KeyVersion = $projection.keyversion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _AllocKeyText     on  _AllocKeyText.Allocationkey = $projection.allockey

  association [0..1] to /ESRCC/I_ALLOCATIONPERIOD  as _AllocPeriodText  on  _AllocPeriodText.AllocationPeriod = $projection.allocationperiod

{
  key alocshare.uuid                                                                                  as AlocUUID,
      receivercharegout.UUID                                                                          as ReceiverUUID,
      receivercharegout._ServiceCost._CostCenterCost.Fplv,
      receivercharegout._ServiceCost._CostCenterCost.Ryear,
      receivercharegout._ServiceCost._CostCenterCost.Poper,
      cast( receivercharegout._ServiceCost._CostCenterCost.Sysid as /esrcc/provider_sysid )           as Sysid,
      cast( receivercharegout._ServiceCost._CostCenterCost.Ccode as /esrcc/provider_ccode )           as Ccode,
      cast( receivercharegout._ServiceCost._CostCenterCost.Legalentity as /esrcc/provider_entity )    as Legalentity,
      cast( receivercharegout._ServiceCost._CostCenterCost.Costobject as /esrcc/provider_costobject ) as Costobject,
      cast( receivercharegout._ServiceCost._CostCenterCost.Costcenter as /esrcc/provider_costcenter ) as Costcenter,
      receivercharegout._ServiceCost.Serviceproduct,
      receivercharegout.ReceiverSysId,
      receivercharegout.ReceiverCompanyCode,
      receivercharegout.Receivingentity,
      receivercharegout.ReceiverCostObject,
      receivercharegout.ReceiverCostCenter,
      alocshare.keyversion,
      alocshare.allockey,
      //  key alloctype,
      alocshare.allocationperiod,
      alocshare.refperiod,
      alocshare.weightage,
      alocshare.reckpivalue,
      cast(round(alocshare.initialreckpishare * 100, 3) as abap.dec(15,3))                            as totalreckpishare,
      cast(round(alocshare.reckpishare * 100,2) as abap.dec(15,3))                                    as reckpishare,
      receivercharegout._ServiceCost._CostCenterCost.Country                                          as legalentitycountry,
      receivercharegout.Country                                                                       as receivingcountry,
      receivercharegout._ServiceCost.OECD,
      receivercharegout._ServiceCost.oecdDescription,

      /* Associations */
      _ReceiverAllocation,
      //      _AverageReceiverAllocation,
      //Associations//
      receivercharegout._ServiceCost._CostCenterCost.ccodedescription,
      receivercharegout._ServiceCost._CostCenterCost.legalentitydescription,
      receivercharegout._ServiceCost._CostCenterCost.costobjectdescription,
      receivercharegout._ServiceCost._CostCenterCost.costcenterdescription,
      receivercharegout._ServiceCost._CostCenterCost.costdatasetdescription,
      receivercharegout._ServiceCost.Serviceproductdescription,
      receivercharegout.ccodedescription                                                              as RecCcodedescription,
      receivercharegout.receivingentitydescription,
      receivercharegout.costobjectdescription                                                         as RecCostObjectdescription,
      receivercharegout.costcenterdescription                                                         as RecCostCenterdescription,

      _KeyVersionText,
      _AllocKeyText,
      //      _AllocTypeText,
      _AllocPeriodText,
      receivercharegout._ServiceCost._CostCenterCost._legalCountryText.CountryName                    as legalcountryname,
      receivercharegout._ReceivingCountryText.CountryName                                             as ReceivingCountryName

}
