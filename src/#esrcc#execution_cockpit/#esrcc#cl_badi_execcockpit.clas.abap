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

  METHOD /esrcc/if_execcockpit~background_scheduler.

    DATA lt_keys TYPE /esrcc/tt_keys.
    DATA lt_uuid TYPE RANGE OF sysuuid_x16.
    DATA lo_std_badi    TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lo_trueup_badi TYPE REF TO /esrcc/badi_trueuprecal.

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

      IF lo_std_badi IS NOT BOUND.
        TRY.
            GET BADI lo_std_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

       IF lo_trueup_badi IS NOT BOUND.
        TRY.
            GET BADI lo_trueup_badi.
          CATCH cx_badi_not_implemented cx_badi_unknown_error.
        ENDTRY.
      ENDIF.

      CASE <ls_parameters>-low.

        WHEN /esrcc/if_calculate_chargeout=>calculate_stdchargeout.
          IF lo_std_badi IS BOUND.

            CALL BADI lo_std_badi->calculate_stdchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>finalize_stdchargeout.
          IF lo_std_badi IS BOUND.

            CALL BADI lo_std_badi->finalize_stdchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>reopen_stdchargeout.
          IF lo_std_badi IS BOUND.

            CALL BADI lo_std_badi->reopen_stdchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>calculate_stdseqchargeout.
          IF lo_std_badi IS BOUND.

            CALL BADI lo_std_badi->calculate_stdseqchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>finalize_stdseqchargeout.
          IF lo_std_badi IS BOUND.

            CALL BADI lo_std_badi->finalize_stdseqchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>reopen_stdseqchargeout.
          IF lo_std_badi IS BOUND.

            CALL BADI lo_std_badi->reopen_stdseqchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>calculate_recalchargeout.
          IF lo_trueup_badi IS BOUND.

            CALL BADI lo_trueup_badi->calculate_recalchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>finalize_recalchargeout.
          IF lo_trueup_badi IS BOUND.

            CALL BADI lo_trueup_badi->finalize_recalchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>reopen_recalchargeout.
          IF lo_trueup_badi IS BOUND.

            CALL BADI lo_trueup_badi->reopen_recalchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.
        WHEN /esrcc/if_calculate_chargeout=>calculate_recalseqchargeout.
          IF lo_trueup_badi IS BOUND.

            CALL BADI lo_trueup_badi->calculate_recalseqchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.

        WHEN /esrcc/if_calculate_chargeout=>finalize_recalseqchargeout.
          IF lo_trueup_badi IS BOUND.

            CALL BADI lo_trueup_badi->finalize_recalseqchargeout
              EXPORTING
                it_keys = lt_keys
*               it_poper =
              .

          ENDIF.

        WHEN /esrcc/if_calculate_chargeout=>reopen_recalseqchargeout.
          IF lo_trueup_badi IS BOUND.

            CALL BADI lo_trueup_badi->reopen_recalseqchargeout
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
