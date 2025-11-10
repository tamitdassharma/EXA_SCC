CLASS /esrcc/cl_badi_wf_cst DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ts_stewardship,
        stewardship_uuid  TYPE sysuuid_x16,
        sysid             TYPE /esrcc/sysid,
        sysid_desc        TYPE /esrcc/description,
        legal_entity      TYPE /esrcc/legalentity,
        legal_entity_desc TYPE /esrcc/description,
        company_code      TYPE /esrcc/ccode_de,
        company_code_desc TYPE /esrcc/description,
        cost_object       TYPE /esrcc/costobject_de,
        cost_object_desc  TYPE /esrcc/description,
        cost_center       TYPE /esrcc/costcenter,
        cost_center_desc  TYPE /esrcc/description,
        valid_from        TYPE /esrcc/validfrom,
        valid_to          TYPE /esrcc/validto,
        stewardship       TYPE /esrcc/stewardship,
        chain_id          TYPE /esrcc/chain_id,
        chain_sequence    TYPE /esrcc/chain_sequence,
      END OF ts_stewardship .
    TYPES:
      tt_stewardship TYPE STANDARD TABLE OF ts_stewardship .

    METHODS get_stewardship_data
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      EXPORTING
        !et_stewardship    TYPE tt_stewardship .
    METHODS build_stewardship
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !ct_task_desc      TYPE /esrcc/tt_wf_st_len .
    METHODS build_product
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !ct_task_desc      TYPE /esrcc/tt_wf_st_len .
    METHODS build_receiver
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !ct_task_desc      TYPE /esrcc/tt_wf_st_len .
ENDCLASS.



CLASS /esrcc/cl_badi_wf_cst IMPLEMENTATION.


  METHOD /esrcc/if_workflow_enh~get_agents.
    /esrcc/cl_wf_agents=>get_agents(
        EXPORTING
          iv_wf_id          = iv_wf_id
          iv_approval_level = iv_approval_level
        IMPORTING
          et_agents         = et_agents
      ).
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_description.    " CDS Name: /ESRCC/I_Stewrdshp
    CLEAR et_task_desc.

    build_stewardship(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc = et_task_desc ).

    build_product(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc = et_task_desc ).

    build_receiver(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc = et_task_desc ).

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.    " CDS Name: /ESRCC/I_Stewrdshp
    CLEAR ev_header.

    get_stewardship_data(
      EXPORTING
        it_leading_object = it_leading_object
      IMPORTING
        et_stewardship    = DATA(lt_stewardship)
    ).

    IF lt_stewardship IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_stewardship) = lt_stewardship[ 1 ].

*   Create Workflow Title
    ev_header = |{ TEXT-005 }: { ls_stewardship-legal_entity } ({ ls_stewardship-legal_entity_desc }) { /esrcc/cl_wf_utility=>title_separator } | &&
                |{ ls_stewardship-cost_center } ({ ls_stewardship-cost_center_desc })|.
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
** Group based on Legal Entity and Cost Center
*    get_stewardship_data(
*      EXPORTING
*        it_leading_object = it_leading_object
*      IMPORTING
*        et_stewardship    = DATA(lt_stewardship)
*    ).
*
*    DATA ls_curr_stewardship LIKE LINE OF lt_stewardship.
*    LOOP AT lt_stewardship INTO DATA(ls_stewardship).
*      IF ls_curr_stewardship-legal_entity <> ls_stewardship-legal_entity OR
*         ls_curr_stewardship-cost_center  <> ls_stewardship-cost_center.
*        ls_curr_stewardship = ls_stewardship.
*        APPEND INITIAL LINE TO et_wf_split_data ASSIGNING FIELD-SYMBOL(<fs_wf_split_data>).
*      ENDIF.
*
*      APPEND VALUE #( stewardship_uuid = ls_stewardship-stewardship_uuid ) TO <fs_wf_split_data>-segment.
*    ENDLOOP.

    LOOP AT it_leading_object INTO DATA(ls_leading_object).
      APPEND INITIAL LINE TO et_wf_split_data ASSIGNING FIELD-SYMBOL(<fs_split_data>).
      APPEND ls_leading_object TO <fs_split_data>-segment.
    ENDLOOP.
  ENDMETHOD.


  METHOD build_product.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_STWDSP'.

