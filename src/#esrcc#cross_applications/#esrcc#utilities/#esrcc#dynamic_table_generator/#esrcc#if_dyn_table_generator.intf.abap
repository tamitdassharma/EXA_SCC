INTERFACE /esrcc/if_dyn_table_generator PUBLIC.
  TYPES:
    BEGIN OF ddic_field_info,
      tabname   TYPE tabname,
      fieldname TYPE /esrcc/field_name,
      langu     TYPE char2,
*  position      : tabfdpos;
*  offset        : doffset;
      domname   TYPE /esrcc/domain_name,
      rollname  TYPE /esrcc/domain_name,
*  checktable    : tabname;
*  leng          : ddleng;
*  intlen        : intlen;
*  outputlen     : outputlen;
*  decimals      : decimals;
*  datatype      : dynptype;
*  inttype       : inttype;
*  reftable      : reftable;
*  reffield      : reffield;
*  precfield     : precfield;
*  authorid      : authorid;
*  memoryid      : memoryid;
*  logflag       : logflag;
*  mask          : as4mask;
*  masklen       : masklen;
      convexit  TYPE /ESRCC/Conversion_exit,
*  headlen       : headlen;
*  scrlen1       : scrlen_s;
*  scrlen2       : scrlen_m;
*  scrlen3       : scrlen_l;
*  fieldtext     : as4text;
*  reptext       : reptext;
*  scrtext_s     : scrtext_s;
*  scrtext_m     : scrtext_m;
*  scrtext_l     : scrtext_l;
*  keyflag       : keyflag;
*  lowercase     : lowercase;
*  mac           : ddshattach;
*  genkey        : as4flag;
*  noforkey      : as4flag;
*  valexi        : valexi;
*  noauthch      : as4flag;
*  sign          : signflag;
*  dynpfld       : dynprofld;
*  f4availabl    : ddf4avail;
*  comptype      : comptype;
*  lfieldname    : fnam_____4;
*  ltrflddis     : ddltrflddi;
*  bidictrlc     : ddbidictrl;
*  outputstyle   : outputstyle;
*  nohistory     : ddnohistory;
*  ampmformat    : ddampmformat;
    END OF ddic_field_info,

    ddic_field_info_list TYPE SORTED TABLE OF ddic_field_info WITH UNIQUE KEY tabname fieldname langu.

  METHODS:
    get_table_components      RETURNING VALUE(components)         TYPE cl_abap_structdescr=>component_table,
    override_table_components IMPORTING !components               TYPE cl_abap_structdescr=>component_table,
    get_dynamic_table         RETURNING VALUE(dynamic_table)      TYPE REF TO data,
    get_dynamic_table_line    RETURNING VALUE(dynamic_table_line) TYPE REF TO data,

    get_field_list IMPORTING table_name        TYPE tabname
                             field_name        TYPE /esrcc/field_name
                   RETURNING VALUE(field_list) TYPE ddic_field_info,

    generate IMPORTING table_name                 TYPE tabname
             RETURNING VALUE(is_exception_raised) TYPE xsdboolean,

    destroy.

ENDINTERFACE.
