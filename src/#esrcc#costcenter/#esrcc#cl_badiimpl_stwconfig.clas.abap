CLASS /esrcc/cl_badiimpl_stwconfig DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_badi_stwconfig .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badiimpl_stwconfig IMPLEMENTATION.
  METHOD /esrcc/if_badi_stwconfig~derive_stewardshipconfig.

    DATA stewardship    TYPE TABLE OF /esrcc/stewrdshp.
    DATA serviceproduct TYPE TABLE OF /esrcc/stwd_sp.
    DATA receivers      TYPE TABLE OF /esrcc/stwdsprec.
    DATA ip_count       TYPE /esrcc/chain_sequence.
    DATA hub_count      TYPE /esrcc/chain_sequence VALUE 99999.
    DATA ushub_count    TYPE /esrcc/chain_sequence VALUE 199999.
    DATA element6       TYPE /esrcc/hierarchy1.
    DATA hubcostobejctype  TYPE /esrcc/costobject_de VALUE 'SCC'.

    SELECT SINGLE * FROM /esrcc/hier_def
      WHERE hierarchy1 = @is_config-hierarchy1
        AND hierarchy2 = @is_config-hierarchy2
        AND hierarchy3 = @is_config-hierarchy3
        AND hierarchy4 = @is_config-hierarchy4
        AND valid_from = @is_config-valid_from
        INTO @DATA(config).


    element6 = config-hierarchy1.

*Get all cost objects mapped with additional attribute these will act as initial providers
    SELECT cstobject~*, le~country, le~tpprofile, le~local_curr FROM /esrcc/cst_objct AS cstobject
      INNER JOIN /esrcc/le AS le
      ON le~legalentity = cstobject~legal_entity
      WHERE hierarchy1 = @config-hierarchy1
        AND hierarchy2 = @config-hierarchy2
        AND hierarchy3 = @config-hierarchy3
        AND hierarchy4 = @config-hierarchy4
        AND cost_object = 'CC'
        INTO TABLE @DATA(costobjects).

*get all cost objects
    SELECT cstobject~*, le~country, le~tpprofile, le~local_curr FROM /esrcc/cst_objct AS cstobject
    INNER JOIN /esrcc/le AS le
    ON le~legalentity = cstobject~legal_entity
    ORDER BY sysid, legal_entity, company_code INTO TABLE @DATA(allcostobjects).

*get all service product already configured
    SELECT * FROM /esrcc/srvpro ORDER BY serviceproduct INTO TABLE @DATA(allServiceProducts).

*   get legal entity master data
    SELECT * FROM /esrcc/le ORDER BY legalentity INTO TABLE @DATA(legalentities) .

*   get all stewardship configs
    SELECT * FROM /esrcc/stewrdshp
        WHERE chain_id   = @element6
          AND valid_from = @config-valid_from
*          AND valid_to   = @config-valid_to
          INTO TABLE @DATA(allStewardships).

* get indirect allocation data for hub entities

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

*group the cost objects based on attributes, functional area and sector ( businessdivision )
    LOOP AT costobjects INTO DATA(costobject)
                GROUP BY ( hierarchy1 = costobject-cstobject-hierarchy1
                           hierarchy2 = costobject-cstobject-hierarchy2
                           hierarchy3 = costobject-cstobject-hierarchy3
                           hierarchy4 = costobject-cstobject-hierarchy4
                           business_division = costobject-cstobject-business_division
                           functional_area   = costobject-cstobject-functional_area ) INTO DATA(cbgroup).

      LOOP AT GROUP cbgroup ASSIGNING FIELD-SYMBOL(<cbgroup>) WHERE tpprofile NE 'HUB'.

