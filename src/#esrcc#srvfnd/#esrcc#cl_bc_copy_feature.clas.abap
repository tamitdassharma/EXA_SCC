CLASS /esrcc/cl_bc_copy_feature DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_badi_interface.
    INTERFACES /esrcc/if_bc_copy_feature.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS identify_date
      IMPORTING
        iv_parent_date            TYPE /esrcc/date
        is_parent_target_validity TYPE /esrcc/if_bc_copy_feature~ts_validity
        iv_is_to_date             TYPE abap_boolean OPTIONAL
      CHANGING
        cv_child_date             TYPE /esrcc/date.

    METHODS determine_value
      IMPORTING
        iv_child              TYPE i
        iv_target_parent_from TYPE i
        iv_target_parent_to   TYPE i
      RETURNING
        VALUE(rv_value)       TYPE i.

    METHODS build_date
      IMPORTING
        iv_year        TYPE i
        iv_month       TYPE i
        iv_day         TYPE i
      RETURNING
        VALUE(rv_date) TYPE /esrcc/date.

ENDCLASS.


CLASS /esrcc/cl_bc_copy_feature IMPLEMENTATION.
  METHOD /esrcc/if_bc_copy_feature~auto_adjust_child_validity.
    " Valid From
    identify_date( EXPORTING iv_parent_date            = is_parent_validity-from
                             is_parent_target_validity = is_parent_target_validity
                   CHANGING  cv_child_date             = cs_child_validity-from ).

    " Valid To
    identify_date( EXPORTING iv_parent_date            = is_parent_validity-to
                             is_parent_target_validity = is_parent_target_validity
                             iv_is_to_date             = abap_true
                   CHANGING  cv_child_date             = cs_child_validity-to ).
  ENDMETHOD.

  METHOD identify_date.
    IF cv_child_date BETWEEN is_parent_target_validity-from AND is_parent_target_validity-to.
      RETURN.
    ENDIF.

    DATA(ls_target_date) = COND #( WHEN iv_is_to_date = abap_false THEN is_parent_target_validity-from ELSE is_parent_target_validity-to ).
    IF cv_child_date = iv_parent_date.
      cv_child_date = ls_target_date.
      RETURN.
    ENDIF.

    /esrcc/cl_config_util=>extract_date_components( EXPORTING date  = cv_child_date
                                                    IMPORTING year  = DATA(lv_child_year)
                                                              month = DATA(lv_child_month)
                                                              day   = DATA(lv_child_day) ).

    /esrcc/cl_config_util=>extract_date_components( EXPORTING date = iv_parent_date
                                                    IMPORTING year = DATA(lv_parent_year) ).

    /esrcc/cl_config_util=>extract_date_components( EXPORTING date  = ls_target_date
                                                    IMPORTING year  = DATA(lv_target_year)
                                                              month = DATA(lv_target_month) ).

    /esrcc/cl_config_util=>extract_date_components( EXPORTING date  = is_parent_target_validity-from
                                                    IMPORTING year  = DATA(lv_parent_target_from_year)
                                                              month = DATA(lv_parent_target_from_month) ).

    /esrcc/cl_config_util=>extract_date_components( EXPORTING date  = is_parent_target_validity-to
                                                    IMPORTING year  = DATA(lv_parent_target_to_year)
                                                              month = DATA(lv_parent_target_to_month) ).

    IF lv_parent_year = lv_child_year.
      DATA(lv_new_year)  = lv_target_year.
      DATA(lv_new_month) = determine_value( iv_child              = lv_child_month
                                            iv_target_parent_from = lv_parent_target_from_month
                                            iv_target_parent_to   = lv_parent_target_to_month ).
    ELSE.
      lv_new_month = lv_target_month.
      lv_new_year = determine_value( iv_child              = lv_child_year
                                     iv_target_parent_from = lv_parent_target_from_year
                                     iv_target_parent_to   = lv_parent_target_to_year ).
    ENDIF.

    cv_child_date = build_date( iv_year  = lv_new_year
                                iv_month = lv_new_month
                                iv_day   = lv_child_day ).

    IF lv_child_month <> lv_new_month AND iv_is_to_date = abap_true.
      cv_child_date = /esrcc/cl_utility_core=>get_last_day_of_month( date = cv_child_date ).
    ENDIF.
  ENDMETHOD.

  METHOD determine_value.
    rv_value = COND int2( WHEN iv_child BETWEEN iv_target_parent_from AND iv_target_parent_to THEN iv_child
                                   WHEN iv_child < iv_target_parent_from THEN iv_target_parent_from
                                   WHEN iv_child > iv_target_parent_to THEN iv_target_parent_to ).
  ENDMETHOD.

  METHOD build_date.
    rv_date = |{ iv_year }{ COND #( WHEN iv_month < 10 THEN |0{ iv_month }| ELSE iv_month ) }{ COND #( WHEN iv_day < 10 THEN |0{ iv_day }| ELSE iv_day ) }|.
  ENDMETHOD.
ENDCLASS.
