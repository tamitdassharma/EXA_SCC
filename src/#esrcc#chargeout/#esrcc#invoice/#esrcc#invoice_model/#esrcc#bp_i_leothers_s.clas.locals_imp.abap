CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/LE_OTHERS'
                                       table_entity_relations = VALUE #( ( entity = 'OtherInformation' table = '/ESRCC/LE_OTHERS' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_leothers_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR otherinformationall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION otherinformationall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR otherinformationall
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_leothers_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_leothers_s IN LOCAL MODE
    ENTITY otherinformationall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
                        %tky = row-%tky
                        %action-edit = edit_flag
                        %assoc-_otherinformation = edit_flag
                        %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_leothers_s IN LOCAL MODE
      ENTITY otherinformationall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_leothers_s IN LOCAL MODE
      ENTITY otherinformationall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LEOTHERS' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS lsc_/esrcc/i_leothers_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_leothers_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-otherinformationall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_leothers DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR otherinformation~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR otherinformation
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR otherinformation RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR otherinformation RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION otherinformation~copy.
ENDCLASS.

CLASS lhc_/esrcc/i_leothers IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_leothers_s.
    SELECT SINGLE transportrequestid FROM /esrcc/d_le_ot_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = transportrequestid
                                table             = '/ESRCC/LE_OTHERS'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-otherinformation ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_LEOTHERS' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_leothers_s\_otherinformation.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-otherinformation = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_leothers_s IN LOCAL MODE
      ENTITY otherinformation
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid             = key_cid
                             %is_draft        = <ref_main>-%is_draft
                             %data            = CORRESPONDING #( <ref_main> EXCEPT legalentity singletonid )
                             legalentity      = key-%param-legalentity
                             role             = key-%param-role
                             sysid            = key-%param-sysid
                             companycode      = key-%param-companycode
                             costobject       = key-%param-costobject
                             businessdivision = key-%param-businessdivision
                             transactiongroup = key-%param-transactiongroup ) ) ) TO new_main.
    ENDLOOP.

    MODIFY ENTITIES OF /esrcc/i_leothers_s IN LOCAL MODE
      ENTITY otherinformationall CREATE BY \_otherinformation
      FIELDS (
               legalentity
               role
               sysid
               companycode
               costobject
               businessdivision
               transactiongroup
               account
               businesspartnernumber
             ) WITH new_main
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-otherinformation = mapped_create-otherinformation.
    INSERT LINES OF read_failed-otherinformation INTO TABLE failed-otherinformation.

    IF failed-otherinformation IS INITIAL.
      reported-otherinformation = VALUE #( FOR created IN mapped-otherinformation (
                                     %cid               = created-%cid
                                     %action-copy       = if_abap_behv=>mk-on
                                     %msg               = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-otherinformationall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
