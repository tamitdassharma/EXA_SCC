CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_ledger        TYPE STRUCTURE FOR READ RESULT /esrcc/i_ledger_s\\ledger,
      tt_ledger_create TYPE TABLE FOR CREATE /esrcc/i_ledger_s\\ledgerall\_ledger,
      BEGIN OF ts_control,
        ledger TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_ledger
        IMPORTING
          entity  TYPE ts_ledger
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_ledger
        IMPORTING
          entities TYPE tt_ledger_create
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

  METHOD validate_ledger.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-ledger = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEDGER' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_ledger.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LedgerAll' ) )
        source_entity_name = '/ESRCC/C_LEDGER'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_ledger(
          entity  = CORRESPONDING #( target )
          control = VALUE #( ledger = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LEDGER'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Ledger' table = '/ESRCC/LEDGER' )
                                         ( entity = 'LedgerText' table = '/ESRCC/LEDGER_T' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_ledger_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ledgerall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ledgerall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ledgerall
        RESULT result,
      precheck_cba_ledger FOR PRECHECK
        IMPORTING entities FOR CREATE ledgerall\_ledger.
ENDCLASS.

CLASS lhc_/esrcc/i_ledger_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_ledger_s IN LOCAL MODE
    ENTITY ledgerall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_ledger = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_ledger_s IN LOCAL MODE
      ENTITY ledgerall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_ledger_s IN LOCAL MODE
      ENTITY ledgerall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LEDGER' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_ledger.
    lcl_custom_validation=>precheck_cba_ledger(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-ledger
        reported = reported-ledger ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_ledger_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_ledger_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-ledgerall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_ledger DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ledger~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ledger
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION ledger~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ledger
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ledger
        RESULT    result.
ENDCLASS.

CLASS lhc_/esrcc/i_ledger IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_ledger_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_ledge_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LEDGER'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ledger ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_ledgertext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_ledger TYPE TABLE FOR CREATE /esrcc/i_ledger_s\_ledger.
    DATA new_ledgertext TYPE TABLE FOR CREATE /esrcc/i_ledger_s\\ledger\_ledgertext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-ledger = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_ledger_s IN LOCAL MODE
      ENTITY ledger
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_ledger)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_ledger_s IN LOCAL MODE
      ENTITY ledger BY \_ledgertext
      ALL FIELDS WITH CORRESPONDING #( ref_ledger )
      RESULT DATA(ref_ledgertext).

    LOOP AT ref_ledger ASSIGNING FIELD-SYMBOL(<ref_ledger>).
      DATA(key) = keys[ KEY draft %tky = <ref_ledger>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_ledger>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_ledger>-%is_draft
          %data = CORRESPONDING #( <ref_ledger> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            ledger
            locallastchangedat
            singletonid
        ) ) )
      ) TO new_ledger ASSIGNING FIELD-SYMBOL(<new_ledger>).
      <new_ledger>-%target[ 1 ]-ledger = key-%param-ledger.
      FIELD-SYMBOLS <new_ledgertext> LIKE LINE OF new_ledgertext.
      UNASSIGN <new_ledgertext>.
      LOOP AT ref_ledgertext ASSIGNING FIELD-SYMBOL(<ref_ledgertext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-ledger = key-%tky-ledger.
        IF <new_ledgertext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_ledgertext ASSIGNING <new_ledgertext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_ledgertext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_ledgertext> EXCEPT
                                                 ledger
                                                 locallastchangedat
                                                 singletonid
        ) ) INTO TABLE <new_ledgertext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-ledger = key-%param-ledger.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_ledger(
      EXPORTING
        entities = new_ledger
      CHANGING
        failed   = failed-ledger
        reported = reported-ledger ).

    IF failed-ledger IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_ledger_s IN LOCAL MODE
        ENTITY ledgerall CREATE BY \_ledger
        FIELDS (
                 ledger
                 active
               ) WITH new_ledger
        ENTITY ledger CREATE BY \_ledgertext
        FIELDS (
                 spras
                 ledger
                 description
               ) WITH new_ledgertext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-ledger = mapped_create-ledger.
    INSERT LINES OF read_failed-ledger INTO TABLE failed-ledger.

    IF failed-ledger IS INITIAL AND failed-ledgertext IS INITIAL.
      reported-ledger = VALUE #( FOR created IN mapped-ledger (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-ledgerall-%is_draft = created-%is_draft
                                                 %path-ledgerall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LEDGER' ).
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_ledgertext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ledgertext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ledgertext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_ledgertext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_ledger_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_ledge_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LEDGER_T'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ledgertext ) ).
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
