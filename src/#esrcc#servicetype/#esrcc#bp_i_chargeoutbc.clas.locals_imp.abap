CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_chargeout        TYPE STRUCTURE FOR READ RESULT /esrcc/i_chargeoutbc_s\\chargeout,
      tt_chargeout_create TYPE TABLE FOR CREATE /esrcc/i_chargeoutbc_s\\chargeoutall\_chargeout,

      BEGIN OF ts_control_chargeout,
        chargeoutruleid TYPE if_abap_behv=>t_xflag,
        validfrom       TYPE if_abap_behv=>t_xflag,
        validto         TYPE if_abap_behv=>t_xflag,
      END OF ts_control_chargeout.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,

      validate_chargeout
        IMPORTING
          entity  TYPE ts_chargeout
          control TYPE ts_control_chargeout.

    CLASS-METHODS:
      precheck_cba_chargeout
        IMPORTING
          entities TYPE tt_chargeout_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_chargeout.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-chargeoutruleid = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHARGEOUTRULEID' ) TO fields. ENDIF.
    IF control-validto         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

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

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.

      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
      ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_chargeout.
    TYPES ts_chargeout TYPE STRUCTURE FOR READ RESULT /esrcc/i_chargeoutbc_s\\chargeout.

    DATA(lo_chargeout) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ChargeoutAll' ) )
        source_entity_name = '/ESRCC/C_CHARGEOUTBC'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_chargeout ).

    LOOP AT entities INTO DATA(entity).

      SELECT DISTINCT
             chrg~serviceproduct
          FROM /esrcc/d_chargeo AS chrg
          INNER JOIN @entity-%target AS tent
              ON  tent~serviceproduct = chrg~serviceproduct
              AND tent~validfrom      = chrg~validfrom
          WHERE chrg~draftentityoperationcode NOT IN ( 'D', 'L' )
          INTO TABLE @DATA(duplicate_entities).

      LOOP AT entity-%target INTO DATA(target) GROUP BY ( serviceproduct = target-serviceproduct
                                                          validfrom      = target-validfrom
                                                          size           = GROUP SIZE )
          ASCENDING REFERENCE INTO DATA(group_ref).
        lo_validation->validate_chargeout(
          entity  = CORRESPONDING #( group_ref->* )
          control = VALUE #( validfrom = if_abap_behv=>mk-on )
        ).

        IF line_exists( duplicate_entities[ serviceproduct = group_ref->serviceproduct ] ) OR group_ref->size > 1.
          lo_chargeout->set_duplicate_error( entity = CORRESPONDING ts_chargeout( group_ref->* ) ).
        ENDIF.
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/CHARGEOUT'
                                       table_entity_relations = VALUE #( ( entity = 'Chargeout' table = '/ESRCC/CHARGEOUT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_chargeoutbc_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR chargeoutall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR chargeoutall
        RESULT result,
      precheck_cba_chargeout FOR PRECHECK
        IMPORTING entities FOR CREATE chargeoutall\_chargeout,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION chargeoutall~selectcustomizingtransptreq RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_chargeoutbc_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
    ENTITY chargeoutall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_chargeout = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CHARGEOUTBC' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_chargeout.
    lcl_custom_validation=>precheck_cba_chargeout(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-chargeout
        reported = reported-chargeout ).
  ENDMETHOD.

  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
      ENTITY chargeoutall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
      ENTITY chargeoutall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_chargeoutbc_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_chargeoutbc_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-chargeoutall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_chargeoutbc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR chargeout
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR chargeout~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE chargeout,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR chargeout RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR chargeout RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION chargeout~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR chargeout~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_chargeoutbc IMPLEMENTATION.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD validatedata.
    DATA:
      draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_chargeoutbc_s\\chargeout.

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
         ENTITY chargeout
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT chrg~*
      FROM /esrcc/d_chargeo AS chrg
      INNER JOIN @entities AS ent
        ON  ent~serviceproduct = chrg~serviceproduct
      WHERE chrg~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_chargeout) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ChargeoutAll' ) )
        source_entity_name = '/ESRCC/C_CHARGEOUTBC'
      CHANGING
        reported_entity    = reported-chargeout
        failed_entity      = failed-chargeout ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_chargeout ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_chargeout( entity = entity control = VALUE #( chargeoutruleid = if_abap_behv=>mk-on
                                                                            validto         = if_abap_behv=>mk-on ) ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE serviceproduct = entity-serviceproduct
                                                  AND uuid           <> entity-uuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_chargeout->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                               src_to      = draft-validto
                                                               src_entity  = draft
                                                               curr_from   = entity-validfrom
                                                               curr_to     = entity-validto
                                                               curr_entity = entity ).
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
       EXPORTING
         paths              = VALUE #( ( path = 'ChargeoutAll' ) )
         source_entity_name = '/ESRCC/C_CHARGEOUTBC'
       CHANGING
         reported_entity    = reported-chargeout
         failed_entity      = failed-chargeout ) ).

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
        ENTITY chargeout
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(chargeout).

    LOOP AT entities INTO DATA(entity) WHERE %control-chargeoutruleid = if_abap_behv=>mk-on
                                          OR %control-validto         = if_abap_behv=>mk-on.
      lo_validation->validate_chargeout(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chargeoutruleid = entity-%control-chargeoutruleid
                           validto         = entity-%control-validto )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CHARGEOUTBC' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_chargeoutbc_s\_chargeout.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-chargeout = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
      ENTITY chargeout
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid           = key_cid
                             %is_draft      = <ref_main>-%is_draft
                             %data          = CORRESPONDING #( <ref_main> EXCEPT uuid serviceproduct validfrom validto singletonid )
                             serviceproduct = key-%param-serviceproduct
                             validfrom      = key-%param-validfrom
                             validto        = key-%param-validto ) ) ) TO new_main.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_chargeout(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-chargeout
        reported = reported-chargeout ).

    IF failed-chargeout IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_chargeoutbc_s IN LOCAL MODE
        ENTITY chargeoutall CREATE BY \_chargeout
        FIELDS (
                 serviceproduct
                 validfrom
                 validto
                 chargeoutruleid
               ) WITH new_main
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-chargeout = mapped_create-chargeout.
    INSERT LINES OF read_failed-chargeout INTO TABLE failed-chargeout.

    IF failed-chargeout IS INITIAL.
      reported-chargeout = VALUE #( FOR created IN mapped-chargeout (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-chargeoutall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_chargeoutbc_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_charg_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/CHARGEOUT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-chargeout ) ).
  ENDMETHOD.

ENDCLASS.
