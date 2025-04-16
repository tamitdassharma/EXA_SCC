CLASS /esrcc/cl_file_upld_util_badi DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_file_upld_util_badi.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF cost_element_mapping_type,
        sysid        TYPE /esrcc/sysid,
        legalentity  TYPE /esrcc/legalentity,
        ccode        TYPE /esrcc/ccode_de,
        costelement  TYPE /esrcc/costelement,
        valid_from   TYPE datn,
        costtype     TYPE /esrcc/costtype_de,
        postingtype  TYPE /esrcc/postingtype_de,
        costind      TYPE /esrcc/costind_de,
        usagetype    TYPE /esrcc/usage,
        valid_to     TYPE datn,
        reason_id    TYPE /esrcc/reasonid,
        value_source TYPE /esrcc/ce_value_source,
      END OF cost_element_mapping_type,

      cost_elements_mapping_type TYPE STANDARD TABLE OF cost_element_mapping_type WITH EMPTY KEY,

      BEGIN OF cost_object_type,
        sysid             TYPE /esrcc/sysid,
        legalentity       TYPE /esrcc/legalentity,
        company_code      TYPE /esrcc/ccode_de,
        cost_object       TYPE /esrcc/costobject_de,
        cost_center       TYPE /esrcc/costcenter,
        functional_area   TYPE /esrcc/functional_area,
        profit_center     TYPE /esrcc/profit_center,
        business_division TYPE /esrcc/businessdivision,
      END OF cosT_OBJECT_TYPE,

      cost_objects_type TYPE STANDARD TABLE OF cost_object_type WITH EMPTY KEY.

    METHODS:
      _costs_elements_mapping CHANGING data_structure  TYPE any,
      _convert_date_to_internal IMPORTING date_format    TYPE xsdboolean
                                CHANGING  value          TYPE any
                                RETURNING VALUE(message) TYPE string,
      _convert_local_to_group_amount IMPORTING year                 TYPE /esrcc/ryear
                                               period               TYPE poper
                                               local_amount         TYPE /esrcc/hsl
                                               local_currency       TYPE /esrcc/localcurr
                                               group_currency       TYPE /esrcc/groupcurr
                                               conversion_rate_type TYPE /esrcc/conversion_rate_type
                                     RETURNING VALUE(amount)        TYPE /esrcc/ksl,
      _fetch_from_db RETURNING VALUE(_result) TYPE cost_elements_mapping_type,
      _fetch_cost_object RETURNING VALUE(_result) TYPE cost_objects_type.

    DATA:
      _cost_elements_mapping TYPE cost_elements_mapping_type,
      _cost_objects          TYPE cost_objects_type,
      _group_configuration   TYPE /esrcc/group,
      _user_decimal_format   TYPE xsdboolean.
ENDCLASS.



CLASS /ESRCC/CL_FILE_UPLD_UTIL_BADI IMPLEMENTATION.


  METHOD /esrcc/if_file_upld_util_badi~convert_standard_data_type.
    message = SWITCH #( component-type->type_kind
                     WHEN 'D' THEN _convert_date_to_internal( EXPORTING date_format = date_format CHANGING value = cell_value ) ).
  ENDMETHOD.


  METHOD /esrcc/if_file_upld_util_badi~determine_business_field.
    IF table_name = '/ESRCC/CB_LI_TMP'.
      _costs_elements_mapping( CHANGING data_structure = change_structure ).
    ENDIF.
  ENDMETHOD.


  METHOD /esrcc/if_file_upld_util_badi~validate_business_field.
    is_validated = abap_true.

    ASSIGN COMPONENT 'SYSID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<system_id>).
    ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE data_structure TO FIELD-SYMBOL(<legal_entity>).
    ASSIGN COMPONENT 'CCODE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<ccode>).
    ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_object>).
    ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_center>).
    ASSIGN COMPONENT 'COSTELEMENT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_element>).
