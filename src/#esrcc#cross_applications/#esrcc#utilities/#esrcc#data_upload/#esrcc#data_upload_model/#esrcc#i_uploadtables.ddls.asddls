@EndUserText.label: 'Upload Tables'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_I_UPLOAD_TABLES'
@Metadata.allowExtensions: true
define root custom entity /ESRCC/I_UploadTables

{     
      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: 'Table Name'
  key tableName   : tabname;
      @UI.hidden  : true
      language    : abap.lang;
      @UI.lineItem: [{ position: 20 }]
      @EndUserText.label: 'Table Description'
      description : abap.string(256);

}
