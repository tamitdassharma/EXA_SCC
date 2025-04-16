CLASS /esrcc/cl_utility_core DEFINITION PUBLIC FINAL CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Get UTC date and time from UTC time stamp</p>
      "!
      "! @parameter time_stamp | <p class="shorttext synchronized" lang="en">UTC Time Stamp</p>
      "! @parameter date | <p class="shorttext synchronized" lang="en">UTC Date</p>
      "! @parameter time | <p class="shorttext synchronized" lang="en">UTC Time</p>
      get_utc_date_time_ts EXPORTING time_stamp TYPE timestampl
                                     date       TYPE datn
                                     time       TYPE timn,
      "! <p class="shorttext synchronized" lang="en">Get the last day of the month</p>
      "! Get the last day of the month for the date provided as input in the format YYYYMMDD.
      "! @parameter date | <p class="shorttext synchronized" lang="en">Input Date: YYYYMMDD</p>
      "! @parameter end_date | <p class="shorttext synchronized" lang="en">End Date</p>
      get_last_day_of_month IMPORTING date            TYPE datn
                            RETURNING VALUE(end_date) TYPE datn,

      get_group_configuration RETURNING VALUE(group) TYPE /esrcc/group,

      curr_internal_to_external
        IMPORTING
          currency        TYPE /esrcc/localcurr
          amount_internal TYPE /esrcc/hsl ##ADT_PARAMETER_UNTYPED
        EXPORTING
          amount_external TYPE /esrcc/hsl,

      curr_external_to_internal
        IMPORTING
          currency        TYPE /esrcc/localcurr
          amount_external TYPE /esrcc/hsl ##ADT_PARAMETER_UNTYPED
        EXPORTING
          amount_internal TYPE /esrcc/hsl,

      currency_conversion
        IMPORTING
          amount          TYPE /esrcc/hsl
          source_curr     TYPE /esrcc/localcurr
          target_curr     TYPE /esrcc/localcurr
          validon         TYPE /esrcc/validfrom
        EXPORTING
          convertedamount TYPE /esrcc/hsl,

      Check_Workflow_Active
        IMPORTING
          application TYPE /esrcc/application_type_de OPTIONAL
        EXPORTING
          wf_flag     TYPE abap_boolean.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_UTILITY_CORE IMPLEMENTATION.


  METHOD get_last_day_of_month.
    IF date IS NOT INITIAL.
      end_date = |{ date+0(6) }{ SWITCH #( date+4(2)
                                   WHEN 1  THEN 31
                                   WHEN 2  THEN COND #( WHEN date+0(4) MOD 4 EQ 0 THEN 29 ELSE 28 )
                                   WHEN 3  THEN 31
                                   WHEN 4  THEN 30
                                   WHEN 5  THEN 31
                                   WHEN 6  THEN 30
                                   WHEN 7  THEN 31
                                   WHEN 8  THEN 31
                                   WHEN 9  THEN 30
                                   WHEN 10 THEN 31
                                   WHEN 11 THEN 30
                                   WHEN 12 THEN 31 ) }|.
    ENDIF.
  ENDMETHOD.


  METHOD get_utc_date_time_ts.
    " Get timestamp value in the UTC format.
    GET TIME STAMP FIELD time_stamp.
    " Provide date and time interpreting the UTC timestamp for central use.
    CONVERT TIME STAMP time_stamp
    TIME ZONE 'UTC' INTO DATE date TIME time.
  ENDMETHOD.


  METHOD get_group_configuration.
    SELECT SINGLE * FROM /esrcc/group INTO @group.
  ENDMETHOD.


  METHOD check_workflow_active.

    IF application IS NOT INITIAL.

      SELECT SINGLE workflowactive FROM /esrcc/wf_switch WHERE application = @application INTO @wf_flag .

    ELSE.

      SELECT single workflowactive FROM /esrcc/wf_switch WHERE ( application = 'CBS' OR
                                           application = 'SCM' OR
                                           application = 'CHR' )
                                           AND workflowactive = @abap_true INTO @wf_flag.

    ENDIF.

  ENDMETHOD.


  METHOD currency_conversion.

    TRY.
        cl_exchange_rates=>convert_to_local_currency(
          EXPORTING
            date              = validon
            foreign_amount    = amount
            foreign_currency  = source_curr
            local_currency    = target_curr
*        rate              = 0
*        rate_type         = 'M'
*        do_read_tcurr     = abap_true
          IMPORTING
*        exchange_rate     =
*        foreign_factor    =
            local_amount      = convertedamount
*        local_factor      =
*        fixed_rate        =
*        derived_rate_type =
        ).
      CATCH cx_exchange_rates.
        "handle exception
    ENDTRY.

  ENDMETHOD.


  METHOD curr_external_to_internal.

    DATA shift TYPE i.
    DATA p_factor TYPE p DECIMALS 3.

    SELECT SINGLE decimals FROM i_currency WHERE currency = @currency INTO @DATA(decimals).
    IF sy-subrc = 0.
      shift = 2 - Decimals.
    ELSE.
      shift = 0.
    ENDIF.

    p_factor = 1.

    IF shift <> 0.
      DO shift TIMES.
        p_factor = p_factor * 10.
      ENDDO.
    ENDIF.

    IF p_factor <> 0.
      amount_internal = amount_external / p_factor.
    ELSE.
      amount_internal = amount_external.
    ENDIF.

  ENDMETHOD.


  METHOD curr_internal_to_external.

    DATA shift TYPE i.
    DATA amount_int TYPE  bapicurx-bapicurx.
    SELECT SINGLE decimals FROM i_currency WHERE currency = @currency INTO @DATA(decimals).
    IF sy-subrc = 0.
      shift = 2 - decimals.
    ELSE.
      shift = 0.
    ENDIF.

    amount_int = amount_internal.
    amount_external = 10 ** shift.
    amount_external = amount_external * amount_int.

  ENDMETHOD.
ENDCLASS.
