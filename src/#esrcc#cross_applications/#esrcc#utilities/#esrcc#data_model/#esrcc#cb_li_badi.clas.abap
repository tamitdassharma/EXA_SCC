CLASS /esrcc/cb_li_badi DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /esrcc/if_dao_badi.

  PRIVATE SECTION.
    TYPES:
      _line_items_type TYPE STANDARD TABLE OF /esrcc/cb_li WITH DEFAULT KEY.

    " Internal table to hold line items
    DATA:
      _line_items TYPE _line_items_type.

    METHODS:
      _remove_finalized_line_items CHANGING model TYPE _line_items_type,
      _find_invalid_hsl            CHANGING model TYPE _line_items_type,
      _remove_missing_master_data  CHANGING model TYPE _line_items_type,
      _convert_to_foreign_currency
        IMPORTING !date                 TYPE sydate
                  foreign_currency      TYPE fcurr_curr
                  local_amount          TYPE any
                  local_currency        TYPE tcurr_curr
        RETURNING VALUE(foreign_amount) TYPE /esrcc/ksl
        RAISING   cx_exchange_rates.
ENDCLASS.


CLASS /esrcc/cb_li_badi IMPLEMENTATION.
  METHOD /esrcc/if_dao_badi~validate_data.
    " Assuming /esrcc/cb_li is a structure or table type defined in your system
    _line_items = CORRESPONDING #( model ).

    " Remove finalized line items before validation
    _remove_finalized_line_items( CHANGING model = _line_items ).

    " Find invalid HSLs and log them
    _find_invalid_hsl( CHANGING model = _line_items ).

    " Remove items with missing master data
    _remove_missing_master_data( CHANGING model = _line_items ).

    " Additional validation logic can be added here
  ENDMETHOD.

  METHOD /esrcc/if_dao_badi~determine_data.
    TYPES:
      BEGIN OF cost_element_mapping_type,
        sysid        TYPE /esrcc/sysid,
        legalentity  TYPE /esrcc/legalentity,
        ccode        TYPE /esrcc/ccode_de,
        costelement  TYPE /esrcc/costelement,
        valid_from   TYPE /esrcc/validfrom,
        costtype     TYPE /esrcc/costtype_de,
        postingtype  TYPE /esrcc/postingtype_de,
        costind      TYPE /esrcc/costind_de,
        usagetype    TYPE /esrcc/usage,
        valid_to     TYPE /esrcc/validto,
        reason_id    TYPE /esrcc/reasonid,
        value_source TYPE /esrcc/ce_value_source,
      END OF cost_element_mapping_type,

      cost_elements_mapping_type TYPE STANDARD TABLE OF cost_element_mapping_type WITH DEFAULT KEY.

    " Initialize the internal table for line items
    _line_items = VALUE _line_items_type( ).

    IF _line_items IS INITIAL.
      RETURN.
    ENDIF.

    " Fetch cost object mapping data from the database
    SELECT FROM /esrcc/cst_objct
      FIELDS *
      FOR ALL ENTRIES IN @_line_items
      WHERE sysid        = @_line_items-sysid
        AND legal_entity = @_line_items-legalentity
        AND company_code = @_line_items-ccode
        AND cost_object  = @_line_items-costobject
        AND cost_center  = @_line_items-costcenter
      INTO TABLE @FINAL(cost_objects_mapping).

    " Fetch cost element mapping data from the database
    SELECT
      FROM /esrcc/cst_elmnt AS header
             INNER JOIN
               /esrcc/cstelmtch AS matching ON matching~cost_element_uuid = header~cost_element_uuid
      FIELDS sysid,
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
      FOR ALL ENTRIES IN @_line_items
      WHERE header~sysid        = @_line_items-sysid
        AND header~legal_entity = @_line_items-legalentity
        AND header~company_code = @_line_items-ccode
        AND header~cost_element = @_line_items-costelement
      INTO TABLE @FINAL(cost_elements_mapping).         "#EC CI_NOWHERE

    " Get the group configurations
    FINAL(group_configuration) = /esrcc/cl_utility_core=>get_group_configuration( ).

    " Initialize variables for date and time
    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(time_stamp) ).

    " Prepare the final line items based on the mappings and configurations
    TRY.
        FINAL(line_items) = VALUE _line_items_type(
            FOR <item> IN _line_items
            LET valid_on              = |{ <item>-ryear }{ <item>-poper+1 }01|
                last_date             = /esrcc/cl_utility_core=>get_last_day_of_month(
                                            date = |{ <item>-ryear }{ <item>-poper+1 }01| )
                cost_object_mapping   = VALUE #( cost_objects_mapping[ sysid        = <item>-sysid
                                                                       legal_entity = <item>-legalentity
                                                                       company_code = <item>-ccode
                                                                       cost_object  = <item>-costobject
                                                                       cost_center  = <item>-costcenter ] OPTIONAL )
                cost_element_mappings = VALUE cost_elements_mapping_type( FOR <cost_element_mapping> IN cost_elements_mapping
                                                                          WHERE (     sysid        = <item>-sysid
                                                                                  AND legalentity  = <item>-legalentity
                                                                                  AND ccode        = <item>-ccode
                                                                                  AND costelement  = <item>-costelement
                                                                                  AND valid_from  <= valid_on
                                                                                  AND valid_to    >= valid_on )
                                                                          ( <cost_element_mapping> ) )
                cost_element_mapping  = VALUE #( cost_element_mappings[ 1 ] OPTIONAL ) IN
            ( VALUE #(
                  BASE CORRESPONDING #( <item> )
                  " Cost Object Mapping
                  functionalarea   = cost_object_mapping-functional_area
                  businessdivision = cost_object_mapping-business_division
                  profitcenter     = cost_object_mapping-profit_center
                  " Cost Element Mapping
                  costtype         = cost_element_mapping-costtype
                  costind          = cost_element_mapping-costind
                  usagecal         = COND #( WHEN cost_element_mapping-usagetype IS INITIAL
                                             THEN 'I'
                                             ELSE cost_element_mapping-usagetype )
                  reasonid         = cost_element_mapping-reason_id
                  value_source     = cost_element_mapping-value_source
                  " Additional fields
                  status           = 'A' " Assuming 'A' indicates active status
                  postingtype      = COND #( WHEN group_configuration-cost_sign = '+'
                                             THEN COND #( WHEN <item>-hsl < 0 THEN |INCOME| ELSE |EXPENSE| )
                                             ELSE COND #( WHEN <item>-hsl < 0 THEN |EXPENSE| ELSE |INCOME| ) )
                  ksl              = _convert_to_foreign_currency( date             = last_date
                                                                   foreign_currency = group_configuration-group_currency
                                                                   local_amount     = <item>-hsl
                                                                   local_currency   = <item>-localcurr )
                  groupcurr        = group_configuration-group_currency
                  " Administration fields
                  created_at       = time_stamp
                  created_by       = sy-uname
                  last_changed_at  = time_stamp
                  last_changed_by  = sy-uname ) ) ).
      CATCH cx_exchange_rates.
    ENDTRY.

    " Set the model to the final line items
    model = line_items.
  ENDMETHOD.

  METHOD _remove_finalized_line_items.
    DATA(finalized_items) = VALUE _line_items_type( ).

    SELECT
      FROM @model AS cb_li
             INNER JOIN
               /esrcc/cb_li AS db ON  cb_li~ryear       = db~ryear
                                  AND cb_li~poper       = db~poper
                                  AND cb_li~fplv        = db~fplv
                                  AND cb_li~sysid       = db~sysid
                                  AND cb_li~legalentity = db~legalentity
                                  AND cb_li~ccode       = db~ccode
                                  AND cb_li~belnr       = db~belnr
                                  AND cb_li~buzei       = db~buzei
                                  AND cb_li~costobject  = db~costobject
                                  AND cb_li~costcenter  = db~costcenter
                                  AND cb_li~costelement = db~costelement
      FIELDS *
      WHERE db~status = 'F' " Assuming 'F' indicates finalized status
      INTO CORRESPONDING FIELDS OF TABLE @finalized_items.

    " Remove finalised items from the model
    ##INDEX_NUM DELETE model FROM finalized_items.

    " Add finalized items to the log
  ENDMETHOD.

  METHOD _find_invalid_hsl.
    SELECT FROM @model AS cb_li
      FIELDS *
      WHERE cb_li~hsl IS INITIAL
      " TODO: variable is assigned but never used (ABAP cleaner)
      INTO TABLE @FINAL(invalid_hsls).

    " If invalid HSLs are found, log them as needed
  ENDMETHOD.

  METHOD _convert_to_foreign_currency.
    cl_exchange_rates=>convert_to_foreign_currency( EXPORTING date             = date
                                                              foreign_currency = foreign_currency
                                                              local_amount     = local_amount
                                                              local_currency   = local_currency
                                                    IMPORTING foreign_amount   = foreign_amount ).
  ENDMETHOD.

  METHOD _remove_missing_master_data.
    DATA(missing_data) = VALUE _line_items_type( ).
    DATA(missing_master_data) = VALUE _line_items_type( ).

    " Check for missing master data: System ID in the line items
    SELECT
      FROM @model AS cb_li
             LEFT OUTER JOIN
               /esrcc/sys_info AS sys_info ON cb_li~sysid = sys_info~system_id
      FIELDS *
      WHERE sys_info~system_id IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @missing_data.

    " Append missing data to the master data table
    APPEND LINES OF missing_data TO missing_master_data.

