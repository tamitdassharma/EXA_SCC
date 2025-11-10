CLASS /esrcc/cl_config_ve_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      tt_co_rule     TYPE STANDARD TABLE OF /esrcc/c_corule WITH DEFAULT KEY,
      tt_markup      TYPE STANDARD TABLE OF /esrcc/c_srvmkp WITH DEFAULT KEY,
      tt_stewardship TYPE STANDARD TABLE OF /esrcc/c_stewrdshp WITH DEFAULT KEY,
      tt_hier_def    TYPE STANDARD TABLE OF /esrcc/c_hierdef WITH DEFAULT KEY.

    DATA:
      gv_entity TYPE string.

    METHODS calculate_co_rule
      CHANGING ct_co_rule TYPE tt_co_rule.
    METHODS markup_update_comment
      CHANGING ct_markup TYPE tt_markup.
    METHODS stewardship_update_comment
      CHANGING ct_stewardship TYPE tt_stewardship.
    METHODS hier_def_update_comment
      CHANGING ct_hier_def TYPE tt_hier_def.
    METHODS: generate_comments
      IMPORTING
        comment_id          TYPE /esrcc/commentid
      RETURNING
        VALUE(comment_text) TYPE /esrcc/comment.
ENDCLASS.



CLASS /esrcc/cl_config_ve_handler IMPLEMENTATION.


  METHOD calculate_co_rule.
    DATA(lt_co_rule_relevance) = /esrcc/cl_config_util=>get_co_rule_config( ).

    SELECT rule~ruleid, coalesce( draft~chargeoutmethod, db~chargeout_method, rule~chargeoutmethod ) AS chargeoutmethod,
           CASE WHEN rule~commentid IS INITIAL THEN db~comment_id END AS commentid
        FROM @ct_co_rule AS rule
        LEFT OUTER JOIN /esrcc/d_co_rule AS draft
            ON draft~ruleid = rule~ruleid
           AND draft~draftentityoperationcode NOT IN ( 'D', 'L' )
        LEFT OUTER JOIN /esrcc/co_rule AS db
            ON db~rule_id = rule~ruleid
        INTO CORRESPONDING FIELDS OF TABLE @ct_co_rule.

    LOOP AT ct_co_rule ASSIGNING FIELD-SYMBOL(<fs_co_rule>).
      DATA(ls_relevance) = VALUE #( lt_co_rule_relevance[ chargeout_method = <fs_co_rule>-chargeoutmethod ] OPTIONAL ).

      <fs_co_rule>-hidecostversion        = COND #( WHEN ls_relevance-cost_version         = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-hidecapacityversion    = COND #( WHEN ls_relevance-capacity_version     = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-hideconsumptionversion = COND #( WHEN ls_relevance-consumption_version  = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-hidekeyversion         = COND #( WHEN ls_relevance-key_version          = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-hideadhocallocationkey = COND #( WHEN ls_relevance-adhoc_allocation_key = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-hideweightagetab       = COND #( WHEN ls_relevance-weightage_tab        = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-comments               = generate_comments( comment_id = <fs_co_rule>-commentid ).
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_comments.
    CHECK comment_id IS NOT INITIAL.

    /esrcc/cl_comments_util=>read_comments(
      EXPORTING
        instanceid = comment_id
      IMPORTING
        comments   = DATA(comments)
    ).

    comment_text = REDUCE /esrcc/comment( INIT comment = VALUE /esrcc/comment( )
                             FOR wa IN comments
                             LET user_format = |{ wa-created_at TIMESTAMP = USER }| IN
                             NEXT comment =
                             COND #( WHEN comment IS INITIAL THEN |{ wa-created_by }: { user_format(19) }{ cl_abap_char_utilities=>cr_lf }{ wa-wfcommenttext }|
                                     ELSE |{ comment }{ cl_abap_char_utilities=>cr_lf }{ cl_abap_char_utilities=>cr_lf }{ wa-created_by }: { user_format(19) }{ cl_abap_char_utilities=>cr_lf }{ wa-wfcommenttext }| ) ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    CASE gv_entity.
      WHEN '/ESRCC/C_CORULE'.
        DATA(lt_co_rule) = CORRESPONDING tt_co_rule( it_original_data ).

        calculate_co_rule(
          CHANGING
            ct_co_rule = lt_co_rule
        ).

        ct_calculated_data = CORRESPONDING #( lt_co_rule ).

      WHEN '/ESRCC/C_SRVMKP'.
        DATA(lt_markup) = CORRESPONDING tt_markup( it_original_data ).

        markup_update_comment(
          CHANGING
            ct_markup = lt_markup
        ).

        ct_calculated_data = CORRESPONDING #( lt_markup ).

      WHEN '/ESRCC/C_STEWRDSHP'.
        DATA(lt_stewardship) = CORRESPONDING tt_stewardship( it_original_data ).

        stewardship_update_comment(
          CHANGING
            ct_stewardship = lt_stewardship
        ).

        ct_calculated_data = CORRESPONDING #( lt_stewardship ).

      WHEN '/ESRCC/C_HIERDEF'.
        DATA(lt_hier_def) = CORRESPONDING tt_hier_def( it_original_data ).

        hier_def_update_comment(
          CHANGING
            ct_hier_def = lt_hier_def
        ).

        ct_calculated_data = CORRESPONDING #( lt_hier_def ).
    ENDCASE.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    gv_entity = iv_entity.
  ENDMETHOD.


  METHOD markup_update_comment.
    ASSIGN ct_markup[ 1 ] TO FIELD-SYMBOL(<fs_markup>).

    IF <fs_markup>-commentid IS INITIAL.
      " Comment ID is not getting passed, hence retrieve it from table
      SELECT SINGLE comment_id
        FROM /esrcc/srvmkp
        WHERE serviceproduct = @<fs_markup>-serviceproduct
          AND validfrom      = @<fs_markup>-validfrom
        INTO @<fs_markup>-commentid.
    ENDIF.

    <fs_markup>-comments = generate_comments( <fs_markup>-commentid ).
  ENDMETHOD.


  METHOD stewardship_update_comment.
    ASSIGN ct_stewardship[ 1 ] TO FIELD-SYMBOL(<fs_stewardship>).

    IF <fs_stewardship>-commentid IS INITIAL.
      " Comment ID is not getting passed, hence retrieve it from table
      SELECT SINGLE comment_id
        FROM /esrcc/stewrdshp
        WHERE stewardship_uuid = @<fs_stewardship>-stewardshipuuid
        INTO @<fs_stewardship>-commentid.
    ENDIF.

    <fs_stewardship>-comments = generate_comments( <fs_stewardship>-commentid ).
  ENDMETHOD.

  METHOD hier_def_update_comment.
    ASSIGN ct_hier_def[ 1 ] TO FIELD-SYMBOL(<fs_hier_def>).

    IF <fs_hier_def>-commentid IS INITIAL.
      " Comment ID is not getting passed, hence retrieve it from table
      SELECT SINGLE comment_id
        FROM /esrcc/hier_def
        WHERE hierarchy1 = @<fs_hier_def>-hierarchy1
          AND hierarchy2 = @<fs_hier_def>-hierarchy2
          AND hierarchy3 = @<fs_hier_def>-hierarchy3
          AND hierarchy4 = @<fs_hier_def>-hierarchy4
          AND valid_from = @<fs_hier_def>-validfrom
        INTO @<fs_hier_def>-commentid.
    ENDIF.

    <fs_hier_def>-comments = generate_comments( <fs_hier_def>-commentid ).
  ENDMETHOD.

ENDCLASS.