*   Get service products
    SELECT FROM /esrcc/i_stwdsp AS prd
      INNER JOIN @it_leading_object AS lobj
        ON lobj~stewardship_uuid = prd~stewardshipuuid
      FIELDS prd~stewardshipuuid,
             prd~serviceproduct,
             prd~\_serviceproducttext-description AS serviceproduct_desc,
             prd~validfrom,
             prd~validto,
             prd~shareofcost
      ORDER BY prd~serviceproduct,
               prd~validfrom
      INTO TABLE @DATA(lt_products).

    SELECT prd~serviceproduct, COUNT( * ) AS count
      FROM @lt_products AS prd
      GROUP BY prd~serviceproduct
      INTO TABLE @DATA(lt_product_count).

*   Header Text
    APPEND |<h2>{ TEXT-003 }</h2>| TO ct_task_desc.

    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'SERVICEPRODUCT' data_element = '/ESRCC/SRVPRODUCT' )
                                 ( field_name = 'SHAREOFCOST' data_element = '/ESRCC/COSTSHARE' ) )
    ).

*   Column Header
    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    APPEND lo_html->html_tag_new_row( ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'SERVICEPRODUCT' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-001 ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'SHAREOFCOST' ) TO ct_task_desc.
    APPEND |</tr>| TO ct_task_desc.

*   Column content
    LOOP AT lt_products INTO DATA(ls_product).
      APPEND lo_html->html_tag_new_row( ) TO ct_task_desc.

      DATA(count) = VALUE #( lt_product_count[ serviceproduct = ls_product-serviceproduct ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_product-serviceproduct } ({ ls_product-serviceproduct_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.
      ENDIF.
      APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_product-validfrom DATE = ENVIRONMENT } - { ls_product-validto DATE = ENVIRONMENT }| ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_product-shareofcost ) ) TO ct_task_desc.
      APPEND |</tr>| TO ct_task_desc.

      DELETE lt_product_count WHERE serviceproduct = ls_product-serviceproduct.
    ENDLOOP.
    APPEND |</table>| TO ct_task_desc.
  ENDMETHOD.


  METHOD build_receiver.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_STWDSPREC'.

*   Get service receivers
    SELECT FROM /esrcc/i_stwdsprec AS rec
      INNER JOIN /esrcc/i_stwdsp AS prd
        ON prd~serviceproductuuid = rec~serviceproductuuid
      INNER JOIN @it_leading_object AS lobj
        ON lobj~stewardship_uuid = prd~stewardshipuuid
      FIELDS rec~stewardshipuuid,
             rec~serviceproduct,
             rec~\_serviceproduct\_serviceproducttext-description AS serviceproduct_desc,
             rec~\_serviceproduct-validfrom,
             rec~\_serviceproduct-validto,
             rec~\_costobject-sysid,
             rec~\_costobject\_sysidtext-description AS sysid_desc,
             rec~\_costobject-legalentity,
             rec~\_costobject\_legalentity-description AS legalentity_desc,
             rec~\_costobject-companycode,
             rec~\_costobject\_ccodetext-ccodedescription AS companycode_desc,
             rec~\_costobject-costobject,
             rec~\_costobject\_costobjtypetext-text AS costobject_desc,
             rec~\_costobject-costcenter,
             rec~\_costobject\_costobjecttext[ spras = @sy-langu ]-description AS costcenter_desc,
             rec~invoicecurrency,
             rec~\_invoicecurrency-currencyname AS invoicecurrency_desc,
             rec~erpsalesorder,
             rec~contractid,
             rec~active
      ORDER BY
        rec~serviceproduct,
        rec~\_serviceproduct-validfrom,
        rec~\_serviceproduct-validto,
        rec~\_costobject-sysid,
        rec~\_costobject-legalentity,
        rec~\_costobject-companycode,
        rec~\_costobject-costobject,
        rec~\_costobject-costcenter
      INTO TABLE @DATA(lt_receivers).

    SELECT rec~serviceproduct, rec~validfrom, rec~validto, COUNT( * ) AS count
      FROM @lt_receivers AS rec
      GROUP BY rec~serviceproduct, rec~validfrom, rec~validto
      INTO TABLE @DATA(product_count).

    SELECT rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, COUNT( * ) AS count
      FROM @lt_receivers AS rec
      GROUP BY rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid
      INTO TABLE @DATA(sysid_count).

    SELECT rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, rec~legalentity, COUNT( * ) AS count
      FROM @lt_receivers AS rec
      GROUP BY rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, rec~legalentity
      INTO TABLE @DATA(le_count).

    SELECT rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, rec~legalentity, rec~companycode, COUNT( * ) AS count
      FROM @lt_receivers AS rec
      GROUP BY rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, rec~legalentity, rec~companycode
      INTO TABLE @DATA(ccode_count).

    SELECT rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, rec~legalentity, rec~companycode, rec~costobject, COUNT( * ) AS count
      FROM @lt_receivers AS rec
      GROUP BY rec~serviceproduct, rec~validfrom, rec~validto, rec~sysid, rec~legalentity, rec~companycode, rec~costobject
      INTO TABLE @DATA(cobj_count).

