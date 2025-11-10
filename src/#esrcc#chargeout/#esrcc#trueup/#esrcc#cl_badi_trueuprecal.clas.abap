CLASS /esrcc/cl_badi_trueuprecal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_trueuprecal.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_trueuprecal IMPLEMENTATION.

  METHOD /esrcc/if_trueuprecal~calculate_recalchargeout.

    /esrcc/cl_calculate_trueup=>calculate_recalchargeout(
      EXPORTING
        it_keys  = it_keys
        it_poper = it_poper
      IMPORTING
        ev_failed = ev_failed
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~calculate_recalseqchargeout.

    /esrcc/cl_calculate_trueup=>calculate_recalseqchargeout(
      it_keys           = it_keys
      iv_costbasereopen = iv_costbasereopen
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~finalize_recalchargeout.

    /esrcc/cl_calculate_trueup=>finalize_recalchargeout(
      it_keys  = it_keys
      it_poper = it_poper
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~finalize_recalseqchargeout.

    /esrcc/cl_calculate_trueup=>finalize_recalseqchargeout(
       EXPORTING
         it_keys   = it_keys
     ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~reopen_recalchargeout.

    /esrcc/cl_calculate_trueup=>reopen_recalchargeout(
      it_keys  = it_keys
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~reopen_recalseqchargeout.

    /esrcc/cl_calculate_trueup=>reopen_recalseqchargeout(
      it_keys           = it_keys
      iv_costbasereopen = iv_costbasereopen
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~virtual_posting.

    /esrcc/cl_calculate_trueup=>virtual_posting(
      it_keys  = it_keys
      it_poper = it_poper
      iv_recalrefpoper = iv_recalrefpoper
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~determine_trueup.

    /esrcc/cl_calculate_trueup=>determine_trueup(
      it_keys  = it_keys
      it_poper = it_poper
      iv_recalrefpoper = iv_recalrefpoper
      iv_workflow      = iv_workflow
    ).

  ENDMETHOD.

ENDCLASS.
