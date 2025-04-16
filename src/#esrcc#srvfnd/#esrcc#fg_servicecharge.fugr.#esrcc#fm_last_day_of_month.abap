function /esrcc/fm_last_day_of_month.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(DAY_IN) TYPE  /ESRCC/VALIDFROM
*"  EXPORTING
*"     REFERENCE(END_OF_MONTH) TYPE  /ESRCC/VALIDFROM
*"----------------------------------------------------------------------
  data: lv_end_of(2) type c,
        lv_date type /esrcc/validfrom.

  case day_in+4(2).
    when '01'.
      lv_end_of = '31'.
    when '02'.
      lv_date(4) = day_in(4).
      lv_date+4(4) = '0228'.
      lv_date = lv_date + 1.
      if lv_date+4(4) eq '0301'.
        lv_end_of = '28'.
      else.
        lv_end_of = '29'.
      endif.
    when '03'.
      lv_end_of = '31'.
    when '04'.
      lv_end_of = '30'.
    when '05'.
      lv_end_of = '31'.
    when '06'.
      lv_end_of = '30'.
    when '07'.
      lv_end_of = '31'.
    when '08'.
      lv_end_of = '31'.
    when '09'.
      lv_end_of = '30'.
    when '10'.
      lv_end_of = '31'.
    when '11'.
      lv_end_of = '30'.
    when '12'.
      lv_end_of = '31'.
  endcase.
  end_of_month = day_in.
  end_of_month+6(2) = lv_end_of.

ENDFUNCTION.
