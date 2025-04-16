CLASS /esrcc/cl_config_util DEFINITION PUBLIC
  INHERITING FROM /esrcc/cl_abap_behv_msghandler
  CREATE PROTECTED.

  PUBLIC SECTION.
    CONSTANTS c_config_msg TYPE symsgid VALUE '/ESRCC/CONFIG_MSG' ##NO_TEXT.

    TYPES:
      BEGIN OF ENUM validation_type,
        mandatory,
        non_mandatory,
        validity,
        overlapping_validity,
        overlapping_sequence,
        start_end_of_month,
        period,
        percentage,
        percentage_100,
        invalid_data,
        date_out_of_range,
        child_mandatory,
        child_non_mandatory,
        duplicate,
        not_exists,
      END OF ENUM validation_type,

      BEGIN OF ts_field_mapping_auth,
        legal_entity TYPE abp_field_name,
        cost_object  TYPE abp_field_name,
        cost_number  TYPE abp_field_name,
      END OF ts_field_mapping_auth,

      BEGIN OF ts_uuid_16,
        uuid      TYPE sysuuid_x16,
        serv_con  TYPE abap_boolean,
        serv_cap  TYPE abap_boolean,
        alloc_key TYPE abap_boolean,
      END OF ts_uuid_16,

      BEGIN OF ts_foreign_check,
        serv_consumption TYPE abap_boolean,
        serv_capacity    TYPE abap_boolean,
        alloc_key        TYPE abap_boolean,
      END OF ts_foreign_check,

      BEGIN OF ts_co_rule_config,
        chargeout_method     TYPE /esrcc/chargout,
        cost_version         TYPE abap_boolean,
        capacity_version     TYPE abap_boolean,
        consumption_version  TYPE abap_boolean,
        key_version          TYPE abap_boolean,
        adhoc_allocation_key TYPE abap_boolean,
        weightage_tab        TYPE abap_boolean,
      END OF ts_co_rule_config,

      BEGIN OF ts_bc_group,
        tech_id  TYPE c LENGTH 30,   " Data Element available in Higher version: SMBC_TECHNICAL_ID (Unreleased)
        bc_group TYPE c LENGTH 30,   " Data Element available in Higher version: SMBC_GROUP (Unreleased)
        db_tab   TYPE STANDARD TABLE OF sxco_dbt_object_name WITH EMPTY KEY,
      END OF ts_bc_group.

    TYPES:
      tt_fields         TYPE STANDARD TABLE OF ts_field,
      tt_uuid_16        TYPE STANDARD TABLE OF ts_uuid_16 WITH EMPTY KEY,
      tt_co_rule_config TYPE STANDARD TABLE OF ts_co_rule_config WITH KEY chargeout_method,
      tt_bc_group       TYPE STANDARD TABLE OF ts_bc_group WITH KEY tech_id.

    CLASS-METHODS
      create
        IMPORTING
          paths              TYPE tt_path OPTIONAL
          assoc_paths        TYPE tt_path OPTIONAL
          source_entity_name TYPE sxco_cds_object_name
          is_transition      TYPE abap_boolean OPTIONAL
        CHANGING
          reported_entity    TYPE STANDARD TABLE
          failed_entity      TYPE STANDARD TABLE
        RETURNING
          VALUE(instance)    TYPE REF TO /esrcc/cl_config_util.

    CLASS-METHODS get_co_rule_config
      RETURNING
        VALUE(co_rule_config) TYPE tt_co_rule_config.

    CLASS-METHODS message_on_action
      RETURNING
        VALUE(msg) TYPE REF TO if_abap_behv_message.

    METHODS validate_initial
      IMPORTING
        fields     TYPE tt_fields
        !entity    TYPE any
        message_no TYPE symsgno DEFAULT '001'.
    METHODS validate_non_mandatory
      IMPORTING
        fields  TYPE tt_fields
        !entity TYPE any.
    METHODS validate_validity
      IMPORTING
        !from   TYPE /esrcc/validfrom
        !to     TYPE /esrcc/validto
        !entity TYPE any.
    METHODS validate_overlapping_validity
      IMPORTING
        !src_from    TYPE /esrcc/validfrom
        !src_to      TYPE /esrcc/validto
        !src_entity  TYPE any
        !curr_from   TYPE /esrcc/validfrom
        !curr_to     TYPE /esrcc/validto
        !curr_entity TYPE any.
    METHODS validate_start_end_of_month
      IMPORTING
        !entity     TYPE any
      CHANGING
        !start_date TYPE /esrcc/validfrom
        !end_date   TYPE /esrcc/validto.
    METHODS validate_poper
      IMPORTING
        fields  TYPE tt_fields
        !entity TYPE any.
    METHODS validate_percentage
      IMPORTING
        fields  TYPE tt_fields
        !entity TYPE any.
    METHODS validate_percentage_100
      IMPORTING
        value   TYPE any
        !entity TYPE any.
    METHODS set_duplicate_error
      IMPORTING
        entity TYPE any.
    METHODS set_state_message
      IMPORTING
        fieldname  TYPE abp_field_name OPTIONAL
        entity     TYPE any
        msg        TYPE REF TO if_abap_behv_message
        state_area TYPE string.
    METHODS get_field_text
      IMPORTING
        fieldname    TYPE abp_field_name OPTIONAL
        data_element TYPE sxco_ad_object_name OPTIONAL
      RETURNING
        VALUE(text)  TYPE string.
    METHODS foreign_check_cost_object
      IMPORTING
        entities           TYPE STANDARD TABLE
        uuid_fieldname     TYPE abp_field_name
        error_fieldname    TYPE abp_field_name      " Since UUID fieldname is hidden in the UI, required to set element error on visible field
        cost_object_uuids  TYPE tt_uuid_16
        action             TYPE ts_action
        foreign_check      TYPE ts_foreign_check
      RETURNING
        VALUE(foreign_ref) TYPE abap_boolean.

    CLASS-METHODS
      config_bc_group
        RETURNING
          VALUE(bc_groups) TYPE tt_bc_group.

  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        paths              TYPE tt_path
        assoc_paths        TYPE tt_path
        source_entity_name TYPE sxco_cds_object_name
        is_transition      TYPE abap_boolean.

  PRIVATE SECTION.

    DATA:
      gv_source_entity_name TYPE sxco_cds_object_name,
      gv_data_element       TYPE sxco_ad_object_name,
      gs_active_field       TYPE ts_field,
      gt_fields             TYPE SORTED TABLE OF ts_field WITH NON-UNIQUE DEFAULT KEY,
      go_abap_dictionary    TYPE REF TO /esrcc/cl_abap_dictionary.

    METHODS extract_field_label
      IMPORTING
        fieldname    TYPE abp_field_name
        data_element TYPE sxco_ad_object_name
      RETURNING
        VALUE(text)  TYPE string.
