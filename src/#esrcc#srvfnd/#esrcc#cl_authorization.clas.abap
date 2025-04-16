CLASS /esrcc/cl_authorization DEFINITION
  PUBLIC
  INHERITING FROM /esrcc/cl_abap_behv_msghandler
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      c_config_msg       TYPE symsgid VALUE '/ESRCC/CONFIG_MSG' ##NO_TEXT,
      c_no_authorization TYPE string VALUE 'NO_AUTHORIZATION',

      BEGIN OF c_authorization_activity,
        create  TYPE activ_auth VALUE '01',
        change  TYPE activ_auth VALUE '02',
        display TYPE activ_auth VALUE '03',
        delete  TYPE activ_auth VALUE '06',
        execute TYPE activ_auth VALUE '16',
      END OF c_authorization_activity.

    TYPES:
      BEGIN OF ts_field_mapping_auth,
        legal_entity TYPE abp_field_name,
        cost_object  TYPE abp_field_name,
        cost_number  TYPE abp_field_name,
      END OF ts_field_mapping_auth.

    TYPES:
      BEGIN OF ts_auth_value,
        legal_entity TYPE /esrcc/legalentity,
        cost_object  TYPE /esrcc/costobject_de,
        cost_number  TYPE /esrcc/costcenter,
      END OF ts_auth_value.

    METHODS constructor
      IMPORTING
        paths              TYPE tt_path OPTIONAL
        source_entity_name TYPE sxco_cds_object_name OPTIONAL.

    CLASS-METHODS
      create
        IMPORTING
          paths              TYPE tt_path OPTIONAL
          source_entity_name TYPE sxco_cds_object_name
        CHANGING
          reported_entity    TYPE STANDARD TABLE
          failed_entity      TYPE STANDARD TABLE
        RETURNING
          VALUE(instance)    TYPE REF TO /esrcc/cl_authorization.

    METHODS check_authorization
      IMPORTING
        entity               TYPE any
        auth_value           TYPE ts_auth_value
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.

    METHODS set_authorization_for_instance
      IMPORTING
        key                   TYPE any
        set_authorization_for TYPE ts_authorization_for
        auth_value            TYPE ts_auth_value
      CHANGING
        result                TYPE STANDARD TABLE OPTIONAL
      RETURNING
        VALUE(is_authorized)  TYPE abap_boolean.

    METHODS is_unauthorized
      IMPORTING
        auth_value             TYPE ts_auth_value
        create                 TYPE abap_boolean
        update                 TYPE abap_boolean
        delete                 TYPE abap_boolean
      RETURNING
        VALUE(is_unauthorized) TYPE abap_boolean.

    METHODS regulate_action_submit
      IMPORTING
        is_draft            TYPE abp_behv_flag OPTIONAL
        wf_status           TYPE /esrcc/status_de
      RETURNING
        VALUE(is_regulated) TYPE if_abap_behv=>t_xflag.

    METHODS regulate_action_finalize
      IMPORTING
        is_draft            TYPE abp_behv_flag OPTIONAL
        wf_status           TYPE /esrcc/status_de
      RETURNING
        VALUE(is_regulated) TYPE if_abap_behv=>t_xflag.

    METHODS regulate_action_reopen
      IMPORTING
        is_draft            TYPE abp_behv_flag OPTIONAL
        wf_status           TYPE /esrcc/status_de
      RETURNING
        VALUE(is_regulated) TYPE if_abap_behv=>t_xflag.

    METHODS regulate_action_update
      IMPORTING
        is_draft            TYPE abp_behv_flag OPTIONAL
        wf_status           TYPE /esrcc/status_de
      RETURNING
        VALUE(is_regulated) TYPE if_abap_behv=>t_xflag.

    METHODS regulate_action_delete
      IMPORTING
        is_draft            TYPE abp_behv_flag OPTIONAL
        wf_status           TYPE /esrcc/status_de
      RETURNING
        VALUE(is_regulated) TYPE if_abap_behv=>t_xflag.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ts_authorized_list,
        auth_value TYPE ts_auth_value,
        create     TYPE if_abap_behv=>t_xflag,
        update     TYPE if_abap_behv=>t_xflag,
        delete     TYPE if_abap_behv=>t_xflag,
      END OF ts_authorized_list.

    DATA:
      go_abap_dictionary    TYPE REF TO /esrcc/cl_abap_dictionary,
      gv_source_entity_name TYPE sxco_cds_object_name,
      gt_wf_submit          TYPE /esrcc/cl_wf_utility=>tt_workflow_status,
      gt_wf_finalize        TYPE /esrcc/cl_wf_utility=>tt_workflow_status,
      gt_wf_reopen          TYPE /esrcc/cl_wf_utility=>tt_workflow_status,
      gt_wf_update          TYPE /esrcc/cl_wf_utility=>tt_workflow_status,
      gt_wf_delete          TYPE /esrcc/cl_wf_utility=>tt_workflow_status,
      gt_authorized_list    TYPE SORTED TABLE OF ts_authorized_list WITH NON-UNIQUE DEFAULT KEY.

    METHODS is_authorized
      IMPORTING
        legal_entity_flag    TYPE abap_boolean
        cost_object_flag     TYPE abap_boolean
        cost_number_flag     TYPE abap_boolean
        auth_value           TYPE ts_auth_value
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE if_abap_behv=>t_xflag.

    METHODS check_auth_legal_entity
      IMPORTING
        legal_entity         TYPE /esrcc/legalentity
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.

    METHODS check_auth_cost_object
      IMPORTING
        cost_object          TYPE /esrcc/costobject_de
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.

    METHODS check_auth_cost_number
      IMPORTING
        cost_object          TYPE /esrcc/costobject_de
        cost_number          TYPE /esrcc/costcenter
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.

    METHODS check_auth_reopen
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.

    METHODS derive_field_label
      IMPORTING
        legal_entity       TYPE /esrcc/legalentity OPTIONAL
        cost_object        TYPE /esrcc/costobject_de OPTIONAL
        cost_number        TYPE /esrcc/costcenter OPTIONAL
      EXPORTING
        legal_entity_label TYPE string
        cost_object_label  TYPE string
        cost_number_label  TYPE string.

    METHODS determine_regulation_state
      IMPORTING
        is_draft            TYPE if_abap_behv=>t_xflag
        wf_status           TYPE /esrcc/status_de
        wf_status_allowed   TYPE /esrcc/cl_wf_utility=>tt_workflow_status
      RETURNING
        VALUE(is_regulated) TYPE if_abap_behv=>t_xflag.
