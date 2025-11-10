CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_map        TYPE STRUCTURE FOR READ RESULT /esrcc/i_licmap_s\\licensee,
      tt_map_create TYPE TABLE FOR CREATE /esrcc/i_licmap_s\\licenseeall\_licensee,

      BEGIN OF ts_control,
        licenseesysid       TYPE if_abap_behv=>t_xflag,
        licenseelegalentity TYPE if_abap_behv=>t_xflag,
        licenseecompanycode TYPE if_abap_behv=>t_xflag,
        licenseecostobject  TYPE if_abap_behv=>t_xflag,
        licenseecostcenter  TYPE if_abap_behv=>t_xflag,
        invoicecurrency     TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_mapping
        IMPORTING
          entity  TYPE ts_map
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_mapping
        IMPORTING
          entities TYPE tt_map_create
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

  METHOD validate_mapping.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-licenseesysid       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSEESYSID' ) TO fields. ENDIF.
    IF control-licenseelegalentity = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSEELEGALENTITY' ) TO fields. ENDIF.
    IF control-licenseecompanycode = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSEECOMPANYCODE' ) TO fields. ENDIF.
    IF control-licenseecostobject  = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSEECOSTOBJECT' ) TO fields. ENDIF.
    IF control-licenseecostcenter  = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LICENSEECOSTCENTER' ) TO fields. ENDIF.
    IF control-invoicecurrency     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'INVOICECURRENCY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_mapping.
