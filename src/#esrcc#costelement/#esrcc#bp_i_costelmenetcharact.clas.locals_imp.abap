CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_ce_char                  TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar,
      tt_cost_element_char_create TYPE TABLE FOR CREATE /esrcc/i_costelmenetcharacte_s\\costelementcharall\_costelementchar,
      BEGIN OF ts_control,
        validfrom      TYPE if_abap_behv=>t_xflag,
        validto        TYPE if_abap_behv=>t_xflag,
        cost_indicator TYPE if_abap_behv=>t_xflag,
        posting_type   TYPE if_abap_behv=>t_xflag,
        usage_type     TYPE if_abap_behv=>t_xflag,
        value_source   TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_ce_char
        IMPORTING
          entity  TYPE ts_ce_char
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_cost_element_char
        IMPORTING
          entities TYPE tt_cost_element_char_create
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

  METHOD validate_ce_char.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validfrom      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto        = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.
    IF control-cost_indicator = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTINDICATOR' ) TO fields. ENDIF.
    IF control-posting_type   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'POSTINGTYPE' ) TO fields. ENDIF.
    IF control-usage_type     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'USAGETYPE' ) TO fields. ENDIF.
    IF control-value_source   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALUESOURCE' ) TO fields. ENDIF.

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

  METHOD precheck_cba_cost_element_char.
    TYPES ts_ce_char TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar.
    CONSTANTS c_vs_virtual TYPE /esrcc/ce_value_source VALUE 'SCC'.

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostElementCharAll' ) )
        source_entity_name = '/ESRCC/C_COSTELMENETCHARACTE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).

    SELECT SINGLE text
      FROM /esrcc/i_valuesource
      WHERE valuesource = @c_vs_virtual
      INTO @DATA(value_source_text).

    LOOP AT entities INTO DATA(entity).
*     Identify duplicate entries
      SELECT DISTINCT
             celem~costelementuuid
          FROM /esrcc/d_cstelmt AS celem
          INNER JOIN @entity-%target AS tent
              ON  tent~costelementuuid = celem~costelementuuid
              AND tent~validfrom       = celem~validfrom
          WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
          INTO TABLE @DATA(duplicate_entities).

