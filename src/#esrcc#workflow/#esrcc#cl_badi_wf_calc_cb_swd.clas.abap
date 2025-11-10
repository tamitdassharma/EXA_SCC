CLASS /esrcc/cl_badi_wf_calc_cb_swd DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_wf_calc_cb_swd IMPLEMENTATION.


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
    CLEAR: et_task_desc.
    DATA lv_price                 TYPE c LENGTH 50.
    DATA lv_price_str             TYPE string.
    DATA lv_text_concat           TYPE string.
    DATA ls_task_desc             TYPE /esrcc/s_wf_st_len.

    APPEND '<h3> General Information </h3>' TO et_task_desc.

** Keys for CDS
**  Fplv,Ryear, Poper,Sysid, Legalentity, Ccode,Costobject,Costcenter
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,currencytype,
*      billingfrequqncy,billingperiod,
      currency,
      totalcost,
      excludedtotalcost,
      includetotalcost,
      origtotalcost,
      passtotalcost,
      stewardship,
      remainingcostbase,
      legalentitydescription,
      ccodedescription,
      costobjectdescription,
      costcenterdescription,
      costdatasetdescription
*      billingfrequencydescription,
*      billingperioddescription
      FROM /esrcc/i_costbasestewardship
       FOR ALL ENTRIES IN @it_leading_object WHERE
*                                                  fplv = @it_leading_object-fplv
*                                              AND ryear = @it_leading_object-ryear
*                                              AND sysid = @it_leading_object-sysid
*                                              AND  legalentity = @it_leading_object-legalentity
*                                              AND  ccode = @it_leading_object-ccode
*                                              AND  costobject = @it_leading_object-costobject
*                                              AND  costcenter = @it_leading_object-costcenter
*                                              AND  billingfrequqncy = @it_leading_object-billfrequency
*                                              AND  billingperiod = @it_leading_object-billingperiod
                                                   uuid = @it_leading_object-cc_uuid
                                              AND  currencytype = 'L'
      INTO  TABLE @DATA(lt_cc_cost_line)  .

** Do sum
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,currencytype,
*          billingfrequqncy,billingperiod,
          currency,
         SUM( totalcost ) AS totalcost,
         SUM( excludedtotalcost ) AS excludedtotalcost,
         SUM( includetotalcost ) AS includetotalcost,
         SUM(  origtotalcost ) AS  origtotalcost,
         SUM( passtotalcost ) AS passtotalcost,
         SUM( remainingcostbase ) AS remainingcostbase,
          stewardship,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription
*          billingfrequencydescription,
*          billingperioddescription
      FROM @lt_cc_cost_line AS cc_cost  GROUP BY
      fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,currencytype,
*      billingfrequqncy,billingperiod,
      currency,
      stewardship,
      legalentitydescription,
      ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription
*          billingfrequencydescription,
*          billingperioddescription
      INTO TABLE @DATA(lt_cc_cost).


    LOOP AT lt_cc_cost INTO DATA(ls_cc_cost).

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      "      lv_text_concat =   |<tr> <td> Cost Planning (Dataset) </td>| & | : | & | <td> { ls_cc_cost-fplv }({ ls_cc_cost-costdatasetdescription })</td></tr>| .
      lv_text_concat =   |<tr> <td> Cost Dataset</td> <td> { ls_cc_cost-costdatasetdescription }</td></tr>| .

      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      "      lv_text_concat =   |Year| & | : | & | { ls_cc_cost-ryear } | .
      lv_text_concat =   |<tr> <td> Year </td> <td> { ls_cc_cost-ryear } </td></tr>| .

      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Period </td> <td> { ls_cc_cost-poper }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Billing Frequency </td> <td> { ls_cc_cost-billingfrequencydescription }</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.
