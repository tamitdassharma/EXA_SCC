@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Comment'
define root abstract entity /ESRCC/C_COMMENT  
{   
    @EndUserText.label: 'Comments'
    @UI.multiLineText: true
    comments : /esrcc/comment;
    
}
