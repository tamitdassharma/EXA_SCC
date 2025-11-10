CLASS /esrcc/cl_badi_wf_cpm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CPM IMPLEMENTATION.


  METHOD /esrcc/if_workflow_enh~get_agents.
    /esrcc/cl_wf_agents=>get_agents(
      EXPORTING
        iv_wf_id          = iv_wf_id
        iv_approval_level = iv_approval_level
      IMPORTING
        et_agents         = et_agents
    ).
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_description.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_SRVMKP'.

    CLEAR et_task_desc.

*   Get service markups with descriptions
    SELECT FROM /esrcc/i_srvmkp AS mkp
      INNER JOIN @it_leading_object AS lobj
        ON  lobj~serviceproduct = mkp~serviceproduct
        AND lobj~valid_from     = mkp~validfrom
      FIELDS mkp~serviceproduct,
             mkp~\_producttext-description AS serviceproduct_desc,
             mkp~validfrom,
             mkp~validto,
             mkp~origcost,
             mkp~passcost,
             mkp~intraorigcost,
             mkp~intrapasscost,
             mkp~commentid
      INTO TABLE @DATA(lt_markup).

    SELECT mkp~serviceproduct, COUNT( * ) AS count
      FROM @lt_markup AS mkp
      GROUP BY mkp~serviceproduct
      INTO TABLE @DATA(product_count).

*   Header
    APPEND |<h2>{ TEXT-001 }</h2>| TO et_task_desc.

    DATA(lo_html) = NEW /esrcc/cl_wf_html( cds_entity_name = lc_entity_name
                                           fields          = VALUE #( ( field_name = 'SERVICEPRODUCT' data_element = '/ESRCC/SRVPRODUCT' )
                                                                      ( field_name = 'COMMENTS'       data_element = '/ESRCC/COMMENT' ) ) ).

*   Header Row 1
    APPEND lo_html->html_tag_new_table( ) TO et_task_desc.
    APPEND lo_html->html_tag_new_row( ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'SERVICEPRODUCT' iv_addn_prop = 'rowspan="2"' ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-002 iv_addn_prop = 'rowspan="2"' ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-003 iv_addn_prop = 'colspan="2"' ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-004 iv_addn_prop = 'colspan="2"' ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'COMMENTS' iv_addn_prop = 'rowspan="2"' ) TO et_task_desc.
    APPEND |</tr>| TO et_task_desc.

*   Header Row 2
    APPEND lo_html->html_tag_new_row( ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-005 ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-006 ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-005 ) TO et_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_content = TEXT-006 ) TO et_task_desc.
    APPEND |</tr>| TO et_task_desc.

*   Content Rows
    LOOP AT lt_markup INTO DATA(ls_markup).
      APPEND lo_html->html_tag_new_row( ) TO et_task_desc.

      DATA(count) = VALUE #( product_count[ serviceproduct = ls_markup-serviceproduct ]-count OPTIONAL ).
      IF count > 0.
        APPEND LINES OF lo_html->generate_table_column( iv_content   = |{ ls_markup-serviceproduct } ({ ls_markup-serviceproduct_desc })|
                                                        iv_addn_prop = COND #( WHEN count > 1 THEN |rowspan="{ count }"| ELSE '' ) ) TO et_task_desc.
      ENDIF.

      APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_markup-validfrom DATE = ENVIRONMENT } - { ls_markup-validto DATE = ENVIRONMENT }| ) TO et_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_markup-origcost ) ) TO et_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_markup-passcost ) ) TO et_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_markup-intraorigcost ) ) TO et_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_markup-intrapasscost ) ) TO et_task_desc.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_markup-commentid
        IMPORTING
          comments   = DATA(comments)
      ).

      DELETE comments WHERE workflow_id IS NOT INITIAL.
      APPEND LINES OF lo_html->generate_table_column( iv_content = VALUE #( comments[ 1 ]-wfcommenttext OPTIONAL ) ) TO et_task_desc.
      APPEND |</tr>| TO et_task_desc.

      DELETE product_count WHERE serviceproduct = ls_markup-serviceproduct.
    ENDLOOP.
    APPEND |</table>| TO et_task_desc.
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.    " CDS Name: /ESRCC/I_SrvMkp
    CLEAR: ev_header.

    SELECT FROM /esrcc/i_srvmkp AS mkp
        INNER JOIN @it_leading_object AS lobj
          ON  lobj~serviceproduct = mkp~serviceproduct
          AND lobj~valid_from     = mkp~validfrom
        FIELDS mkp~serviceproduct,
               mkp~\_producttext-description AS serviceproduct_desc
        INTO TABLE @DATA(lt_markup).

    IF lt_markup IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_markup) = lt_markup[ 1 ].

*   Create Workflow Title
    ev_header = |{ text-007 }: { ls_markup-serviceproduct } ({ ls_markup-serviceproduct_desc })|.
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
    LOOP AT it_leading_object INTO DATA(ls_leading_object) GROUP BY ( serviceproduct = ls_leading_object-serviceproduct )
                                                           ASSIGNING FIELD-SYMBOL(<grp_ref>).
      APPEND INITIAL LINE TO et_wf_split_data ASSIGNING FIELD-SYMBOL(<fs_wf_split_data>).
      LOOP AT GROUP <grp_ref> ASSIGNING FIELD-SYMBOL(<fs_group>).
        APPEND CORRESPONDING #( <fs_group> ) TO <fs_wf_split_data>-segment.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
