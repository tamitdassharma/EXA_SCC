@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Application Logs Items Projection'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
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
            by: 'CreatedAt',
            direction: #DESC
        }],
        visualizations: [{
            type: #AS_LINEITEM
        }]
    }]
}
define view entity /ESRCC/C_ApplicationLogItems
  as projection on /ESRCC/I_ApplicationLogItems
{
  key     LogUuid,
          LogHeaderUuid,
          ParentLogUuid,
          @ObjectModel.text.element: [ 'MessageID' ]
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
          
          
          IsParent,
          _log_header : redirected to parent /ESRCC/C_ApplicationLogs
}