*   Header Text
    APPEND |<h2>{ TEXT-004 }</h2>| TO ct_task_desc.

*   Column Header
    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'SERVICEPRODUCT'  data_element = '/ESRCC/SRVPRODUCT' )
                                 ( field_name = 'SYSID'           data_element = '/ESRCC/RECSYSID' )
                                 ( field_name = 'LEGALENTITY'     data_element = '/ESRCC/RECEIVINGNTITY' )
                                 ( field_name = 'COMPANYCODE'     data_element = '/ESRCC/RECCCODE_DE' )
                                 ( field_name = 'COSTOBJECT'      data_element = '/ESRCC/RECCOSTOBJECT_DE' )
                                 ( field_name = 'COSTCENTER'      data_element = '/ESRCC/RECCOSTCENTER' )
                                 ( field_name = 'INVOICECURRENCY' data_element = 'WAERS' )
                                 ( field_name = 'ERPSALESORDER'   data_element = '/ESRCC/ERPSALESORDER' )
                                 ( field_name = 'CONTRACTID'      data_element = '/ESRCC/CONTRACTID' )
                                 ( field_name = 'ACTIVE'          data_element = '/ESRCC/ACTIVE' ) )
    ).

    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    APPEND lo_html->html_tag_new_row( ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'SERVICEPRODUCT' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-001 ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'SYSID' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'LEGALENTITY' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'COMPANYCODE' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'COSTOBJECT' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'COSTCENTER' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'INVOICECURRENCY' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'ERPSALESORDER' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'CONTRACTID' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'ACTIVE' ) TO ct_task_desc.
    APPEND |</tr>| TO ct_task_desc.