**************************************************************************************************
*                                       Provider Determination
**************************************************************************************************
* if there is already something configured then skip
        READ TABLE allstewardships TRANSPORTING NO FIELDS WITH KEY cost_object_uuid = <cbgroup>-cstobject-cost_object_uuid.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        APPEND INITIAL LINE TO stewardship ASSIGNING FIELD-SYMBOL(<stewardship>).
        <stewardship>-valid_from = config-valid_from.
        <stewardship>-valid_to   = config-valid_to.
        <stewardship>-stewardship = config-stewardship.
        <stewardship>-cost_object_uuid = <cbgroup>-cstobject-cost_object_uuid.
        <stewardship>-workflow_status = 'A'.   "Approved
        <stewardship>-chain_id = element6.
        ip_count = ip_count + 1.
        <stewardship>-chain_sequence = ip_count.

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <stewardship>-stewardship_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        <stewardship>-created_by = sy-uname.
        <stewardship>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
           IMPORTING
             time_stamp = <stewardship>-created_at
         ).

        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <stewardship>-last_changed_at
        ).

**************************************************************************************************
*                                     Service Product Determination
**************************************************************************************************
*        Check if service product already exist if not skip the config
        DATA(_serviceproduct) = element6 && '.' && <cbgroup>-cstobject-functional_area.

        READ TABLE allserviceproducts TRANSPORTING NO FIELDS WITH KEY serviceproduct = _serviceproduct BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        APPEND INITIAL LINE TO serviceproduct ASSIGNING FIELD-SYMBOL(<serviceproduct>).
        <serviceproduct>-service_product = element6 && '.' && <cbgroup>-cstobject-functional_area.
        <serviceproduct>-share_of_cost   = 100.
        <serviceproduct>-valid_from = config-valid_from.
        <serviceproduct>-valid_to   = config-valid_to.
        <serviceproduct>-stewardship_uuid = <stewardship>-stewardship_uuid.
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <serviceproduct>-service_product_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        <serviceproduct>-created_by = sy-uname.
        <serviceproduct>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
           IMPORTING
             time_stamp = <serviceproduct>-created_at
         ).

        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <serviceproduct>-last_changed_at
        ).


**************************************************************************************************
*                                     Receiver Determination (Provider to Hub)
**************************************************************************************************
*  Check if its the hub scenario then receiver is hub otherwise prinicpal entities
        IF config-is_hub = abap_true.

          IF <cbgroup>-country = 'US'.
*           Determine the cost object of hub by reading the hub entity with same functional area as the provider
*            which will act as a receiver,
            READ TABLE allcostobjects ASSIGNING FIELD-SYMBOL(<costobject>) WITH KEY cstobject-sysid           = <cbgroup>-cstobject-sysid
                                                                                    country                   = <cbgroup>-country
                                                                                    cstobject-cost_object     = hubcostobejctype
                                                                                    tpprofile                 = 'HUB'
                                                                                    cstobject-hierarchy1      = element6
                                                                                    cstobject-functional_area = <cbgroup>-cstobject-functional_area.
            IF sy-subrc = 0.
*                  add the US hub as the receiver
              EXIT.
            ENDIF.

          ELSE.

*           Determine the cost object of hub by reading the hub entity with same functional area as the provider
*            which will act as a receiver,
            LOOP AT allcostobjects ASSIGNING <costobject> WHERE cstobject-sysid             = <cbgroup>-cstobject-sysid
                                                            AND country                     <> 'US'
                                                            AND cstobject-cost_object       = hubcostobejctype
                                                            AND tpprofile                   = 'HUB'
                                                            AND cstobject-hierarchy1        = element6
*                                                            AND cstobject-business_division = <cbgroup>-cstobject-business_division
                                                            AND cstobject-functional_area   = <cbgroup>-cstobject-functional_area.
*
              IF ( <cbgroup>-cstobject-business_division = <costobject>-cstobject-business_division ) OR
                 ( <cbgroup>-cstobject-business_division <> 'MT' AND <costobject>-cstobject-business_division IS INITIAL ).
                EXIT.
              ENDIF.
            ENDLOOP.

          ENDIF.

          IF <costobject> IS NOT ASSIGNED.
            CONTINUE.
          ELSE.
            APPEND INITIAL LINE TO receivers ASSIGNING FIELD-SYMBOL(<receivers>).
            <receivers>-invoice_currency = <costobject>-local_curr.
            <receivers>-active = abap_true.
            <receivers>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
            <receivers>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
            IF lo_uuid IS BOUND.
              TRY.
                  <receivers>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                CATCH cx_uuid_error.
                  "handle exception
              ENDTRY.
            ENDIF.
            <receivers>-created_by = sy-uname.
            <receivers>-last_changed_by = sy-uname.
            /esrcc/cl_utility_core=>get_utc_date_time_ts(
               IMPORTING
                 time_stamp = <receivers>-created_at
             ).

            /esrcc/cl_utility_core=>get_utc_date_time_ts(
              IMPORTING
                time_stamp = <receivers>-last_changed_at
            ).
          ENDIF.

