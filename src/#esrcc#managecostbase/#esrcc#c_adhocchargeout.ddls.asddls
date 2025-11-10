@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Include/Exclude Items in Calculation'
define root abstract entity /ESRCC/C_ADHOCCHARGEOUT
{
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
  contractid             : /esrcc/contractid;
  allocationkey          : /esrcc/allockey;
  receivers              : abap.string;
}
