CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_usergrp             TYPE STRUCTURE FOR READ RESULT /esrcc/i_wfusrg_s\\usergroup,
      ts_user_mapping        TYPE STRUCTURE FOR READ RESULT /esrcc/i_wfusrg_s\\usermapping,
      tt_usergrp_create      TYPE TABLE FOR CREATE /esrcc/i_wfusrg_s\\usergroupall\_usergroup,
      tt_user_mapping_create TYPE TABLE FOR CREATE /esrcc/i_wfusrg_s\\usergroup\_usermapping,

      BEGIN OF ts_control_usergroup,
        usergroup TYPE if_abap_behv=>t_xflag,
      END OF ts_control_usergroup,

      BEGIN OF ts_control_user_mapping,
        userid TYPE if_abap_behv=>t_xflag,
      END OF ts_control_user_mapping.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_user_group
        IMPORTING
          entity  TYPE ts_usergrp
          control TYPE ts_control_usergroup,

      validate_user_mapping
        IMPORTING
          entity  TYPE ts_user_mapping
          control TYPE ts_control_user_mapping.

    CLASS-METHODS:
      precheck_cba_user_group
        IMPORTING
          entities TYPE tt_usergrp_create
        CHANGING
          reported TYPE any
          failed   TYPE any,

      precheck_cba_user_mapping
        IMPORTING
          entities TYPE tt_user_mapping_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_user_group.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-usergroup = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'USERGROUP' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.


  METHOD validate_user_mapping.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-userid = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'USERID' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_user_group.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'UserGroupAll' ) )
        source_entity_name = '/ESRCC/C_WFUSRG'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_user_group(
          entity  = CORRESPONDING #( target )
          control = VALUE #( usergroup = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_user_mapping.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'UserGroupAll' )
                                      ( path = 'UserGroup' ) )
        source_entity_name = '/ESRCC/C_WFUSRM'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_user_mapping(
          entity  = CORRESPONDING #( target )
          control = VALUE #( userid = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.
CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/WFUSRG'
                                       table_entity_relations = VALUE #( ( entity = 'UserGroup' table = '/ESRCC/WFUSRG' )
                                                                         ( entity = 'UserMapping' table = '/ESRCC/WFUSRM' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_usermapping DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR usermapping RESULT result.
    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR usermapping~validatetransportrequest.
ENDCLASS.

CLASS lhc_usermapping IMPLEMENTATION.

  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_wfusrg_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_wfusr_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/WFUSRM'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-usermapping ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_/esrcc/i_wfusrg_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR usergroupall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR usergroupall
        RESULT result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION usergroupall~selectcustomizingtransptreq RESULT result,
      precheck_cba_usergroup FOR PRECHECK
        IMPORTING entities FOR CREATE usergroupall\_usergroup.
ENDCLASS.

CLASS lhc_/esrcc/i_wfusrg_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_wfusrg_s IN LOCAL MODE
    ENTITY usergroupall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_usergroup = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_WFUSRG' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_wfusrg_s IN LOCAL MODE
      ENTITY usergroupall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_wfusrg_s IN LOCAL MODE
      ENTITY usergroupall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

  METHOD precheck_cba_usergroup.
    lcl_custom_validation=>precheck_cba_user_group(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-usergroup
        reported = reported-usergroup ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_wfusrg_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_wfusrg_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-usergroupall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_wfusrg DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR usergroup
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR usergroup RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR usergroup RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION usergroup~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR usergroup~validatetransportrequest.
    METHODS precheck_cba_usermapping FOR PRECHECK
      IMPORTING entities FOR CREATE usergroup\_usermapping.
ENDCLASS.

CLASS lhc_/esrcc/i_wfusrg IMPLEMENTATION.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_WFUSRG' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main    TYPE TABLE FOR CREATE /esrcc/i_wfusrg_s\_usergroup,
      new_usr_map TYPE TABLE FOR CREATE /esrcc/i_wfusrg_s\\usergroup\_usermapping.

    FIELD-SYMBOLS <new_usr_map> LIKE LINE OF new_usr_map.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-usergroup = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_wfusrg_s IN LOCAL MODE
      ENTITY usergroup
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_wfusrg_s IN LOCAL MODE
      ENTITY usergroup BY \_usermapping
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_usr_map).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid      = key_cid
                             %is_draft = <ref_main>-%is_draft
                             %data     = CORRESPONDING #( <ref_main> EXCEPT usergroup singletonid )
                             usergroup = key-%param-usergroup ) ) ) TO new_main.

      UNASSIGN <new_usr_map>.
      LOOP AT ref_usr_map ASSIGNING FIELD-SYMBOL(<ref_usr_map>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
                                                                                  AND %tky-usergroup = key-%tky-usergroup.
        IF <new_usr_map> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_usr_map ASSIGNING <new_usr_map>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && <ref_usr_map>-userid
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_usr_map> EXCEPT usergroup singletonid )
                        usergroup = key-%param-usergroup ) INTO TABLE <new_usr_map>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_user_group(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-usergroup
        reported = reported-usergroup ).

    IF failed-usergroup IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_wfusrg_s IN LOCAL MODE
        ENTITY usergroupall CREATE BY \_usergroup
        FIELDS (
                 usergroup
               ) WITH new_main
        ENTITY usergroup CREATE BY \_usermapping
        FIELDS (
                 usergroup
                 userid
               ) WITH new_usr_map
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-usergroup = mapped_create-usergroup.
    INSERT LINES OF read_failed-usergroup INTO TABLE failed-usergroup.

    IF failed-usergroup IS INITIAL AND failed-usermapping IS INITIAL.
      reported-usergroup = VALUE #( FOR created IN mapped-usergroup (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-usergroupall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_wfusrg_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_wfusr_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/WFUSRG'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-usergroup ) ).
  ENDMETHOD.

  METHOD precheck_cba_usermapping.
    lcl_custom_validation=>precheck_cba_user_mapping(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-usermapping
        reported = reported-usermapping ).
  ENDMETHOD.

ENDCLASS.
