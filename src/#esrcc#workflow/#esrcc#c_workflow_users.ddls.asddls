@EndUserText.label: 'Workflow Users'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_WORKFLOWUSERS'
@Metadata.allowExtensions: true
define root custom entity /ESRCC/C_WORKFLOW_USERS
{
  key application       : /esrcc/application_type_de;
  key legalentity       : /esrcc/legalentity;
  key sysid             : /esrcc/sysid;
  key costobject        : /esrcc/costobject_de;
  key costcenter        : /esrcc/costcenter;
  key approval_level    : /esrcc/approvallevel;
      useremail         : abap.string( 0 );  
}
