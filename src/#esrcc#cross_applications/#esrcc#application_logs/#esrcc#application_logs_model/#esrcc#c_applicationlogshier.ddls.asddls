@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy projection for Appl Logs'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S
}
@Metadata.allowExtensions: true
@UI: {
    headerInfo: {
        typeName: 'Message',
        typeNamePlural: 'Messages'
    },
    presentationVariant: [{
        sortOrder: [{
            by: 'Application',
            direction: #ASC
        },
        {
            by: 'SubApplication',
            direction: #ASC
        },
        {
            by: 'RunNumber',
            direction: #DESC
        }],
        visualizations: [{
            type: #AS_LINEITEM
        }]
    }]
}
define root view entity /ESRCC/C_ApplicationLogsHier
  provider contract transactional_query
  as projection on /ESRCC/I_ApplicationLogsHierF
{
  key     Hid,
          ParentHid,
          HierarchyLevel,
          DrilldownState,
          @Consumption: {
              filter: {
                  mandatory: true,
                  selectionType: #SINGLE,
                  multipleSelections: false
              }
          }
          @ObjectModel.text.element: ['ApplicationDescription']
          Application,
          @Consumption: {
              filter: {
                  mandatory: true,
                  selectionType: #SINGLE,
                  multipleSelections: false
              }
          }
          @ObjectModel.text.element: ['SubApplicationDescription']
          SubApplication,
          RunNumber,
          ReportingYear,
          PeriodFrom,
          PeriodTo,
          PlanningVersion,
          @ObjectModel.text.element: ['LegalEntityDescription']
          LegalEntity,
          @ObjectModel.text.element: ['SystemIdDescription']
          SystemId,
          @ObjectModel.text.element: ['CompanyCodeDescription']
          CompanyCode,
          CreatedBy,
          MessageId,
          MessageNumber,
          MessageType,
          MessageTypeCriticality,
          MessageV1,
          MessageV2,
          MessageV3,
          MessageV4,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_VE_MESSAGE_TEXT'
  virtual MessageText : abap.char(255),
          CreatedAt,
          LogHeaderUuid,
          Ryear,
          Poper,
          Fplv,
          Sysid,
          InvalidRecordLegalentity,
          Ccode,
          Belnr,
          Buzei,
          Costobject,
          Costcenter,
          Costelement,
          Businessdivision,
          Profitcenter,
          @Semantics.amount.currencyCode : 'Localcurr'
          Hsl,
          Localcurr,
          @Semantics.amount.currencyCode : 'Groupcurr'
          Ksl,
          Groupcurr,
          Vendor,
          Postingtype,
          Costind,
          Usagecal,
          RootUUID,
          @Semantics.text: true
          ApplicationDescription,
          @Semantics.text: true
          SubApplicationDescription,
          @Semantics.text: true
          SystemIdDescription,
          @Semantics.text: true
          CompanyCodeDescription,
          @Semantics.text: true
          LegalEntityDescription


}