*        ENDIF.

**************************************************************************************************
*      2nd Step                Hub as provider
**************************************************************************************************

**************************************************************************************************
*                                       Provider Determination
**************************************************************************************************
*     As hubs are at functional area so its possible already a config has been added then skip
          READ TABLE allstewardships TRANSPORTING NO FIELDS WITH KEY cost_object_uuid = <receivers>-cost_object_uuid.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
          READ TABLE stewardship TRANSPORTING NO FIELDS WITH KEY cost_object_uuid = <receivers>-cost_object_uuid.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
          APPEND INITIAL LINE TO stewardship ASSIGNING <stewardship>.
          <stewardship>-valid_from = config-valid_from.
          <stewardship>-valid_to   = config-valid_to.
          <stewardship>-stewardship = config-stewardship.
          <stewardship>-cost_object_uuid = <receivers>-cost_object_uuid.
          <stewardship>-workflow_status = 'A'.   "Approved
          <stewardship>-chain_id = element6.
          hub_count = hub_count + 1.
          <stewardship>-chain_sequence = hub_count.

* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                <stewardship>-stewardship_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
          <stewardship>-created_by = sy-uname.
          <stewardship>-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = <stewardship>-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = <stewardship>-last_changed_at
          ).

**************************************************************************************************
*                                     Service Product Determination
**************************************************************************************************
*        Check if service product already exist if not skip the config
          _serviceproduct = element6 && '.' && <cbgroup>-cstobject-functional_area.

          READ TABLE allserviceproducts TRANSPORTING NO FIELDS WITH KEY serviceproduct = _serviceproduct BINARY SEARCH.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          APPEND INITIAL LINE TO serviceproduct ASSIGNING <serviceproduct>.
          <serviceproduct>-service_product = element6 && '.' && <cbgroup>-cstobject-functional_area.
          <serviceproduct>-share_of_cost   = 100.
          <serviceproduct>-valid_from = config-valid_from.
          <serviceproduct>-valid_to   = config-valid_to.
          <serviceproduct>-stewardship_uuid = <stewardship>-stewardship_uuid.
* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                <serviceproduct>-service_product_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
          <serviceproduct>-created_by = sy-uname.
          <serviceproduct>-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = <serviceproduct>-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = <serviceproduct>-last_changed_at
          ).


**************************************************************************************************
*                                     Receiver Determination (Hub to principal)
**************************************************************************************************
*    Determine the country of the provider
          IF <costobject>-country = 'US'.
*      US receivers or principal receivers profit centers
            LOOP AT allcostobjects ASSIGNING <costobject> WHERE cstobject-business_division = <cbgroup>-cstobject-business_division
                                                            AND country                     = 'US'
                                                            AND cstobject-cost_object       = 'PC'.

              APPEND INITIAL LINE TO receivers ASSIGNING <receivers>.
              <receivers>-invoice_currency = <cbgroup>-local_curr.
              <receivers>-active = abap_true.
              <receivers>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
              <receivers>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <receivers>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <receivers>-created_by = sy-uname.
              <receivers>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <receivers>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <receivers>-last_changed_at
              ).

            ENDLOOP.
          ELSE.

