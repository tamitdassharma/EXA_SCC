CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_object TYPE STRUCTURE FOR READ RESULT /esrcc/i_cstobjct_s\\costobject,

      BEGIN OF ts_control,
        costcenter    TYPE if_abap_behv=>t_xflag,
*        billfrequency TYPE if_abap_behv=>t_xflag,
      END OF ts_control,

      tt_cstobj_create TYPE TABLE FOR CREATE /esrcc/i_cstobjct_s\\costobjectall\_costobject.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_cost_object
        IMPORTING
          entity  TYPE ts_cost_object
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_cost_object
        IMPORTING
          entities TYPE tt_cstobj_create
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

  METHOD validate_cost_object.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-costcenter    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTCENTER' ) TO fields. ENDIF.
*    IF control-billfrequency = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'BILLINGFREQUENCY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_cost_object.
    TYPES ts_cost_object TYPE STRUCTURE FOR READ RESULT /esrcc/i_cstobjct_s\\costobject.

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostObjectAll' ) )
        source_entity_name = '/ESRCC/C_CSTOBJCT'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostObjectAll' ) )
        source_entity_name = '/ESRCC/C_CSTOBJCT'
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    LOOP AT entities INTO DATA(entity).
      SELECT DISTINCT
             cobj~sysid,
             cobj~legalentity,
             cobj~companycode,
             cobj~costobject,
             cobj~costcenter
          FROM /esrcc/d_cstobj AS cobj
          INNER JOIN @entity-%target AS tent
              ON  tent~sysid       = cobj~sysid
              AND tent~legalentity = cobj~legalentity
              AND tent~companycode = cobj~companycode
              AND tent~costobject  = cobj~costobject
              AND tent~costcenter  = cobj~costcenter
          WHERE cobj~draftentityoperationcode NOT IN ( 'D', 'L' )
          INTO TABLE @DATA(duplicate_entities).

      LOOP AT entity-%target INTO DATA(target) GROUP BY ( sysid       = target-sysid
                                                          legalentity = target-legalentity
                                                          companycode = target-companycode
                                                          costobject  = target-costobject
                                                          costcenter  = target-costcenter
                                                          size        = GROUP SIZE )
          ASCENDING REFERENCE INTO DATA(group_ref).
        lo_validation->validate_cost_object(
          entity  = CORRESPONDING #( group_ref->* )
          control = VALUE #( costcenter = if_abap_behv=>mk-on )
        ).

        lo_auth->check_authorization(
          EXPORTING
            entity     = CORRESPONDING ts_cost_object( group_ref->* )
            auth_value = VALUE #( cost_object = group_ref->costobject )
            activity   = /esrcc/cl_authorization=>c_authorization_activity-create
        ).

        IF line_exists( duplicate_entities[ sysid       = group_ref->sysid
                                            legalentity = group_ref->legalentity
                                            companycode = group_ref->companycode
                                            costobject  = group_ref->costobject
                                            costcenter  = group_ref->costcenter ] ) OR group_ref->size > 1.
          lo_cost_object->set_duplicate_error( entity = CORRESPONDING ts_cost_object( group_ref->* ) ).
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/CST_OBJCT'
                                       table_entity_relations = VALUE #( ( entity = 'CostObject' table = '/ESRCC/CST_OBJCT' )
                                                                         ( entity = 'CostObjectText' table = '/ESRCC/CST_OBJTT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_cstobjct_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costobjectall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costobjectall
        RESULT result,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION costobjectall~edit,
      precheck_cba_costobject FOR PRECHECK
        IMPORTING entities FOR CREATE costobjectall\_costobject,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION costobjectall~selectcustomizingtransptreq RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjct_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
    ENTITY costobjectall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_costobject = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CSTOBJCT' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.

  METHOD edit.
    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    SELECT DISTINCT legalentity, costobject FROM /esrcc/i_cstobjct INTO TABLE @DATA(cost_objects). "#EC CI_NOWHERE

    LOOP AT cost_objects INTO DATA(cost_object).
      DATA(is_unauthorized) = lo_auth->is_unauthorized(
        EXPORTING
          auth_value = CORRESPONDING #( cost_object MAPPING legal_entity = legalentity cost_object = costobject )
          create     = abap_true
          update     = abap_true
          delete     = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_true.
      reported-costobjectall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                              number   = '019'
                                                              severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_costobject.
    lcl_custom_validation=>precheck_cba_cost_object(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-costobject
        reported = reported-costobject ).
  ENDMETHOD.

  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
      ENTITY costobjectall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
      ENTITY costobjectall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_cstobjct_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_cstobjct_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costobjectall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_cstobjct DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costobject,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR costobject RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR costobject~validatedata.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE costobject.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR costobject RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION costobject~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR costobject~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjct IMPLEMENTATION.
  METHOD precheck_update.
    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'CostObjectAll' ) )
          assoc_paths        = VALUE #( ( path = '_CostObjectAll' ) )
          source_entity_name = '/ESRCC/C_CSTOBJCT'
        CHANGING
          reported_entity    = reported-costobject
          failed_entity      = failed-costobject ).

*    IF lo_cost_object->foreign_check_cost_object(
*      EXPORTING
*        entities          = entities
*        uuid_fieldname    = 'COSTOBJECTUUID'
*        error_fieldname   = 'LEGALENTITY'
*        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = costobjectuuid )
*        action            = VALUE #( update = abap_true )
*        foreign_check     = VALUE #( serv_consumption = abap_true serv_capacity = abap_true alloc_key = abap_true )
*    ) = abap_true.
*      RETURN.
*    ENDIF.

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