ENDCLASS.



CLASS /ESRCC/CL_CONFIG_UTIL IMPLEMENTATION.


  METHOD config_bc_group.
    bc_groups = VALUE #(
*                        GROUP 1
                         ( tech_id = '/ESRCC/BUS_DIV'             bc_group = '/ESRCC/BC_GROUP1' db_tab = VALUE #( ( '/ESRCC/BUS_DIV' )
                                                                                                                  ( '/ESRCC/BUS_DIVT' ) ) )
                         ( tech_id = '/ESRCC/FUNCTIONALAREAS'     bc_group = '/ESRCC/BC_GROUP1' db_tab = VALUE #( ( '/ESRCC/FNC_AREA' )
                                                                                                                  ( '/ESRCC/FNC_AREAT' ) ) )
                         ( tech_id = '/ESRCC/LE'                  bc_group = '/ESRCC/BC_GROUP1' db_tab = VALUE #( ( '/ESRCC/LE' )
                                                                                                                  ( '/ESRCC/LE_T' ) ) )
                         ( tech_id = '/ESRCC/LECCODE'             bc_group = '/ESRCC/BC_GROUP1' db_tab = VALUE #( ( '/ESRCC/LE_CCODE' )
                                                                                                                  ( '/ESRCC/CCODET' ) ) )
                         ( tech_id = '/ESRCC/PFC'                 bc_group = '/ESRCC/BC_GROUP1' db_tab = VALUE #( ( '/ESRCC/PFC' )
                                                                                                                  ( '/ESRCC/PFCT' ) ) )