*      NonUS receivers or principal receivers profit centers
            LOOP AT allcostobjects ASSIGNING <costobject> WHERE cstobject-business_division = <cbgroup>-cstobject-business_division
                                                            AND country                    <> 'US'
                                                            AND cstobject-cost_object       = 'PC'.

              APPEND INITIAL LINE TO receivers ASSIGNING <receivers>.
              <receivers>-invoice_currency = <cbgroup>-local_curr.
              <receivers>-active = abap_true.
              <receivers>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
              <receivers>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <receivers>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <receivers>-created_by = sy-uname.
              <receivers>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <receivers>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <receivers>-last_changed_at
              ).

            ENDLOOP.

*           Determine the cost object of hub by reading the hub entity with same functional area as the provider
*            which will act as a receiver,
            READ TABLE allcostobjects ASSIGNING <costobject> WITH KEY cstobject-sysid           = <cbgroup>-cstobject-sysid
                                                                      country                   = 'US'
                                                                      cstobject-cost_object     = hubcostobejctype
                                                                      tpprofile                 = 'HUB'
                                                                      cstobject-functional_area = <cbgroup>-cstobject-functional_area.
            IF sy-subrc = 0.
*                  add the US hub as the receiver
              APPEND INITIAL LINE TO receivers ASSIGNING FIELD-SYMBOL(<usreceiver>).
              <usreceiver>-invoice_currency     = <cbgroup>-local_curr.
              <usreceiver>-active               = abap_true.
              <usreceiver>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
              <usreceiver>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <usreceiver>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <usreceiver>-created_by = sy-uname.
              <usreceiver>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <usreceiver>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <usreceiver>-last_changed_at
              ).


**************************************************************************************************
*      3rd Step                Hub as provider
**************************************************************************************************

**************************************************************************************************
*                                       Provider Determination
**************************************************************************************************
*     As hubs are at functional area so its possible already a config has been added then skip
              READ TABLE allstewardships TRANSPORTING NO FIELDS WITH KEY cost_object_uuid = <usreceiver>-cost_object_uuid.
              IF sy-subrc = 0.
                CONTINUE.
              ENDIF.
              READ TABLE stewardship TRANSPORTING NO FIELDS WITH KEY cost_object_uuid = <usreceiver>-cost_object_uuid.
              IF sy-subrc = 0.
                CONTINUE.
              ENDIF.
              APPEND INITIAL LINE TO stewardship ASSIGNING <stewardship>.
              <stewardship>-valid_from = config-valid_from.
              <stewardship>-valid_to   = config-valid_to.
              <stewardship>-stewardship = config-stewardship.
              <stewardship>-cost_object_uuid = <usreceiver>-cost_object_uuid.
              <stewardship>-workflow_status = 'A'.   "Approved
              <stewardship>-chain_id = element6.
              ushub_count = ushub_count + 1.
              <stewardship>-chain_sequence = ushub_count.

* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <stewardship>-stewardship_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <stewardship>-created_by = sy-uname.
              <stewardship>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <stewardship>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <stewardship>-last_changed_at
              ).

**************************************************************************************************
*                                     Service Product Determination
**************************************************************************************************
*        Check if service product already exist if not skip the config
              _serviceproduct = element6 && '.' && <cbgroup>-cstobject-functional_area.

              READ TABLE allserviceproducts TRANSPORTING NO FIELDS WITH KEY serviceproduct = _serviceproduct BINARY SEARCH.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

              APPEND INITIAL LINE TO serviceproduct ASSIGNING <serviceproduct>.
              <serviceproduct>-service_product = element6 && '.' && <cbgroup>-cstobject-functional_area.
              <serviceproduct>-share_of_cost   = 100.
              <serviceproduct>-valid_from = config-valid_from.
              <serviceproduct>-valid_to   = config-valid_to.
              <serviceproduct>-stewardship_uuid = <stewardship>-stewardship_uuid.
* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <serviceproduct>-service_product_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <serviceproduct>-created_by = sy-uname.
              <serviceproduct>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <serviceproduct>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <serviceproduct>-last_changed_at
              ).


**************************************************************************************************
*                                     Receiver Determination (USHub to principal)
**************************************************************************************************

*      US receivers or principal receivers profit centers
              LOOP AT allcostobjects ASSIGNING <costobject> WHERE cstobject-business_division = <cbgroup>-cstobject-business_division
                                                              AND country                     = 'US'
                                                              AND cstobject-cost_object       = 'PC'.
