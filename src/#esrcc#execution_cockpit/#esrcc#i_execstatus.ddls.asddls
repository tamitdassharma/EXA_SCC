@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Execution Status'
define view entity /ESRCC/I_EXECSTATUS 
as select from /esrcc/exec_st as status
    
  association [0..1] to /esrcc/execst_t as statustext
   on status.application = statustext.application
   and status.status = statustext.status
   and statustext.spras = $session.system_language


{
    key application as Application,
    key status as Status,   
    color as Color,       
    statustext.description as statusdescription 
}
