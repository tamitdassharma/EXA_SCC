CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_license        TYPE STRUCTURE FOR READ RESULT /esrcc/i_license_s\\license,
      tt_license_create TYPE TABLE FOR CREATE /esrcc/i_license_s\\licenseall\_license,
      BEGIN OF ts_control,
        license    TYPE if_abap_behv=>t_xflag,
        licensetyp TYPE if_abap_behv=>t_xflag,
        ruleid     TYPE if_abap_behv=>t_xflag,
        validfrom  TYPE if_abap_behv=>t_xflag,
        validto    TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_license
        IMPORTING
          entity  TYPE ts_license
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_license
        IMPORTING
          entities TYPE tt_license_create
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

  METHOD validate_license.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-license    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSE' ) TO fields. ENDIF.
    IF control-licensetyp = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSETYP' ) TO fields. ENDIF.
    IF control-ruleid     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RULEID' ) TO fields. ENDIF.
    IF control-validfrom  = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_from) = entity-validfrom.
      DATA(lv_to) = entity-validto.
      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_from
          end_date   = lv_to
      ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_license.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseAll' ) )
        source_entity_name = '/ESRCC/C_LICENSE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_license(
          entity  = CORRESPONDING #( target )
          control = VALUE #( license = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LICENSE'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'License' table = '/ESRCC/LICENSE' )
                                         ( entity = 'LicenseText' table = '/ESRCC/LICENSET' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_license_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR licenseall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION licenseall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR licenseall
        RESULT result,
      precheck_cba_license FOR PRECHECK
        IMPORTING entities FOR CREATE licenseall\_license.
ENDCLASS.

CLASS lhc_/esrcc/i_license_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
    ENTITY licenseall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_license = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
      ENTITY licenseall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
      ENTITY licenseall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LICENSE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_license.
    lcl_custom_validation=>precheck_cba_license(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-license
        reported = reported-license ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_license_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_license_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-licenseall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_license DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR license~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR license
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION license~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR license
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR license
        RESULT    result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR license~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE license.
ENDCLASS.

CLASS lhc_/esrcc/i_license IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_license_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_licen_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LICENSE'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-license ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_licensetext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_license TYPE TABLE FOR CREATE /esrcc/i_license_s\_license.
    DATA new_licensetext TYPE TABLE FOR CREATE /esrcc/i_license_s\\license\_licensetext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-license = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
      ENTITY license
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_license)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
      ENTITY license BY \_licensetext
      ALL FIELDS WITH CORRESPONDING #( ref_license )
      RESULT DATA(ref_licensetext).

    LOOP AT ref_license ASSIGNING FIELD-SYMBOL(<ref_license>).
      DATA(key) = keys[ KEY draft %tky = <ref_license>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_license>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_license>-%is_draft
          %data = CORRESPONDING #( <ref_license> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            license
            locallastchangedat
            singletonid
        ) ) )
      ) TO new_license ASSIGNING FIELD-SYMBOL(<new_license>).
      <new_license>-%target[ 1 ]-license = key-%param-license.
      FIELD-SYMBOLS <new_licensetext> LIKE LINE OF new_licensetext.
      UNASSIGN <new_licensetext>.
      LOOP AT ref_licensetext ASSIGNING FIELD-SYMBOL(<ref_licensetext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-license = key-%tky-license.
        IF <new_licensetext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_licensetext ASSIGNING <new_licensetext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_licensetext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_licensetext> EXCEPT
                                                 license
                                                 locallastchangedat
                                                 singletonid
        ) ) INTO TABLE <new_licensetext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-license = key-%param-license.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_license(
      EXPORTING
        entities = new_license
      CHANGING
        failed   = failed-license
        reported = reported-license ).

    IF failed-license IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
        ENTITY licenseall CREATE BY \_license
        FIELDS (
                 license
                 licensetyp
                 ruleid
                 validfrom
                 validto
               ) WITH new_license
        ENTITY license CREATE BY \_licensetext
        FIELDS (
                 spras
                 license
                 description
               ) WITH new_licensetext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-license = mapped_create-license.
    INSERT LINES OF read_failed-license INTO TABLE failed-license.

    IF failed-license IS INITIAL AND failed-licensetext IS INITIAL.
      reported-license = VALUE #( FOR created IN mapped-license (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-licenseall-%is_draft = created-%is_draft
                                                 %path-licenseall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LICENSE' ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
  METHOD validatedata.
    DATA draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_license_s\\license.

    READ ENTITIES OF /esrcc/i_license_s IN LOCAL MODE
         ENTITY license
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseAll' ) )
        source_entity_name = '/ESRCC/C_LICENSE'
      CHANGING
        reported_entity    = reported-license
        failed_entity      = failed-license ) ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_license(
        entity  = entity
        control = VALUE #( licensetyp = if_abap_behv=>mk-on
                           ruleid     = if_abap_behv=>mk-on
                           validfrom  = if_abap_behv=>mk-on
                           validto    = if_abap_behv=>mk-on ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseAll' ) )
        source_entity_name = '/ESRCC/C_LICENSE'
      CHANGING
        reported_entity    = reported-license
        failed_entity      = failed-license ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-licensetyp = if_abap_behv=>mk-on
                                          OR %control-ruleid     = if_abap_behv=>mk-on
                                          OR %control-validfrom  = if_abap_behv=>mk-on
                                          OR %control-validto    = if_abap_behv=>mk-on.
      lo_validation->validate_license(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( licensetyp = entity-%control-licensetyp
                             ruleid     = entity-%control-ruleid
                             validfrom  = entity-%control-validfrom
                             validto    = entity-%control-validto )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_licensetext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR licensetext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR licensetext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_licensetext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_license_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_licen_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LICENSET'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-licensetext ) ).
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
