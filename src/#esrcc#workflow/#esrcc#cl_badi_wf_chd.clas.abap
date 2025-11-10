CLASS /esrcc/cl_badi_wf_chd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_badi_workflow_bc .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS build_task_description
      IMPORTING
        it_leading_object TYPE /esrcc/tt_wf_leadingobject_bc
      CHANGING
        ct_task_desc      TYPE /esrcc/tt_wf_st_len.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CHD IMPLEMENTATION.


  METHOD /esrcc/if_badi_workflow_bc~get_agents.
    /esrcc/cl_wf_agents=>get_agents_bc(
      EXPORTING
        iv_wf_id          = iv_wf_id
        iv_approval_level = iv_approval_level
      IMPORTING
        et_agents         = et_agents
    ).
  ENDMETHOD.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_description.
    CLEAR et_task_desc.

    build_task_description(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc = et_task_desc ).
  ENDMETHOD.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_title.
    CLEAR: ev_header.
    CHECK it_leading_object IS NOT INITIAL.

    DATA(ls_leading_object) = it_leading_object[ 1 ].

**   Get list of values
*    SELECT SINGLE FROM /ESRCC/I_HierDef
*      FIELDS Hierarchy1,
*             \_ruletext[ spras = @sy-langu ]-description,
*             chargeoutmethod,
*             \_chargeout-text AS ch_method_desc
*      WHERE ruleid = @ls_leading_object-rule_id
*      INTO @DATA(ls_corule).

*   Create Workflow Title
    ev_header = |{ text-001 }: | &&
                ls_leading_object-hierarchy1 && /esrcc/cl_wf_utility=>title_separator &&
                ls_leading_object-hierarchy2 && /esrcc/cl_wf_utility=>title_separator &&
                ls_leading_object-hierarchy3 && /esrcc/cl_wf_utility=>title_separator &&
                ls_leading_object-hierarchy4 && /esrcc/cl_wf_utility=>title_separator &&
                |{ ls_leading_object-valid_from DATE = USER }|.
  ENDMETHOD.


  METHOD /esrcc/if_badi_workflow_bc~split_and_create_wf_data.
    LOOP AT it_leading_object INTO DATA(ls_leading_object).
      APPEND INITIAL LINE TO et_wf_split_data ASSIGNING FIELD-SYMBOL(<fs_split_data>).
      APPEND ls_leading_object TO <fs_split_data>-segment.
    ENDLOOP.
  ENDMETHOD.


  METHOD build_task_description.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_HIERDEF'.

*   Get chargeout rules with descriptions
    SELECT FROM /esrcc/i_hierdef AS hd
      INNER JOIN @it_leading_object AS lobj
        ON  lobj~hierarchy1 = hd~hierarchy1
        AND lobj~hierarchy2 = hd~hierarchy2
        AND lobj~hierarchy3 = hd~hierarchy3
        AND lobj~hierarchy4 = hd~hierarchy4
        AND lobj~valid_from = hd~validfrom
      FIELDS hd~hierarchy1,
             hd~hierarchy2,
             hd~hierarchy3,
             hd~hierarchy4,
             hd~validfrom,
             hd~validto,
             hd~ruleid,
             hd~\_ruletext-description AS ruleid_desc,
             hd~srvprddef,
             hd~srvrecdef,
             hd~stewardship,
             hd~currencyderivationtype,
             hd~\_currencytypetext-text AS currencydervtype_desc,
             hd~ishub,
             hd~commentid
      INTO TABLE @DATA(lt_hierdef).

*   Get fieldname descriptions
    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'HIERARCHY1'             data_element = '/ESRCC/HIERARCHY1' )
                                 ( field_name = 'HIERARCHY2'             data_element = '/ESRCC/HIERARCHY2' )
                                 ( field_name = 'HIERARCHY3'             data_element = '/ESRCC/HIERARCHY3' )
                                 ( field_name = 'HIERARCHY4'             data_element = '/ESRCC/HIERARCHY4' )
                                 ( field_name = 'RULEID'                 data_element = '/ESRCC/CHARGEOUT_RULE_ID' )
                                 ( field_name = 'SRVPRDDEF'              data_element = '/ESRCC/SERVICE_PRODUCT_DEF' )
                                 ( field_name = 'SRVRECDEF'              data_element = '/ESRCC/SERVICE_RECEIVER_DEF' )
                                 ( field_name = 'STEWARDSHIP'            data_element = '/ESRCC/STEWARDSHIP' )
                                 ( field_name = 'CURRENCYDERIVATIONTYPE' data_element = '/ESRCC/CURRENCY_DERIVATION_TYPE' )
                                 ( field_name = 'ISHUB'                  data_element = '/ESRCC/IS_HUB' )
                                 ( field_name = 'COMMENTS'               data_element = '/ESRCC/COMMENT' ) )
    ).

    APPEND |<h2>{ TEXT-001 }</h2>| TO ct_task_desc.

    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    LOOP AT lt_hierdef INTO DATA(ls_hierdef).
*     Hierarchy 1
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'HIERARCHY1'
                        iv_id        = CONV #( ls_hierdef-hierarchy1 )
                      ) TO ct_task_desc.

*     Hierarchy 2
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'HIERARCHY2'
                        iv_id        = CONV #( ls_hierdef-hierarchy2 )
                      ) TO ct_task_desc.

*     Hierarchy 3
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'HIERARCHY3'
                        iv_id        = CONV #( ls_hierdef-hierarchy3 )
                      ) TO ct_task_desc.

*     Hierarchy 4
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'HIERARCHY4'
                        iv_id        = CONV #( ls_hierdef-hierarchy4 )
                      ) TO ct_task_desc.

*     Validity
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = TEXT-002
                        iv_id        = |{ ls_hierdef-validfrom DATE = ENVIRONMENT } - { ls_hierdef-validto DATE = ENVIRONMENT }|
                      ) TO ct_task_desc.

*     Rule ID
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'RULEID'
                        iv_id        = CONV #( ls_hierdef-ruleid )
                        iv_id_desc   = CONV #( ls_hierdef-ruleid_desc )
                      ) TO ct_task_desc.

*     Service Product Rule Definition
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'SRVPRDDEF'
                        iv_id        = CONV #( ls_hierdef-srvprddef )
                      ) TO ct_task_desc.

*     Service Receiver Rule Definition
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'SRVRECDEF'
                        iv_id        = CONV #( ls_hierdef-srvrecdef )
                      ) TO ct_task_desc.

*     Stewardship
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'STEWARDSHIP'
                        iv_id        = CONV #( ls_hierdef-stewardship )
                      ) TO ct_task_desc.

*     Currency Derivation Type
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'CURRENCYDERIVATIONTYPE'
                        iv_id        = CONV #( ls_hierdef-currencyderivationtype )
                        iv_id_desc   = CONV #( ls_hierdef-currencydervtype_desc )
                      ) TO ct_task_desc.

*     Hub Info
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'ISHUB'
                        iv_id        = CONV #( ls_hierdef-ishub )
                      ) TO ct_task_desc.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_hierdef-commentid
        IMPORTING
          comments   = DATA(comments)
      ).

      DELETE comments WHERE workflow_id IS NOT INITIAL.
      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COMMENTS'
                      iv_id        = VALUE #( comments[ 1 ]-wfcommenttext OPTIONAL )
                    ) TO ct_task_desc.
    ENDLOOP.

    APPEND lo_html->html_tag_end_table( ) TO ct_task_desc.
  ENDMETHOD.
ENDCLASS.
