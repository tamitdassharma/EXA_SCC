CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_rule        TYPE STRUCTURE FOR READ RESULT /esrcc/i_roycomp_s\\rule,
      tt_rule_create TYPE TABLE FOR CREATE /esrcc/i_roycomp_s\\ruleall\_rule,
      BEGIN OF ts_control,
        ruleid                   TYPE if_abap_behv=>t_xflag,
        royaltycomputationmethod TYPE if_abap_behv=>t_xflag,
        value                    TYPE if_abap_behv=>t_xflag,
        amountvalue              TYPE if_abap_behv=>t_xflag,
        currency                 TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_rule
        IMPORTING
          entity  TYPE ts_rule
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_rule
        IMPORTING
          entities TYPE tt_rule_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA:
      config_util_ref             TYPE REF TO /esrcc/cl_config_util,
      royalty_comp_rule_relevance TYPE /esrcc/cl_config_util=>tt_royalty_comp_rule_config.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
    royalty_comp_rule_relevance = /esrcc/cl_config_util=>get_royalty_comp_rule_config( ).
  ENDMETHOD.

  METHOD validate_rule.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-ruleid                   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RULEID' ) TO fields. ENDIF.
    IF control-royaltycomputationmethod = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ROYALTYCOMPUTATIONMETHOD' ) TO fields. ENDIF.

    DATA(relevance_info) = VALUE #( royalty_comp_rule_relevance[ royalty_comp_method = entity-royaltycomputationmethod ] OPTIONAL ).
    IF control-value = if_abap_behv=>mk-on AND relevance_info-value = abap_true.
      APPEND VALUE #( fieldname = 'VALUE' ) TO fields.
    ENDIF.

    IF control-amountvalue = if_abap_behv=>mk-on AND relevance_info-amount_value = abap_true.
      APPEND VALUE #( fieldname = 'AMOUNTVALUE' ) TO fields.
    ENDIF.

    IF control-currency = if_abap_behv=>mk-on AND relevance_info-currency = abap_true.
      APPEND VALUE #( fieldname = 'CURRENCY' ) TO fields.
    ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