*                  READ TABLE legalentities ASSIGNING <receivingentity>
*                   WITH KEY legalentity = <costobject>-legal_entity BINARY SEARCH.
*                  IF sy-subrc = 0.
*                    IF <receivingentity> = 'US'.
                APPEND INITIAL LINE TO receivers ASSIGNING <receivers>.
                <receivers>-invoice_currency = <cbgroup>-local_curr.
                <receivers>-active = abap_true.
                <receivers>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
                <receivers>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
                IF lo_uuid IS BOUND.
                  TRY.
                      <receivers>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                    CATCH cx_uuid_error.
                      "handle exception
                  ENDTRY.
                ENDIF.
                <receivers>-created_by = sy-uname.
                <receivers>-last_changed_by = sy-uname.
                /esrcc/cl_utility_core=>get_utc_date_time_ts(
                   IMPORTING
                     time_stamp = <receivers>-created_at
                 ).

                /esrcc/cl_utility_core=>get_utc_date_time_ts(
                  IMPORTING
                    time_stamp = <receivers>-last_changed_at
                ).
*                    ENDIF.
*                  ENDIF.
              ENDLOOP.
              EXIT.
            ENDIF.
*        ENDLOOP.
          ENDIF.
*    ENDIF.

        ELSE.

*    Determine the country of the provider
          IF <cbgroup>-country = 'US'.
*      US receivers or principal receivers profit centers
            LOOP AT allcostobjects ASSIGNING <costobject> WHERE cstobject-business_division = <cbgroup>-cstobject-business_division
                                                            AND country                     = 'US'
                                                            AND cstobject-cost_object       = 'PC'.

              APPEND INITIAL LINE TO receivers ASSIGNING <receivers>.
              <receivers>-invoice_currency = <cbgroup>-local_curr.
              <receivers>-active = abap_true.
              <receivers>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
              <receivers>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <receivers>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <receivers>-created_by = sy-uname.
              <receivers>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <receivers>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <receivers>-last_changed_at
              ).

            ENDLOOP.
          ELSE.

*      NonUS receivers or principal receivers profit centers
            LOOP AT allcostobjects ASSIGNING <costobject> WHERE cstobject-business_division = <cbgroup>-cstobject-business_division
                                                            AND country                    <> 'US'
                                                            AND cstobject-cost_object       = 'PC'.

              APPEND INITIAL LINE TO receivers ASSIGNING <receivers>.
              <receivers>-invoice_currency = <cbgroup>-local_curr.
              <receivers>-active = abap_true.
              <receivers>-cost_object_uuid     = <costobject>-cstobject-cost_object_uuid.
              <receivers>-service_product_uuid = <serviceproduct>-service_product_uuid.
* Assign the 16 digit unique identifier
              IF lo_uuid IS BOUND.
                TRY.
                    <receivers>-serv_prod_rec_uuid = lo_uuid->create_uuid_x16( ).
                  CATCH cx_uuid_error.
                    "handle exception
                ENDTRY.
              ENDIF.
              <receivers>-created_by = sy-uname.
              <receivers>-last_changed_by = sy-uname.
              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                 IMPORTING
                   time_stamp = <receivers>-created_at
               ).

              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                IMPORTING
                  time_stamp = <receivers>-last_changed_at
              ).

            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    MODIFY /esrcc/stewrdshp FROM TABLE @stewardship.
    MODIFY /esrcc/stwd_sp   FROM TABLE @serviceproduct.
    MODIFY /esrcc/stwdsprec FROM TABLE @receivers.

  ENDMETHOD.

  METHOD /esrcc/if_badi_stwconfig~add_provider.


  ENDMETHOD.

  METHOD /esrcc/if_badi_stwconfig~add_receiver.

  ENDMETHOD.

  METHOD /esrcc/if_badi_stwconfig~add_serviceproduct.



  ENDMETHOD.

  METHOD /esrcc/if_badi_stwconfig~derive_costelements.

  ENDMETHOD.

  METHOD /esrcc/if_badi_stwconfig~derive_costobjects.

    DATA costobjects TYPE TABLE OF /esrcc/cst_objct.
    DATA costobject TYPE /esrcc/cst_objct.

