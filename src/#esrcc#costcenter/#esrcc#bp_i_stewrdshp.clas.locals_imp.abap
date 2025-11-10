CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_stewardship            TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship,
      ts_service_product        TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct,
      ts_service_receiver       TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\servicereceiver,
      tt_sharecost              TYPE STANDARD TABLE OF /esrcc/stwd_sp WITH EMPTY KEY,
      tt_stewardship            TYPE TABLE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship,
      tt_stewardship_create     TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\stewardshipall\_stewardship,
      tt_service_product_create TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\stewardship\_serviceproduct,
      tt_receiver_create        TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\serviceproduct\_servicereceiver,

      BEGIN OF ts_control_stewardship,
        chainid       TYPE if_abap_behv=>t_xflag,
        chainsequence TYPE if_abap_behv=>t_xflag,
        validfrom     TYPE if_abap_behv=>t_xflag,
        validto       TYPE if_abap_behv=>t_xflag,
        stewardship   TYPE if_abap_behv=>t_xflag,
      END OF ts_control_stewardship,
      BEGIN OF ts_control_service_product,
        validfrom   TYPE if_abap_behv=>t_xflag,
        validto     TYPE if_abap_behv=>t_xflag,
        shareofcost TYPE if_abap_behv=>t_xflag,
      END OF ts_control_service_product,
      BEGIN OF ts_control_service_receiver,
        invoicecurrency TYPE if_abap_behv=>t_xflag,
      END OF ts_control_service_receiver.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_stewardship
        IMPORTING
          entity  TYPE ts_stewardship
          control TYPE ts_control_stewardship,
      validate_service_product
        IMPORTING
          entity  TYPE ts_service_product
          control TYPE ts_control_service_product,
      validate_service_receiver
        IMPORTING
          entity  TYPE ts_service_receiver
          control TYPE ts_control_service_receiver,
      calculate_costshare_sum
        IMPORTING
          sharecost     TYPE tt_sharecost
        EXPORTING
          sharecost_sum TYPE tt_sharecost.

    CLASS-METHODS:
      precheck_cba_stewardship
        IMPORTING
          entities TYPE tt_stewardship_create
        CHANGING
          reported TYPE any
          failed   TYPE any,

      precheck_cba_service_product
        IMPORTING
          entities TYPE tt_service_product_create
        CHANGING
          reported TYPE any
          failed   TYPE any,

      precheck_cba_receiver
        IMPORTING
          entities TYPE tt_receiver_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_stewardship.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-chainid       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHAINID' ) TO fields. ENDIF.
    IF control-chainsequence = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHAINSEQUENCE' ) TO fields. ENDIF.
    IF control-validfrom     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-stewardship = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'STEWARDSHIP' ) )
        entity = entity
      ).
    ENDIF.

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

  METHOD precheck_cba_stewardship.
    TYPES ts_stewardship TYPE STRUCTURE FOR CREATE /esrcc/i_stewrdshp_s\\stewardshipall\_stewardship.

    DATA(lo_stewardship) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_stewardship ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).

*   TEMPORARY VALIDATION: Since auto-populate using additionalBinding annotation is not working in ABAP Version 7.58 SP00,
*   the below validation is implemented that can be removed if issue is addressed or works in higher version
    SELECT db~*
        FROM /esrcc/cst_objct AS db
        INNER JOIN @target_entities AS tent
            ON tent~costobjectuuid = db~cost_object_uuid
        INTO TABLE @DATA(db_entries).

    SELECT DISTINCT
           stw~sysid,
           stw~legalentity,
           stw~companycode,
           stw~costobject,
           stw~costcenter
        FROM /esrcc/d_stewrds AS stw
        INNER JOIN @target_entities AS tent
            ON  tent~sysid       = stw~sysid
            AND tent~legalentity = stw~legalentity
            AND tent~companycode = stw~companycode
            AND tent~costobject  = stw~costobject
            AND tent~costcenter  = stw~costcenter
            AND tent~validfrom   = stw~validfrom
        WHERE stw~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( sysid       = entity-sysid
                                                         legalentity = entity-legalentity
                                                         companycode = entity-companycode
                                                         costobject  = entity-costobject
                                                         costcenter  = entity-costcenter
                                                         validfrom   = entity-validfrom
                                                         size        = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).

      READ TABLE target_entities INDEX sy-tabix INTO DATA(t_entity).

      CHECK lo_auth->check_authorization(
        EXPORTING
          entity     = t_entity
          auth_value = CORRESPONDING #( group_ref->* MAPPING legal_entity = legalentity cost_object = costobject cost_number = costcenter )
          activity   = /esrcc/cl_authorization=>c_authorization_activity-create
      ) = abap_true.

*     START: TEMPORARY VALIDATION
      DATA(db_entry) = VALUE #( db_entries[ cost_object_uuid = t_entity-costobjectuuid ] OPTIONAL ).
      DATA(sysid)   = COND abap_boolean( WHEN t_entity-sysid       <> db_entry-sysid        THEN abap_true ELSE abap_false ).
      DATA(le)      = COND abap_boolean( WHEN t_entity-legalentity <> db_entry-legal_entity THEN abap_true ELSE abap_false ).
      DATA(ccode)   = COND abap_boolean( WHEN t_entity-companycode <> db_entry-company_code THEN abap_true ELSE abap_false ).
      DATA(cobj)    = COND abap_boolean( WHEN t_entity-costobject  <> db_entry-cost_object  THEN abap_true ELSE abap_false ).
      DATA(ccenter) = COND abap_boolean( WHEN t_entity-costcenter  <> db_entry-cost_center  THEN abap_true ELSE abap_false ).

      IF sysid = abap_true OR le = abap_true OR ccode = abap_true OR cobj = abap_true OR ccenter = abap_true.
        lo_stewardship->set_state_message(
            entity     = entity
            msg        = /esrcc/cl_config_msg_handler=>no_entry_for_costobj( )
            state_area = CONV #( /esrcc/cl_config_util=>invalid_data )
      ).
      ENDIF.
