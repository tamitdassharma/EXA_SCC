CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_product        TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvpro_s\\serviceproduct,
      tt_product_create TYPE TABLE FOR CREATE /esrcc/i_srvpro_s\\serviceproductall\_serviceproduct,
      BEGIN OF ts_control,
        serviceproduct TYPE if_abap_behv=>t_xflag,
        servicetype    TYPE if_abap_behv=>t_xflag,
        oecdtpg        TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_product
        IMPORTING
          entity  TYPE ts_product
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_service_product
        IMPORTING
          entities TYPE tt_product_create
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

  METHOD validate_product.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-serviceproduct = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SERVICEPRODUCT' ) TO fields. ENDIF.
    IF control-servicetype = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SERVICETYPE' ) TO fields. ENDIF.
    IF control-oecdtpg = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'OECDTPG' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_service_product.
    TYPES ts_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvpro_s\\serviceproduct.

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceProductAll' ) )
        source_entity_name = '/ESRCC/C_SRVPRO'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_product(
          entity  = CORRESPONDING #( target )
          control = VALUE #( serviceproduct = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/SRVPRO'
                                       table_entity_relations = VALUE #( ( entity = 'ServiceProduct' table = '/ESRCC/SRVPRO' )
                                                                         ( entity = 'ServiceProductText' table = '/ESRCC/SRVPROT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvpro_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR serviceproductall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION serviceproductall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR serviceproductall
        RESULT result,
      precheck_cba_serviceproduct FOR PRECHECK
        IMPORTING entities FOR CREATE serviceproductall\_serviceproduct.
ENDCLASS.

CLASS lhc_/esrcc/i_srvpro_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
    ENTITY serviceproductall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_serviceproduct = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
      ENTITY serviceproductall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
      ENTITY serviceproductall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_SRVPRO' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_serviceproduct.
    lcl_custom_validation=>precheck_cba_service_product(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-serviceproduct
        reported = reported-serviceproduct ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_srvpro_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_srvpro_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-serviceproductall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_srvpro DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR serviceproduct~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR serviceproduct
        RESULT result,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE serviceproduct.

    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR serviceproduct~validatedata.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR serviceproduct RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR serviceproduct RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION serviceproduct~copy.
ENDCLASS.

CLASS lhc_/esrcc/i_srvpro IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_srvpro_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_srvp_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/SRVPRO'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-serviceproduct ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_serviceproducttext = edit_flag.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'ServiceProductAll' ) )
          source_entity_name = '/ESRCC/C_SRVPRO'
        CHANGING
          reported_entity    = reported-serviceproduct
          failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-servicetype = if_abap_behv=>mk-on
                                          OR %control-oecdtpg     = if_abap_behv=>mk-on.
      lo_validation->validate_product(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( servicetype = entity-%control-servicetype
                           oecdtpg     = entity-%control-oecdtpg )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
        ENTITY serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceProductAll' ) )
        source_entity_name = '/ESRCC/C_SRVPRO'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE servicetype IS INITIAL
                                                         OR oecdtpg     IS INITIAL.
      lo_validation->validate_product(
        entity  = <entity>
        control = VALUE #( servicetype = if_abap_behv=>mk-on
                           oecdtpg     = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_SRVPRO' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_srvpro_s\_serviceproduct,
      new_text TYPE TABLE FOR CREATE /esrcc/i_srvpro_s\\serviceproduct\_serviceproducttext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-serviceproduct = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
      ENTITY serviceproduct
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
      ENTITY serviceproduct BY \_serviceproducttext
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
                             %data          = CORRESPONDING #( <ref_main> EXCEPT serviceproduct singletonid )
                             serviceproduct = key-%param-serviceproduct ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft      = key-%tky-%is_draft
                                                                            AND %tky-serviceproduct = key-%tky-serviceproduct.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid           = key_cid && <ref_text>-spras
                        %is_draft      = key-%is_draft
                        %data          = CORRESPONDING #( <ref_text> EXCEPT serviceproduct singletonid )
                        serviceproduct = key-%param-serviceproduct ) INTO TABLE <new_text>-%target.
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
      MODIFY ENTITIES OF /esrcc/i_srvpro_s IN LOCAL MODE
        ENTITY serviceproductall CREATE BY \_serviceproduct
        FIELDS (
                 serviceproduct
                 servicetype
                 transactiongroup
                 oecdtpg
                 ipowner
               ) WITH new_main
        ENTITY serviceproduct CREATE BY \_serviceproducttext
        FIELDS (
                 spras
                 serviceproduct
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-serviceproduct = mapped_create-serviceproduct.
    INSERT LINES OF read_failed-serviceproduct INTO TABLE failed-serviceproduct.

    IF failed-serviceproduct IS INITIAL AND failed-serviceproducttext IS INITIAL.
      reported-serviceproduct = VALUE #( FOR created IN mapped-serviceproduct (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-serviceproductall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_srvprotext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR serviceproducttext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR serviceproducttext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_srvprotext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_srvpro_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_srvp_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/SRVPROT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-serviceproducttext ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
