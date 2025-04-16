@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Simulate Adhoc Chargeout'
define root abstract entity /ESRCC/C_SIMULATECHARGEOUT
{
  ryear                  : /esrcc/ryear;
  poper                  : poper;
  fplv                   : /esrcc/costdataset_de;
  sysid                  : /esrcc/sysid;
  legalentity            : /esrcc/legalentity;
  ccode                  : /esrcc/ccode_de;
  belnr                  : /esrcc/doc_no;
  buzei                  : /esrcc/buzei;
  costobject             : /esrcc/costobject_de;
  costcenter             : /esrcc/costcenter;
  costelement            : /esrcc/costelement;
  Serviceproduct         : /esrcc/srvproduct;
  rule_id                : /esrcc/chargeout_rule_id;
  @EndUserText.label     : 'Mark-up on Value Add (%)'
  valueaddmarkup         : abap.dec(5,2);
  @EndUserText.label     : 'Mark-up on Pass Through (%)'
  passthroughmarkup      : abap.dec(5,2);
  @EndUserText.label     : 'Mark-up on Value Add (%)'
  intravalueaddmarkup    : abap.dec(5,2);
  @EndUserText.label     : 'Mark-up on Pass Through (%)'
  intrapassthroughmarkup : abap.dec(5,2);
  @EndUserText.label     : 'Mark-up on Value Add (%)'
  intervalueaddmarkup    : abap.dec(5,2);
  @EndUserText.label     : 'Mark-up on Pass Through (%)'
  interpassthroughmarkup : abap.dec(5,2);
  allocationkey          : /esrcc/allockey;
  receivers              : abap.string;
}
