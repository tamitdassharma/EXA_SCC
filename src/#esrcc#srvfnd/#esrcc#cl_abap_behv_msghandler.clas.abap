CLASS /esrcc/cl_abap_behv_msghandler DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_path,
        path TYPE sxco_cds_association_name,
      END OF ts_path,

      BEGIN OF ts_field,
        fieldname TYPE abp_field_name,
        fieldtext TYPE string,
      END OF ts_field,

      BEGIN OF ts_authorized,
        create TYPE if_abap_behv=>t_xflag,
        update TYPE if_abap_behv=>t_xflag,
        delete TYPE if_abap_behv=>t_xflag,
      END OF ts_authorized,

      BEGIN OF ts_authorization_for,
        create          TYPE abap_boolean,
        update          TYPE abap_boolean,
        delete          TYPE abap_boolean,
        create_by_assoc TYPE abap_boolean,
      END OF ts_authorization_for,

      BEGIN OF ts_action,
        create TYPE abap_boolean,
        update TYPE abap_boolean,
        delete TYPE abap_boolean,
      END OF ts_action,

      tt_path TYPE STANDARD TABLE OF ts_path.

    METHODS constructor
      IMPORTING
        paths         TYPE tt_path OPTIONAL
        assoc_paths   TYPE tt_path OPTIONAL
        is_transition TYPE abap_boolean OPTIONAL.

    METHODS set_entities
      CHANGING
        reported_entity TYPE STANDARD TABLE
        failed_entity   TYPE STANDARD TABLE.

    METHODS set_message_for_field
      IMPORTING
        entity TYPE any
        field  TYPE ts_field OPTIONAL
        msg    TYPE REF TO if_abap_behv_message.

    METHODS set_state_area
      IMPORTING
        state_area TYPE string.

    METHODS set_first_flag
      IMPORTING
        is_first TYPE abap_boolean DEFAULT 'X'.

    METHODS authorize_instance
      IMPORTING
        key                   TYPE any
        set_authorization_for TYPE ts_authorization_for
        authorized            TYPE ts_authorized
      CHANGING
        result                TYPE STANDARD TABLE.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS c_singletonid TYPE abp_field_name VALUE 'SINGLETONID' ##NO_TEXT.

    DATA:
      gv_state_area    TYPE string,
      gv_is_transition TYPE abap_boolean,
      gv_first         TYPE abap_boolean,
      gs_field         TYPE ts_field,
      gs_action        TYPE ts_action,
      gt_paths         TYPE tt_path,
      gt_assoc_paths   TYPE tt_path,

      gr_reported      TYPE REF TO data,
      gr_failed        TYPE REF TO data.

    METHODS set_reported
      IMPORTING
        entity TYPE any
        msg    TYPE REF TO if_abap_behv_message.

    METHODS set_failed
      IMPORTING
        entity TYPE any.

    METHODS reset_state_area
      IMPORTING
        key_component TYPE abp_field_name
        key_value     TYPE any.

    METHODS set_path
      IMPORTING
        entity          TYPE any
      CHANGING
        reported_entity TYPE any.

    METHODS set_element_field_error
      CHANGING
        reported TYPE any.

    METHODS copy_key
      IMPORTING
        source      TYPE any
      CHANGING
        destination TYPE any.
ENDCLASS.



CLASS /ESRCC/CL_ABAP_BEHV_MSGHANDLER IMPLEMENTATION.


  METHOD authorize_instance.
    " Populate "result"
    APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<res>).

*    " Populate Key
*    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE key TO FIELD-SYMBOL(<tky>).
*    IF sy-subrc = 0.
*      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <res> TO FIELD-SYMBOL(<tky_r>).
*      IF sy-subrc = 0.
*        <tky_r> = CORRESPONDING #( <tky> ).
*      ENDIF.
*    ENDIF.
    " Populate Key
    copy_key(
      EXPORTING
        source      = key
      CHANGING
        destination = <res>
    ).

    IF <res> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    " Set create authorization
    IF set_authorization_for-create = abap_true.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-create OF STRUCTURE <res> TO FIELD-SYMBOL(<create>).
      IF sy-subrc = 0.
        <create> = authorized-create.
      ENDIF.
    ENDIF.

    " Set authorization status for 'association' (child entity)
    IF set_authorization_for-create_by_assoc = abap_true.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-assoc OF STRUCTURE <res> TO FIELD-SYMBOL(<assoc>).
      IF sy-subrc = 0.
        LOOP AT gt_paths INTO DATA(path).
          TRANSLATE path-path TO UPPER CASE.
          ASSIGN COMPONENT path-path OF STRUCTURE <assoc> TO FIELD-SYMBOL(<path>).
          IF sy-subrc = 0.
            <path> = authorized-create.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    " Set update authorization
    IF set_authorization_for-update = abap_true.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-update OF STRUCTURE <res> TO FIELD-SYMBOL(<update>).
      IF sy-subrc = 0.
        <update> = authorized-update.
      ENDIF.
    ENDIF.

    " Set delete authorization
    IF set_authorization_for-delete = abap_true.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-delete OF STRUCTURE <res> TO FIELD-SYMBOL(<delete>).
      IF sy-subrc = 0.
        <delete> = authorized-delete.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
    gt_paths = paths.
    gt_assoc_paths = assoc_paths.
    gv_is_transition = is_transition.
  ENDMETHOD.


  METHOD copy_key.
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE source TO FIELD-SYMBOL(<source>).
    IF sy-subrc = 0.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE destination TO FIELD-SYMBOL(<destination>).
      IF sy-subrc = 0.
        <destination> = CORRESPONDING #( <source> ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD reset_state_area.      " Reset error state area of previous messages
    FIELD-SYMBOLS <reported_entities> TYPE STANDARD TABLE.

    CHECK gv_first = abap_true AND gv_is_transition = abap_false.   " To be set only once
    CHECK key_component IS NOT INITIAL.

    ASSIGN gr_reported->* TO <reported_entities>.

    APPEND INITIAL LINE TO <reported_entities> ASSIGNING FIELD-SYMBOL(<reported_entity>).
    ASSIGN COMPONENT key_component OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<key_r>).
    IF sy-subrc = 0.
      <key_r> = key_value.
    ENDIF.

    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-state_area OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<state_area>).
    IF sy-subrc = 0.
      <state_area> = gv_state_area.
    ENDIF.

    CLEAR gv_first.
  ENDMETHOD.


  METHOD set_element_field_error.       " Set error on field
    IF gs_field-fieldname IS INITIAL OR gv_is_transition = abap_true.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-element OF STRUCTURE reported TO FIELD-SYMBOL(<elements>).
    IF sy-subrc = 0.
      ASSIGN COMPONENT gs_field-fieldname OF STRUCTURE <elements> TO FIELD-SYMBOL(<field>).
      IF sy-subrc = 0.
        <field> = if_abap_behv=>mk-on.      " Mark on
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_entities.
    me->gr_reported = REF #( reported_entity ).
    me->gr_failed = REF #( failed_entity ).
  ENDMETHOD.


  METHOD set_failed.    " Set failed entity
    FIELD-SYMBOLS <failed_entities> TYPE STANDARD TABLE.

