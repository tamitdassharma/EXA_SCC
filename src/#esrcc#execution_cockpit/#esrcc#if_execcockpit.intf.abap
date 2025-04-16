interface /ESRCC/IF_EXECCOCKPIT
  public .


  interfaces IF_BADI_INTERFACE .

  class-methods CALCULATE_COSTBASE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods CALCULATE_SERVICECOSTSHARE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods CALCULATE_CHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods FINALIZE_COSTBASE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods FINALIZE_SERVICECOSTSHARE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods FINALIZE_CHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPEN_COSTBASE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPEN_SERVICESHARE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPEN_CHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods CALCULATE_ADHOCCHARGEOUT
    importing
      !IT_CBLI type /ESRCC/TT_CBLI
      !IS_PARAMETERS type /ESRCC/C_ADHOCCHARGEOUT
      !IT_RECEIVERS type /ESRCC/TT_RECEIVERS
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods SEQUENTIALCHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPNESEQUENTIALCHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods VIRTUAL_POSTING
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods DELETE_ADHOC_CHARGEOUT
    importing
      !ID type SYSUUID_X16
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
endinterface.
