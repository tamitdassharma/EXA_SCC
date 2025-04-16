@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Application Logs Projection'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
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
define root view entity /ESRCC/C_ApplicationLogs
  provider contract transactional_query
  as projection on /ESRCC/I_ApplicationLogs
{
  key LogHeaderUUID,
      @Consumption: {
          filter: {
              mandatory: true,
              selectionType: #SINGLE,
              multipleSelections: false
          }
      }
      
      Application,
      @Consumption: {
          filter: {
              mandatory: true,
              selectionType: #SINGLE,
              multipleSelections: false
          }
      }
      
      SubApplication,
      
      RunNumber,
      
      ReportingYear,
      
      
      PeriodFrom,
      
      
      PeriodTo,
      
      PlanningVersion,
      
      
      LegalEntity,
      
      
      SystemId,
      
      
      CompanyCode,
      @Semantics.user.createdBy: true

      
      
      CreatedBy,
      /* Associations */
      _invalid_records,
      _log_items : redirected to composition child /ESRCC/C_ApplicationLogItems

}