*   get all hubs entity master data
    SELECT le~legalentity, leccode~sysid , leccode~ccode FROM /esrcc/le AS le
    INNER JOIN /esrcc/le_ccode AS leccode
    ON leccode~legalentity = le~legalentity
    AND leccode~active = @abap_true
    WHERE tpprofile = 'HUB' INTO TABLE @DATA(legalentities) .

*   get all functional areas
    SELECT * FROM /esrcc/fnc_area INTO TABLE @DATA(functionalareas).

*   get all elements 6 from cost object master data
    SELECT DISTINCT hierarchy1 FROM /esrcc/cst_objct INTO TABLE @DATA(element6).

*   get all cost objects with hub
    SELECT costobject~* FROM /esrcc/cst_objct AS costobject
       INNER JOIN /esrcc/le AS le
       ON le~legalentity = costobject~legal_entity
       AND le~tpprofile = 'HUB'
       ORDER BY
       sysid,
       legal_entity,
       company_code,
       cost_object,
       cost_center
       INTO TABLE @DATA(hubcostobjects).

* get indirect allocation data for hub entities
    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).


    LOOP AT legalentities ASSIGNING FIELD-SYMBOL(<legalentities>).
      LOOP AT element6 ASSIGNING FIELD-SYMBOL(<element6>) WHERE hierarchy1 IS NOT INITIAL.
        LOOP AT functionalareas ASSIGNING FIELD-SYMBOL(<functionalareas>).

          costobject-sysid        = <legalentities>-sysid.
          costobject-legal_entity = <legalentities>-legalentity.
          costobject-company_code = <legalentities>-ccode.
          costobject-cost_object  = 'SCC'.
          costobject-cost_center  = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area.
          costobject-hierarchy1   = <element6>-hierarchy1.
          costobject-functional_area = <functionalareas>-functional_area.
* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                costobject-cost_object_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.

          costobject-created_by = sy-uname.
          costobject-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = costobject-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = costobject-last_changed_at
          ).

          READ TABLE hubcostobjects TRANSPORTING NO FIELDS
                     WITH KEY sysid = costobject-sysid
                              legal_entity = costobject-legal_entity
                              company_code = costobject-company_code
                              cost_object   = costobject-cost_object
                              cost_center  = costobject-cost_center
                              BINARY SEARCH.
          IF sy-subrc <> 0.
            APPEND costobject TO costobjects.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY /esrcc/cst_objct FROM TABLE @costobjects.

  ENDMETHOD.

  METHOD /esrcc/if_badi_stwconfig~derive_serviceproducts.

    DATA serviceproducts TYPE TABLE OF /esrcc/srvpro.
    DATA sp_markup        TYPE TABLE OF /esrcc/srvmkp.
    DATA sp_rule          TYPE TABLE OF /esrcc/chargeout.
    DATA servicetypes     TYPE TABLE OF /esrcc/srtype.
    DATA servicetypetexts TYPE TABLE OF /esrcc/srvtypet.
    DATA tgs              TYPE TABLE OF /esrcc/srvtg.

*   get all functional areas
    SELECT * FROM /esrcc/fnc_area INTO TABLE @DATA(functionalareas).

*   get all functional areas text
    SELECT * FROM /esrcc/fnc_areat INTO TABLE @DATA(functionalareatexts).

*   get all elements 6 from cost object master data
    SELECT DISTINCT hierarchy1 FROM /esrcc/cst_objct INTO TABLE @DATA(element6).

*   get all service types
    SELECT * FROM /esrcc/srtype ORDER BY srvtype INTO TABLE @DATA(srvtypes).

*   get all service types
    SELECT * FROM /esrcc/srvtypet ORDER BY srvtype INTO TABLE @DATA(srvtypetexts).

*   get all service types
    SELECT * FROM /esrcc/srvtg ORDER BY transactiongroup INTO TABLE @DATA(transactiongroups).