*     END: TEMPORARY VALIDATION

      lo_validation->validate_stewardship(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF line_exists( duplicate_entities[ sysid       = group_ref->sysid
                                          legalentity = group_ref->legalentity
                                          companycode = group_ref->companycode
                                          costobject  = group_ref->costobject
                                          costcenter  = group_ref->costcenter ] ) OR group_ref->size > 1.
        lo_stewardship->set_duplicate_error( entity = t_entity ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_service_product.
    TYPES ts_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct.

    DATA(lo_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_product ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    DATA(stewardship_uuid) = VALUE #( entities[ 1 ]-stewardshipuuid ).
    SELECT DISTINCT
           prod~serviceproduct
        FROM /esrcc/d_stwd_sp AS prod
        INNER JOIN @target_entities AS tent
            ON  tent~serviceproduct  = prod~serviceproduct
            AND tent~validfrom       = prod~validfrom
        WHERE prod~draftentityoperationcode NOT IN ( 'D', 'L' )
          AND prod~stewardshipuuid = @stewardship_uuid
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( prod      = entity-serviceproduct
                                                         validfrom = entity-validfrom
                                                         size      = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      lo_validation->validate_service_product(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF line_exists( duplicate_entities[ serviceproduct = group_ref->prod ] ) OR group_ref->size > 1.
        lo_product->set_duplicate_error( entity = CORRESPONDING ts_product( group_ref->* ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_receiver.
    TYPES ts_receiver TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\servicereceiver.

    DATA(lo_receiver) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSPREC'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_receiver ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    DATA(service_product_uuid) = VALUE #( entities[ 1 ]-serviceproductuuid ).
    SELECT
           rec~serviceproductuuid,
           rec~costobjectuuid
        FROM /esrcc/d_stwdspr AS rec
        INNER JOIN @target_entities AS tent
            ON tent~costobjectuuid     = rec~costobjectuuid
        WHERE rec~draftentityoperationcode NOT IN ( 'D', 'L' )
          AND rec~serviceproductuuid = @service_product_uuid
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( costobjectuuid = entity-costobjectuuid size = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      IF line_exists( duplicate_entities[ costobjectuuid = group_ref->costobjectuuid ] ) OR group_ref->size > 1.
        lo_receiver->set_duplicate_error( entity = CORRESPONDING ts_receiver( group_ref->* ) ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_service_product.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-shareofcost = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'SHAREOFCOST' ) )
        entity = entity
      ).
    ENDIF.

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

      IF control-validto = if_abap_behv=>mk-on.
        config_util_ref->validate_initial(
          fields = VALUE #( ( fieldname = 'VALIDTO' ) )
          entity = entity
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_service_receiver.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-invoicecurrency = if_abap_behv=>mk-on. fields = VALUE #( ( fieldname = 'INVOICECURRENCY' ) ). ENDIF.

    config_util_ref->validate_initial(
      fields     = fields
      entity     = entity
    ).
  ENDMETHOD.

  METHOD calculate_costshare_sum.
    SELECT stewardship_uuid, valid_from AS date
      FROM @sharecost AS share
      WHERE share~valid_to <> '00000000'
      INTO TABLE @DATA(dates).

    SELECT stewardship_uuid,
           CASE WHEN share~valid_to <> '99991231' THEN dats_add_days( share~valid_to , 1 ) ELSE share~valid_to END AS date
      FROM @sharecost AS share
      WHERE share~valid_to <> '00000000'
      APPENDING TABLE @dates.

    SORT dates BY stewardship_uuid date.
    DELETE ADJACENT DUPLICATES FROM dates COMPARING stewardship_uuid date.
    DATA(count) = lines( dates ).

    DATA curr LIKE LINE OF dates.
    LOOP AT dates INTO DATA(date).
      IF curr-stewardship_uuid <> date-stewardship_uuid.
        curr = CORRESPONDING #( date ).
        APPEND CORRESPONDING #( date MAPPING valid_from = date ) TO sharecost_sum ASSIGNING FIELD-SYMBOL(<sum>).
      ELSE.
        <sum>-valid_to = COND #( WHEN date-date <> '99991231' THEN date-date - 1 ELSE date-date ).
        LOOP AT sharecost INTO DATA(share) WHERE stewardship_uuid = date-stewardship_uuid.
          IF <sum>-valid_from BETWEEN share-valid_from AND share-valid_to OR
             <sum>-valid_to BETWEEN share-valid_from AND share-valid_to.
            <sum>-share_of_cost = <sum>-share_of_cost + share-share_of_cost.
          ENDIF.
        ENDLOOP.
        IF count <> sy-tabix.
          APPEND CORRESPONDING #( date MAPPING valid_from = date ) TO sharecost_sum ASSIGNING <sum>.
        ENDIF.
      ENDIF.
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/STEWRDSHP'
                                       table_entity_relations = VALUE #( ( entity = 'Stewardship' table = '/ESRCC/STEWRDSHP' )
                                                                         ( entity = 'ServiceProduct' table = '/ESRCC/STWD_SP' )
                                                                         ( entity = 'ServiceReceiver' table = '/ESRCC/STWDSPREC' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_stewrdshp_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR stewardshipall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR stewardshipall
        RESULT result,
      precheck_cba_stewardship FOR PRECHECK
        IMPORTING entities FOR CREATE stewardshipall\_stewardship,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION stewardshipall~edit,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION stewardshipall~selectcustomizingtransptreq RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_stewrdshp_s IMPLEMENTATION.
  METHOD get_instance_features.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ).
      DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    ELSE.
      edit_flag = if_abap_behv=>fc-o-enabled.
    ENDIF.

    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
    ENTITY stewardshipall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_stewardship = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_STEWRDSHP' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_stewardship.
    lcl_custom_validation=>precheck_cba_stewardship(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-stewardship
        reported = reported-stewardship ).
  ENDMETHOD.

  METHOD edit.
    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    SELECT DISTINCT legalentity FROM /esrcc/i_stewrdshp INTO TABLE @DATA(legal_entities). "#EC CI_NOWHERE

    LOOP AT legal_entities INTO DATA(entity).
      DATA(is_unauthorized) = lo_auth->is_unauthorized(
        EXPORTING
          auth_value = VALUE #( legal_entity = entity-legalentity )
          create     = abap_true
          update     = abap_true
          delete     = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_false.
      SELECT DISTINCT costobject, costcenter FROM /esrcc/i_stewrdshp INTO TABLE @DATA(cost_numbers). "#EC CI_NOWHERE
      LOOP AT cost_numbers INTO DATA(cost_number).
        is_unauthorized = lo_auth->is_unauthorized(
          EXPORTING
            auth_value = CORRESPONDING #( cost_number MAPPING cost_object = costobject cost_number = costcenter )
            create      = abap_true
            update      = abap_true
            delete      = abap_true
        ).

        IF is_unauthorized = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF is_unauthorized = abap_true.
      reported-stewardshipall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                               number   = '019'
                                                               severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY stewardshipall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY stewardshipall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_stewrdshp_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_stewrdshp_s IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-stewardshipall INDEX 1 INTO DATA(all).
      IF all-transportrequestid IS NOT INITIAL.
        lhc_rap_tdat_cts=>get( )->record_changes(
                                    transport_request = all-transportrequestid
                                    create            = REF #( create )
                                    update            = REF #( update )
                                    delete            = REF #( delete ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_stewrdshp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_stewardship TYPE TABLE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship.

    CLASS-METHODS set_workflow_status
      IMPORTING
        entities                     TYPE tt_stewardship
        for_workflow_internal_status TYPE /esrcc/status_de
        to_workflow_status           TYPE /esrcc/status_de.

    CLASS-METHODS set_workflow_internal_status
      IMPORTING
        entities           TYPE tt_stewardship
        to_workflow_status TYPE /esrcc/status_de.

  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR stewardship RESULT result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
            IMPORTING REQUEST requested_authorizations FOR stewardship RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~submit RESULT result.
    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~finalize RESULT result.
    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR stewardship~updateworkflowstatus.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR stewardship~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE stewardship.
    METHODS precheck_cba_serviceproduct FOR PRECHECK
      IMPORTING entities FOR CREATE stewardship\_serviceproduct.
    METHODS precheck_cba_servicereceiver FOR PRECHECK
      IMPORTING entities FOR CREATE serviceproduct\_servicereceiver.
    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR stewardship~triggerworkflow.
    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR stewardship~updateinternalworkflowstatus.
    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~reopen RESULT result.
    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR stewardship~updatecomment.
    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~copy.
    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR stewardship~validatetransportrequest.

ENDCLASS.

CLASS lhc_/esrcc/i_stewrdshp IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
          ENTITY stewardship
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( paths = VALUE #( ( path = '_ServiceProduct' ) ( path = '_ServiceReceiver' ) ) ).
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      LOOP AT keys INTO DATA(key).
        DATA(entity) = VALUE #( entities[ KEY draft %tky = key-%tky ] OPTIONAL ).
        lo_auth->set_authorization_for_instance(
          EXPORTING
            key                   = key
            set_authorization_for = VALUE #( update = abap_true delete = abap_true copy = abap_true create_by_assoc = abap_true )
            auth_value            = VALUE #( legal_entity = entity-legalentity cost_object = entity-costobject cost_number = entity-costcenter )
          CHANGING
            result                = result
        ).
      ENDLOOP.
      DATA(auth_result) = result.
    ENDIF.

    result = VALUE #( FOR wa IN entities
                      LET update   = COND #( WHEN VALUE #( auth_result[ KEY draft %tky = wa-%tky ]-%update OPTIONAL ) = if_abap_behv=>fc-o-disabled
                                                THEN if_abap_behv=>fc-o-disabled
                                             ELSE lo_auth->regulate_action_update( wf_status = wa-workflowstatus ) )
                          delete   = COND #( WHEN VALUE #( auth_result[ KEY draft %tky = wa-%tky ]-%delete OPTIONAL ) = if_abap_behv=>fc-o-disabled
                                                THEN if_abap_behv=>fc-o-disabled
                                             ELSE lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus ) )
                      IN ( %tky                    = wa-%tky
                           %action-copy            = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-submit          = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-finalize        = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-reopen          = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %update                 = update
                           %delete                 = delete
                           %assoc-_serviceproduct  = update ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_STEWRDSHIP' ).
  ENDMETHOD.

  METHOD submit.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities)

        ENTITY stewardship
        BY \_serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(products).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        BY \_servicereceiver
        ALL FIELDS WITH CORRESPONDING #( products )
        RESULT DATA(receivers).

*   Validate Products & Receivers
    IF products IS INITIAL.
      /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'StewardshipAll' ) )
          source_entity_name = '/ESRCC/C_STEWRDSHIP'
        CHANGING
          reported_entity    = reported-stewardship
          failed_entity      = failed-stewardship
      )->set_state_message(
        entity     = entities[ 1 ]
        msg        = new_message(
                       id       = /esrcc/cl_config_util=>c_config_msg
                       number   = '027'
                       severity = if_abap_behv_message=>severity-error
                       v1       = COND scx_attrname( WHEN products IS INITIAL AND receivers IS INITIAL THEN TEXT-002
                                                     WHEN products IS INITIAL THEN TEXT-003 ) )
        state_area = CONV #( /esrcc/cl_config_util=>child_mandatory )
      ).
      RETURN.
    ELSE.
      DATA(lo_config) = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'StewardshipAll' )
                                        ( path = 'Stewardship' ) )
          source_entity_name = '/ESRCC/C_STWDSP'
        CHANGING
          reported_entity    = reported-serviceproduct
          failed_entity      = failed-serviceproduct
      ).

      LOOP AT products INTO DATA(product).
        IF NOT line_exists( receivers[ serviceproductuuid = product-serviceproductuuid ] ).
          lo_config->set_state_message(
            entity     = product
            msg        = new_message(
                           id       = /esrcc/cl_config_util=>c_config_msg
                           number   = '027'
                           severity = if_abap_behv_message=>severity-error
                           v1       = TEXT-004 )
            state_area = CONV #( /esrcc/cl_config_util=>child_mandatory ) ).
          DATA(validation_failed) = abap_true.
        ELSEIF NOT line_exists( receivers[ serviceproductuuid = product-serviceproductuuid active = abap_true ] ).
          lo_config->set_state_message(
            entity     = product
            msg        = new_message(
                           id       = /esrcc/cl_config_util=>c_config_msg
                           number   = '031'
                           severity = if_abap_behv_message=>severity-error )
            state_area = CONV #( /esrcc/cl_config_util=>child_mandatory ) ).
          validation_failed = abap_true.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF validation_failed = abap_true.
      RETURN.
    ENDIF.

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
            ENTITY stewardship
            UPDATE FIELDS ( commentid comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
            WITH VALUE #( FOR entity IN entities
                            ( %tky                      = entity-%tky
                              workflowid                = ''
                              commentid                 = COND #( WHEN entity-commentid IS INITIAL THEN cl_uuid_factory=>create_system_uuid( )->create_uuid_c32( ) ELSE entity-commentid )
                              comments                  = VALUE #( keys[ KEY draft %tky = entity-%tky ]-%param-comments OPTIONAL )
                              workflowstatus            = /esrcc/cl_wf_utility=>wf_status-in_process
                              workflowstatuscriticality = criticality
                              workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-in_process ) )
            FAILED failed
            REPORTED reported
            MAPPED mapped.
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param = entity ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-finalize_in_process ).
    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-finalize_in_process
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-finalize_in_process
                          workflowstatuscriticality = criticality ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky %param = entity ) ).
    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD updateworkflowstatus.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set workflow status to "Draft"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>wf_status-draft
      to_workflow_status           = /esrcc/cl_wf_utility=>wf_status-draft
    ).

    " Set workflow status to "Finalized"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>wf_status-finalize_in_process
      to_workflow_status           = /esrcc/cl_wf_utility=>wf_status-finalized
    ).

    " Set workflow status to "Approved"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>wf_status-reopen_in_process
      to_workflow_status           = /esrcc/cl_wf_utility=>wf_status-approved
    ).
  ENDMETHOD.

  METHOD set_workflow_status.
    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = to_workflow_status ).
    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus = for_workflow_internal_status )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowstatus            = to_workflow_status
                          workflowstatuscriticality = criticality
                          %control                  = VALUE #( workflowstatus            = if_abap_behv=>mk-on
                                                               workflowstatuscriticality = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.


  METHOD set_workflow_internal_status.
    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
          ENTITY stewardship
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> to_workflow_status )
                          ( %tky                   = entity-%tky
                            %is_draft              = entity-%is_draft
                            workflowinternalstatus = to_workflow_status
                            %control               = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD validatedata.
    DATA:
      draft           TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship,
      service_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY stewardship
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT st~*
      FROM /esrcc/d_stewrds AS st
      INNER JOIN @entities AS ent
        ON  ent~sysid       = st~sysid
        AND ent~legalentity = st~legalentity
        AND ent~companycode = st~companycode
        AND ent~costobject  = st~costobject
        AND ent~costcenter  = st~costcenter
      WHERE st~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    " To validate duplicate chain sequence
    DATA overlapping_chain_seqs TYPE TABLE OF /esrcc/d_stewrds.
    SELECT st~*
      FROM /esrcc/d_stewrds AS st
      INNER JOIN @entities AS ent
        ON  ent~chainid = st~chainid
        AND ent~chainid <> ''
        AND ( st~validfrom BETWEEN ent~validfrom AND ent~validto OR st~validto BETWEEN ent~validfrom AND ent~validto )
      WHERE st~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO CORRESPONDING FIELDS OF TABLE @overlapping_chain_seqs.
    SORT overlapping_chain_seqs BY stewardshipuuid.
    DELETE ADJACENT DUPLICATES FROM overlapping_chain_seqs COMPARING stewardshipuuid.

    " Calculate sum of share % for Service Product
    SELECT share~stewardshipuuid, share~validfrom, share~validto, share~shareofcost, share~serviceproductuuid
      FROM /esrcc/d_stwd_sp AS share
      INNER JOIN @entities AS ent
        ON  ent~stewardshipuuid = share~stewardshipuuid
      WHERE share~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(products).

    DATA(lo_stewardship) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
      CHANGING
        reported_entity    = reported-stewardship
        failed_entity      = failed-stewardship ).

    DATA(lo_service_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_stewardship ).
    lo_validation->calculate_costshare_sum(
      EXPORTING
        sharecost     = CORRESPONDING #( products )
      IMPORTING
        sharecost_sum = DATA(sharecost_sum) ).

    DATA(chain_sequence_text) = lo_stewardship->get_field_text( fieldname = 'CHAINSEQUENCE' data_element = '/ESRCC/CHAIN_SEQUENCE' ).
    DATA(chain_id_text) = lo_stewardship->get_field_text( fieldname = 'CHAINID' data_element = '/ESRCC/CHAIN_ID' ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_stewardship( entity  = entity
                                           control = VALUE #( chainid       = COND #( WHEN entity-chainsequence IS NOT INITIAL THEN if_abap_behv=>mk-on )
                                                              chainsequence = COND #( WHEN entity-chainid IS NOT INITIAL THEN if_abap_behv=>mk-on )
                                                              validto       = if_abap_behv=>mk-on
                                                              stewardship   = if_abap_behv=>mk-on ) ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE sysid           = entity-sysid
                                                  AND legalentity     = entity-legalentity
                                                  AND companycode     = entity-companycode
                                                  AND costobject      = entity-costobject
                                                  AND costcenter      = entity-costcenter
                                                  AND stewardshipuuid <> entity-stewardshipuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_stewardship->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                                 src_to      = draft-validto
                                                                 src_entity  = draft
                                                                 curr_from   = entity-validfrom
                                                                 curr_to     = entity-validto
                                                                 curr_entity = entity ).
      ENDLOOP.

      " Validate validity of Service Product
      LOOP AT products INTO DATA(product) WHERE stewardshipuuid = entity-stewardshipuuid
                                            AND ( validfrom NOT BETWEEN entity-validfrom AND entity-validto
                                             OR   validto NOT BETWEEN entity-validfrom AND entity-validto ).
        service_product = CORRESPONDING #( product ).
        service_product = CORRESPONDING #( BASE ( service_product ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_product->set_state_message(
          entity     = service_product
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '013' severity = cl_abap_behv=>ms-error )
          state_area = CONV #( /esrcc/cl_config_util=>date_out_of_range )
        ).
      ENDLOOP.

      " Reset State Area
      lo_stewardship->reset_state_area( entity = entity state_area = CONV #( /esrcc/cl_config_util=>overlapping_sequence ) ).

      " Validate chain sequence
      LOOP AT overlapping_chain_seqs INTO DATA(chain_seq) WHERE stewardshipuuid <> entity-stewardshipuuid.
        draft = CORRESPONDING #( chain_seq ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).

        " Reset State Area
        lo_stewardship->reset_state_area( entity = draft state_area = CONV #( /esrcc/cl_config_util=>overlapping_sequence ) ).

        IF chain_seq-chainid = entity-chainid AND
           chain_seq-chainsequence = entity-chainsequence AND
           ( chain_seq-validfrom BETWEEN entity-validfrom AND entity-validto OR chain_seq-validto BETWEEN entity-validfrom AND entity-validto ).
          lo_stewardship->set_state_message(
            fieldname  = 'CHAINSEQUENCE'
            entity     = draft
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '024' severity = cl_abap_behv=>ms-error
                                      v1 = chain_sequence_text
                                      v2 = chain_id_text
                                      v3 = chain_seq-chainid )
            state_area = CONV #( /esrcc/cl_config_util=>overlapping_sequence )
          ).

          lo_stewardship->set_state_message(
            fieldname  = 'CHAINSEQUENCE'
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '024' severity = cl_abap_behv=>ms-error
                                      v1 = chain_sequence_text
                                      v2 = chain_id_text
                                      v3 = chain_seq-chainid )
            state_area = CONV #( /esrcc/cl_config_util=>overlapping_sequence )
          ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
      CHANGING
        reported_entity    = reported-stewardship
        failed_entity      = failed-stewardship ) ).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(stewardships).

    LOOP AT entities INTO DATA(entity) WHERE %control-chainid       = if_abap_behv=>mk-on
                                          OR %control-chainsequence = if_abap_behv=>mk-on
                                          OR %control-stewardship   = if_abap_behv=>mk-on
                                          OR %control-validto       = if_abap_behv=>mk-on.
      IF entity-%control-chainid = if_abap_behv=>mk-on AND entity-%control-chainsequence = if_abap_behv=>mk-off.
        entity-chainsequence = stewardships[ KEY draft %tky = entity-%tky ]-chainsequence.
      ENDIF.

      IF entity-%control-chainid = if_abap_behv=>mk-off AND entity-%control-chainsequence = if_abap_behv=>mk-on.
        entity-chainid = stewardships[ KEY draft %tky = entity-%tky ]-chainid.
      ENDIF.

      lo_validation->validate_stewardship(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chainid       = COND #( WHEN entity-chainsequence IS NOT INITIAL THEN if_abap_behv=>mk-on )
                           chainsequence = COND #( WHEN entity-chainid IS NOT INITIAL THEN if_abap_behv=>mk-on )
                           validto       = entity-%control-validto
                           stewardship   = entity-%control-stewardship )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_serviceproduct.
    lcl_custom_validation=>precheck_cba_service_product(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-serviceproduct
        reported = reported-serviceproduct ).
  ENDMETHOD.


  METHOD precheck_cba_servicereceiver.
    lcl_custom_validation=>precheck_cba_receiver(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-servicereceiver
        reported = reported-servicereceiver ).
  ENDMETHOD.

  METHOD triggerworkflow.
    DATA leading_objects_failed TYPE /esrcc/tt_wf_leadingobject_err.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>app-bc_stewardship ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.
      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject( entities MAPPING stewardship_uuid = stewardshipuuid EXCEPT * )
        IMPORTING
          leading_objects_error = leading_objects_failed
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( stewardshipuuid           = failed-leading_object-stewardship_uuid
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
          ENTITY stewardship
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-approved
                          workflowstatuscriticality = criticality
                          workflowinternalstatus    = workflow_internal_status ) )
        FAILED failed_mod
        MAPPED mapped_mod.
    ENDIF.
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set internal status to "Draft" for modified entries
    set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>wf_status-draft
    ).
  ENDMETHOD.

  METHOD reopen.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowid                = ''
                          workflowstatus            = /esrcc/cl_wf_utility=>wf_status-reopen_in_process
                          workflowstatuscriticality = criticality
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>wf_status-reopen_in_process ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param = entity ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD updatecomment.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity) WHERE commentid IS NOT INITIAL.
      /esrcc/cl_comments_util=>modify_comments(
        comments    = VALUE #( instanceid = entity-commentid )
        iv_comments = entity-comments
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main  TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\_stewardship,
      new_prod  TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\stewardship\_serviceproduct,
      new_rec   TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\serviceproduct\_servicereceiver,
      copy_badi TYPE REF TO /esrcc/bc_copy_feature.

    FIELD-SYMBOLS:
      <new_prod> LIKE LINE OF new_prod,
      <new_rec>  LIKE LINE OF new_rec.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-stewardship = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    GET BADI copy_badi.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY stewardship
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY stewardship BY \_serviceproduct
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_prod).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY serviceproduct BY \_servicereceiver
      ALL FIELDS WITH CORRESPONDING #( ref_prod )
      RESULT DATA(ref_rec).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid           = key_cid
                             %is_draft      = <ref_main>-%is_draft
                             %data          = CORRESPONDING #( <ref_main> EXCEPT stewardshipuuid costobjectuuid sysid legalentity companycode costobject costcenter validfrom validto singletonid )
                             costobjectuuid = key-%param-costobjectuuid
                             sysid          = key-%param-sysid
                             legalentity    = key-%param-legalentity
                             companycode    = key-%param-companycode
                             costobject     = key-%param-costobject
                             costcenter     = key-%param-costcenter
                             validfrom      = key-%param-validfrom
                             validto        = key-%param-validto ) ) ) TO new_main.

      UNASSIGN <new_prod>.
      LOOP AT ref_prod ASSIGNING FIELD-SYMBOL(<ref_prod>) USING KEY draft WHERE %tky-%is_draft  = key-%tky-%is_draft
                                                                            AND stewardshipuuid = key-%tky-stewardshipuuid.
        IF <new_prod> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_prod ASSIGNING <new_prod>.
        ENDIF.

        DATA(prod_cid) = key_cid && <ref_prod>-serviceproductuuid.
        DATA(parent_validity)        = VALUE /esrcc/if_bc_copy_feature=>ts_validity( from = <ref_main>-validfrom to = <ref_main>-validto ).
        DATA(parent_target_validity) = VALUE /esrcc/if_bc_copy_feature=>ts_validity( from = key-%param-validfrom to = COND #( WHEN key-%param-validto IS NOT INITIAL THEN key-%param-validto ELSE <ref_main>-validto ) ).
        DATA(child_validity)         = VALUE /esrcc/if_bc_copy_feature=>ts_validity( from = <ref_prod>-validfrom to = <ref_prod>-validto ).

        CALL BADI copy_badi->auto_adjust_child_validity
          EXPORTING
            is_parent_validity        = parent_validity
            is_parent_target_validity = parent_target_validity
          CHANGING
            cs_child_validity         = child_validity.

        INSERT VALUE #( %cid      = prod_cid
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_prod> EXCEPT serviceproductuuid stewardshipuuid validfrom validto singletonid )
                        validfrom = child_validity-from
                        validto   = child_validity-to ) INTO TABLE <new_prod>-%target.

        UNASSIGN <new_rec>.
        LOOP AT ref_rec ASSIGNING FIELD-SYMBOL(<ref_rec>) USING KEY draft WHERE %tky-%is_draft     = <ref_prod>-%tky-%is_draft
                                                                            AND serviceproductuuid = <ref_prod>-%tky-serviceproductuuid.
          IF <new_rec> IS NOT ASSIGNED.
            INSERT VALUE #( %cid_ref  = prod_cid
                            %is_draft = key-%is_draft ) INTO TABLE new_rec ASSIGNING <new_rec>.
          ENDIF.

          INSERT VALUE #( %cid      = prod_cid && <ref_rec>-servicereceiveruuid
                          %is_draft = key-%is_draft
                          %data     = CORRESPONDING #( <ref_rec> EXCEPT servicereceiveruuid serviceproductuuid singletonid ) ) INTO TABLE <new_rec>-%target.
        ENDLOOP.
      ENDLOOP.

      SORT <new_prod>-%target BY serviceproduct validfrom.
      DELETE ADJACENT DUPLICATES FROM <new_prod>-%target COMPARING serviceproduct validfrom.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_stewardship(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-stewardship
        reported = reported-stewardship ).

    IF failed-stewardship IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardshipall CREATE BY \_stewardship
        FIELDS (
                 sysid
                 legalentity
                 companycode
                 costobject
                 costcenter
                 validfrom
                 validto
                 stewardship
                 costobjectuuid
                 chainid
                 chainsequence
               ) WITH new_main
        ENTITY stewardship CREATE BY \_serviceproduct
        FIELDS (
                 serviceproduct
                 validfrom
                 validto
                 shareofcost
               ) WITH new_prod
        ENTITY serviceproduct CREATE BY \_servicereceiver
        FIELDS (
                 costobjectuuid
                 sysid
                 legalentity
                 companycode
                 costobject
                 costcenter
                 invoicecurrency
                 erpsalesorder
                 contractid
                 active
               ) WITH new_rec
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-stewardship = mapped_create-stewardship.
    INSERT LINES OF read_failed-stewardship INTO TABLE failed-stewardship.

    IF failed-stewardship IS INITIAL AND failed-serviceproduct IS INITIAL AND failed-servicereceiver IS INITIAL.
      reported-stewardship = VALUE #( FOR created IN mapped-stewardship (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-stewardshipall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_stewrdshp_s.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_stewr_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/STEWRDSHP'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-stewardship ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_serviceproduct DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR serviceproduct RESULT result.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE serviceproduct.

    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR serviceproduct~validatedata.
    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR serviceproduct~updateinternalworkflowstatus.
    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR serviceproduct~validatetransportrequest.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR serviceproduct RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION serviceproduct~copy.

