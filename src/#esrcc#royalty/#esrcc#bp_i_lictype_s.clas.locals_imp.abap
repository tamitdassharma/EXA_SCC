CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_licence_type        TYPE STRUCTURE FOR READ RESULT /esrcc/i_lictype_s\\licensetype,
      tt_licence_type_create TYPE TABLE FOR CREATE /esrcc/i_lictype_s\\licensetypeall\_licensetype,
      BEGIN OF ts_control,
        licensetype TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_license_type
        IMPORTING
          entity  TYPE ts_licence_type
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_license_type
        IMPORTING
          entities TYPE tt_licence_type_create
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

  METHOD validate_license_type.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-licensetype = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSETYPE' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_license_type.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseTypeAll' ) )
        source_entity_name = '/ESRCC/C_LICTYPE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_license_type(
          entity  = CORRESPONDING #( target )
          control = VALUE #( licensetype = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LICTYPE'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'LicenseType' table = '/ESRCC/LICTYPE' )
                                         ( entity = 'LicenseTypeText' table = '/ESRCC/LICTYEPT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_lictype_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR licensetypeall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION licensetypeall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR licensetypeall
        RESULT result,
      precheck_cba_licensetype FOR PRECHECK
        IMPORTING entities FOR CREATE licensetypeall\_licensetype.
ENDCLASS.

CLASS lhc_/esrcc/i_lictype_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_lictype_s IN LOCAL MODE
    ENTITY licensetypeall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_licensetype = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_lictype_s IN LOCAL MODE
      ENTITY licensetypeall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_lictype_s IN LOCAL MODE
      ENTITY licensetypeall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LICTYPE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_licensetype.
    lcl_custom_validation=>precheck_cba_license_type(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-licensetype
        reported = reported-licensetype ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_lictype_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_lictype_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-licensetypeall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_lictype DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR licensetype~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR licensetype
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION licensetype~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR licensetype
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR licensetype
        RESULT    result..
ENDCLASS.

CLASS lhc_/esrcc/i_lictype IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_lictype_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_licty_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LICTYPE'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-licensetype ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_licensetypetext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_licensetype TYPE TABLE FOR CREATE /esrcc/i_lictype_s\_licensetype.
    DATA new_licensetypetext TYPE TABLE FOR CREATE /esrcc/i_lictype_s\\licensetype\_licensetypetext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-licensetype = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_lictype_s IN LOCAL MODE
      ENTITY licensetype
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_licensetype)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_lictype_s IN LOCAL MODE
      ENTITY licensetype BY \_licensetypetext
      ALL FIELDS WITH CORRESPONDING #( ref_licensetype )
      RESULT DATA(ref_licensetypetext).

    LOOP AT ref_licensetype ASSIGNING FIELD-SYMBOL(<ref_licensetype>).
      DATA(key) = keys[ KEY draft %tky = <ref_licensetype>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_licensetype>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_licensetype>-%is_draft
          %data = CORRESPONDING #( <ref_licensetype> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            licensetype
            locallastchangedat
            singletonid
        ) ) )
      ) TO new_licensetype ASSIGNING FIELD-SYMBOL(<new_licensetype>).
      <new_licensetype>-%target[ 1 ]-licensetype = key-%param-licensetype.
      FIELD-SYMBOLS <new_licensetypetext> LIKE LINE OF new_licensetypetext.
      UNASSIGN <new_licensetypetext>.
      LOOP AT ref_licensetypetext ASSIGNING FIELD-SYMBOL(<ref_licensetypetext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-licensetype = key-%tky-licensetype.
        IF <new_licensetypetext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_licensetypetext ASSIGNING <new_licensetypetext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_licensetypetext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_licensetypetext> EXCEPT
                                                 licensetype
                                                 locallastchangedat
                                                 singletonid
        ) ) INTO TABLE <new_licensetypetext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-licensetype = key-%param-licensetype.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_license_type(
      EXPORTING
        entities = new_licensetype
      CHANGING
        failed   = failed-licensetype
        reported = reported-licensetype ).

    IF failed-licensetype IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_lictype_s IN LOCAL MODE
        ENTITY licensetypeall CREATE BY \_licensetype
        FIELDS (
                 licensetype
               ) WITH new_licensetype
        ENTITY licensetype CREATE BY \_licensetypetext
        FIELDS (
                 spras
                 licensetype
                 description
               ) WITH new_licensetypetext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-licensetype = mapped_create-licensetype.
    INSERT LINES OF read_failed-licensetype INTO TABLE failed-licensetype.

    IF failed-licensetype IS INITIAL AND failed-licensetypetext IS INITIAL.
      reported-licensetype = VALUE #( FOR created IN mapped-licensetype (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-licensetypeall-%is_draft = created-%is_draft
                                                 %path-licensetypeall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LICTYPE' ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_lictypetext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR licensetypetext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR licensetypetext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_lictypetext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_lictype_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_licty_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LICTYEPT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-licensetypetext ) ).
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
