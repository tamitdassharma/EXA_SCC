INTERFACE /esrcc/if_stdchargeout
  PUBLIC .

  INTERFACES: if_badi_interface.

  CLASS-METHODS calculate_stdchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS finalize_stdchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS reopen_stdchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS calculate_stdseqchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS finalize_stdseqchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS reopen_stdseqchargeout
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
      !iv_costbasereopen TYPE abap_boolean OPTIONAL
      !it_poper          TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed         TYPE abap_boolean .

  CLASS-METHODS virtual_posting
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS calculate_adhocchargeout
    IMPORTING
      !it_cbli       TYPE /esrcc/tt_cbli
      !is_parameters TYPE /esrcc/c_adhocchargeout
      !it_receivers  TYPE /esrcc/tt_receivers
    EXPORTING
      !ev_failed     TYPE abap_boolean .

  CLASS-METHODS delete_adhoc_chargeout
    IMPORTING
      !id        TYPE sysuuid_x16
    EXPORTING
      !ev_failed TYPE abap_boolean .

ENDINTERFACE.
