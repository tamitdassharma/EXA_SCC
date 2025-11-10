CLASS /esrcc/cl_config_msg_handler DEFINITION
INHERITING FROM /esrcc/cl_abap_behv_msghandler
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      duplicate_key
        RETURNING
          VALUE(msg) TYPE REF TO if_abap_behv_message,

      inform_on_action
        RETURNING
          VALUE(msg) TYPE REF TO if_abap_behv_message,

      inform_on_sync
        RETURNING
          VALUE(msg) TYPE REF TO if_abap_behv_message,

      no_entry_for_costobj
        RETURNING
          VALUE(msg) TYPE REF TO if_abap_behv_message,

      duplicate_cost_element
        IMPORTING
          v1         TYPE simple
        RETURNING
          VALUE(msg) TYPE REF TO if_abap_behv_message,

      same_sender_receiver
        RETURNING
          VALUE(msg) TYPE REF TO if_abap_behv_message.

    METHODS background_job_scheduled
      IMPORTING
        v1         TYPE simple
      RETURNING
        VALUE(msg) TYPE REF TO if_abap_behv_message.


  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS c_config_msg TYPE symsgid VALUE '/ESRCC/CONFIG_MSG' ##NO_TEXT.
ENDCLASS.



CLASS /esrcc/cl_config_msg_handler IMPLEMENTATION.
  METHOD duplicate_key.
    msg = NEW cl_abap_behv( )->new_message(
                               id       = c_config_msg
                               number   = '023'
                               severity = if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD inform_on_action.
    msg = NEW cl_abap_behv( )->new_message(
                              id       = c_config_msg
                              number   = '028'
                              severity = if_abap_behv_message=>severity-success ).
  ENDMETHOD.


  METHOD inform_on_sync.
    msg = NEW cl_abap_behv( )->new_message(
                              id       = c_config_msg
                              number   = '033'
                              severity = if_abap_behv_message=>severity-success ).
  ENDMETHOD.


  METHOD no_entry_for_costobj.
    msg = NEW cl_abap_behv( )->new_message(
                               id       = c_config_msg
                               number   = '029'
                               severity = if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD duplicate_cost_element.
    msg = NEW cl_abap_behv( )->new_message(
                               id       = /esrcc/cl_config_util=>c_config_msg
                               number   = '030'
                               severity = if_abap_behv_message=>severity-error
                               v1       = v1 ).
  ENDMETHOD.

  METHOD same_sender_receiver.
    msg = NEW cl_abap_behv( )->new_message(
                               id       = /esrcc/cl_config_util=>c_config_msg
                               number   = '026'
                               severity = if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD background_job_scheduled.
    msg = NEW cl_abap_behv( )->new_message(
                               id       = /esrcc/cl_config_util=>c_config_msg
                               number   = '034'
                               severity = if_abap_behv_message=>severity-information
                               v1       = v1 ).
  ENDMETHOD.

ENDCLASS.