ENDCLASS.

CLASS lhc_serviceproduct IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(service_products).

    SELECT SINGLE stw~workflowstatus
        FROM /esrcc/i_stewrdshp AS stw
        INNER JOIN @service_products AS srv_prd
            ON srv_prd~stewardshipuuid = stw~stewardshipuuid
        INTO @DATA(wf_status).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    DATA(regulate_update) = lo_auth->regulate_action_update( wf_status = wf_status ).
    DATA(regulate_delete) = lo_auth->regulate_action_delete( wf_status = wf_status ).

    result = VALUE #( FOR wa IN service_products
                         ( %tky    = wa-%tky
                           %update = regulate_update
                           %delete = regulate_delete
                           %action-copy = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wf_status )
                           %assoc-_servicereceiver = regulate_update ) ).
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-shareofcost = if_abap_behv=>mk-on
                                          OR %control-validfrom   = if_abap_behv=>mk-on
                                          OR %control-validto     = if_abap_behv=>mk-on.
      lo_validation->validate_service_product(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto     = entity-%control-validto
                           shareofcost = entity-%control-shareofcost )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft                    TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct,
          current_stewardship_uuid TYPE sysuuid_x16.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY serviceproduct
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities)

         ENTITY serviceproduct
         BY \_stewardship
         FIELDS ( validfrom validto ) WITH CORRESPONDING #( keys )
         RESULT DATA(stewardships).

    SELECT prod~*
      FROM /esrcc/d_stwd_sp AS prod
      INNER JOIN @entities AS ent
        ON  ent~serviceproduct  = prod~serviceproduct
        AND ent~stewardshipuuid = prod~stewardshipuuid
      WHERE prod~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_service_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_service_product ).
    lo_validation->calculate_costshare_sum(
      EXPORTING
        sharecost     = CORRESPONDING #( entities MAPPING service_product_uuid = serviceproductuuid
                                                          service_product      = serviceproduct
                                                          valid_from           = validfrom
                                                          valid_to             = validto
                                                          share_of_cost        = shareofcost
                                                          stewardship_uuid     = stewardshipuuid )
      IMPORTING
        sharecost_sum = DATA(sharecost_sum)
    ).

    SORT entities BY stewardshipuuid serviceproductuuid validfrom.
    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_product(
        entity  = entity
        control = VALUE #( validto = if_abap_behv=>mk-on shareofcost = if_abap_behv=>mk-on )
      ).

      " Validate sum of share cost
      IF current_stewardship_uuid <> entity-stewardshipuuid.
        current_stewardship_uuid = entity-stewardshipuuid.
        lo_service_product->validate_percentage_100(
          value  = VALUE #( sharecost_sum[ stewardship_uuid = entity-stewardshipuuid ]-share_of_cost OPTIONAL )
          entity = entity
        ).
      ENDIF.

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE serviceproduct     = entity-serviceproduct
                                                  AND stewardshipuuid    = entity-stewardshipuuid
                                                  AND serviceproductuuid <> entity-serviceproductuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_product->validate_overlapping_validity(
          src_from    = draft-validfrom
          src_to      = draft-validto
          src_entity  = draft
          curr_from   = entity-validfrom
          curr_to     = entity-validto
          curr_entity = entity
        ).
      ENDLOOP.

      " Validate dates overflow with Cost Object Type validity
      DATA(stw) = VALUE #( stewardships[ KEY entity stewardshipuuid = entity-stewardshipuuid ] OPTIONAL ).
      IF     stw IS NOT INITIAL
         AND (    entity-validfrom NOT BETWEEN stw-validfrom AND stw-validto
               OR entity-validto NOT BETWEEN stw-validfrom AND stw-validto ).
        lo_service_product->set_state_message(
          entity     = entity
          msg        = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                    number   = '013'
                                    severity = cl_abap_behv=>ms-error )
          state_area = CONV #( /esrcc/cl_config_util=>date_out_of_range )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        BY \_stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      SELECT DISTINCT prod~stewardshipuuid, key~%is_draft
        FROM /esrcc/i_stwdsp AS prod
        INNER JOIN @keys AS key
          ON key~serviceproductuuid = prod~serviceproductuuid
        INTO CORRESPONDING FIELDS OF TABLE @entities.
    ENDIF.

    lhc_/esrcc/i_stewrdshp=>set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>wf_status-draft
    ).
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_stewrdshp_s.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_stewr_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/STWD_SP'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-serviceproduct ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_STEWRDSHP' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\stewardship\_serviceproduct,
      new_rec  TYPE TABLE FOR CREATE /esrcc/i_stewrdshp_s\\serviceproduct\_servicereceiver.

    FIELD-SYMBOLS <new_rec> LIKE LINE OF new_rec.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-serviceproduct = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY serviceproduct
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
      ENTITY serviceproduct BY \_servicereceiver
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_rec).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %is_draft = <ref_main>-%is_draft
        stewardshipuuid = <ref_main>-stewardshipuuid
        %target = VALUE #( ( %cid           = key_cid
                             %is_draft      = <ref_main>-%is_draft
                             %data          = CORRESPONDING #( <ref_main> EXCEPT serviceproductuuid serviceproduct validfrom validto singletonid )
                             serviceproduct = key-%param-serviceproduct
                             validfrom      = key-%param-validfrom
                             validto        = key-%param-validto ) ) ) TO new_main.

      UNASSIGN <new_rec>.
      LOOP AT ref_rec ASSIGNING FIELD-SYMBOL(<ref_rec>) USING KEY draft WHERE %tky-%is_draft     = key-%tky-%is_draft
                                                                          AND serviceproductuuid = key-%tky-serviceproductuuid.
        DATA(tabix) = sy-tabix.
        IF <new_rec> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_rec ASSIGNING <new_rec>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && tabix
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_rec> EXCEPT servicereceiveruuid serviceproductuuid singletonid ) ) INTO TABLE <new_rec>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_service_product(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-serviceproduct
        reported = reported-serviceproduct ).

    IF failed-serviceproduct IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship CREATE BY \_serviceproduct
        FIELDS (
                 serviceproduct
                 validfrom
                 validto
                 shareofcost
                 stewardshipuuid
               ) WITH new_main
        ENTITY serviceproduct CREATE BY \_servicereceiver
        FIELDS (
                 costobjectuuid
                 sysid
                 legalentity
                 companycode
                 costobject
                 costcenter
                 invoicecurrency
                 erpsalesorder
                 contractid
                 active
               ) WITH new_rec
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-serviceproduct = mapped_create-serviceproduct.
    INSERT LINES OF read_failed-serviceproduct INTO TABLE failed-serviceproduct.

    IF failed-serviceproduct IS INITIAL AND failed-servicereceiver IS INITIAL.
      reported-serviceproduct = VALUE #( FOR created IN mapped-serviceproduct (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-stewardshipall = VALUE #( %is_draft = created-%is_draft ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_servicereceiver DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR servicereceiver RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR servicereceiver~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE servicereceiver.
    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR servicereceiver~updateinternalworkflowstatus.
    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR servicereceiver~validatetransportrequest.

