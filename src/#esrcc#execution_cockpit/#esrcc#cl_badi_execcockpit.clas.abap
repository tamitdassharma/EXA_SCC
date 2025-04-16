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



CLASS /esrcc/cl_badi_execcockpit IMPLEMENTATION.


  METHOD /esrcc/if_execcockpit~calculate_adhocchargeout.

    /esrcc/cl_calculate_chargeout=>calculate_adhocchargeout(
      it_cbli       = it_cbli
      is_parameters = is_parameters
      it_receivers  = it_receivers
    ).

  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_chargeout.

    /esrcc/cl_calculate_chargeout=>calculate_chargeout(
      EXPORTING
        it_keys  = it_keys
        it_poper = it_poper
      IMPORTING
        ev_failed = ev_failed
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


  METHOD /esrcc/if_execcockpit~delete_adhoc_chargeout.

    /esrcc/cl_calculate_chargeout=>delete_adhoc_chargeout( id =  id ).

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

  METHOD /esrcc/if_execcockpit~background_scheduler.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA lt_uuid TYPE RANGE OF sysuuid_x16.
    DATA lo_badi TYPE REF TO /esrcc/badi_cockpit.

    LOOP AT it_parameters ASSIGNING FIELD-SYMBOL(<ls_parameters>) WHERE selname = /esrcc/cl_apj_rt_service=>id_param.
      APPEND INITIAL LINE TO lt_uuid ASSIGNING FIELD-SYMBOL(<ls_uuid>).
      MOVE-CORRESPONDING <ls_parameters> TO <ls_uuid>.
    ENDLOOP.

    SELECT proclogs~* FROM /esrcc/proclogs AS proclogs
             INNER JOIN @lt_uuid AS id
             ON id~low = proclogs~uuid
             INTO CORRESPONDING FIELDS OF TABLE @lt_keys.

    READ TABLE it_parameters ASSIGNING <ls_parameters> WITH KEY selname = /esrcc/cl_apj_rt_service=>action_param.
    IF sy-subrc = 0.

      IF lo_badi IS NOT BOUND.
        TRY.
            GET BADI lo_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      CASE <ls_parameters>-low.

        WHEN /esrcc/if_calculate_chargeout=>action_calculate_costbase.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->calculate_costbase
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_finalize_costbase.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->finalize_costbase
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_reopen_costbase.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->reopen_costbase
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_calculat_serviceproduct.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->calculate_servicecostshare
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_finalize_serviceproduct.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->finalize_servicecostshare
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_reopen_serviceproduct.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->reopen_serviceshare
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_calculat_chargeout.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->calculate_chargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_finalize_chargeout.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->finalize_chargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_reopen_chargeout.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->reopen_chargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_sequential_chargeout.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->sequentialchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>action_reopenseq_chargeout.
          IF lo_badi IS BOUND.

            CALL BADI lo_badi->reopnesequentialchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