*     Identify already assigned cost element entities
      SELECT DISTINCT
             tent~cstelmntcharuuid
          FROM /esrcc/d_cstelmt AS celem
          INNER JOIN @entity-%target AS tent
              ON  tent~sysid       = celem~sysid
              AND tent~legalentity = celem~legalentity
              AND tent~companycode = celem~companycode
              AND tent~valuesource = celem~valuesource
              AND tent~validfrom   BETWEEN celem~validfrom AND celem~validto
          WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
            AND tent~valuesource  = @c_vs_virtual
            AND celem~valuesource = @c_vs_virtual
          INTO TABLE @DATA(assigned_entities).

      LOOP AT entity-%target INTO DATA(target) GROUP BY ( costelementuuid  = target-costelementuuid
                                                          validfrom        = target-validfrom
                                                          size             = GROUP SIZE )
          ASCENDING REFERENCE INTO DATA(group_ref).
        READ TABLE entity-%target INTO DATA(t_entity) INDEX sy-tabix.

        lo_validation->validate_ce_char(
          entity  = CORRESPONDING #( group_ref->* )
          control = VALUE #( validfrom = if_abap_behv=>mk-on )
        ).

        " Validate duplicate entries
        IF line_exists( duplicate_entities[ costelementuuid = group_ref->costelementuuid ] ) OR group_ref->size > 1.
          lo_config_util->set_state_message(
            entity     = CORRESPONDING ts_ce_char( target )
            msg        = /esrcc/cl_config_msg_handler=>duplicate_key( )
            state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
        ELSEIF line_exists( assigned_entities[ cstelmntcharuuid = t_entity-cstelmntcharuuid ] ).
          " Validate cost element assignment
          lo_config_util->set_state_message(
            entity     = CORRESPONDING ts_ce_char( t_entity )
            msg        = /esrcc/cl_config_msg_handler=>duplicate_cost_element( v1 = value_source_text )
            state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/COSTELMENETCHARACTE'
                                       table_entity_relations = VALUE #( ( entity = 'CostElementChar' table = '/ESRCC/CSTELMTCH' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS c_source_entity TYPE sxco_cds_object_name VALUE '/ESRCC/C_COSTELMENETCHARACTE'.
    CONSTANTS c_path TYPE sxco_cds_association_name VALUE 'CostElementCharAll'.

    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costelementcharall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costelementcharall
        RESULT result,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR costelementchar
        RESULT result,
      precheck_cba_costelementchar FOR PRECHECK
        IMPORTING entities FOR CREATE costelementcharall\_costelementchar,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costelementchar~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costelementchar,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION costelementcharall~selectcustomizingtransptreq RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION costelementchar~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR costelementchar~validatetransportrequest.
    METHODS get_instance_features_1 FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR costelementchar RESULT result.

    METHODS get_global_authorizations_1 FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR costelementchar RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
    ENTITY costelementcharall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_costelementchar = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_COSTELMENETCHARACTE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD precheck_cba_costelementchar.
    lcl_custom_validation=>precheck_cba_cost_element_char(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-costelementchar
        reported = reported-costelementchar ).
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/c_costelmenetcharacte_s\\costelementchar.
    CONSTANTS c_vs_virtual TYPE /esrcc/ce_value_source VALUE 'SCC'.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
         ENTITY costelementchar
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT ele~*
      FROM /esrcc/d_cstelmt AS ele
      INNER JOIN @entities AS ent
        ON  ent~sysid        = ele~sysid
        AND ent~legalentity  = ele~legalentity
        AND ent~companycode  = ele~companycode
*        AND ent~costelement  = ele~costelement
      WHERE ele~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_ce_char) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = c_path ) )
        source_entity_name = c_source_entity
      CHANGING
        reported_entity    = reported-costelementchar
        failed_entity      = failed-costelementchar ).

    SELECT SINGLE text
        FROM /esrcc/i_valuesource
        WHERE valuesource = @c_vs_virtual
        INTO @DATA(value_source_text).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_ce_char ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_ce_char(
        entity  = entity
        control = VALUE #( validto        = if_abap_behv=>mk-on
                           cost_indicator = if_abap_behv=>mk-on
                           posting_type   = if_abap_behv=>mk-on
                           usage_type     = if_abap_behv=>mk-on
                           value_source   = if_abap_behv=>mk-on )
      ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date)
           WHERE     sysid            = entity-sysid
                 AND legalentity      = entity-legalentity
                 AND companycode      = entity-companycode
                 AND costelement      = entity-costelement
                 AND cstelmntcharuuid <> entity-cstelmntcharuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_ce_char->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                             src_to      = draft-validto
                                                             src_entity  = draft
                                                             curr_from   = entity-validfrom
                                                             curr_to     = entity-validto
                                                             curr_entity = entity ).
      ENDLOOP.

      IF entity-valuesource = c_vs_virtual.
        LOOP AT overlapping_dates INTO date WHERE cstelmntcharuuid <> entity-cstelmntcharuuid
                                              AND sysid            = entity-sysid
                                              AND legalentity      = entity-legalentity
                                              AND companycode      = entity-companycode
                                              AND valuesource      = c_vs_virtual
                                              AND ( validfrom      BETWEEN entity-validfrom AND entity-validto
                                                OR  validto        BETWEEN entity-validfrom AND entity-validto ).
          lo_ce_char->set_state_message(
            entity     = entity
            msg        = new_message(
                           id       = /esrcc/cl_config_util=>c_config_msg
                           number   = '030'
                           severity = if_abap_behv_message=>severity-error
                           v1       = value_source_text )
            state_area = CONV #( /esrcc/cl_config_util=>duplicate )
          ).
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = c_path ) )
          source_entity_name = c_source_entity
        CHANGING
          reported_entity    = reported-costelementchar
          failed_entity      = failed-costelementchar ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-costindicator = if_abap_behv=>mk-on
                                          OR %control-validto       = if_abap_behv=>mk-on
                                          OR %control-postingtype   = if_abap_behv=>mk-on
                                          OR %control-usagetype     = if_abap_behv=>mk-on
                                          OR %control-valuesource   = if_abap_behv=>mk-on.
      lo_validation->validate_ce_char(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto        = entity-%control-validto
                           cost_indicator = entity-%control-costindicator
                           posting_type   = entity-%control-postingtype
                           usage_type     = entity-%control-usagetype
                           value_source   = entity-%control-valuesource )
      ).
    ENDLOOP.
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
      ENTITY costelementcharall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
      ENTITY costelementcharall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_costelmenetcharacte_s\_costelementchar.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-costelementchar = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
      ENTITY costelementchar
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid            = key_cid
                             %is_draft       = <ref_main>-%is_draft
                             %data           = CORRESPONDING #( <ref_main> EXCEPT cstelmntcharuuid validfrom validto singletonid )
                             sysid           = key-%param-sysid
                             legalentity     = key-%param-legalentity
                             companycode     = key-%param-companycode
                             costelement     = key-%param-costelement
                             validfrom       = key-%param-validfrom
                             validto         = key-%param-validto
                             costelementuuid = key-%param-costelementuuid ) ) ) TO new_main.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_cost_element_char(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-costelementchar
        reported = reported-costelementchar ).

    IF failed-costelementchar IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementcharall CREATE BY \_costelementchar
        FIELDS (
                 sysid
                 legalentity
                 companycode
                 costelement
                 validfrom
                 validto
                 costtype
                 postingtype
                 costindicator
                 usagetype
                 reasonid
                 valuesource
                 costelementuuid
               ) WITH new_main
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-costelementchar = mapped_create-costelementchar.
    INSERT LINES OF read_failed-costelementchar INTO TABLE failed-costelementchar.

    IF failed-costelementchar IS INITIAL.
      reported-costelementchar = VALUE #( FOR created IN mapped-costelementchar (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-costelementcharall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_costelmenetcharacte_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_cstel_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/CSTELMTCH'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-costelementchar ) ).
  ENDMETHOD.

  METHOD get_instance_features_1.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations_1.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_COSTELMENETCHARACTE' ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costelementcharall INDEX 1 INTO DATA(all).
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