*   Get key values
    DATA(key_component) = cl_abap_behv=>co_techfield_name-tky.
    ASSIGN COMPONENT key_component OF STRUCTURE entity TO FIELD-SYMBOL(<key_value>).
    IF sy-subrc <> 0.
      key_component = cl_abap_behv=>co_techfield_name-cid.
      ASSIGN COMPONENT key_component OF STRUCTURE entity TO <key_value>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

    ASSIGN gr_failed->* TO <failed_entities>.
    APPEND INITIAL LINE TO <failed_entities> ASSIGNING FIELD-SYMBOL(<failed>).
    ASSIGN COMPONENT key_component OF STRUCTURE <failed> TO FIELD-SYMBOL(<tky_f>).
    IF sy-subrc = 0.
      <tky_f> = <key_value>.
    ENDIF.
  ENDMETHOD.


  METHOD set_first_flag.
    gv_first = is_first.
  ENDMETHOD.


  METHOD set_message_for_field.
    gs_field = field.

*   Set reported entity with message
    set_reported(
      entity = entity
      msg    = msg
    ).

*   Set failed entity
    IF msg IS BOUND.
      set_failed( entity = entity ).
    ENDIF.
  ENDMETHOD.


  METHOD set_path.      " Populate path data for navigation from message
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-path OF STRUCTURE reported_entity TO FIELD-SYMBOL(<path>).
    IF sy-subrc = 0.
      LOOP AT gt_paths INTO DATA(path).
        TRANSLATE path-path TO UPPER CASE.
        ASSIGN COMPONENT path-path OF STRUCTURE <path> TO FIELD-SYMBOL(<path_entity>).
        IF sy-subrc = 0.
          <path_entity> = CORRESPONDING #( entity ).

          ASSIGN COMPONENT c_singletonid OF STRUCTURE <path_entity> TO FIELD-SYMBOL(<singletonid>).
          IF sy-subrc = 0 AND <singletonid> IS INITIAL.
            ASSIGN COMPONENT c_singletonid OF STRUCTURE entity TO FIELD-SYMBOL(<singletonid_entity>).
            IF sy-subrc = 0.
              <singletonid> = <singletonid_entity>.
            ELSE.
              <singletonid> = 1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD set_reported.
    FIELD-SYMBOLS <reported_entities> TYPE STANDARD TABLE.

*   Get key values
    DATA(key_component) = cl_abap_behv=>co_techfield_name-tky.
    ASSIGN COMPONENT key_component OF STRUCTURE entity TO FIELD-SYMBOL(<key_value>).
    IF sy-subrc <> 0.
      key_component = cl_abap_behv=>co_techfield_name-cid.
      ASSIGN COMPONENT key_component OF STRUCTURE entity TO <key_value>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

*   Reset previous messages
    reset_state_area( EXPORTING key_component = key_component key_value = <key_value> ).

    IF msg IS NOT BOUND.
      RETURN.
    ENDIF.

*   Set key value
    ASSIGN gr_reported->* TO <reported_entities>.
    APPEND INITIAL LINE TO <reported_entities> ASSIGNING FIELD-SYMBOL(<reported_entity>).
    ASSIGN COMPONENT key_component OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<key_r>).
    IF sy-subrc = 0.
      <key_r> = <key_value>.
    ENDIF.

*   Set message
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-msg OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<msg>).
    IF sy-subrc = 0.
      <msg> = msg.
    ENDIF.

*   Set state area for message
    IF gv_is_transition = abap_false.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-state_area OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<state_area>).
      IF sy-subrc = 0.
        <state_area> = gv_state_area.
      ENDIF.
    ENDIF.

*   Set path information (Association)
    set_path(
      EXPORTING
        entity          = entity
      CHANGING
        reported_entity = <reported_entity>
    ).

*   Set error on field
    set_element_field_error( CHANGING reported = <reported_entity> ).
  ENDMETHOD.


  METHOD set_state_area.
    gv_state_area = state_area.
  ENDMETHOD.
ENDCLASS.
