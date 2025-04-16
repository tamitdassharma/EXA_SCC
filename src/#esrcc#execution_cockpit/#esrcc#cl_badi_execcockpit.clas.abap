CLASS /esrcc/cl_badi_execcockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_execcockpit .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_BADI_EXECCOCKPIT IMPLEMENTATION.


  METHOD /esrcc/if_execcockpit~calculate_chargeout.

    /esrcc/cl_calculate_chargeout=>calculate_chargeout(
      EXPORTING
        it_keys  = it_keys
        it_poper = it_poper
      IMPORTING
        ev_failed = ev_failed
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~finalize_chargeout.

    /esrcc/cl_calculate_chargeout=>finalize_chargeout(
      it_keys  = it_keys
      it_poper = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~finalize_costbase.

    /esrcc/cl_calculate_chargeout=>finalize_costbase(
      it_keys  = it_keys
      it_poper = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~finalize_servicecostshare.

    /esrcc/cl_calculate_chargeout=>finalize_servicecostshare(
      it_keys  = it_keys
      it_poper = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopen_chargeout.

    /esrcc/cl_calculate_chargeout=>reopen_chargeout(
      it_keys           = it_keys
      iv_costbasereopen = iv_costbasereopen
      it_poper          = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopen_costbase.

    /esrcc/cl_calculate_chargeout=>reopen_costbase(
      it_keys  = it_keys
      it_poper = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopen_serviceshare.

    /esrcc/cl_calculate_chargeout=>reopen_serviceshare(
      it_keys           = it_keys
      iv_costbasereopen = iv_costbasereopen
      it_poper          = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_adhocchargeout.

    /esrcc/cl_calculate_chargeout=>calculate_adhocchargeout(
      it_cbli       = it_cbli
      is_parameters = is_parameters
      it_receivers  = it_receivers
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_costbase.

    /esrcc/cl_calculate_chargeout=>calculate_costbase(
      EXPORTING
        it_keys   = it_keys
        it_poper  = it_poper
      IMPORTING
        ev_failed = ev_Failed
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_servicecostshare.

    /esrcc/cl_calculate_chargeout=>calculate_servicecostshare(
      EXPORTING
        it_keys  = it_keys
        it_poper = it_poper
      IMPORTING
        ev_failed = ev_failed
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopnesequentialchargeout.

    /esrcc/cl_calculate_chargeout=>reopnesequentialchargeout(
      it_keys           = it_keys
      iv_costbasereopen = iv_costbasereopen
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~sequentialchargeout.


    /esrcc/cl_calculate_chargeout=>sequentialchargeout(
      it_keys           = it_keys
      iv_costbasereopen = iv_costbasereopen
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~virtual_posting.

    /esrcc/cl_calculate_chargeout=>virtual_posting(
      it_keys  = it_keys
      it_poper = it_poper
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~delete_adhoc_chargeout.

    /esrcc/cl_calculate_chargeout=>delete_adhoc_chargeout( id =  id ).

  ENDMETHOD.
ENDCLASS.