*    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
*      EXPORTING
*        paths              = VALUE #( ( path = 'LicenseeAll' ) )
*        source_entity_name = '/ESRCC/C_LICMAP'
*        is_transition      = abap_true
*      CHANGING
*        reported_entity    = reported
*        failed_entity      = failed ) ).
*
*    LOOP AT entities INTO DATA(entity).
*      LOOP AT entity-%target INTO DATA(target).
*        lo_validation->validate_mapping(
*          entity  = CORRESPONDING #( target )
*          control = VALUE #( validfrom = if_abap_behv=>mk-on )
*        ).
*      ENDLOOP.
*    ENDLOOP.

    TYPES ts_lic_map TYPE STRUCTURE FOR READ RESULT /esrcc/i_licmap_s\\licensee.

    DATA(lo_lic_map) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseeAll' ) )
        source_entity_name = '/ESRCC/C_LICMAP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    SELECT
           map~licenseecostobjectuuid,
           map~license
        FROM /esrcc/d_lic_map AS map
        INNER JOIN @target_entities AS tent
            ON  tent~licenseecostobjectuuid = map~licenseecostobjectuuid
            AND tent~license                = map~license
        WHERE map~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( licenseecostobjectuuid = entity-licenseecostobjectuuid
                                                         license                = entity-license
                                                         size                   = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      IF line_exists( duplicate_entities[ licenseecostobjectuuid = group_ref->licenseecostobjectuuid
                                          license                = group_ref->license ] ) OR group_ref->size > 1.
        lo_lic_map->set_duplicate_error( entity = CORRESPONDING ts_lic_map( group_ref->* ) ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
*    SELECT
*           map~licensorcostobjectuuid,
*           map~license
*        FROM /esrcc/d_lic_map AS map
*        INNER JOIN @target_entities AS tent
*            ON  tent~licensorcostobjectuuid = map~licensorcostobjectuuid
*            AND tent~license                = map~license
*        WHERE map~draftentityoperationcode NOT IN ( 'D', 'L' )
*        INTO TABLE @DATA(duplicate_entities).
*
*    LOOP AT target_entities INTO DATA(entity) GROUP BY ( licensorcostobjectuuid = entity-licensorcostobjectuuid
*                                                         license                = entity-license
*                                                         size                   = GROUP SIZE )
*        ASCENDING REFERENCE INTO DATA(group_ref).
*      IF line_exists( duplicate_entities[ licensorcostobjectuuid = group_ref->licensorcostobjectuuid
*                                          license                = group_ref->license ] ) OR group_ref->size > 1.
*        lo_lic_map->set_duplicate_error( entity = CORRESPONDING ts_lic_map( group_ref->* ) ).
*        CONTINUE.
*      ENDIF.
*    ENDLOOP.
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LIC_MAP'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Licensee' table = '/ESRCC/LIC_MAP' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_licmap_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR licenseeall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION licenseeall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR licenseeall
        RESULT result,
      precheck_cba_licensee FOR PRECHECK
        IMPORTING entities FOR CREATE licenseeall\_licensee.
ENDCLASS.

CLASS lhc_/esrcc/i_licmap_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_licmap_s IN LOCAL MODE
    ENTITY licenseeall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_licensee = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_licmap_s IN LOCAL MODE
      ENTITY licenseeall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_licmap_s IN LOCAL MODE
      ENTITY licenseeall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LICMAP' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_licensee.
    lcl_custom_validation=>precheck_cba_mapping(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-licensee
        reported = reported-licensee ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_licmap_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_licmap_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-licenseeall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) )->update_last_changed_date_time( view_entity_name   = '/ESRCC/I_LICMAP'
                                                                                                        maintenance_object = '/ESRCC/LIC_MAP' ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_licmap DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR licensee~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR licensee
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR licensee RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR licensee RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE licensee.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION licensee~copy.

    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR licensee~validatedata.
ENDCLASS.

CLASS lhc_/esrcc/i_licmap IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_licmap_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_lic_m_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LIC_MAP'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-licensee ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_BUSDIV' ).
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseeAll' ) )
        source_entity_name = '/ESRCC/C_LICMAP'
      CHANGING
        reported_entity    = reported-licensee
        failed_entity      = failed-licensee ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-licenseesysid       = if_abap_behv=>mk-on
                                          OR %control-licenseelegalentity = if_abap_behv=>mk-on
                                          OR %control-licenseecompanycode = if_abap_behv=>mk-on
                                          OR %control-licenseecostobject  = if_abap_behv=>mk-on
                                          OR %control-licenseecostcenter  = if_abap_behv=>mk-on
                                          OR %control-invoicecurrency     = if_abap_behv=>mk-on.
      lo_validation->validate_mapping(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( licenseesysid       = entity-%control-licenseesysid
                             licenseelegalentity = entity-%control-licenseelegalentity
                             licenseecompanycode = entity-%control-licenseecompanycode
                             licenseecostobject  = entity-%control-licenseecostobject
                             licenseecostcenter  = entity-%control-licenseecostcenter
                             invoicecurrency     = entity-%control-invoicecurrency )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_licmap_s\_licensee.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-licensee = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_licmap_s IN LOCAL MODE
      ENTITY licensee
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid                   = key_cid
                             %is_draft              = <ref_main>-%is_draft
                             %data                  = CORRESPONDING #( <ref_main> EXCEPT uuid licensorsysid licensorlegalentity licensorcompanycode licensorcostobject licensorcostcenter license singletonid )
                             licensorsysid          = key-%param-licensorsysid
                             licensorlegalentity    = key-%param-licensorlegalentity
                             licensorcompanycode    = key-%param-licensorcompanycode
                             licensorcostobject     = key-%param-licensorcostobject
                             licensorcostcenter     = key-%param-licensorcostcenter
                             license                = key-%param-license
                             licensorcostobjectuuid = key-%param-licensorcostobjectuuid ) ) ) TO new_main.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_mapping(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-licensee
        reported = reported-licensee ).

    IF failed-licensee IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_licmap_s IN LOCAL MODE
        ENTITY licenseeall CREATE BY \_licensee
        FIELDS (
                 licensorsysid
                 licensorlegalentity
                 licensorcompanycode
                 licensorcostobject
                 licensorcostcenter
                 license
                 licenseesysid
                 licenseelegalentity
                 licenseecompanycode
                 licenseecostobject
                 licenseecostcenter
                 licensorcostobjectuuid
                 licenseecostobjectuuid
                 invoicecurrency
                 erpsalesorder
                 agreementid
                 active
               ) WITH new_main
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-licensee = mapped_create-licensee.
    INSERT LINES OF read_failed-licensee INTO TABLE failed-licensee.

    IF failed-licensee IS INITIAL.
      reported-licensee = VALUE #( FOR created IN mapped-licensee (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-licenseeall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_licmap_s IN LOCAL MODE
         ENTITY licensee
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LicenseeAll' ) )
        source_entity_name = '/ESRCC/C_LICMAP'
      CHANGING
        reported_entity    = reported-licensee
        failed_entity      = failed-licensee ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_mapping(
        entity  = entity
        control = VALUE #( licenseesysid       = if_abap_behv=>mk-on
                           licenseelegalentity = if_abap_behv=>mk-on
                           licenseecompanycode = if_abap_behv=>mk-on
                           licenseecostobject  = if_abap_behv=>mk-on
                           licenseecostcenter  = if_abap_behv=>mk-on
                           invoicecurrency     = if_abap_behv=>mk-on )
      ).

      " Validate if licensor and licensee are same
      IF entity-licensorcostobjectuuid = entity-licenseecostobjectuuid.
        lo_config_util->set_state_message(
          entity     = entity
          msg        = /esrcc/cl_config_msg_handler=>same_sender_receiver( )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
