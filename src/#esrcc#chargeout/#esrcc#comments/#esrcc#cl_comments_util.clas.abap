CLASS /esrcc/cl_comments_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS modify_comments
      IMPORTING
        !comments    TYPE /esrcc/comments
        !iv_comments TYPE /esrcc/comment.

    CLASS-METHODS read_comments
      IMPORTING
        !instanceid  TYPE /esrcc/commentid OPTIONAL
        !workflowid  TYPE /esrcc/sww_wiid OPTIONAL
        !taskid      TYPE string OPTIONAL
      EXPORTING
        !commenttext TYPE string
        !comments    TYPE /esrcc/tt_comment.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_COMMENTS_UTIL IMPLEMENTATION.


  METHOD modify_comments.

    DATA _comments TYPE /esrcc/comments.

    MOVE-CORRESPONDING comments TO _comments.

    _comments-created_by = sy-uname.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = _comments-created_at
    ).

    _comments-wfcomment = xco_cp=>string( iv_comments
      )->as_xstring( xco_cp_character=>code_page->utf_8
      )->value.

    cl_uuid_factory=>create_system_uuid(
      RECEIVING
        generator = DATA(lo_uuid)
    ).

    TRY.
        _comments-id = lo_uuid->create_uuid_c32( ).
      CATCH cx_uuid_error.
    ENDTRY.

    MODIFY /esrcc/comments FROM @_comments.

  ENDMETHOD.


  METHOD read_comments.

    IF taskid IS INITIAL.
      SELECT * FROM /esrcc/comments WHERE instanceid = @instanceid
                                    ORDER BY created_at DESCENDING
                                    INTO CORRESPONDING FIELDS OF TABLE @comments.

    ELSE.
      SELECT * FROM /esrcc/comments WHERE instanceid = @instanceid
                                      AND taskid = @taskid
                                    ORDER BY created_at DESCENDING
                                    INTO CORRESPONDING FIELDS OF TABLE @comments.
    ENDIF.

    LOOP AT comments ASSIGNING FIELD-SYMBOL(<comment>).

      <comment>-wfcommenttext = xco_cp=>xstring( <comment>-wfcomment
        )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