ENDCLASS.



CLASS /ESRCC/CL_AUTHORIZATION IMPLEMENTATION.


  METHOD check_authorization. " Check authorization and set error message
    " Set message number according to requested activity
    DATA(msg_no) = SWITCH symsgno( activity WHEN c_authorization_activity-create THEN '016'
                                            WHEN c_authorization_activity-change THEN '017'
                                            WHEN c_authorization_activity-delete THEN '018' ).

    " Read authorization from buffer list
    DATA(list) = VALUE #( gt_authorized_list[ auth_value = auth_value ] OPTIONAL ).
    IF list IS NOT INITIAL.
      DATA(authorized_status) = SWITCH #( activity WHEN c_authorization_activity-create THEN list-create
                                                   WHEN c_authorization_activity-change THEN list-update
                                                   WHEN c_authorization_activity-delete THEN list-delete ).
    ENDIF.

    " Legal Entity
    IF auth_value-legal_entity IS NOT INITIAL.
      is_authorized = COND #( WHEN list IS INITIAL THEN check_auth_legal_entity( legal_entity = auth_value-legal_entity activity = activity )
                                                   ELSE SWITCH #( authorized_status WHEN if_abap_behv=>auth-allowed THEN abap_true ELSE abap_false ) ).
      IF is_authorized = abap_false.
        derive_field_label(
            EXPORTING
              legal_entity = auth_value-legal_entity
            IMPORTING
              legal_entity_label = DATA(legal_entity_label) ).

        DATA(v1) = |{ legal_entity_label }: { auth_value-legal_entity }|.
      ENDIF.
    ELSE.
      is_authorized = abap_true.    " Authorize legal entity, required for next step
    ENDIF.

    " Cost Object & Cost Number
    IF auth_value-cost_object IS NOT INITIAL AND is_authorized = abap_true.   " If Cost Object is associated with Legal Entity, first Legal Entity should be authorized
      SELECT SINGLE text FROM /esrcc/i_costobjects WHERE costobject = @auth_value-cost_object INTO @DATA(cost_object_desc).

      " Cost Object & Cost Number (Cost Number always associated with Cost Object)
      IF auth_value-cost_number IS NOT INITIAL.
        is_authorized = COND #( WHEN list IS INITIAL THEN check_auth_cost_number( cost_object = auth_value-cost_object cost_number = auth_value-cost_number activity = activity )
                                                     ELSE SWITCH #( authorized_status WHEN if_abap_behv=>auth-allowed THEN abap_true ELSE abap_false ) ).
        IF is_authorized = abap_false.
          derive_field_label(
            EXPORTING
              cost_object = auth_value-cost_object
              cost_number = auth_value-cost_number
            IMPORTING
              cost_object_label = DATA(cost_object_label)
              cost_number_label = DATA(cost_number_label) ).

          v1 = |{ cost_object_label }: { cost_object_desc }, { cost_number_label }: { auth_value-cost_number }|.
        ENDIF.
      ELSE.
        " Cost Object
        is_authorized = COND #( WHEN list IS INITIAL THEN check_auth_cost_object( cost_object = auth_value-cost_object activity = activity )
                                                     ELSE SWITCH #( authorized_status WHEN if_abap_behv=>auth-allowed THEN abap_true ELSE abap_false ) ).
        IF is_authorized = abap_false.
          derive_field_label(
            EXPORTING
              cost_object = auth_value-cost_object
            IMPORTING
              cost_object_label = cost_object_label ).

          v1 = |{ cost_object_label }: { cost_object_desc }|.
        ENDIF.
      ENDIF.
    ENDIF.

    " No authorization, set error message
    IF is_authorized = abap_false.
      set_state_area( state_area = c_no_authorization ).
      set_first_flag( ).
      set_message_for_field(
        entity = entity
        msg    = new_message( id = c_config_msg number = msg_no severity = if_abap_behv_message=>severity-error v1 = v1 )
      ).
    ENDIF.

    " Buffer the data
    IF list IS INITIAL.
      INSERT VALUE #( auth_value = auth_value
                      create = COND #( WHEN activity = c_authorization_activity-create THEN authorized_status )
                      update = COND #( WHEN activity = c_authorization_activity-change THEN authorized_status )
                      delete = COND #( WHEN activity = c_authorization_activity-delete THEN authorized_status ) ) INTO TABLE gt_authorized_list.
    ENDIF.
  ENDMETHOD.


  METHOD check_auth_cost_number.
    AUTHORITY-CHECK OBJECT '/ESRCC/CO'
    ID '/ESRCC/OBJ' FIELD cost_object
    ID '/ESRCC/CN'  FIELD cost_number
    ID 'ACTVT'      FIELD activity.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD check_auth_cost_object.
    AUTHORITY-CHECK OBJECT '/ESRCC/CO'      ##AUTH_FLD_MISSING
    ID '/ESRCC/OBJ' FIELD cost_object
    ID 'ACTVT'      FIELD activity.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD check_auth_legal_entity.
    AUTHORITY-CHECK OBJECT '/ESRCC/LE'
    ID '/ESRCC/LE' FIELD legal_entity
    ID 'ACTVT'     FIELD activity.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD check_auth_reopen.
    AUTHORITY-CHECK OBJECT '/ESRCC/SPC'
    ID 'ACTVT' FIELD '16'.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD constructor.
    super->constructor( paths = paths ).
    gv_source_entity_name = source_entity_name.
  ENDMETHOD.


  METHOD create.
    instance = NEW /esrcc/cl_authorization(
          paths              = paths
          source_entity_name = source_entity_name
      ).

    instance->set_entities(
      CHANGING
        reported_entity = reported_entity
        failed_entity   = failed_entity
    ).
  ENDMETHOD.


  METHOD derive_field_label.
    IF go_abap_dictionary IS NOT BOUND.
      go_abap_dictionary = NEW /esrcc/cl_abap_dictionary( iv_entity_name = gv_source_entity_name ).
    ENDIF.

    IF legal_entity IS SUPPLIED.
      legal_entity_label = go_abap_dictionary->derive_field_label(
                    iv_data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = legal_entity ) )
                    iv_field_name   = 'LEGALENTITY'
                  ).
    ENDIF.

    IF cost_object IS SUPPLIED.
      cost_object_label = go_abap_dictionary->derive_field_label(
                    iv_data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = cost_object ) )
                    iv_field_name   = 'COSTOBJECT'
                  ).
    ENDIF.

    IF cost_number IS SUPPLIED.
      cost_number_label = go_abap_dictionary->derive_field_label(
                    iv_data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = cost_number ) )
                    iv_field_name   = 'COSTCENTER'
                  ).
    ENDIF.
  ENDMETHOD.


  METHOD determine_regulation_state.
    is_regulated = COND #( WHEN is_draft = if_abap_behv=>mk-on AND wf_status IN wf_status_allowed
                              THEN if_abap_behv=>fc-o-enabled
                           ELSE if_abap_behv=>fc-o-disabled ).
  ENDMETHOD.


  METHOD is_authorized.
    " LEGAL_ENTITY_FLAG (LE): True, if Legal Entity to be checked
    " COST_OBJECT_FLAG (CO):  True, if Cost Object to be checked
    " COST_NUMBER_FLAG (CN):  True, if Cost Number to be checked
    " LE = 'X', CO = '',  CN = ''  => Auth check only LE
    " LE = '',  CO = 'X', CN = ''  => Auth check only CO
    " LE = '',  CO = 'X', CN = 'X' => Auth check CO & CN combination
    " LE = 'X', CO = 'X', CN = ''  => Auth check LE, if authorized, auth check CO
    " LE = 'X', CO = 'X', CN = 'X' => Auth check LE, if authorized, auth check CO & CN combination

    is_authorized = SWITCH #( COND abap_boolean( WHEN ( legal_entity_flag = abap_true AND check_auth_legal_entity( legal_entity = auth_value-legal_entity activity = activity ) = abap_true ) OR   " Auth check LE
                                                        legal_entity_flag = abap_false    " No auth check required for LE
                                                 THEN COND #( WHEN cost_object_flag = abap_true AND cost_number_flag = abap_true    " Auth check CO & CN
                                                                 THEN check_auth_cost_number( cost_object = auth_value-cost_object cost_number = auth_value-cost_number activity = activity )   " Auth status of CO & CN
                                                              WHEN cost_object_flag = abap_true AND cost_number_flag = abap_false   " Auth check CO
                                                                 THEN check_auth_cost_object( cost_object = auth_value-cost_object activity = activity )   " Auth status of CO
                                                              ELSE abap_true )  " Authorized LE
                                                  ELSE abap_false )             " Unauthorized LE
                              WHEN abap_true THEN if_abap_behv=>auth-allowed    " Authorized LE or CO or CO/CN
                              ELSE if_abap_behv=>auth-unauthorized ).           " Unauthorized LE or CO or CO/CN
  ENDMETHOD.


  METHOD is_unauthorized.
    " Check if entry is authorized
    DATA(is_authorized) = set_authorization_for_instance(
                            EXPORTING
                              key                   = VALUE ts_authorized_list( auth_value = auth_value )
                              set_authorization_for = VALUE #( create = abap_true update = abap_true delete = abap_true )
                              auth_value            = auth_value
                          ).

    is_unauthorized = SWITCH #( is_authorized WHEN abap_true THEN abap_false ELSE abap_true ).
  ENDMETHOD.


  METHOD regulate_action_delete.
    IF gt_wf_delete IS INITIAL.
      gt_wf_delete = /esrcc/cl_wf_utility=>wf_status_action_delete( ).
    ENDIF.

    is_regulated = determine_regulation_state(
                     is_draft          = COND #( WHEN is_draft IS SUPPLIED THEN is_draft ELSE if_abap_behv=>mk-on )
                     wf_status         = wf_status
                     wf_status_allowed = gt_wf_delete
                   ).
  ENDMETHOD.


  METHOD regulate_action_finalize.
    IF gt_wf_finalize IS INITIAL.
      gt_wf_finalize = /esrcc/cl_wf_utility=>wf_status_action_finalize( ).
    ENDIF.

    is_regulated = determine_regulation_state(
                     is_draft          = COND #( WHEN is_draft IS SUPPLIED THEN is_draft ELSE if_abap_behv=>mk-on )
                     wf_status         = wf_status
                     wf_status_allowed = gt_wf_finalize
                   ).
  ENDMETHOD.


  METHOD regulate_action_reopen.
    IF gt_wf_reopen IS INITIAL.
      gt_wf_reopen = /esrcc/cl_wf_utility=>wf_status_action_reopen( ).
    ENDIF.

    check_auth_reopen( ).

    is_regulated = COND #( WHEN check_auth_reopen( ) = abap_false THEN if_abap_behv=>auth-unauthorized
                           ELSE determine_regulation_state(
                                  is_draft          = COND #( WHEN is_draft IS SUPPLIED THEN is_draft ELSE if_abap_behv=>mk-on )
                                  wf_status         = wf_status
                                  wf_status_allowed = gt_wf_reopen
                                ) ).
  ENDMETHOD.


  METHOD regulate_action_submit.
    IF gt_wf_submit IS INITIAL.
      gt_wf_submit = /esrcc/cl_wf_utility=>wf_status_action_submit( ).
    ENDIF.

    is_regulated = determine_regulation_state(
                     is_draft          = COND #( WHEN is_draft IS SUPPLIED THEN is_draft ELSE if_abap_behv=>mk-on )
                     wf_status         = wf_status
                     wf_status_allowed = gt_wf_submit
                   ).
  ENDMETHOD.


  METHOD regulate_action_update.
    IF gt_wf_update IS INITIAL.
      gt_wf_update = /esrcc/cl_wf_utility=>wf_status_action_update( ).
    ENDIF.

    is_regulated = determine_regulation_state(
                     is_draft          = COND #( WHEN is_draft IS SUPPLIED THEN is_draft ELSE if_abap_behv=>mk-on )
                     wf_status         = wf_status
                     wf_status_allowed = gt_wf_update
                   ).
  ENDMETHOD.


  METHOD set_authorization_for_instance.