*                        GROUP 2
                         ( tech_id = '/ESRCC/COSTELEMENTS'        bc_group = '/ESRCC/BC_GROUP2' db_tab = VALUE #( ( '/ESRCC/CST_ELMNT' )
                                                                                                                  ( '/ESRCC/CST_ELMTT' ) ) )
                         ( tech_id = '/ESRCC/COSTELMENETCHARACTE' bc_group = '/ESRCC/BC_GROUP2' db_tab = VALUE #( ( '/ESRCC/CSTELMTCH' ) ) )
                         ( tech_id = '/ESRCC/REASON'              bc_group = '/ESRCC/BC_GROUP2' db_tab = VALUE #( ( '/ESRCC/REASON' )
                                                                                                                  ( '/ESRCC/REASONT' ) ) )

*                        GROUP 3
                         ( tech_id = '/ESRCC/SRTYPE'              bc_group = '/ESRCC/BC_GROUP3' db_tab = VALUE #( ( '/ESRCC/SRTYPE' )
                                                                                                                  ( '/ESRCC/SRVTYPET' ) ) )
                         ( tech_id = '/ESRCC/SRVPRO'              bc_group = '/ESRCC/BC_GROUP3' db_tab = VALUE #( ( '/ESRCC/SRVPRO' )
                                                                                                                  ( '/ESRCC/SRVPROT' ) ) )
                         ( tech_id = '/ESRCC/SRVTG'               bc_group = '/ESRCC/BC_GROUP3' db_tab = VALUE #( ( '/ESRCC/SRVTG' )
                                                                                                                  ( '/ESRCC/TGT' ) ) )

*                        GROUP 4
                         ( tech_id = '/ESRCC/SRVMKP'              bc_group = '/ESRCC/BC_GROUP4' db_tab = VALUE #( ( '/ESRCC/SRVMKP' ) ) )
                         ( tech_id = '/ESRCC/ALLOCKEYS'           bc_group = '/ESRCC/BC_GROUP4' db_tab = VALUE #( ( '/ESRCC/ALLOCKEYS' )
                                                                                                                  ( '/ESRCC/ALLOCKEYT' ) ) )

*                        GROUP 5
                         ( tech_id = '/ESRCC/CHARGEOUT'           bc_group = '/ESRCC/BC_GROUP5' db_tab = VALUE #( ( '/ESRCC/CHARGEOUT' ) ) )
                         ( tech_id = '/ESRCC/CORULE'              bc_group = '/ESRCC/BC_GROUP5' db_tab = VALUE #( ( '/ESRCC/CO_RULE' )
                                                                                                                  ( '/ESRCC/CO_RULET' )
                                                                                                                  ( '/ESRCC/ALOC_WGT' ) ) )

*                        GROUP 6
                         ( tech_id = '/ESRCC/CST_OBJCT'           bc_group = '/ESRCC/BC_GROUP6' db_tab = VALUE #( ( '/ESRCC/CST_OBJCT' )
                                                                                                                  ( '/ESRCC/CST_OBJTT' ) ) )
                         ( tech_id = '/ESRCC/STEWRDSHP'           bc_group = '/ESRCC/BC_GROUP6' db_tab = VALUE #( ( '/ESRCC/STEWRDSHP' )
                                                                                                                  ( '/ESRCC/STWDSP' )
                                                                                                                  ( '/ESRCC/STWDSPREC' ) ) )

