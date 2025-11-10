class /ESRCC/CL_WF_HTML definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ts_field,
        field_name   TYPE sxco_cds_field_name,
        data_element TYPE sxco_ad_object_name,
      END OF ts_field .
  types:
    tt_field TYPE STANDARD TABLE OF ts_field WITH EMPTY KEY .

  methods CONSTRUCTOR
    importing
      !CDS_ENTITY_NAME type SXCO_CDS_OBJECT_NAME optional
      !FIELDS type TT_FIELD optional .
  methods HTML_TAG_NEW_ROW
    returning
      value(RV_TAG) type /ESRCC/WF_STD_TXT_LENGTH .
  methods HTML_TAG_NEW_COLUMN
    importing
      !IS_HEADER type ABAP_BOOLEAN optional
      !IV_ADDN_PROP type /ESRCC/WF_STD_TXT_LENGTH optional
    returning
      value(RV_TAG) type /ESRCC/WF_STD_TXT_LENGTH .
  methods HTML_TAG_NEW_TABLE
    returning
      value(RV_TAG) type /ESRCC/WF_STD_TXT_LENGTH .
  methods HTML_TAG_END_TABLE
    returning
      value(RV_TAG) type /ESRCC/WF_STD_TXT_LENGTH .
  methods GENERATE_TABLE_LINE
    importing
      !IV_FIELDNAME type SXCO_CDS_FIELD_NAME
      !IV_ID type /ESRCC/WF_STD_TXT_LENGTH
      !IV_ID_DESC type /ESRCC/WF_STD_TXT_LENGTH optional
    returning
      value(RT_TASK_DESC) type /ESRCC/TT_WF_ST_LEN .
  methods GENERATE_TABLE_COLUMN
    importing
      !IS_HEADER type ABAP_BOOLEAN optional
      !IV_CONTENT type /ESRCC/WF_STD_TXT_LENGTH optional
      !IV_FIELDNAME type SXCO_CDS_FIELD_NAME optional
      !IV_ADDN_PROP type /ESRCC/WF_STD_TXT_LENGTH optional
    returning
      value(RT_TASK_DESC) type /ESRCC/TT_WF_ST_LEN .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ts_field_info,
        name TYPE abp_field_name,
        text TYPE string,
      END OF ts_field_info .

    DATA:
      gt_field_info TYPE SORTED TABLE OF ts_field_info WITH NON-UNIQUE KEY name .
ENDCLASS.



CLASS /ESRCC/CL_WF_HTML IMPLEMENTATION.


  METHOD constructor.
    IF cds_entity_name IS INITIAL OR fields IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_abap_dictionary) = NEW /esrcc/cl_abap_dictionary( iv_entity_name = cds_entity_name ).
    LOOP AT fields INTO DATA(field).
      INSERT VALUE #( name = field-field_name
                      text = lo_abap_dictionary->derive_field_label( EXPORTING iv_data_element = field-data_element
                                                                               iv_field_name   = field-field_name ) )
        INTO TABLE gt_field_info.
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_table_column.
    APPEND html_tag_new_column( is_header = is_header iv_addn_prop = iv_addn_prop ) TO rt_task_desc.
    APPEND COND #( WHEN iv_content IS SUPPLIED THEN iv_content ELSE VALUE #( gt_field_info[ name = iv_fieldname ]-text OPTIONAL ) ) TO rt_task_desc.
    APPEND  COND #( WHEN is_header = abap_true THEN '</th>' ELSE '</td>' ) TO rt_task_desc.
  ENDMETHOD.


  METHOD generate_table_line.
    APPEND html_tag_new_row( ) TO rt_task_desc.
    DATA(field_text) = VALUE #( gt_field_info[ name = iv_fieldname ]-text OPTIONAL ).
    APPEND LINES OF generate_table_column( iv_content =  COND #( WHEN field_text IS INITIAL THEN iv_fieldname ELSE field_text ) ) TO rt_task_desc.
    APPEND LINES OF generate_table_column( iv_content = COND #( WHEN iv_id_desc IS INITIAL THEN iv_id ELSE |{ iv_id } ({ iv_id_desc })| ) ) TO rt_task_desc.
    APPEND '</tr>' TO rt_task_desc.
  ENDMETHOD.


  METHOD html_tag_new_column.
    IF is_header = abap_true.
      DATA(tag) = '<th'.
    ELSE.
      tag = '<td'.
      DATA(style) = 'style="text-align:left"'.
    ENDIF.

    rv_tag = |{ tag } role="gridcell" class="sapMPluginsColumnResizerResizable sapMListTblCell" { iv_addn_prop } { style }>|.
  ENDMETHOD.


  METHOD html_tag_new_row.
    rv_tag = |<tr role="row" class="sapMLIB sapMLIBShowSeparator sapMListTblRow">|.
  ENDMETHOD.


  METHOD html_tag_new_table.
    rv_tag = |<table role="grid" class="sapMListModeNone sapMListTblSubCnt sapMListShowSeparatorsAll sapMListTbl sapMListUl">|.
  ENDMETHOD.


  METHOD html_tag_end_table.
    rv_tag = |</table>|.
  ENDMETHOD.
ENDCLASS.
