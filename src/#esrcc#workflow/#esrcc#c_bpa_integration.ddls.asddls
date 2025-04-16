@EndUserText.label: 'BPA Integration'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_BPA_INTEGRATION'
@Metadata.allowExtensions: true
define root custom entity /ESRCC/C_BPA_INTEGRATION
{
  key application                 : /esrcc/application_type_de;
  key workflow_id                 : /esrcc/workflowid;
      fplv                        : /esrcc/costdataset_de;
      ryear                       : /esrcc/ryear;
      billfrequency               : /esrcc/billfrequency;
      billingperiod               : /esrcc/billperiod;
      legalentity                 : /esrcc/legalentity;
      ccode                       : /esrcc/ccode_de;
      sysid                       : /esrcc/sysid;
      costobject                  : /esrcc/costobject_de;
      costnumber                  : /esrcc/costcenter;
      serviceproduct              : /esrcc/srvproduct;
      receivingentity             : /esrcc/receivingntity;
      approval_level              : /esrcc/approvallevel;
      costdatasetdescription      : /esrcc/description;
      billingfrequencydescription : /esrcc/description;
      billingperioddescription    : /esrcc/description;
      legalentitydescription      : /esrcc/description;
      ccodedescription            : /esrcc/description;
      costobjectdescription       : /esrcc/description;
      costcenterdescription       : /esrcc/description;
      Serviceproductdescription   : /esrcc/description;
      receivingentitydescription  : /esrcc/description;
      totalcost                   : abap.string(0);
      excludedcost                : abap.string(0);
      includedcost                : abap.string(0);
      origtotalcost               : abap.string(0);
      passtotalcost               : abap.string(0);
      stewardship                 : abap.string(0);
      remainingcostbase           : abap.string(0);
      srvcostshare                : abap.string(0);
      valueaddshare               : abap.string(0);
      passthroughshare            : abap.string(0);
      valueaddmarkupabs           : abap.string(0);
      passthrumarkupabs           : abap.string(0);
      totalsrvmarkupabs           : abap.string(0);
      totalchargeoutamount        : abap.string(0);
      chargeoutforservice         : abap.string(0);
      totaludmarkupabs            : abap.string(0);
      totalcostbaseabs            : abap.string(0);
      valuaddabs                  : abap.string(0);
      passthruabs                 : abap.string(0);
      amountlc                    : abap.string(0);
      amountgc                    : abap.string(0);
      subject                     : abap.string(0);
      open_task                   : abap.string(0);
}