*                        GROUP 7
                         ( tech_id = '/ESRCC/LEBNKINFO'           bc_group = '/ESRCC/BC_GROUP7' db_tab = VALUE #( ( '/ESRCC/LEBNKINFO' ) ) )
                         ( tech_id = '/ESRCC/LETAXINFO'           bc_group = '/ESRCC/BC_GROUP7' db_tab = VALUE #( ( '/ESRCC/LETAXINFO' ) ) )
                         ( tech_id = '/ESRCC/LE_ADDRESS'          bc_group = '/ESRCC/BC_GROUP7' db_tab = VALUE #( ( '/ESRCC/LE_ADDRES' ) ) )
                         ( tech_id = '/ESRCC/LE_OTHERS'           bc_group = '/ESRCC/BC_GROUP7' db_tab = VALUE #( ( '/ESRCC/LE_OTHERS' ) ) )

*                        GROUP 8
                         ( tech_id = '/ESRCC/WFCUST'              bc_group = '/ESRCC/BC_GROUP8' db_tab = VALUE #( ( '/ESRCC/WFCUST' ) ) )
                         ( tech_id = '/ESRCC/WFSWITCH'            bc_group = '/ESRCC/BC_GROUP8' db_tab = VALUE #( ( '/ESRCC/WFSWITCH' ) ) )
                         ( tech_id = '/ESRCC/WFUSRG'              bc_group = '/ESRCC/BC_GROUP8' db_tab = VALUE #( ( '/ESRCC/WFUSRG' )
                                                                                                                  ( '/ESRCC/WFUSRM' ) ) )

*                        GROUP 9
                         ( tech_id = '/ESRCC/BILLINGFREQUENCY'    bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/BILLFREQ' ) ) )
                         ( tech_id = '/ESRCC/EXECSTATUS'          bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/EXEC_ST' )
                                                                                                                  ( '/ESRCC/EXECST_T' ) ) )
                         ( tech_id = '/ESRCC/EXTCONFIG'           bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/EXTCONFIG' ) ) )
                         ( tech_id = '/ESRCC/EXT_OBJ'             bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/EXT_OBJCT' )
                                                                                                                  ( '/ESRCC/EXTOBJCTT' ) ) )
                         ( tech_id = '/ESRCC/GROUPCONFIG'         bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/GROUP' ) ) )
                         ( tech_id = '/ESRCC/SYSINFO'             bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/SYS_INFO' )
                                                                                                                  ( '/ESRCC/SYS_INFOT' ) ) )
                         ( tech_id = '/ESRCC/PACKAGECODE'         bc_group = '/ESRCC/BC_GROUP9' db_tab = VALUE #( ( '/ESRCC/PKG_CODE' )
                                                                                                                  ( '/ESRCC/PKG_CODET' ) ) ) ).
  ENDMETHOD.


  METHOD constructor.
    super->constructor(
      paths         = paths
      assoc_paths   = assoc_paths
      is_transition = is_transition
    ).

    gv_source_entity_name = source_entity_name.
    go_abap_dictionary = NEW /esrcc/cl_abap_dictionary( iv_entity_name = source_entity_name ).
  ENDMETHOD.


  METHOD create.
    instance = NEW /esrcc/cl_config_util(
        paths              = paths
        assoc_paths        = assoc_paths
        source_entity_name = source_entity_name
        is_transition      = is_transition
    ).

    instance->set_entities(
      CHANGING
        reported_entity = reported_entity
        failed_entity   = failed_entity
    ).
  ENDMETHOD.


  METHOD extract_field_label.
    DATA(field) = VALUE ts_field( fieldname = fieldname
                                  fieldtext = go_abap_dictionary->derive_field_label(
                                                EXPORTING
                                                  iv_data_element = data_element
                                                  iv_field_name   = fieldname
                                              ) ).

    text = field-fieldtext.
    INSERT field INTO TABLE gt_fields.
  ENDMETHOD.


  METHOD foreign_check_cost_object.
*   If Cost Object is used in Service Consumption, Capacity or Allocation Key apps, the requested action is restricted.
    IF cost_object_uuids IS INITIAL OR action IS INITIAL OR foreign_check IS INITIAL.
      RETURN.
    ENDIF.

    DATA(uuid_usage_tab) = cost_object_uuids.

    IF foreign_check-serv_consumption = abap_true.
      SELECT DISTINCT
            uuid~uuid,
            CASE WHEN srv_con~cost_object_uuid IS NOT NULL THEN @abap_true ELSE @abap_false END AS serv_con,
            serv_cap,
            alloc_key
        FROM @uuid_usage_tab AS uuid
        LEFT OUTER JOIN /esrcc/consumptn AS srv_con
            ON srv_con~cost_object_uuid = uuid~uuid
        INTO TABLE @uuid_usage_tab.
    ENDIF.

    IF foreign_check-serv_capacity = abap_true.
      SELECT DISTINCT
            uuid~uuid,
            serv_con,
            CASE WHEN srv_cap~cost_object_uuid IS NOT NULL THEN @abap_true ELSE @abap_false END AS serv_cap,
            alloc_key
        FROM @uuid_usage_tab AS uuid
        LEFT OUTER JOIN /esrcc/srv_cpcty AS srv_cap
            ON srv_cap~cost_object_uuid = uuid~uuid
        INTO TABLE @uuid_usage_tab.
    ENDIF.

    IF foreign_check-alloc_key = abap_true.
      SELECT DISTINCT
            uuid~uuid,
            serv_con,
            serv_cap,
            CASE WHEN ind_alloc~cost_object_uuid IS NOT NULL THEN @abap_true ELSE @abap_false END AS alloc_key
        FROM @uuid_usage_tab AS uuid
        LEFT OUTER JOIN /esrcc/indtalloc AS ind_alloc
            ON ind_alloc~cost_object_uuid = uuid~uuid
        INTO TABLE @uuid_usage_tab.
    ENDIF.

    IF NOT line_exists( uuid_usage_tab[ serv_con  = abap_true ] ) AND
       NOT line_exists( uuid_usage_tab[ serv_cap  = abap_true ] ) AND
       NOT line_exists( uuid_usage_tab[ alloc_key = abap_true ] ).
      RETURN.
    ENDIF.

    foreign_ref = abap_true.

    " Raise message
    set_state_area( state_area = CONV #( mandatory ) ).
    set_first_flag( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      ASSIGN COMPONENT uuid_fieldname OF STRUCTURE <entity> TO FIELD-SYMBOL(<uuid>).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      DATA(uuid_usage) = VALUE #( uuid_usage_tab[ uuid = <uuid> ] OPTIONAL ).
      IF uuid_usage-serv_con = abap_true.
        DATA(v1) = CONV symsgv( TEXT-001 ).
      ENDIF.

      IF uuid_usage-serv_cap = abap_true.
        v1 = COND #( WHEN v1 IS INITIAL THEN TEXT-002 ELSE |{ v1 }{ COND #( WHEN uuid_usage-alloc_key = abap_true THEN ',' ELSE '&' ) } { TEXT-002 }| ).
      ENDIF.

      IF uuid_usage-alloc_key = abap_true.
        DATA(v2) = COND symsgv( WHEN v1 IS INITIAL THEN TEXT-003 ELSE |& { TEXT-003 }| ).
      ENDIF.

      IF v1 IS NOT INITIAL OR v2 IS NOT INITIAL.
        set_message_for_field(
            EXPORTING
              entity = <entity>
              field  = VALUE #( fieldname = error_fieldname )
              msg    = NEW cl_abap_behv( )->new_message( id       = c_config_msg
                                                         number   = COND #( WHEN action-update = abap_true THEN '022'
                                                                            WHEN action-delete = abap_true THEN '021' )
                                                         severity = cl_abap_behv=>ms-error
                                                         v1       = v1
                                                         v2       = v2 ) ).
      ENDIF.

      CLEAR: v1, v2.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_co_rule_config.
*   Parameters relevant for "Direct Chargeout"
    APPEND VALUE #( chargeout_method     = 'D'
                    cost_version         = abap_true
                    capacity_version     = abap_true
                    consumption_version  = abap_true
                    key_version          = abap_false
                    adhoc_allocation_key = abap_false
                    weightage_tab        = abap_false ) TO co_rule_config.

*   Parameters relevant for "Indirect Chargeout"
    APPEND VALUE #( chargeout_method     = 'I'
                    cost_version         = abap_true
                    capacity_version     = abap_false
                    consumption_version  = abap_false
                    key_version          = abap_true
                    adhoc_allocation_key = abap_false
                    weightage_tab        = abap_true ) TO co_rule_config.

*   Parameters relevant for "Adhoc Chargeout"
    APPEND VALUE #( chargeout_method     = 'A'
                    cost_version         = abap_false
                    capacity_version     = abap_false
                    consumption_version  = abap_false
                    key_version          = abap_false
                    adhoc_allocation_key = abap_true
                    weightage_tab        = abap_false ) TO co_rule_config.
  ENDMETHOD.


  METHOD get_field_text.
    DATA(lv_fieldname) = COND #( WHEN fieldname IS NOT INITIAL THEN fieldname ELSE gs_active_field-fieldname ).

    text = COND #( WHEN gs_active_field-fieldtext IS NOT INITIAL THEN gs_active_field-fieldtext
                   ELSE VALUE #( gt_fields[ fieldname = lv_fieldname ]-fieldtext OPTIONAL ) ).

    IF text IS INITIAL.
      text = extract_field_label( fieldname = lv_fieldname data_element = COND #( WHEN data_element IS NOT INITIAL THEN data_element ELSE gv_data_element ) ).
    ENDIF.
  ENDMETHOD.


  METHOD message_on_action.
    msg = NEW cl_abap_behv( )->new_message(
                              id       = /esrcc/cl_config_util=>c_config_msg
                              number   = '028'
                              severity = if_abap_behv_message=>severity-success ).
  ENDMETHOD.


  METHOD set_duplicate_error.
    set_state_message(
      entity     = entity
      msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '023'
                         severity = if_abap_behv_message=>severity-error
                       )
      state_area = CONV #( /esrcc/cl_config_util=>duplicate )
    ).
  ENDMETHOD.


  METHOD set_state_message.
    set_state_area( state_area = state_area ).
    set_first_flag( ).

    set_message_for_field(
      entity = entity
      field  = VALUE #( fieldname = fieldname )
      msg    = msg
    ).
  ENDMETHOD.


  METHOD validate_initial.
    set_state_area( state_area = CONV #( mandatory ) ).
    set_first_flag( ).

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <value> IS INITIAL.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message_for_field(
          EXPORTING
            entity = entity
            field  = gs_active_field
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = message_no severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_non_mandatory.
    set_state_area( state_area = CONV #( non_mandatory ) ).
    set_first_flag( ).

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <value> IS NOT INITIAL.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message_for_field(
          EXPORTING
            entity = entity
            field  = gs_active_field
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '014' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_overlapping_validity.
    set_state_area( state_area = CONV #( overlapping_validity ) ).
    set_first_flag( ).

    IF curr_from BETWEEN src_from AND src_to OR curr_to BETWEEN src_from AND src_to
    OR src_from BETWEEN curr_from AND curr_to OR src_to BETWEEN curr_from AND curr_to.
      DATA(msg) = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '003' severity = cl_abap_behv=>ms-error ).
    ENDIF.

*   Entity 1
    set_message_for_field(
      EXPORTING
        entity = src_entity
        msg    = msg ).

*   Entity 2
    set_first_flag( ).    " Reset previous error on this entity
    set_message_for_field(
      EXPORTING
        entity = curr_entity
        msg    = msg ).
  ENDMETHOD.


  METHOD validate_percentage.
    set_state_area( state_area = CONV #( percentage ) ).
    set_first_flag( ).

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <value> NOT BETWEEN 0 AND 100.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message_for_field(
          EXPORTING
            entity = entity
            field  = gs_active_field
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '005' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_percentage_100.
    set_state_area( state_area = CONV #( percentage_100 ) ).
    set_first_flag( ).

    IF value <> 100.
      DATA(invalid) = abap_true.
      gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = value ).
    ENDIF.

    set_message_for_field(
        EXPORTING
          entity = entity
          msg    = COND #( WHEN invalid = abap_true
                           THEN NEW cl_abap_behv( )->new_message( id = c_config_msg number = '009' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ) ).
  ENDMETHOD.


  METHOD validate_poper.
    set_state_area( state_area = CONV #( period ) ).
    set_first_flag( ).

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      IF <value> NOT BETWEEN '001' AND '012'.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message_for_field(
          EXPORTING
            entity = entity
            field  = gs_active_field
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '004' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_start_end_of_month.
    set_state_area( state_area = CONV #( start_end_of_month ) ).
    set_first_flag( ).

    IF start_date IS NOT INITIAL AND start_date+6(2) <> '01'.
      gs_active_field-fieldname = 'VALIDFROM'.
      start_date+6(2) = '01'.

      gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = start_date ).

      set_message_for_field(
        EXPORTING
          entity = entity
          field  = gs_active_field
          msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '006' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
    ENDIF.

    IF end_date IS NOT INITIAL.
      DATA(lv_date) = /esrcc/cl_utility_core=>get_last_day_of_month( EXPORTING date = end_date ).
      IF end_date <> lv_date.
        gs_active_field-fieldname = 'VALIDTO'.
        end_date = lv_date.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = end_date ).

        set_message_for_field(
          EXPORTING
            entity = entity
            field  = gs_active_field
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '007' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_validity.
    set_state_area( state_area = CONV #( validity ) ).
    set_first_flag( ).

    IF from IS NOT INITIAL AND to IS NOT INITIAL AND from > to.
      DATA(invalid) = abap_true.
      gs_active_field-fieldname = 'VALIDTO'.
    ELSE.
      CLEAR gs_active_field.
    ENDIF.

    set_message_for_field(
      EXPORTING
        entity = entity
        field  = gs_active_field
        msg    = COND #( WHEN invalid = abap_true
                         THEN NEW cl_abap_behv( )->new_message( id = c_config_msg number = '002' severity = cl_abap_behv=>ms-error ) ) ).
  ENDMETHOD.
ENDCLASS.
