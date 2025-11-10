CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_sys_info        TYPE STRUCTURE FOR READ RESULT /esrcc/i_sysinfo_s\\systeminfo,
      tt_sys_info_create TYPE TABLE FOR CREATE /esrcc/i_sysinfo_s\\systeminfoall\_systeminfo,
      BEGIN OF ts_control,
        systemid TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_system_info
        IMPORTING
          entity  TYPE ts_sys_info
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_sys_info
        IMPORTING
          entities TYPE tt_sys_info_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_system_info.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-systemid = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSTEMID' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_sys_info.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'SystemInfoAll' ) )
        source_entity_name = '/ESRCC/C_SYSINFO'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_system_info(
          entity  = CORRESPONDING #( target )
          control = VALUE #( systemid = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/SYSINFO'
                                       table_entity_relations = VALUE #( ( entity = 'SystemInfo' table = '/ESRCC/SYS_INFO' )
                                                                         ( entity = 'SystemInfoText' table = '/ESRCC/SYS_INFOT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_sysinfo_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR systeminfoall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION systeminfoall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR systeminfoall
        RESULT result,
      precheck_cba_systeminfo FOR PRECHECK
        IMPORTING entities FOR CREATE systeminfoall\_systeminfo.
ENDCLASS.

CLASS lhc_/esrcc/i_sysinfo_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_sysinfo_s IN LOCAL MODE
    ENTITY systeminfoall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
                %tky = row-%tky
                %action-edit = edit_flag
                %assoc-_systeminfo = edit_flag
                %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_sysinfo_s IN LOCAL MODE
      ENTITY systeminfoall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_sysinfo_s IN LOCAL MODE
      ENTITY systeminfoall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_SYSINFO' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_systeminfo.
    lcl_custom_validation=>precheck_cba_sys_info(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-systeminfo
        reported = reported-systeminfo ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_sysinfo_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_sysinfo_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-systeminfoall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_sysinfo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR systeminfo~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR systeminfo
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR systeminfo RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR systeminfo RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION systeminfo~copy.
ENDCLASS.

CLASS lhc_/esrcc/i_sysinfo IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_sysinfo_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_sys_i_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/SYS_INFO'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-systeminfo ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_systeminfotext = edit_flag.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_SYSINFO' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_sysinfo_s\_systeminfo,
      new_text TYPE TABLE FOR CREATE /esrcc/i_sysinfo_s\\systeminfo\_systeminfotext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-systeminfo = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_sysinfo_s IN LOCAL MODE
      ENTITY systeminfo
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_sysinfo_s IN LOCAL MODE
      ENTITY systeminfo BY \_systeminfotext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid      = key_cid
                             %is_draft = <ref_main>-%is_draft
                             %data     = CORRESPONDING #( <ref_main> EXCEPT systemid singletonid )
                             systemid  = key-%param-systemid ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
                                                                            AND %tky-systemid  = key-%tky-systemid.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && <ref_text>-spras
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_text> EXCEPT systemid singletonid )
                        systemid  = key-%param-systemid ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_sys_info(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-systeminfo
        reported = reported-systeminfo ).

    IF failed-systeminfo IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_sysinfo_s IN LOCAL MODE
        ENTITY systeminfoall CREATE BY \_systeminfo
        FIELDS (
                 systemid
                 sourcerfcdestination
                 hostrfcdestination
                 systemtype
                 signforsales
                 signforcogs
                 isactive
               ) WITH new_main
        ENTITY systeminfo CREATE BY \_systeminfotext
        FIELDS (
                 spras
                 systemid
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-systeminfo = mapped_create-systeminfo.
    INSERT LINES OF read_failed-systeminfo INTO TABLE failed-systeminfo.

    IF failed-systeminfo IS INITIAL AND failed-systeminfotext IS INITIAL.
      reported-systeminfo = VALUE #( FOR created IN mapped-systeminfo (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-systeminfoall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_sysinfotext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR systeminfotext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR systeminfotext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_sysinfotext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_sysinfo_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_sys_i_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/SYS_INFOT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-systeminfotext ) ).
  ENDMETHOD.

  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
