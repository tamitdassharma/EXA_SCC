CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_royalty_key        TYPE STRUCTURE FOR READ RESULT /esrcc/i_roykey_s\\royaltykey,
      tt_royalty_key_create TYPE TABLE FOR CREATE /esrcc/i_roykey_s\\roykeyall\_royaltykey,
      BEGIN OF ts_control,
        royaltykey TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_royalty_key
        IMPORTING
          entity  TYPE ts_royalty_key
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_royalty_key
        IMPORTING
          entities TYPE tt_royalty_key_create
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

  METHOD validate_royalty_key.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-royaltykey = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ROYALTYBASEKEY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_royalty_key.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RoyaltyKeyAll' ) )
        source_entity_name = '/ESRCC/C_ROYKEY'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_royalty_key(
          entity  = CORRESPONDING #( target )
          control = VALUE #( royaltykey = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_rap_tdat_cts DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/RoyKey'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'RoyaltyKey' table = '/ESRCC/ROYKEY' )
                                         ( entity = 'RoyaltyKeyText' table = '/ESRCC/ROYKEYT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_roykey_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR roykeyall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION roykeyall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR roykeyall
        RESULT result,
      precheck_cba_royaltykey FOR PRECHECK
        IMPORTING entities FOR CREATE roykeyall\_royaltykey.
ENDCLASS.

CLASS lhc_/esrcc/i_roykey_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
    ENTITY roykeyall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_royaltykey = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY roykeyall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY roykeyall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
  DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ROYKEY' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_royaltykey.
    lcl_custom_validation=>precheck_cba_royalty_key(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-royaltykey
        reported = reported-royaltykey ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_roykey_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_roykey_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-roykeyall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_roykey DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR royaltykey~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR royaltykey
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION royaltykey~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR royaltykey
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR royaltykey
        RESULT    result.
ENDCLASS.

CLASS lhc_/esrcc/i_roykey IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_roykey_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_royke_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/ROYKEY'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-royaltykey ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_royaltykeytext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_royaltykey TYPE TABLE FOR CREATE /esrcc/i_roykey_s\_royaltykey.
    DATA new_royaltykeytext TYPE TABLE FOR CREATE /esrcc/i_roykey_s\\royaltykey\_royaltykeytext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-royaltykey = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY royaltykey
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_royaltykey)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY royaltykey BY \_royaltykeytext
      ALL FIELDS WITH CORRESPONDING #( ref_royaltykey )
      RESULT DATA(ref_royaltykeytext).

    LOOP AT ref_royaltykey ASSIGNING FIELD-SYMBOL(<ref_royaltykey>).
      DATA(key) = keys[ KEY draft %tky = <ref_royaltykey>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_royaltykey>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_royaltykey>-%is_draft
          %data = CORRESPONDING #( <ref_royaltykey> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            locallastchangedat
            royaltybasekey
            singletonid
        ) ) )
      ) TO new_royaltykey ASSIGNING FIELD-SYMBOL(<new_royaltykey>).
      <new_royaltykey>-%target[ 1 ]-royaltybasekey = key-%param-royaltybasekey.
      FIELD-SYMBOLS <new_royaltykeytext> LIKE LINE OF new_royaltykeytext.
      UNASSIGN <new_royaltykeytext>.
      LOOP AT ref_royaltykeytext ASSIGNING FIELD-SYMBOL(<ref_royaltykeytext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-royaltybasekey = key-%tky-royaltybasekey.
        IF <new_royaltykeytext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_royaltykeytext ASSIGNING <new_royaltykeytext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_royaltykeytext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_royaltykeytext> EXCEPT
                                                 locallastchangedat
                                                 royaltybasekey
                                                 singletonid
        ) ) INTO TABLE <new_royaltykeytext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-royaltybasekey = key-%param-royaltybasekey.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_royalty_key(
      EXPORTING
        entities = new_royaltykey
      CHANGING
        failed   = failed-royaltykey
        reported = reported-royaltykey ).

    IF failed-royaltykey IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY roykeyall CREATE BY \_royaltykey
        FIELDS (
                 royaltybasekey
               ) WITH new_royaltykey
        ENTITY royaltykey CREATE BY \_royaltykeytext
        FIELDS (
                 spras
                 royaltybasekey
                 description
               ) WITH new_royaltykeytext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-royaltykey = mapped_create-royaltykey.
    INSERT LINES OF read_failed-royaltykey INTO TABLE failed-royaltykey.

    IF failed-royaltykey IS INITIAL AND failed-royaltykeytext IS INITIAL.
      reported-royaltykey = VALUE #( FOR created IN mapped-royaltykey (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-roykeyall-%is_draft = created-%is_draft
                                                 %path-roykeyall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ROYKEY' ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_roykeytext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR royaltykeytext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR royaltykeytext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_roykeytext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_roykey_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_royke_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/ROYKEYT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-royaltykeytext ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
