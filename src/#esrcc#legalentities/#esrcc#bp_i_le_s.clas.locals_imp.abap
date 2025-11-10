CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_le        TYPE STRUCTURE FOR READ RESULT /esrcc/i_le_s\\legalentity,
      tt_le_create TYPE TABLE FOR CREATE /esrcc/i_le_s\\legalentityall\_legalentity,
      BEGIN OF ts_control,
        legalentity TYPE if_abap_behv=>t_xflag,
        entitytype  TYPE if_abap_behv=>t_xflag,
        role        TYPE if_abap_behv=>t_xflag,
        localcurr   TYPE if_abap_behv=>t_xflag,
        region      TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_legal_entity
        IMPORTING
          entity  TYPE ts_le
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_legal_entity
        IMPORTING
          entities TYPE tt_le_create
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

  METHOD validate_legal_entity.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-legalentity = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.
    IF control-entitytype  = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ENTITYTYPE' ) TO fields. ENDIF.
    IF control-role        = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ROLE' ) TO fields. ENDIF.
    IF control-localcurr   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LOCALCURR' ) TO fields. ENDIF.
    IF control-region      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'REGION' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_legal_entity.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LegalEntityAll' ) )
        source_entity_name = '/ESRCC/C_LE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_legal_entity(
          entity  = CORRESPONDING #( target )
          control = VALUE #( legalentity = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LE'
                                       table_entity_relations = VALUE #( ( entity = 'LegalEntity' table = '/ESRCC/LE' )
                                                                         ( entity = 'LegalEntityText' table = '/ESRCC/LE_T' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_le_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR legalentityall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION legalentityall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR legalentityall
        RESULT result,
      precheck_cba_legalentity FOR PRECHECK
        IMPORTING entities FOR CREATE legalentityall\_legalentity.
ENDCLASS.

CLASS lhc_/esrcc/i_le_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
    ENTITY legalentityall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_legalentity = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
      ENTITY legalentityall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
      ENTITY legalentityall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_legalentity.
    lcl_custom_validation=>precheck_cba_legal_entity(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-legalentity
        reported = reported-legalentity ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_le_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_le_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-legalentityall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_le DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR legalentity~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR legalentity
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR legalentity~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE legalentity,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR legalentity RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR legalentity RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION legalentity~copy.
ENDCLASS.

CLASS lhc_/esrcc/i_le IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_le_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_le_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LE'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-legalentity ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_legalentitytext = edit_flag.
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
         ENTITY legalentity
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LegalEntityAll' ) )
        source_entity_name = '/ESRCC/C_LE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-legalentity
        failed_entity      = failed-legalentity ) ).

    LOOP AT entities INTO DATA(entity)
      WHERE localcurr IS INITIAL
         OR entitytype IS INITIAL
         OR region IS INITIAL
         OR role IS INITIAL.
      lo_validation->validate_legal_entity(
        entity  = entity
        control = VALUE #( entitytype = if_abap_behv=>mk-on region = if_abap_behv=>mk-on localcurr = if_abap_behv=>mk-on role = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LegalEntityAll' ) )
        source_entity_name = '/ESRCC/C_LE'
      CHANGING
        reported_entity    = reported-legalentity
        failed_entity      = failed-legalentity ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-entitytype  = if_abap_behv=>mk-on
                                          OR %control-role        = if_abap_behv=>mk-on
                                          OR %control-localcurr   = if_abap_behv=>mk-on
                                          OR %control-region      = if_abap_behv=>mk-on.
      lo_validation->validate_legal_entity(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( entitytype = entity-%control-entitytype
                           role       = entity-%control-role
                           localcurr  = entity-%control-localcurr
                           region     = entity-%control-region )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LE' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_le_s\_legalentity,
      new_text TYPE TABLE FOR CREATE /esrcc/i_le_s\\legalentity\_legalentitytext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-legalentity = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
      ENTITY legalentity
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
      ENTITY legalentity BY \_legalentitytext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid        = key_cid
                             %is_draft   = <ref_main>-%is_draft
                             %data       = CORRESPONDING #( <ref_main> EXCEPT legalentity singletonid )
                             legalentity = key-%param-legalentity ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft   = key-%tky-%is_draft
                                                                            AND %tky-legalentity = key-%tky-legalentity.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid        = key_cid && <ref_text>-spras
                        %is_draft   = key-%is_draft
                        %data       = CORRESPONDING #( <ref_text> EXCEPT legalentity singletonid )
                        legalentity = key-%param-legalentity ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_legal_entity(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-legalentity
        reported = reported-legalentity ).

    IF failed-legalentity IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_le_s IN LOCAL MODE
        ENTITY legalentityall CREATE BY \_legalentity
        FIELDS (
                 legalentity
                 country
                 localcurr
                 entitytype
                 region
                 role
                 tpprofile
               ) WITH new_main
        ENTITY legalentity CREATE BY \_legalentitytext
        FIELDS (
                 spras
                 legalentity
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-legalentity = mapped_create-legalentity.
    INSERT LINES OF read_failed-legalentity INTO TABLE failed-legalentity.

    IF failed-legalentity IS INITIAL AND failed-legalentitytext IS INITIAL.
      reported-legalentity = VALUE #( FOR created IN mapped-legalentity (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-legalentityall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_letext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR legalentitytext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR legalentitytext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_letext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_le_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_le_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LE_T'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-legalentitytext ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