*   get all service products
    SELECT * FROM /esrcc/srvpro ORDER BY serviceproduct INTO TABLE @DATA(srvpro).

*   get all markups
    SELECT * FROM /esrcc/srvmkp ORDER BY serviceproduct INTO TABLE @DATA(srvmkp).

*   get all rules mapping
    SELECT * FROM /esrcc/chargeout ORDER BY serviceproduct INTO TABLE @DATA(srvrule).


    LOOP AT element6 ASSIGNING FIELD-SYMBOL(<element6>).
      LOOP AT functionalareas ASSIGNING FIELD-SYMBOL(<functionalareas>).

*service types
        DATA(srvtypeid) = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area+0(4).
        READ TABLE srvtypes TRANSPORTING NO FIELDS WITH KEY srvtype = srvtypeid BINARY SEARCH.
        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO servicetypes ASSIGNING FIELD-SYMBOL(<servicetype>).
          <servicetype>-srvtype  = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area+0(4).
          <servicetype>-created_by = sy-uname.
          <servicetype>-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = <servicetype>-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = <servicetype>-last_changed_at
          ).

          APPEND INITIAL LINE TO servicetypetexts ASSIGNING FIELD-SYMBOL(<servicetypetext>).
          <servicetypetext>-srvtype = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area+0(4).
          <servicetypetext>-spras   = sy-langu.
          READ TABLE functionalareatexts ASSIGNING FIELD-SYMBOL(<functionalareatext>)
          WITH KEY functional_area = <functionalareas>-functional_area BINARY SEARCH.
          IF sy-subrc = 0.
          <servicetypetext>-description = <functionalareatext>-description.
          ENDIF.
        ENDIF.


*Service products
        DATA(id) = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area.

        READ TABLE srvpro TRANSPORTING NO FIELDS WITH KEY serviceproduct = id BINARY SEARCH.
        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO serviceproducts ASSIGNING FIELD-SYMBOL(<serviceproduct>).
          <serviceproduct>-serviceproduct = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area.
          <serviceproduct>-servicetype    = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area+0(4).
          <serviceproduct>-oecdtpg        = 'L'.
          <serviceproduct>-created_by = sy-uname.
          <serviceproduct>-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = <serviceproduct>-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = <serviceproduct>-last_changed_at
          ).
        ENDIF.

*Service product markups
        READ TABLE srvmkp TRANSPORTING NO FIELDS WITH KEY serviceproduct = id
                                                          validfrom      = is_config-valid_from.
        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO sp_markup ASSIGNING FIELD-SYMBOL(<sp_markup>).
          <sp_markup>-serviceproduct = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area.
          <sp_markup>-validfrom = is_config-valid_from.
          <sp_markup>-validto   = is_config-valid_to.
          <sp_markup>-created_by = sy-uname.
          <sp_markup>-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = <sp_markup>-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = <sp_markup>-last_changed_at
          ).
        ENDIF.

*service rules
        READ TABLE srvrule TRANSPORTING NO FIELDS WITH KEY serviceproduct = id
                                                           validfrom      = is_config-valid_from.
        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO sp_rule ASSIGNING FIELD-SYMBOL(<sp_rule>).
          <sp_rule>-serviceproduct = <element6>-hierarchy1 && '.' && <functionalareas>-functional_area.
          <sp_rule>-chargeout_rule_id = is_config-rule_id.
          <sp_rule>-validfrom = is_config-valid_from.
          <sp_rule>-validto   = is_config-valid_to.
          <sp_rule>-created_by = sy-uname.
          <sp_rule>-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
             IMPORTING
               time_stamp = <sp_rule>-created_at
           ).

          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = <sp_rule>-last_changed_at
          ).
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    MODIFY /esrcc/srtype FROM TABLE @servicetypes.
    MODIFY /esrcc/srvpro FROM TABLE @serviceproducts.
    MODIFY /esrcc/srvmkp FROM TABLE @sp_markup.
    MODIFY /esrcc/chargeout FROM TABLE @sp_rule.

  ENDMETHOD.

ENDCLASS.
