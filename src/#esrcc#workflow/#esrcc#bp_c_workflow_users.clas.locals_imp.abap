CLASS lhc_C_WORKFLOW_USERS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_workflow_users RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_workflow_users RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_workflow_users.

    METHODS next_approver_level FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_workflow_users~next_approver_level RESULT result.

    METHODS previous_approver_level FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_workflow_users~previous_approver_level RESULT result.
    METHODS initial_approver_level FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_workflow_users~initial_approver_level RESULT result.

ENDCLASS.

CLASS lhc_C_WORKFLOW_USERS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD next_approver_level.

    DATA ls_data type /esrcc/c_workflow_users.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING <key> to ls_data.

      /esrcc/cl_workflow_bpa_api=>determine_next_approver(
        EXPORTING
          parameters    = CORRESPONDING #( <key> )
        IMPORTING
          next_approver = ls_data-approval_level
      ).

      result = VALUE #( (  %param = CORRESPONDING #( ls_data )
                            %key = CORRESPONDING #( <key> ) ) ).
    ENDIF.

  ENDMETHOD.

  METHOD previous_approver_level.

    DATA ls_data type /esrcc/c_workflow_users.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

      MOVE-CORRESPONDING <key> to ls_data.

      /esrcc/cl_workflow_bpa_api=>determine_previous_approver(
        EXPORTING
          parameters    = CORRESPONDING #( <key> )
        IMPORTING
          previous_approver = ls_data-approval_level
      ).

      result = VALUE #( (  %param = CORRESPONDING #( ls_data )
                            %key = CORRESPONDING #( <key> ) ) ).
    ENDIF.

  ENDMETHOD.

  METHOD initial_approver_level.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

    ENDIF.

    result = VALUE #( (  %cid = <key>-%cid
                         %param-approval_level = '01' ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_C_WORKFLOW_USERS DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_C_WORKFLOW_USERS IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
