CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_functional_area  TYPE STRUCTURE FOR READ RESULT /esrcc/i_functionalareas_s\\functionalareas,
      tt_func_area_create TYPE TABLE FOR CREATE /esrcc/i_functionalareas_s\\functionalareasall\_functionalareas,
      BEGIN OF ts_control,
        functionalarea TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_functional_area
        IMPORTING
          entity  TYPE ts_functional_area
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_functional_area
        IMPORTING
          entities TYPE tt_func_area_create
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

  METHOD validate_functional_area.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-functionalarea = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'FUNCTIONALAREA' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_functional_area.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'FunctionalAreasAll' ) )
        source_entity_name = '/ESRCC/C_FUNCTIONALAREAS'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_functional_area(
          entity  = CORRESPONDING #( target )
          control = VALUE #( functionalarea = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/FUNCTIONALAREAS'
                                       table_entity_relations = VALUE #( ( entity = 'FunctionalAreas' table = '/ESRCC/FNC_AREA' )
                                                                         ( entity = 'FunctionalAreasText' table = '/ESRCC/FNC_AREAT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_functionalareas_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR functionalareasall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR functionalareasall
        RESULT result,
      precheck_cba_functionalareas FOR PRECHECK
        IMPORTING entities FOR CREATE functionalareasall\_functionalareas,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION functionalareasall~selectcustomizingtransptreq RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_functionalareas_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_functionalareas_s IN LOCAL MODE
    ENTITY functionalareasall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_functionalareas = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_FUNCTIONALAREAS' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_functionalareas.
    lcl_custom_validation=>precheck_cba_functional_area(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-functionalareas
        reported = reported-functionalareas ).
  ENDMETHOD.

  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_functionalareas_s IN LOCAL MODE
      ENTITY functionalareasall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_functionalareas_s IN LOCAL MODE
      ENTITY functionalareasall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_functionalareas_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_functionalareas_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-functionalareasall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_functionalareas DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR functionalareas
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR functionalareas RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR functionalareas RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION functionalareas~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR functionalareas~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_functionalareas IMPLEMENTATION.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_functionalareastext = edit_flag.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_FUNCTIONALAREAS' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_functionalareas_s\_functionalareas,
      new_text TYPE TABLE FOR CREATE /esrcc/i_functionalareas_s\\functionalareas\_functionalareastext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-functionalareas = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_functionalareas_s IN LOCAL MODE
      ENTITY functionalareas
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_functionalareas_s IN LOCAL MODE
      ENTITY functionalareas BY \_functionalareastext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid           = key_cid
                             %is_draft      = <ref_main>-%is_draft
                             %data          = CORRESPONDING #( <ref_main> EXCEPT functionalarea singletonid )
                             functionalarea = key-%param-functionalarea ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft      = key-%tky-%is_draft
                                                                            AND %tky-functionalarea = key-%tky-functionalarea.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid           = key_cid && <ref_text>-spras
                        %is_draft      = key-%is_draft
                        %data          = CORRESPONDING #( <ref_text> EXCEPT functionalarea singletonid )
                        functionalarea = key-%param-functionalarea ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_functional_area(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-functionalareas
        reported = reported-functionalareas ).

    IF failed-functionalareas IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_functionalareas_s IN LOCAL MODE
        ENTITY functionalareasall CREATE BY \_functionalareas
        FIELDS (
                 functionalarea
               ) WITH new_main
        ENTITY functionalareas CREATE BY \_functionalareastext
        FIELDS (
                 spras
                 functionalarea
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-functionalareas = mapped_create-functionalareas.
    INSERT LINES OF read_failed-functionalareas INTO TABLE failed-functionalareas.

    IF failed-functionalareas IS INITIAL AND failed-functionalareastext IS INITIAL.
      reported-functionalareas = VALUE #( FOR created IN mapped-functionalareas (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-functionalareasall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_functionalareas_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_fnc_a_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/FNC_AREA'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-functionalareas ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_functionalareaste DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR functionalareastext
        RESULT result,
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING keys FOR functionalareastext~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_functionalareaste IMPLEMENTATION.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_functionalareas_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_fnc_a_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/FNC_AREAT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-functionalareastext ) ).
  ENDMETHOD.

ENDCLASS.