*   Column content
    LOOP AT lt_receivers INTO DATA(ls_receiver).
      APPEND lo_html->html_tag_new_row( ) TO ct_task_desc.

      DATA(count) = VALUE #( product_count[ serviceproduct = ls_receiver-serviceproduct
                                            validfrom      = ls_receiver-validfrom
                                            validto        = ls_receiver-validto ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_receiver-serviceproduct } ({ ls_receiver-serviceproduct_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.

        APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_receiver-validfrom DATE = ENVIRONMENT } - { ls_receiver-validto DATE = ENVIRONMENT }|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.
      ENDIF.

      count = VALUE #( sysid_count[ serviceproduct = ls_receiver-serviceproduct
                                    validfrom      = ls_receiver-validfrom
                                    validto        = ls_receiver-validto
                                    sysid          = ls_receiver-sysid ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_receiver-sysid } ({ ls_receiver-sysid_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.
      ENDIF.

      count = VALUE #( le_count[ serviceproduct = ls_receiver-serviceproduct
                                 validfrom      = ls_receiver-validfrom
                                 validto        = ls_receiver-validto
                                 sysid          = ls_receiver-sysid
                                 legalentity    = ls_receiver-legalentity ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_receiver-legalentity } ({ ls_receiver-legalentity_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.
      ENDIF.

      count = VALUE #( ccode_count[ serviceproduct = ls_receiver-serviceproduct
                                    validfrom      = ls_receiver-validfrom
                                    validto        = ls_receiver-validto
                                    sysid          = ls_receiver-sysid
                                    legalentity    = ls_receiver-legalentity
                                    companycode    = ls_receiver-companycode ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_receiver-companycode } ({ ls_receiver-companycode_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.
      ENDIF.

      count = VALUE #( cobj_count[ serviceproduct = ls_receiver-serviceproduct
                                   validfrom      = ls_receiver-validfrom
                                   validto        = ls_receiver-validto
                                   sysid          = ls_receiver-sysid
                                   legalentity    = ls_receiver-legalentity
                                   companycode    = ls_receiver-companycode
                                   costobject     = ls_receiver-costobject ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_receiver-costobject } ({ ls_receiver-costobject_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO ct_task_desc.
      ENDIF.

      APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_receiver-costcenter } ({ ls_receiver-costcenter_desc })| ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_receiver-invoicecurrency } ({ ls_receiver-invoicecurrency_desc })| ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_receiver-erpsalesorder ) ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_receiver-contractid ) ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_receiver-active ) ) TO ct_task_desc.
      APPEND |</tr>| TO ct_task_desc.

      DELETE product_count WHERE serviceproduct = ls_receiver-serviceproduct
                             AND validfrom      = ls_receiver-validfrom
                             AND validto        = ls_receiver-validto.
      DELETE sysid_count WHERE serviceproduct = ls_receiver-serviceproduct
                           AND validfrom      = ls_receiver-validfrom
                           AND validto        = ls_receiver-validto
                           AND sysid          = ls_receiver-sysid.
      DELETE le_count WHERE serviceproduct = ls_receiver-serviceproduct
                        AND validfrom      = ls_receiver-validfrom
                        AND validto        = ls_receiver-validto
                        AND sysid          = ls_receiver-sysid
                        AND legalentity    = ls_receiver-legalentity.
      DELETE ccode_count WHERE serviceproduct = ls_receiver-serviceproduct
                           AND validfrom      = ls_receiver-validfrom
                           AND validto        = ls_receiver-validto
                           AND sysid          = ls_receiver-sysid
                           AND legalentity    = ls_receiver-legalentity
                           AND companycode    = ls_receiver-companycode.
      DELETE cobj_count WHERE serviceproduct = ls_receiver-serviceproduct
                          AND validfrom      = ls_receiver-validfrom
                          AND validto        = ls_receiver-validto
                          AND sysid          = ls_receiver-sysid
                          AND legalentity    = ls_receiver-legalentity
                          AND companycode    = ls_receiver-companycode
                          AND costobject     = ls_receiver-costobject.

    ENDLOOP.
    APPEND |</table>| TO ct_task_desc.
  ENDMETHOD.


  METHOD build_stewardship.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_STEWRDSHP'.

*   Get stewardship with descriptions
    SELECT FROM /esrcc/i_stewrdshp AS stw
      INNER JOIN @it_leading_object AS lobj
        ON lobj~stewardship_uuid = stw~stewardshipuuid
      FIELDS stw~stewardshipuuid,
             stw~\_costobject-sysid,
             stw~\_costobject\_sysidtext-description AS sysid_desc,
             stw~\_costobject-legalentity,
             stw~\_costobject\_legalentity-description AS legalentity_desc,
             stw~\_costobject-companycode,
             stw~\_costobject\_ccodetext-ccodedescription AS companycode_desc,
             stw~\_costobject-costobject,
             stw~\_costobject\_costobjtypetext-text AS costobject_desc,
             stw~\_costobject-costcenter,
             stw~\_costobject\_costobjecttext[ spras = @sy-langu ]-description AS costcenter_desc,
             stw~validfrom,
             stw~validto,
             stw~stewardship,
             stw~chainid,
             stw~chainsequence,
             stw~commentid
      INTO TABLE @DATA(lt_stewardship).

