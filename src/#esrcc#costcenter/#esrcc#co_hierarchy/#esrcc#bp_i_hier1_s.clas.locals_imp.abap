CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_hierarchy        TYPE STRUCTURE FOR READ RESULT /esrcc/i_hier1_s\\hierarchy,
      tt_hierarchy_create TYPE TABLE FOR CREATE /esrcc/i_hier1_s\\hierarchyall\_hierarchy,
      BEGIN OF ts_control,
        hierarchy TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_hierarchy
        IMPORTING
          entity  TYPE ts_hierarchy
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_hierarchy
        IMPORTING
          entities TYPE tt_hierarchy_create
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

  METHOD validate_hierarchy.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-hierarchy = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'HIERARCHY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_hierarchy.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'HierarchyAll' ) )
        source_entity_name = '/ESRCC/C_HIER1'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_hierarchy(
          entity  = CORRESPONDING #( target )
          control = VALUE #( hierarchy = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/HIER1'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Hierarchy' table = '/ESRCC/HIER1' )
                                         ( entity = 'HierarchyText' table = '/ESRCC/HIER1_T' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_hier1_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR hierarchyall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION hierarchyall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR hierarchyall
        RESULT result,
      precheck_cba_hierarchy FOR PRECHECK
        IMPORTING entities FOR CREATE hierarchyall\_hierarchy.
ENDCLASS.

CLASS lhc_/esrcc/i_hier1_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
    ENTITY hierarchyall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_hierarchy = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchyall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchyall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_HIER1' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_hierarchy.
    lcl_custom_validation=>precheck_cba_hierarchy(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-hierarchy
        reported = reported-hierarchy ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_hier1_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_hier1_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-hierarchyall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_hier1 DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR hierarchy~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR hierarchy
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION hierarchy~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR hierarchy
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR hierarchy
        RESULT    result.
ENDCLASS.

CLASS lhc_/esrcc/i_hier1 IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_hier1_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_hier1_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/HIER1'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-hierarchy ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_hierarchytext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_hierarchy TYPE TABLE FOR CREATE /esrcc/i_hier1_s\_hierarchy.
    DATA new_hierarchytext TYPE TABLE FOR CREATE /esrcc/i_hier1_s\\hierarchy\_hierarchytext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-hierarchy = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchy
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_hierarchy)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchy BY \_hierarchytext
      ALL FIELDS WITH CORRESPONDING #( ref_hierarchy )
      RESULT DATA(ref_hierarchytext).

    LOOP AT ref_hierarchy ASSIGNING FIELD-SYMBOL(<ref_hierarchy>).
      DATA(key) = keys[ KEY draft %tky = <ref_hierarchy>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_hierarchy>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_hierarchy>-%is_draft
          %data = CORRESPONDING #( <ref_hierarchy> EXCEPT
            createdat
            createdby
            hierarchy
            lastchangedat
            lastchangedby
            locallastchangedat
            singletonid
        ) ) )
      ) TO new_hierarchy ASSIGNING FIELD-SYMBOL(<new_hierarchy>).
      <new_hierarchy>-%target[ 1 ]-hierarchy = key-%param-hierarchy.
      FIELD-SYMBOLS <new_hierarchytext> LIKE LINE OF new_hierarchytext.
      UNASSIGN <new_hierarchytext>.
      LOOP AT ref_hierarchytext ASSIGNING FIELD-SYMBOL(<ref_hierarchytext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-hierarchy = key-%tky-hierarchy.
        IF <new_hierarchytext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_hierarchytext ASSIGNING <new_hierarchytext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_hierarchytext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_hierarchytext> EXCEPT
                                                 hierarchy
                                                 locallastchangedat
                                                 singletonid
        ) ) INTO TABLE <new_hierarchytext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-hierarchy = key-%param-hierarchy.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchyall CREATE BY \_hierarchy
      FIELDS (
               hierarchy
             ) WITH new_hierarchy
      ENTITY hierarchy CREATE BY \_hierarchytext
      FIELDS (
               spras
               hierarchy
               description
             ) WITH new_hierarchytext
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-hierarchy = mapped_create-hierarchy.
    INSERT LINES OF read_failed-hierarchy INTO TABLE failed-hierarchy.

    IF failed-hierarchy IS INITIAL.
      reported-hierarchy = VALUE #( FOR created IN mapped-hierarchy (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-hierarchyall-%is_draft = created-%is_draft
                                                 %path-hierarchyall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_HIER1' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_hier1text DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR hierarchytext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR hierarchytext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_hier1text IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_hier1_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_hier1_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/HIER1_T'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-hierarchytext ) ).
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