*    LOOP AT entities INTO DATA(entity) WHERE %control-billingfrequency = if_abap_behv=>mk-on.
*      lo_validation->validate_cost_object(
*        entity  = CORRESPONDING #( entity )
*        control = VALUE #( billfrequency = entity-%control-billingfrequency )
*      ).
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).

    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
        ENTITY costobject
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( paths = VALUE #( ( path = '_CostObjectText' ) ) ).

    LOOP AT keys INTO DATA(key).
      DATA(entity) = VALUE #( entities[ KEY draft %tky = key-%tky ] OPTIONAL ).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true copy = abap_true create_by_assoc = abap_true )
          auth_value            = VALUE #( legal_entity = entity-legalentity cost_object = entity-costobject )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
        ENTITY costobject
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
                             EXPORTING
                               paths              = VALUE #( ( path = 'CostObjectAll' ) )
                               assoc_paths        = VALUE #( ( path = '_CostObjectAll' ) )
                               source_entity_name = '/ESRCC/C_CSTOBJCT'
                             CHANGING
                               reported_entity    = reported-costobject
                               failed_entity      = failed-costobject
                           ).

*    lo_cost_object->foreign_check_cost_object(
*      EXPORTING
*        entities          = entities
*        uuid_fieldname    = 'COSTOBJECTUUID'
*        error_fieldname   = 'LEGALENTITY'
*        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = costobjectuuid )
*        action            = VALUE #( update = abap_true )
*        foreign_check     = VALUE #( serv_consumption = abap_true serv_capacity = abap_true alloc_key = abap_true )
*    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE billingfrequency IS INITIAL.
*      lo_validation->validate_cost_object(
*        entity  = <entity>
*        control = VALUE #( billfrequency = if_abap_behv=>mk-on )
*      ).
*    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
*    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
*        ENTITY costobject
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*
*    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
*                         EXPORTING
*                           paths              = VALUE #( ( path = 'CostObjectAll' )
*                                                         ( path = 'CostObject' ) )
*                           assoc_paths        = VALUE #( ( path = '_CostObjectAll' ) )
*                           source_entity_name = '/ESRCC/C_CSTOBJCT'
*                         CHANGING
*                           reported_entity    = reported-costobject
*                           failed_entity      = failed-costobject
*                       ).
*
*    lo_cost_object->foreign_check_cost_object(
*      EXPORTING
*        entities          = entities
*        uuid_fieldname    = 'COSTOBJECTUUID'
*        error_fieldname   = 'LEGALENTITY'
*        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = costobjectuuid )
*        action            = VALUE #( delete = abap_true )
*        foreign_check     = VALUE #( serv_consumption = abap_true serv_capacity = abap_true alloc_key = abap_true )
*    ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CSTOBJCT' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_cstobjct_s\_costobject,
      new_text TYPE TABLE FOR CREATE /esrcc/i_cstobjct_s\\costobject\_costobjecttext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-costobject = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
      ENTITY costobject
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
      ENTITY costobject BY \_costobjecttext
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
                             %data       = CORRESPONDING #( <ref_main> EXCEPT costobjectuuid sysid legalentity companycode costobject costcenter singletonid )
                             sysid       = key-%param-sysid
                             legalentity = key-%param-legalentity
                             companycode = key-%param-companycode
                             costobject  = key-%param-costobject
                             costcenter  = key-%param-costcenter ) ) ) TO new_main ASSIGNING FIELD-SYMBOL(<new>).

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft      = key-%tky-%is_draft
                                                                            AND %tky-costobjectuuid = key-%tky-costobjectuuid.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid                = key_cid && <ref_text>-spras
                        %is_draft           = key-%is_draft
                        %data               = CORRESPONDING #( <ref_text> EXCEPT costobjectuuid singletonid )
                         ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_cost_object(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-costobject
        reported = reported-costobject ).

    IF failed-costobject IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
        ENTITY costobjectall CREATE BY \_costobject
        FIELDS (
                 sysid
                 legalentity
                 companycode
                 costobject
                 costcenter
                 active
                 functionalarea
                 profitcenter
                 businessdivision
                 billingfrequency
                 hierarchy1
                 hierarchy2
                 hierarchy3
                 hierarchy4
               ) WITH new_main
        ENTITY costobject CREATE BY \_costobjecttext
        FIELDS (
                 spras
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-costobject = mapped_create-costobject.
    INSERT LINES OF read_failed-costobject INTO TABLE failed-costobject.

    IF failed-costobject IS INITIAL AND failed-costobjecttext IS INITIAL.
      reported-costobject = VALUE #( FOR created IN mapped-costobject (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-costobjectall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_cstobjct_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_cst_o_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/CST_OBJCT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-costobject ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_cstobjcttext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR costobjecttext RESULT result,
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING keys FOR costobjecttext~validatetransportrequest.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjcttext IMPLEMENTATION.
  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
            ENTITY costobjecttext
            BY \_costobject
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    LOOP AT keys INTO DATA(key).
      DATA(entity) = VALUE #( entities[ KEY draft %tky = CORRESPONDING #( key-%tky ) ] OPTIONAL ).
      lo_auth->set_authorization_for_instance(
        EXPORTING
          key                   = key
          set_authorization_for = VALUE #( update = abap_true delete = abap_true )
          auth_value            = VALUE #( legal_entity = entity-legalentity cost_object = entity-costobject )
        CHANGING
          result                = result
      ).
    ENDLOOP.
  ENDMETHOD.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_cstobjct_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_cst_o_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/CST_OBJTT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-costobjecttext ) ).
  ENDMETHOD.

ENDCLASS.
