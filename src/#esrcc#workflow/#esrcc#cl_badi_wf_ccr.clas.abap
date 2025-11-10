class /ESRCC/CL_BADI_WF_CCR definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /ESRCC/IF_WORKFLOW_ENH .
protected section.
private section.

  methods BUILD_CO_RULE
    importing
      !IT_LEADING_OBJECT type /ESRCC/TT_WF_LEADINGOBJECT
    changing
      !CT_TASK_DESC type /ESRCC/TT_WF_ST_LEN .
  methods BUILD_WEIGHTAGE
    importing
      !IT_LEADING_OBJECT type /ESRCC/TT_WF_LEADINGOBJECT
    changing
      !CT_TASK_DESC type /ESRCC/TT_WF_ST_LEN .
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CCR IMPLEMENTATION.


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
  CLEAR et_task_desc.

  build_co_rule(
    EXPORTING
      it_leading_object = it_leading_object
    CHANGING
      ct_task_desc = et_task_desc ).

ENDMETHOD.


METHOD /esrcc/if_workflow_enh~set_wf_task_title.    " CDS Name: /ESRCC/I_CoRule
  CLEAR: ev_header.

  READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

* Get chargeout rules with descriptions
  SELECT SINGLE FROM /esrcc/i_corule
    FIELDS ruleid,
           \_ruletext[ spras = @sy-langu ]-description,
           chargeoutmethod,
           \_chargeout-text AS ch_method_desc
    WHERE ruleid = @ls_leading_object-rule_id
    INTO @DATA(ls_corule).

* Create Workflow Title
  ev_header = |{ text-003 }: { ls_corule-ruleid } ({ ls_corule-description }) { /esrcc/cl_wf_utility=>title_separator } | &&
              |{ ls_corule-chargeoutmethod } ({ ls_corule-ch_method_desc })|.
ENDMETHOD.


METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
  LOOP AT it_leading_object INTO DATA(ls_leading_object).
    APPEND INITIAL LINE TO et_wf_split_data ASSIGNING FIELD-SYMBOL(<fs_split_data>).
    APPEND ls_leading_object TO <fs_split_data>-segment.
  ENDLOOP.
ENDMETHOD.


  METHOD build_co_rule.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_CORULE'.

*   Get chargeout rules with descriptions
    SELECT FROM /esrcc/i_corule AS rule
      INNER JOIN @it_leading_object AS lobj
        ON lobj~rule_id = rule~ruleid
      FIELDS rule~ruleid,
             rule~\_ruletext[ spras = @sy-langu ]-description,
             rule~chargeoutmethod,
             rule~\_chargeout-text                             AS ch_method_desc,
*             rule~costversion,
*             rule~\_costversiontext-text                       AS costversion_desc,
             rule~capacityversion,
             rule~\_capacityversiontext-text                   AS capacityversion_desc,
             rule~consumptionversion,
             rule~\_consumptionversiontext-text                AS consumptionversion_desc,
             rule~keyversion,
             rule~\_keyversiontext-text                        AS keyversion_desc,
             rule~adhocallocationkey,
             rule~\_allocationkeytext-allocationkeydescription AS adhocallocationkey_desc,
             rule~commentid
      INTO TABLE @DATA(lt_corule).

*   Get fieldname descriptions
    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'RULEID'             data_element = '/ESRCC/CHARGEOUT_RULE_ID' )
                                 ( field_name = 'CHARGEOUTMETHOD'    data_element = '/ESRCC/CHARGOUT' )
                                 ( field_name = 'COSTVERSION'        data_element = '/ESRCC/COST_VERSION' )
                                 ( field_name = 'CAPACITYVERSION'    data_element = '/ESRCC/CAPACITY_VERSION' )
                                 ( field_name = 'CONSUMPTIONVERSION' data_element = '/ESRCC/CONSUMPTION_VERSION' )
                                 ( field_name = 'KEYVERSION'         data_element = '/ESRCC/KEY_VERSION' )
                                 ( field_name = 'ADHOCALLOCATIONKEY' data_element = '/ESRCC/ADHOC_ALLOCATION_KEY' )
                                 ( field_name = 'COMMENTS'           data_element = '/ESRCC/COMMENT' ) )
    ).

*   Get Chargeout Rules Configuration
    DATA(lt_co_rule_relevance) = /esrcc/cl_config_util=>get_co_rule_config( ).

    APPEND |<h2>{ TEXT-001 }</h2>| TO ct_task_desc.

    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    LOOP AT lt_corule INTO DATA(ls_corule).
      DATA(ls_rule_relevance) = VALUE #( lt_co_rule_relevance[ chargeout_method = ls_corule-chargeoutmethod ] OPTIONAL ).

*     Rule ID
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'RULEID'
                        iv_id        = CONV #( ls_corule-ruleid )
                        iv_id_desc   = CONV #( ls_corule-description )
                      ) TO ct_task_desc.

*     Chargeout Method
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'CHARGEOUTMETHOD'
                        iv_id        = CONV #( ls_corule-chargeoutmethod )
                        iv_id_desc   = CONV #( ls_corule-ch_method_desc )
                      ) TO ct_task_desc.

