CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_region        TYPE STRUCTURE FOR READ RESULT /esrcc/i_region_s\\regions,
      tt_region_create TYPE TABLE FOR CREATE /esrcc/i_region_s\\regionall\_regions,
      BEGIN OF ts_control,
        region TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_region
        IMPORTING
          entity  TYPE ts_region
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_region
        IMPORTING
          entities TYPE tt_region_create
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

  METHOD validate_region.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-region = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'REGION' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_region.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RegionAll' ) )
        source_entity_name = '/ESRCC/C_REGION'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_region(
          entity  = CORRESPONDING #( target )
          control = VALUE #( region = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/REGIONS'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Regions' table = '/ESRCC/REGIONS' )
                                         ( entity = 'RegionText' table = '/ESRCC/REGIONST' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_region_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR regionall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION regionall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR regionall
        RESULT result,
      precheck_cba_regions FOR PRECHECK
        IMPORTING entities FOR CREATE regionall\_regions.
ENDCLASS.

CLASS lhc_/esrcc/i_region_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_region_s IN LOCAL MODE
    ENTITY regionall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_regions = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_region_s IN LOCAL MODE
      ENTITY regionall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_region_s IN LOCAL MODE
      ENTITY regionall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_REGIONS' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_regions.
    lcl_custom_validation=>precheck_cba_region(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-regions
        reported = reported-regions ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_region_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_region_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-regionall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_regions DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR regions~validatetransportrequest,
      validatedataconsistency FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR regions~validatedataconsistency,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR regions
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION regions~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR regions
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR regions
        RESULT    result.
ENDCLASS.

CLASS lhc_/esrcc/i_regions IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_region_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_regio_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/REGIONS'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-regions ) ).
  ENDMETHOD.
  METHOD validatedataconsistency.
*    READ ENTITIES OF /ESRCC/I_Region_S IN LOCAL MODE
*      ENTITY Regions
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(Regions).
*    DATA(table) = xco_cp_abap_repository=>object->tabl->database_table->for( '/ESRCC/REGIONS' ).
*    DATA: BEGIN OF element_check,
*            element  TYPE string,
*            check    TYPE ref to if_xco_dp_check,
*          END OF element_check,
*          element_checks LIKE TABLE OF element_check WITH EMPTY KEY.
*    LOOP AT Regions ASSIGNING FIELD-SYMBOL(<Regions>).
*      element_checks = VALUE #(
*        ( element = 'Region' check = table->field( 'REGION' )->get_value_check( ia_value = <Regions>-Region  ) )
*      ).
*      LOOP AT element_checks INTO element_check.
*        element_check-check->execute( ).
*        CHECK element_check-check->passed = xco_cp=>boolean->false.
*        INSERT VALUE #( %TKY        = <Regions>-%TKY ) INTO TABLE failed-Regions.
*        INSERT VALUE #( %TKY        = <Regions>-%TKY
*                        %STATE_AREA = 'Regions_Input_Check' ) INTO TABLE reported-Regions.
*        LOOP AT element_check-check->messages ASSIGNING FIELD-SYMBOL(<msg>).
*          INSERT VALUE #( %TKY = <Regions>-%TKY
*                          %STATE_AREA = 'Regions_Input_Check'
*                          %PATH-RegionAll-SingletonID = 1
*                          %PATH-RegionAll-%IS_DRAFT = <Regions>-%IS_DRAFT
*                          %msg = new_message(
*                                   id       = <msg>->value-msgid
*                                   number   = <msg>->value-msgno
*                                   severity = if_abap_behv_message=>severity-error
*                                   v1       = <msg>->value-msgv1
*                                   v2       = <msg>->value-msgv2
*                                   v3       = <msg>->value-msgv3
*                                   v4       = <msg>->value-msgv4 ) ) INTO TABLE reported-Regions ASSIGNING FIELD-SYMBOL(<rep>).
*          ASSIGN COMPONENT element_check-element OF STRUCTURE <rep>-%ELEMENT TO FIELD-SYMBOL(<comp>).
*          <comp> = if_abap_behv=>mk-on.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_regiontext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_regions TYPE TABLE FOR CREATE /esrcc/i_region_s\_regions.
    DATA new_regiontext TYPE TABLE FOR CREATE /esrcc/i_region_s\\regions\_regiontext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-regions = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_region_s IN LOCAL MODE
      ENTITY regions
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_regions)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_region_s IN LOCAL MODE
      ENTITY regions BY \_regiontext
      ALL FIELDS WITH CORRESPONDING #( ref_regions )
      RESULT DATA(ref_regiontext).

    LOOP AT ref_regions ASSIGNING FIELD-SYMBOL(<ref_regions>).
      DATA(key) = keys[ KEY draft %tky = <ref_regions>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_regions>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_regions>-%is_draft
          %data = CORRESPONDING #( <ref_regions> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            locallastchangedat
            region
            singletonid
        ) ) )
      ) TO new_regions ASSIGNING FIELD-SYMBOL(<new_regions>).
      <new_regions>-%target[ 1 ]-region = key-%param-region.
      FIELD-SYMBOLS <new_regiontext> LIKE LINE OF new_regiontext.
      UNASSIGN <new_regiontext>.
      LOOP AT ref_regiontext ASSIGNING FIELD-SYMBOL(<ref_regiontext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-region = key-%tky-region.
        IF <new_regiontext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_regiontext ASSIGNING <new_regiontext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_regiontext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_regiontext> EXCEPT
                                                 locallastchangedat
                                                 region
                                                 singletonid
        ) ) INTO TABLE <new_regiontext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-region = key-%param-region.
      ENDLOOP.
    ENDLOOP.