*    " Remove items with missing master data from the model
*    DELETE model FROM missing_data.

    " Check for missing master data: Legal Entity in the line items
    SELECT
      FROM @model AS cb_li
             LEFT OUTER JOIN
               /esrcc/le AS legal_entity ON cb_li~LegalEntity = legal_entity~LegalEntity
      FIELDS *
      WHERE legal_entity~LegalEntity IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @missing_data.

    " Append missing data to the master data table
    APPEND LINES OF missing_data TO missing_master_data.

*    " Remove items with missing master data from the model
*    DELETE model FROM missing_data.

    " Check for missing master data: Company Code in the line items
    SELECT
      FROM @model AS cb_li
             LEFT OUTER JOIN
               /esrcc/le_ccode AS company_code ON cb_li~ccode = company_code~ccode
      FIELDS *
      WHERE company_code~ccode IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @missing_data.

    " Append missing data to the master data table
    APPEND LINES OF missing_data TO missing_master_data.

*    " Remove items with missing master data from the model
*    DELETE model FROM missing_data.

    " Check for missing master data: Cost Object in the line items
    SELECT
      FROM @model AS cb_li
             LEFT OUTER JOIN
               /esrcc/cst_objct AS cost_object ON  cb_li~costobject = cost_object~cost_object
                                               AND cb_li~costcenter = cost_object~cost_center
      FIELDS *
      WHERE cost_object~cost_object IS INITIAL
         OR cost_object~cost_center IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @missing_data.

    " Append missing data to the master data table
    APPEND LINES OF missing_data TO missing_master_data.

*    " Remove items with missing master data from the model
*    DELETE model FROM missing_data.

    " Check for missing master data: Cost element in the line items
    SELECT
      FROM @model AS cb_li
             LEFT OUTER JOIN
               /esrcc/cst_elmnt AS cost_element ON cb_li~CostElement = cost_element~cost_element
      FIELDS *
      WHERE cost_element~cost_element IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @missing_data.
    " Append missing data to the master data table
    APPEND LINES OF missing_data TO missing_master_data.

    " Remove items with missing master data from the model
    SORT missing_data BY sysid
                         legalentity
                         ccode
                         costobject
                         costcenter
                         costelement.
    DELETE ADJACENT DUPLICATES FROM missing_data COMPARING sysid legalentity ccode costobject costcenter costelement.
    ##INDEX_NUM DELETE model FROM missing_master_data.

    " Log or handle the missing master data as needed
  ENDMETHOD.
ENDCLASS.