*   Validate non-mandatory fields
    CLEAR fields.
    IF control-value = if_abap_behv=>mk-on AND relevance_info-value = abap_false.
      APPEND VALUE #( fieldname = 'VALUE' ) TO fields.
    ENDIF.

    IF control-amountvalue = if_abap_behv=>mk-on AND relevance_info-amount_value = abap_false.
      APPEND VALUE #( fieldname = 'AMOUNTVALUE' ) TO fields.
    ENDIF.

    IF control-currency = if_abap_behv=>mk-on AND relevance_info-currency = abap_false.
      APPEND VALUE #( fieldname = 'CURRENCY' ) TO fields.
    ENDIF.

    SELECT SINGLE text FROM /esrcc/i_royaltycompmethod WHERE royaltycomputationmethod = @entity-royaltycomputationmethod INTO @DATA(reference_name).

    config_util_ref->validate_non_mandatory(
      fields = fields
      value  = CONV #( reference_name )
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_rule.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_ROYCOMP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_rule(
          entity  = CORRESPONDING #( target )
          control = VALUE #( ruleid = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/ROYCOMP'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Rule' table = '/ESRCC/ROYCOMP' )
                                         ( entity = 'RuleText' table = '/ESRCC/ROYCOMPT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_roycomp_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ruleall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ruleall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ruleall
        RESULT result,
      precheck_cba_rule FOR PRECHECK
        IMPORTING entities FOR CREATE ruleall\_rule.
ENDCLASS.

CLASS lhc_/esrcc/i_roycomp_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
    ENTITY ruleall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_rule = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
      ENTITY ruleall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
      ENTITY ruleall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ROYCOMP' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_rule.
    lcl_custom_validation=>precheck_cba_rule(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-rule
        reported = reported-rule ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_roycomp_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_roycomp_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-ruleall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_roycomp DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR rule~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR rule
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION rule~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR rule
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR rule
        RESULT    result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR rule~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE rule.
ENDCLASS.

CLASS lhc_/esrcc/i_roycomp IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_roycomp_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_royco_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/ROYCOMP'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-rule ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_ruletext = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_rule TYPE TABLE FOR CREATE /esrcc/i_roycomp_s\_rule.
    DATA new_ruletext TYPE TABLE FOR CREATE /esrcc/i_roycomp_s\\rule\_ruletext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-rule = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
      ENTITY rule
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_rule)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
      ENTITY rule BY \_ruletext
      ALL FIELDS WITH CORRESPONDING #( ref_rule )
      RESULT DATA(ref_ruletext).

    LOOP AT ref_rule ASSIGNING FIELD-SYMBOL(<ref_rule>).
      DATA(key) = keys[ KEY draft %tky = <ref_rule>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_rule>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_rule>-%is_draft
          %data = CORRESPONDING #( <ref_rule> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            locallastchangedat
            ruleid
            singletonid
        ) ) )
      ) TO new_rule ASSIGNING FIELD-SYMBOL(<new_rule>).
      <new_rule>-%target[ 1 ]-ruleid = key-%param-ruleid.
      FIELD-SYMBOLS <new_ruletext> LIKE LINE OF new_ruletext.
      UNASSIGN <new_ruletext>.
      LOOP AT ref_ruletext ASSIGNING FIELD-SYMBOL(<ref_ruletext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-ruleid = key-%tky-ruleid.
        IF <new_ruletext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_ruletext ASSIGNING <new_ruletext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_ruletext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_ruletext> EXCEPT
                                                 locallastchangedat
                                                 ruleid
                                                 singletonid
        ) ) INTO TABLE <new_ruletext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-ruleid = key-%param-ruleid.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_rule(
      EXPORTING
        entities = new_rule
      CHANGING
        failed   = failed-rule
        reported = reported-rule ).

    IF failed-rule IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
        ENTITY ruleall CREATE BY \_rule
        FIELDS (
                 ruleid
                 royaltycomputationmethod
                 value
                 currency
               ) WITH new_rule
        ENTITY rule CREATE BY \_ruletext
        FIELDS (
                 spras
                 ruleid
                 description
               ) WITH new_ruletext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-rule = mapped_create-rule.
    INSERT LINES OF read_failed-rule INTO TABLE failed-rule.

    IF failed-rule IS INITIAL AND failed-ruletext IS INITIAL.
      reported-rule = VALUE #( FOR created IN mapped-rule (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-ruleall-%is_draft = created-%is_draft
                                                 %path-ruleall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ROYCOMP' ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
         ENTITY rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_ROYCOMP'
      CHANGING
        reported_entity    = reported-rule
        failed_entity      = failed-rule ) ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_rule(
        entity  = entity
        control = VALUE #( royaltycomputationmethod = if_abap_behv=>mk-on
                           value                    = if_abap_behv=>mk-on
                           amountvalue              = if_abap_behv=>mk-on
                           currency                 = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_ROYCOMP'
      CHANGING
        reported_entity    = reported-rule
        failed_entity      = failed-rule ) ).

    READ ENTITIES OF /esrcc/i_roycomp_s IN LOCAL MODE
      ENTITY rule
      ALL FIELDS WITH CORRESPONDING #( entities )
      RESULT DATA(rules).

    LOOP AT entities INTO DATA(entity) WHERE %control-royaltycomputationmethod = if_abap_behv=>mk-on
                                          OR %control-value                    = if_abap_behv=>mk-on
                                          OR %control-amountvalue              = if_abap_behv=>mk-on
                                          OR %control-currency                 = if_abap_behv=>mk-on.

      IF entity-%control-royaltycomputationmethod = if_abap_behv=>mk-off.
        entity-royaltycomputationmethod = VALUE #( rules[ KEY entity ruleid = entity-ruleid ]-royaltycomputationmethod OPTIONAL ).
      ENDIF.

      lo_validation->validate_rule(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( royaltycomputationmethod = entity-%control-royaltycomputationmethod
                             value                    = entity-%control-value
                             amountvalue              = entity-%control-amountvalue
                             currency                 = entity-%control-currency )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_roycomptext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ruletext~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ruletext
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_roycomptext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_roycomp_s.
    SELECT SINGLE transportrequestid
      FROM /esrcc/d_royco_s
      WHERE singletonid = 1
      INTO @DATA(transportrequestid).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/ROYCOMPT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ruletext ) ).
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
