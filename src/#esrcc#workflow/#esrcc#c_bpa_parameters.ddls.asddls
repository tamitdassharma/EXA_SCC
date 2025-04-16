@EndUserText.label: 'Descision Parameters'
define abstract entity /ESRCC/C_BPA_PARAMETERS
{
  application     : /esrcc/application_type_de;
  comments        : abap.char(1024);
  workflowid      : /esrcc/workflowid;
  instanceid      : abap.string;
}
