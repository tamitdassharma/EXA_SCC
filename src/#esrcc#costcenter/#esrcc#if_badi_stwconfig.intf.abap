interface /ESRCC/IF_BADI_STWCONFIG
  public .


  interfaces IF_BADI_INTERFACE .

  class-methods DERIVE_STEWARDSHIPCONFIG
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
      !IV_SYNC type ABAP_BOOLEAN optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods ADD_PROVIDER
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
      !COUNT type /ESRCC/CHAIN_SEQUENCE
    exporting
      !ES_PROVIDER type /ESRCC/STEWRDSHP
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods ADD_SERVICEPRODUCT
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
    exporting
      !ES_SERVICEPRODUCT type /ESRCC/STWD_SP
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods ADD_RECEIVER
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
    exporting
      !ES_RECEIVERS type /ESRCC/STWDSPREC
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods DERIVE_SERVICEPRODUCTS
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
    exporting
      !ES_RECEIVERS type /ESRCC/STWDSPREC
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods DERIVE_COSTELEMENTS
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods DERIVE_COSTOBJECTS
    importing
      !IS_CONFIG type /ESRCC/HIER_DEF
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
endinterface.