*    ASSIGN COMPONENT 'RYEAR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reporting_year>).
*    ASSIGN COMPONENT 'POPER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<poper>).
    DATA(relative_name) = component-type->get_relative_name( ).

    IF field_value IS NOT INITIAL.
      CASE component-type->get_relative_name( ).
        WHEN '/ESRCC/LEGALENTITY'.
          IF table_name NE '/ESRCC/LE'.
            DATA(legal_entity) = CONV /esrcc/legalentity( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/le WHERE legalentity = @legal_entity INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTCENTER'.
          IF table_name NE '/ESRCC/CST_OBJCT'.
            DATA(cost_center) = CONV /esrcc/costcenter( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/cst_objct WHERE sysid = @<system_id> AND legal_entity = @<legal_entity> AND company_code = @<ccode> AND cost_object = @<cost_object> AND cost_center = @cost_center INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTELEMENT'.
          IF table_name NE '/ESRCC/CST_ELMNT'.
            DATA(cost_element) = CONV /esrcc/costelement( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/cst_elmnt WHERE sysid = @<system_id> AND legal_entity = @<legal_entity> AND company_code = @<ccode> AND cost_element = @cost_element INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/SYSID'.
          IF table_name NE '/ESRCC/SYS_INFO'.
            DATA(system_id) = CONV /esrcc/sysid( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/sys_info WHERE system_id = @system_id INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/CCODE_DE'.
          IF table_name NE '/ESRCC/LE_CCODE'.
            DATA(company_code) = CONV /esrcc/ccode_de( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/le_ccode WHERE ccode = @company_code INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/BUSINESSDIVISION'.
          IF table_name NE '/ESRCC/BUS_DIV' AND field_value IS NOT INITIAL.
            DATA(business_division) = CONV /esrcc/businessdivision( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/bus_div WHERE business_division = @business_division INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/PROFIT_CENTER'.
          IF table_name NE '/ESRCC/PFC' AND field_value IS NOT INITIAL.
            DATA(profit_center) = CONV /esrcc/profit_center( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/pfc WHERE profit_center = @profit_center INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVPRODUCT'.
          IF table_name NE '/ESRCC/SRVPRO'.
            DATA(service_product) = CONV /esrcc/srvproduct( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/srvpro WHERE serviceproduct = @service_product INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVTYPE_DE'.
          IF table_name NE '/ESRCC/SRTYPE' AND field_value IS NOT INITIAL.
            DATA(service_type) = CONV /esrcc/srvtype_de( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/srtype WHERE srvtype = @service_type INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN '/ESRCC/TG'.
          IF table_name NE '/ESRCC/SRVTG' AND field_value IS NOT INITIAL.
            DATA(transaction_group) = CONV /esrcc/tg( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/srvtg WHERE transactiongroup = @transaction_group INTO @is_validated.
            IF sy-subrc NE 0. CLEAR is_validated. ENDIF.
          ENDIF.
        WHEN OTHERS.
          DATA(domain_validator) = /esrcc/cl_domain_validator=>get_instance( ).
          is_validated = domain_validator->validate_domain(
            field_name = CONV #( component-name )
            table_name = table_name
            value      = CONV #( field_value ) ).
      ENDCASE.
    ENDIF.

    IF ( table_name = '/ESRCC/CB_LI' OR table_name = '/ESRCC/CB_LI_TMP' ).
      IF component-name = 'HSL' AND ( field_value IS INITIAL OR field_value = 0 ).
        message-message_id      = /esrcc/if_file_upload_handler=>message_class.
        message-message_type    = 'W'.
        message-message_number  = 015.
      ENDIF.
      IF component-name = 'LOCALCURR' AND field_value IS INITIAL.
*        message-message_id      = /esrcc/if_file_upload_handler=>message_class.
*        message-message_type    = 'E'.
*        message-message_number  = 021.
        is_validated = abap_false.
      ENDIF.
    ENDIF.
    IF table_name = '/ESRCC/SRV_CPCTY' AND component-name = 'UOM' AND field_value IS INITIAL.
      message-message_id      = /esrcc/if_file_upload_handler=>message_class.
      message-message_type    = 'E'.
      message-message_number  = 023.
      is_validated = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD _convert_date_to_internal.
    CLEAR: message.
    DATA(external_format) = VALUE /esrcc/sysid( ).
    external_format = value.

*    IF date_format IS INITIAL.
*      DATA(user_date_format) = cl_abap_datfm=>get_datfm( ).
*    ELSE.
*      user_date_format = date_format.
*    ENDIF.

    CASE cl_abap_datfm=>get_datfm( ).
*    CASE user_date_format. ##DATE_FORMAT
      WHEN '1'.
        IF external_format CA '.'.
          value = |{ external_format+6 }{ external_format+3(2) }{ external_format+0(2) }|.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '2'.
        IF external_format CA '/'.
          value = |{ external_format+6 }{ external_format+0(2) }{ external_format+3(2) }|.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '3'.
        IF external_format+2(1) = '-'.
          value = |{ external_format+6 }{ external_format+0(2) }{ external_format+3(2) }|.
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '4'.
        IF external_format CA '.'.
          REPLACE ALL OCCURRENCES OF '.' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '5'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '6'.
        IF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '7'.
        IF external_format CA '.'.
          REPLACE ALL OCCURRENCES OF '.' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '8'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '9'.
        IF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN 'A'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN 'B'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN 'C'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN OTHERS.
        MESSAGE s022(/esrcc/file_upload) INTO message.
    ENDCASE.
  ENDMETHOD.


  METHOD _convert_local_to_group_amount.
    DATA(last_date) = /esrcc/cl_utility_core=>get_last_day_of_month( date = |{ year }{ period+1 }01| ).

    CALL FUNCTION '/ESRCC/CONV_LCL_TO_GRP_AMOUNT'
      EXPORTING
        date             = last_date
        foreign_currency = group_currency
        local_amount     = local_amount
        local_currency   = local_currency
        type_of_rate     = conversion_rate_type
      IMPORTING
*       exchange_rate    =
        foreign_amount   = amount
*       message          =
      .
  ENDMETHOD.


  METHOD _costs_elements_mapping.
    IF _cost_elements_mapping IS INITIAL.
      _cost_elements_mapping = _fetch_from_db( ).
    ENDIF.

    IF _cost_objects IS INITIAL.
      _cost_objects = _fetch_cost_object( ).
    ENDIF.

    IF _group_configuration IS INITIAL.
      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ENDIF.

    ASSIGN COMPONENT 'SYSID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<system_id>).
    ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE data_structure TO FIELD-SYMBOL(<legal_entity>).
    ASSIGN COMPONENT 'CCODE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<ccode>).
    ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_object>).
    ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_center>).
    ASSIGN COMPONENT 'COSTELEMENT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_element>).
    ASSIGN COMPONENT 'RYEAR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reporting_year>).
    ASSIGN COMPONENT 'POPER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<poper>).

    IF <reporting_year> IS NOT ASSIGNED OR <reporting_year> IS INITIAL OR <poper> IS NOT ASSIGNED OR
       <poper> IS INITIAL OR <legal_entity> IS NOT ASSIGNED OR <legal_entity> IS INITIAL OR
       <ccode> IS NOT ASSIGNED OR <ccode> IS INITIAL OR <cost_element> IS NOT ASSIGNED OR
       <cost_element> IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM @_cost_objects AS objects WHERE sysid = @<system_id> AND legalentity = @<legal_entity>
        AND company_code = @<ccode> AND  cost_object = @<cost_object> AND cost_center = @<cost_center>
        INTO @DATA(cost_object_mapping).
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'FUNCTIONALAREA' OF STRUCTURE data_structure TO FIELD-SYMBOL(<functional_area>).
      IF <functional_area> IS ASSIGNED.
        <functional_area> = cost_object_mapping-functional_area.
        UNASSIGN <functional_area>.
      ENDIF.

      ASSIGN COMPONENT 'BUSINESSDIVISION' OF STRUCTURE data_structure TO FIELD-SYMBOL(<business_division>).
      IF <business_division> IS ASSIGNED.
        <business_division> = cost_object_mapping-business_division.
        UNASSIGN <business_division>.
      ENDIF.


      ASSIGN COMPONENT 'PROFITCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<profit_center>).
      IF <profit_center> IS ASSIGNED.
        <profit_center> = cost_object_mapping-profit_center.
        UNASSIGN <profit_center>.
      ENDIF.
    ENDIF.

    DATA(valid_on) = |{ <reporting_year> }{ <poper>+1 }01|.
    SELECT SINGLE * FROM @_cost_elements_mapping AS mapping WHERE legalentity = @<legal_entity> AND
      ccode = @<ccode> AND costelement = @<cost_element> AND valid_from <= @valid_on AND
      valid_to >= @valid_on INTO @DATA(mapping_information).
    IF sy-subrc = 0.

      ASSIGN COMPONENT 'COSTTYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_element_type>).
      IF <cost_element_type> IS ASSIGNED.
        <cost_element_type> = mapping_information-costtype.
        UNASSIGN <cost_element_type>.
      ENDIF.

      ASSIGN COMPONENT 'COSTIND' OF STRUCTURE data_structure TO FIELD-SYMBOL(<costing_indicator>).
      IF <costing_indicator> IS ASSIGNED.
        <costing_indicator> = mapping_information-costind.
        UNASSIGN <costing_indicator>.
      ENDIF.

      ASSIGN COMPONENT 'USAGECAL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<usage_type>).
      IF <usage_type> IS ASSIGNED.
        <usage_type> = COND #( WHEN mapping_information-usagetype IS INITIAL THEN 'I' ELSE mapping_information-usagetype ).
        UNASSIGN <usage_type>.
      ENDIF.

      ASSIGN COMPONENT 'REASONID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reason_id>).
      IF <reason_id> IS ASSIGNED.
        <reason_id> = mapping_information-reason_id.
        UNASSIGN <reason_id>.
      ENDIF.

      ASSIGN COMPONENT 'VALUE_SOURCE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<value_source>).
      IF <value_source> IS ASSIGNED.
        <value_source> = mapping_information-value_source.
        UNASSIGN <value_source>.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'HSL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<local_amount>).
    IF <local_amount> IS ASSIGNED.
      ASSIGN COMPONENT 'LOCALCURR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<local_currency>).
      IF <local_currency> IS NOT INITIAL.
        /esrcc/cl_utility_core=>curr_external_to_internal(
          EXPORTING
            currency        = <local_currency>
            amount_external = <local_amount>
          IMPORTING
            amount_internal = <local_amount> ).
      ENDIF.
      ASSIGN COMPONENT 'POSTINGTYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<posting_type>).
      IF <posting_type> IS ASSIGNED.
        <posting_type> = COND /esrcc/postingtype_de( WHEN _group_configuration-cost_sign = '+'
                                                       THEN COND #( WHEN <local_amount> < 0 THEN |INCOME| ELSE |EXPENSE| )
                                                       ELSE COND #( WHEN <local_amount> < 0 THEN |EXPENSE| ELSE |INCOME| ) ).
        UNASSIGN <posting_type>.
      ENDIF.
      ASSIGN COMPONENT 'KSL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<group_amount>).
      IF <group_amount> IS ASSIGNED AND <local_currency> IS ASSIGNED AND <local_amount> <> 0.
        <group_amount> = _convert_local_to_group_amount( year                 = <reporting_year>
                                                         period               = <poper>
                                                         local_amount         = <local_amount>
                                                         local_currency       = <local_currency>
                                                         group_currency       = _group_configuration-group_currency
                                                         conversion_rate_type = _group_configuration-conversion_rate_type ).
        UNASSIGN <group_amount>.
      ENDIF.
      ASSIGN COMPONENT 'GROUPCURR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<group_currency>).
      IF <group_currency> IS ASSIGNED.
        <group_currency> = _group_configuration-group_currency.
        UNASSIGN <group_currency>.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'STATUS' OF STRUCTURE data_structure TO FIELD-SYMBOL(<status>).
    IF <status> IS ASSIGNED.
      <status> = 'A'.
      UNASSIGN <status>.
    ENDIF.
  ENDMETHOD.


  METHOD _fetch_cost_object.
    SELECT sysid,                                       "#EC CI_NOWHERE
           legal_entity,
           company_code,
           cost_object,
           cost_center,
           functional_area,
           profit_center,
           business_division
           FROM /esrcc/cst_objct
           INTO TABLE @_result.
  ENDMETHOD.


  METHOD _fetch_from_db.
    " Remove corresponding once satish removed the unwanted fields from the table
    SELECT sysid,
           legal_entity        AS legalentity,
           company_code        AS ccode,
           header~cost_element AS costelement,
           valid_from,
           cost_type           AS costtype,
           posting_type        AS postingtype,
           cost_indicator      AS costind,
           usage_type          AS usagetype,
           valid_to,
           reason_id,
           value_source
      FROM /esrcc/cst_elmnt AS header
             INNER JOIN
               /esrcc/cstelmtch AS matching ON matching~cost_element_uuid = header~cost_element_uuid
      INTO CORRESPONDING FIELDS OF TABLE @_result.      "#EC CI_NOWHERE
  ENDMETHOD.
ENDCLASS.
