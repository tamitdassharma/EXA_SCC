@EndUserText.label: 'Workflow Parameters'
define abstract entity /ESRCC/C_WORKFLOW_DETAILS
{
  application     : /esrcc/application_type_de;
  fplv            : /esrcc/costdataset_de;
  ryear           : /esrcc/ryear;
  billfrequency   : /esrcc/billfrequency;
  billingperiod   : /esrcc/billperiod;
  legalentity     : /esrcc/legalentity;
  ccode           : /esrcc/ccode_de;
  sysid           : /esrcc/sysid;
  costobject      : /esrcc/costobject_de;
  costnumber      : /esrcc/costcenter;
  serviceproduct  : /esrcc/srvproduct;
  receivingentity : /esrcc/receivingntity;
  workflow_id     : /esrcc/workflowid;
}