*      APPEND ''  TO et_task_desc.
*
*      CLEAR lv_text_concat.
*      "      lv_text_concat =   |Billing Period| & | : | & | { ls_cc_cost-billingperiod }({ ls_cc_cost-billingperioddescription }) | .
*      lv_text_concat =   |<tr><td>Billing Period</td> <td> { ls_cc_cost-billingperioddescription }</td></tr> | .
*
*      APPEND lv_text_concat TO et_task_desc.
*      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { ls_cc_cost-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_cc_cost-legalentity } ({ ls_cc_cost-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_cc_cost-ccode } ({ ls_cc_cost-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { ls_cc_cost-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_cc_cost-costcenter } ({ ls_cc_cost-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


*      CLEAR lv_text_concat.
*      lv_text_concat =   |Company Code| & | : | & | { ls_cc_cost-ccode } | .
*      APPEND lv_text_concat TO et_task_desc.
*      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Cost Base and Stewardship Details</h3>| .
      APPEND lv_text_concat TO et_task_desc.



      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.



      CLEAR lv_text_concat.
      lv_price = |{ ls_cc_cost-totalcost CURRENCY = ls_cc_cost-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr><td>Total Cost (Initial) </td> <td> { lv_price_str } | & | { ls_cc_cost-currency }  </td></tr>| .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cc_cost-excludedtotalcost CURRENCY = ls_cc_cost-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Excluded Cost</td> <td> { lv_price_str }  | & | { ls_cc_cost-currency }</td> </tr> | .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cc_cost-includetotalcost CURRENCY = ls_cc_cost-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost Included </td> <td>  { lv_price_str }  | & | { ls_cc_cost-currency }</td> </tr> | . .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cc_cost-origtotalcost CURRENCY = ls_cc_cost-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Value-Add</td> <td> { lv_price_str }  | & | { ls_cc_cost-currency } </td> </tr> | .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cc_cost-passtotalcost CURRENCY = ls_cc_cost-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Pass-Through</td> <td> { lv_price_str }  | & | { ls_cc_cost-currency }</td> </tr> | .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.

      lv_text_concat =   |<tr> <td>Stewardship (%)</td> <td> { ls_cc_cost-stewardship }  </td> </tr> | .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cc_cost-remainingcostbase CURRENCY = ls_cc_cost-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost Base Remaining</td> <td> { lv_price_str }  | & | { ls_cc_cost-currency }</td> </tr>  | .
      APPEND lv_text_concat TO et_task_desc.
      APPEND ''  TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

    ENDLOOP.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.
*CDS Name   /ESRCC/I_CC_COST
    CLEAR: ev_header.
    DATA lv_price                 TYPE c LENGTH 50.
    DATA lv_price_str             TYPE string.
    DATA lv_text_concat           TYPE string.


    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc EQ 0.

*Get Legal Entity Description
      SELECT SINGLE legalentity, description FROM /esrcc/i_legalentityall_f4
         WHERE legalentity = @ls_leading_object-legalentity INTO @DATA(ls_le).

*Get Cost objects
      SELECT SINGLE costobject,text FROM /esrcc/i_costobjects
        WHERE costobject =  @ls_leading_object-costobject INTO @DATA(ls_costobject).

*Get Cost Center Description
      SELECT SINGLE sysid,costcenter,costobject,description FROM /esrcc/i_coscen_f4
          WHERE costcenter =  @ls_leading_object-costcenter
        AND sysid =  @ls_leading_object-sysid
        AND costobject = @ls_leading_object-costobject
        INTO @DATA(ls_cost_center).

**Get Description Billing period
*      SELECT SINGLE billingperiod, text FROM /esrcc/i_billingperiod WHERE billingperiod = @ls_leading_object-billingperiod INTO @DATA(ls_billing_period).
*
**Get Description Billing  frequency
*      SELECT SINGLE billingfreq, text FROM /esrcc/i_billingfreq WHERE billingfreq =  @ls_leading_object-billfrequency INTO @DATA(ls_billing_frequency).

*      CONCATENATE ls_leading_object-legalentity '||'  ls_leading_object-costcenter
*                          INTO  ev_header SEPARATED BY space .

      DATA(lv_legal_s) =   |{ ls_leading_object-legalentity }| & | ({ ls_le-description })|.
      DATA(lv_costobject_s) =   |{ ls_costobject-text }|.
      DATA(lv_costcenter_s) =   |{ ls_leading_object-costcenter }| & | ({ ls_cost_center-description })|.
*      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_billing_frequency-text }/| & |{ ls_billing_period-text }| .
      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_leading_object-poper }| .

* Description should be like
**Cost Center || 2021/M/March || SERV || 007735
*      CONCATENATE lv_costobject_s  '||'  lv_billing_period '||'  lv_legal_s '||'  lv_costcenter_s
*                         INTO  ev_header SEPARATED BY space .
*SERV || 2021/March || 007735
      CONCATENATE lv_legal_s '||'  lv_billing_period '||'  lv_costcenter_s
                         INTO  ev_header SEPARATED BY space .

    ENDIF.


  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
* Group based on Legal Entity cost object and Cost Center
    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data         TYPE  /esrcc/s_split_workflow.

    lt_leading_object_inp = it_leading_object.

    SORT lt_leading_object_inp BY fplv ryear legalentity ccode costobject costcenter.

    DELETE ADJACENT DUPLICATES FROM lt_leading_object_inp COMPARING fplv ryear legalentity ccode costobject costcenter.

    LOOP AT lt_leading_object_inp INTO DATA(ls_leading_object_cb_inp).
      CLEAR lt_leading_object_out.
      CLEAR ls_out_split_data.

      LOOP AT it_leading_object INTO DATA(ls_leading_object)
        WHERE
        fplv = ls_leading_object_cb_inp-fplv
        AND ryear = ls_leading_object_cb_inp-ryear
        AND legalentity = ls_leading_object_cb_inp-legalentity
        AND ccode = ls_leading_object_cb_inp-ccode
        AND costobject = ls_leading_object_cb_inp-costobject
        AND costcenter = ls_leading_object_cb_inp-costcenter.
        APPEND ls_leading_object TO lt_leading_object_out.
      ENDLOOP.

      IF lt_leading_object_out IS NOT INITIAL.
        APPEND LINES OF lt_leading_object_out TO ls_out_split_data-segment.
        APPEND ls_out_split_data TO et_wf_split_data.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