*   Header Text
    APPEND |<h2>{ TEXT-002 }</h2>| TO ct_task_desc.

    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'SYSID'         data_element = '/ESRCC/SYSID' )
                                 ( field_name = 'LEGALENTITY'   data_element = '/ESRCC/LEGALENTITY' )
                                 ( field_name = 'COMPANYCODE'   data_element = '/ESRCC/CCODE_DE' )
                                 ( field_name = 'COSTOBJECT'    data_element = '/ESRCC/COSTOBJECT_DE' )
                                 ( field_name = 'COSTCENTER'    data_element = '/ESRCC/COSTCENTER' )
                                 ( field_name = 'STEWARDSHIP'   data_element = '/ESRCC/STEWARDSHIP' )
                                 ( field_name = 'CHAINID'       data_element = '/ESRCC/CHAIN_ID' )
                                 ( field_name = 'CHAINSEQUENCE' data_element = '/ESRCC/CHAIN_SEQUENCE' )
                                 ( field_name = 'COMMENTS'      data_element = '/ESRCC/COMMENT' ) )
    ).

*   Column content
    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    LOOP AT lt_stewardship INTO DATA(ls_stewardship).
      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'SYSID'
                      iv_id        = CONV #( ls_stewardship-sysid )
                      iv_id_desc   = CONV #( ls_stewardship-sysid_desc )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'LEGALENTITY'
                      iv_id        = CONV #( ls_stewardship-legalentity )
                      iv_id_desc   = CONV #( ls_stewardship-legalentity_desc )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COMPANYCODE'
                      iv_id        = CONV #( ls_stewardship-companycode )
                      iv_id_desc   = CONV #( ls_stewardship-companycode_desc )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COSTOBJECT'
                      iv_id        = CONV #( ls_stewardship-costobject )
                      iv_id_desc   = CONV #( ls_stewardship-costobject_desc )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COSTCENTER'
                      iv_id        = CONV #( ls_stewardship-costcenter )
                      iv_id_desc   = CONV #( ls_stewardship-costcenter_desc )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = TEXT-001
                      iv_id        = |{ ls_stewardship-validfrom DATE = ENVIRONMENT } - { ls_stewardship-validto DATE = ENVIRONMENT }|
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'STEWARDSHIP'
                      iv_id        = CONV #( ls_stewardship-stewardship )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'CHAINID'
                      iv_id        = CONV #( ls_stewardship-chainid )
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'CHAINSEQUENCE'
                      iv_id        = CONV #( ls_stewardship-chainsequence )
                    ) TO ct_task_desc.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_stewardship-commentid
        IMPORTING
          comments   = DATA(comments)
      ).

      DELETE comments WHERE workflow_id IS NOT INITIAL.
      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COMMENTS'
                      iv_id        = VALUE #( comments[ 1 ]-wfcommenttext OPTIONAL )
                    ) TO ct_task_desc.
    ENDLOOP.
    APPEND |</table>| TO ct_task_desc.
  ENDMETHOD.


  METHOD get_stewardship_data.
    SELECT FROM @it_leading_object AS lobj
      INNER JOIN /esrcc/i_stewrdshp AS stw
        ON stw~stewardshipuuid = lobj~stewardship_uuid
      INNER JOIN /esrcc/i_coscen_f4 AS ccen
        ON ccen~costobjectuuid = stw~costobjectuuid
      FIELDS stw~stewardshipuuid         AS stewardship_uuid,
             stw~sysid,
             ccen~sysiddescription       AS sysid_desc,
             stw~legalentity             AS legal_entity,
             ccen~legalentitydescription AS legal_entity_desc,
             stw~companycode             AS company_code,
             ccen~companycodedescription AS company_code_desc,
             stw~costobject              AS cost_object,
             ccen~costobjectdescription  AS cost_object_desc,
             stw~costcenter              AS cost_center,
             ccen~description            AS cost_center_desc,
             stw~validfrom               AS valid_from,
             stw~validto                 AS valid_to,
             stw~stewardship,
             stw~chainid                 AS chain_id,
             stw~chainsequence           AS chain_sequence
    INTO CORRESPONDING FIELDS OF TABLE @et_stewardship.
  ENDMETHOD.
ENDCLASS.
