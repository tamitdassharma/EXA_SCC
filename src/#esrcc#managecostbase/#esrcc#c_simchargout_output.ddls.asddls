@AbapCatalog.extensibility.extensible: true
@EndUserText.label: 'Include/Exclude Items in Calculation'
define root abstract entity /ESRCC/C_SIMCHARGOUT_OUTPUT
{
  Serviceproduct : /esrcc/srvproduct;
  rule_id        : /esrcc/chargeout_rule_id;
  receivers      : abap.string;
  localcurr      : /esrcc/localcurr;
//  @Semantics.amount.currencyCode: 'localcurr'
//  totalcostbase : /esrcc/hsl;
}
