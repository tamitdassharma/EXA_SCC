CLASS /esrcc/cl_config_ve_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      tt_srvaloc TYPE STANDARD TABLE OF /ESRCC/C_ChargeoutBc WITH EMPTY KEY.

    DATA:
      gv_entity TYPE string.

    METHODS: calculate_srvaloc
      CHANGING ct_srvaloc TYPE tt_srvaloc.
ENDCLASS.



CLASS /ESRCC/CL_CONFIG_VE_HANDLER IMPLEMENTATION.


  METHOD calculate_srvaloc.
*    SELECT
*        aloc~serviceproduct,
*        aloc~costversion,
*        aloc~validfrom,
*
*        CASE
*          WHEN draft~chargeout = 'D' THEN @abap_true ELSE CASE WHEN draft~chargeout IS NULL AND db~chargeout = 'D' THEN @abap_true ELSE @abap_false END
*        END AS hideweightage,
*        CASE
*          WHEN draft~chargeout = 'I' THEN @abap_true ELSE CASE WHEN draft~chargeout IS NULL AND db~chargeout = 'I' THEN @abap_true ELSE @abap_false END
*        END AS hideversion
*
*      FROM @ct_srvaloc AS aloc
*      LEFT OUTER JOIN /esrcc/d_srvaloc AS draft
*         ON draft~serviceproduct = aloc~serviceproduct
*        AND draft~costversion    = aloc~costversion
*        AND draft~validfrom      = aloc~validfrom
*        AND draft~draftentityoperationcode NOT IN ( 'D', 'L' )
*      LEFT OUTER JOIN /esrcc/srvaloc AS db
*         ON db~serviceproduct = aloc~serviceproduct
*        AND db~cost_version   = aloc~costversion
*        AND db~validfrom      = aloc~validfrom
*      INTO TABLE @DATA(lt_srvaloc).
*
*    ct_srvaloc = CORRESPONDING #( lt_srvaloc ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    CASE gv_entity.
      WHEN '/ESRCC/C_SRVALOC'.
        DATA(lt_srvaloc) = CORRESPONDING tt_srvaloc( it_original_data ).

        calculate_srvaloc(
          CHANGING
            ct_srvaloc = lt_srvaloc
        ).

        ct_calculated_data = CORRESPONDING #( lt_srvaloc ).
    ENDCASE.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    gv_entity = iv_entity.
  ENDMETHOD.
ENDCLASS.