*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_region(
      EXPORTING
        entities = new_regions
      CHANGING
        failed   = failed-regions
        reported = reported-regions ).

    IF failed-regions IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_region_s IN LOCAL MODE
        ENTITY regionall CREATE BY \_regions
        FIELDS (
                 region
               ) WITH new_regions
        ENTITY regions CREATE BY \_regiontext
        FIELDS (
                 spras
                 region
                 description
               ) WITH new_regiontext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-regions = mapped_create-regions.
    INSERT LINES OF read_failed-regions INTO TABLE failed-regions.

    IF failed-regions IS INITIAL AND failed-regiontext IS INITIAL.
      reported-regions = VALUE #( FOR created IN mapped-regions (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-regionall-%is_draft = created-%is_draft
                                                 %path-regionall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_REGIONS' ).
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_regiontext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR regiontext~validatetransportrequest,
      validatedataconsistency FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR regiontext~validatedataconsistency,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR regiontext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_regiontext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_region_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_regio_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/REGIONST'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-regiontext ) ).
  ENDMETHOD.
  METHOD validatedataconsistency.
*    READ ENTITIES OF /ESRCC/I_Region_S IN LOCAL MODE
*      ENTITY RegionText
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(RegionText).
*    DATA(table) = xco_cp_abap_repository=>object->tabl->database_table->for( '/ESRCC/REGIONST' ).
*    DATA: BEGIN OF element_check,
*            element  TYPE string,
*            check    TYPE ref to if_xco_dp_check,
*          END OF element_check,
*          element_checks LIKE TABLE OF element_check WITH EMPTY KEY.
*    LOOP AT RegionText ASSIGNING FIELD-SYMBOL(<RegionText>).
*      element_checks = VALUE #(
*        ( element = 'Region' check = table->field( 'REGION' )->get_value_check( ia_value = <RegionText>-Region
*              it_additional_fields = VALUE #( ) ) )
*      ).
*      LOOP AT element_checks INTO element_check.
*        element_check-check->execute( ).
*        CHECK element_check-check->passed = xco_cp=>boolean->false.
*        INSERT VALUE #( %TKY        = <RegionText>-%TKY ) INTO TABLE failed-RegionText.
*        INSERT VALUE #( %TKY        = <RegionText>-%TKY
*                        %STATE_AREA = 'RegionText_Input_Check' ) INTO TABLE reported-RegionText.
*        LOOP AT element_check-check->messages ASSIGNING FIELD-SYMBOL(<msg>).
*          INSERT VALUE #( %TKY = <RegionText>-%TKY
*                          %STATE_AREA = 'RegionText_Input_Check'
*                          %PATH-RegionAll-SingletonID = 1
*                          %PATH-RegionAll-%IS_DRAFT = <RegionText>-%IS_DRAFT
*                          %PATH-Regions-%IS_DRAFT = <RegionText>-%IS_DRAFT
*                          %PATH-Regions-Region = <RegionText>-Region
*                          %msg = new_message(
*                                   id       = <msg>->value-msgid
*                                   number   = <msg>->value-msgno
*                                   severity = if_abap_behv_message=>severity-error
*                                   v1       = <msg>->value-msgv1
*                                   v2       = <msg>->value-msgv2
*                                   v3       = <msg>->value-msgv3
*                                   v4       = <msg>->value-msgv4 ) ) INTO TABLE reported-RegionText ASSIGNING FIELD-SYMBOL(<rep>).
*          ASSIGN COMPONENT element_check-element OF STRUCTURE <rep>-%ELEMENT TO FIELD-SYMBOL(<comp>).
*          <comp> = if_abap_behv=>mk-on.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