*   This method is usually called from Instance Method from Behavior Definition Class
*   Sets if instance is authorize
    IF set_authorization_for IS INITIAL OR auth_value IS INITIAL.
      RETURN.
    ENDIF.

    " If object is already validated, read from buffer
    DATA(authorized) = VALUE #( gt_authorized_list[ auth_value = auth_value ] OPTIONAL ).
    IF authorized IS INITIAL.
      DATA(auth_check_not_performed) = abap_true.
      authorized = VALUE #( auth_value = auth_value ).
    ELSE.
      auth_check_not_performed = abap_false.

      DATA(legal_entity_flag) = COND #( WHEN auth_value-legal_entity IS NOT INITIAL THEN abap_true ELSE abap_false ).
      DATA(cost_object_flag)  = COND #( WHEN auth_value-cost_object  IS NOT INITIAL THEN abap_true ELSE abap_false ).
      DATA(cost_number_flag)  = COND #( WHEN auth_value-cost_number  IS NOT INITIAL THEN abap_true ELSE abap_false ).
    ENDIF.

    IF auth_check_not_performed = abap_true.
      " Authorization check for 'Create' Activity
      IF set_authorization_for-create = abap_true OR set_authorization_for-create_by_assoc = abap_true.
        authorized-create = is_authorized(
          EXPORTING
            legal_entity_flag = legal_entity_flag
            cost_object_flag  = cost_object_flag
            cost_number_flag  = cost_number_flag
            auth_value        = auth_value
            activity          = c_authorization_activity-create ).
      ENDIF.

      " Authorization check for 'Change' Activity
      IF set_authorization_for-update = abap_true.
        authorized-update = is_authorized(
          EXPORTING
            legal_entity_flag = legal_entity_flag
            cost_object_flag  = cost_object_flag
            cost_number_flag  = cost_number_flag
            auth_value        = auth_value
            activity          = c_authorization_activity-change ).
      ENDIF.

      " Authorization check for 'Delete' Activity
      IF set_authorization_for-delete = abap_true.
        authorized-delete = is_authorized(
          EXPORTING
            legal_entity_flag = legal_entity_flag
            cost_object_flag  = cost_object_flag
            cost_number_flag  = cost_number_flag
            auth_value        = auth_value
            activity          = c_authorization_activity-delete ).
      ENDIF.
    ENDIF.

*   Set instance authorization
    authorize_instance(
      EXPORTING
        key                   = key
        set_authorization_for = set_authorization_for
        authorized            = CORRESPONDING #( authorized )
      CHANGING
        result                = result
    ).

    " Buffer the data
    IF auth_check_not_performed = abap_true.
      INSERT authorized INTO TABLE gt_authorized_list.
    ENDIF.

    " Return authorization status
    is_authorized = COND #( WHEN authorized-create = if_abap_behv=>auth-unauthorized OR authorized-update = if_abap_behv=>auth-unauthorized OR authorized-delete = if_abap_behv=>auth-unauthorized THEN abap_false ELSE abap_true ).
  ENDMETHOD.
ENDCLASS.