*     Cost Version
*      IF ls_rule_relevance-cost_version = abap_true.
*        APPEND LINES OF lo_html->generate_table_line(
*                          iv_fieldname = 'COSTVERSION'
*                          iv_id        = CONV #( ls_corule-costversion )
*                          iv_id_desc   = CONV #( ls_corule-costversion_desc )
*                        ) TO ct_task_desc.
*      ENDIF.

*     Capacity Version
      IF ls_rule_relevance-capacity_version = abap_true.
        APPEND LINES OF lo_html->generate_table_line(
                          iv_fieldname = 'CAPACITYVERSION'
                          iv_id        = CONV #( ls_corule-capacityversion )
                          iv_id_desc   = CONV #( ls_corule-capacityversion_desc )
                        ) TO ct_task_desc.
      ENDIF.

*     Consumption Version
      IF ls_rule_relevance-consumption_version = abap_true.
        APPEND LINES OF lo_html->generate_table_line(
                          iv_fieldname = 'CONSUMPTIONVERSION'
                          iv_id        = CONV #( ls_corule-consumptionversion )
                          iv_id_desc   = CONV #( ls_corule-consumptionversion_desc )
                        ) TO ct_task_desc.
      ENDIF.

*     Key Version
      IF ls_rule_relevance-key_version = abap_true.
        APPEND LINES OF lo_html->generate_table_line(
                          iv_fieldname = 'KEYVERSION'
                          iv_id        = CONV #( ls_corule-keyversion )
                          iv_id_desc   = CONV #( ls_corule-keyversion_desc )
                        ) TO ct_task_desc.
      ENDIF.

*     Adhoc Allocation Key
      IF ls_rule_relevance-adhoc_allocation_key = abap_true.
        APPEND LINES OF lo_html->generate_table_line(
                          iv_fieldname = 'ADHOCALLOCATIONKEY'
                          iv_id        = CONV #( ls_corule-adhocallocationkey )
                          iv_id_desc   = CONV #( ls_corule-adhocallocationkey_desc )
                        ) TO ct_task_desc.
      ENDIF.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_corule-commentid
        IMPORTING
          comments   = DATA(comments)
      ).

      DELETE comments WHERE workflow_id IS NOT INITIAL.
      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COMMENTS'
                      iv_id        = VALUE #( comments[ 1 ]-wfcommenttext OPTIONAL )
                    ) TO ct_task_desc.
    ENDLOOP.

    APPEND '</table>' TO ct_task_desc.

    IF ls_rule_relevance-weightage_tab = abap_true.
      build_weightage(
        EXPORTING
          it_leading_object = it_leading_object
        CHANGING
          ct_task_desc      = ct_task_desc
      ).
    ENDIF.
  ENDMETHOD.


  METHOD build_weightage.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_CORULE'.

*   Get allocation weightage with descriptions
    SELECT FROM /esrcc/i_allocweightage AS wgt
      INNER JOIN @it_leading_object AS lobj
        ON lobj~rule_id = wgt~ruleid
      FIELDS wgt~ruleid,
             wgt~allocationkey,
             wgt~\_allockeytext-allocationkeydescription AS allocationkey_desc,
             wgt~allocationperiod,
             wgt~\_allocperiodtext-text AS allocationperiod_desc,
             wgt~refperiod,
             wgt~weightage
      INTO TABLE @DATA(lt_weightage).

*   Header Text
    APPEND |<h2>{ TEXT-002 }</h2>| TO ct_task_desc.

    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'ALLOCATIONKEY' data_element = '/ESRCC/ALLOCKEY' )
                                 ( field_name = 'ALLOCATIONPERIOD' data_element = '/ESRCC/ALLOCATION_PERIOD' )
                                 ( field_name = 'REFPERIOD' data_element = '/ESRCC/REFERENCE_PERIOD' )
                                 ( field_name = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
    ).

*   Column Header
    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    APPEND lo_html->html_tag_new_row( ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'ALLOCATIONKEY' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'ALLOCATIONPERIOD' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'REFPERIOD' ) TO ct_task_desc.
    APPEND LINES OF lo_html->generate_table_column( is_header = abap_true iv_fieldname = 'WEIGHTAGE' ) TO ct_task_desc.
    APPEND |</tr>| TO ct_task_desc.

*   Column content
    LOOP AT lt_weightage INTO DATA(ls_weightage).
      APPEND lo_html->html_tag_new_row( ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_weightage-allocationkey } ({ ls_weightage-allocationkey_desc })| ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = |{ ls_weightage-allocationperiod } ({ ls_weightage-allocationperiod_desc })| ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_weightage-refperiod ) ) TO ct_task_desc.
      APPEND LINES OF lo_html->generate_table_column( iv_content = CONV #( ls_weightage-weightage ) ) TO ct_task_desc.
      APPEND |</tr>| TO ct_task_desc.
    ENDLOOP.
    APPEND |</table>| TO ct_task_desc.
  ENDMETHOD.
ENDCLASS.