ENDCLASS.

CLASS lhc_servicereceiver IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY servicereceiver
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(receivers).

    SELECT SINGLE stw~workflowstatus
        FROM /esrcc/i_stewrdshp AS stw
        INNER JOIN @receivers AS rec
            ON rec~stewardshipuuid = stw~stewardshipuuid
        INTO @DATA(wf_status).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    DATA(regulate_update) = lo_auth->regulate_action_update( wf_status = wf_status ).
    DATA(regulate_delete) = lo_auth->regulate_action_delete( wf_status = wf_status ).

    result = VALUE #( FOR wa IN receivers
                         ( %tky    = wa-%tky
                           %update = regulate_update
                           %delete = regulate_delete ) ).
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY servicereceiver
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities)

         ENTITY servicereceiver
         BY \_serviceproduct
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(service_product).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        BY \_stewardship
        ALL FIELDS WITH CORRESPONDING #( service_product )
        RESULT DATA(stewardship).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' )
                                      ( path = 'ServiceProduct' ) )
        source_entity_name = '/ESRCC/C_STWDSPREC'
      CHANGING
        reported_entity    = reported-servicereceiver
        failed_entity      = failed-servicereceiver ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_receiver(
        entity  = entity
        control = VALUE #( invoicecurrency = if_abap_behv=>mk-on )
      ).

      " Validate if provider and receiver are same
      IF line_exists( stewardship[ KEY entity stewardshipuuid = entity-stewardshipuuid costobjectuuid = entity-costobjectuuid ] ).
        lo_config_util->set_state_message(
          entity     = entity
          msg        = /esrcc/cl_config_msg_handler=>same_sender_receiver( )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'StewardshipAll' )
                                        ( path = 'Stewardship' ) )
          source_entity_name = '/ESRCC/C_STWDSPREC'
        CHANGING
          reported_entity    = reported-servicereceiver
          failed_entity      = failed-servicereceiver ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-invoicecurrency = if_abap_behv=>mk-on.
      lo_validation->validate_service_receiver(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( invoicecurrency = entity-%control-invoicecurrency )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY servicereceiver
        BY \_serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(products).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        BY \_stewardship
        ALL FIELDS WITH CORRESPONDING #( products )
        RESULT DATA(stewardships).

    IF stewardships IS INITIAL.     " When entry is deleted
      SELECT DISTINCT rec~stewardshipuuid, key~%is_draft
        FROM /esrcc/i_stwdsprec AS rec
        INNER JOIN @keys AS key
          ON key~servicereceiveruuid = rec~servicereceiveruuid
        INTO CORRESPONDING FIELDS OF TABLE @stewardships.
    ENDIF.

    lhc_/esrcc/i_stewrdshp=>set_workflow_internal_status(
      entities           = stewardships
      to_workflow_status = /esrcc/cl_wf_utility=>wf_status-draft
    ).
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_stewrdshp_s.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_stewr_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/STWDSPREC'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-servicereceiver ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
