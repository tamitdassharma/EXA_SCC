INTERFACE /esrcc/if_trueuprecal
  PUBLIC .

  INTERFACES: if_badi_interface.

  CLASS-METHODS calculate_recalchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS finalize_recalchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS reopen_recalchargeout
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
      !iv_costbasereopen TYPE abap_boolean OPTIONAL
      !it_poper          TYPE /esrcc/tt_poper_range OPTIONAL
    EXPORTING
      !ev_failed         TYPE abap_boolean .

  CLASS-METHODS calculate_recalseqchargeout
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
      !iv_costbasereopen TYPE abap_boolean OPTIONAL
    EXPORTING
      !ev_failed         TYPE abap_boolean .

  CLASS-METHODS finalize_recalseqchargeout
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
      !iv_costbasereopen TYPE abap_boolean OPTIONAL
    EXPORTING
      !ev_failed         TYPE abap_boolean .

  CLASS-METHODS reopen_recalseqchargeout
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
      !iv_costbasereopen TYPE abap_boolean OPTIONAL
    EXPORTING
      !ev_failed         TYPE abap_boolean .

  CLASS-METHODS virtual_posting
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
      !it_poper  TYPE /esrcc/tt_poper_range
      !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS: determine_trueup
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_poper         TYPE /esrcc/tt_poper_range OPTIONAL
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
        !iv_workflow      TYPE abap_boolean.

ENDINTERFACE.
