class /ESRCC/CL_BADI_WF_CBL definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /ESRCC/IF_WORKFLOW_ENH .
protected section.
private section.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CBL IMPLEMENTATION.


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
    DATA : lv_price     TYPE c length 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    READ TABLE it_leading_object INTO DATA(ls_leading_object_cb) INDEX 1.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

    SELECT ryear,poper,fplv,sysid,legalentity,ccode,belnr,buzei,costobject,costcenter,costelement,
      hsl,
      localcurr,
      ksl,
      groupcurr,
      costind,
      usagecal,
      ccodedescription,
      legalentitydescription,
      costobjectdescription,
      costcenterdescription,
      costelementdescription,
      costtypedescription,
      costinddescription,
      costdatasetdescription,
      usagecaldescription
      FROM /esrcc/c_managecostbase
      FOR ALL ENTRIES IN @it_leading_object WHERE
                                                   ryear = @it_leading_object-ryear
                                              AND  poper = @it_leading_object-poper
                                              AND  fplv = @it_leading_object-fplv
                                              AND  sysid = @it_leading_object-sysid
                                              AND  legalentity = @it_leading_object-legalentity
                                              AND  ccode = @it_leading_object-ccode
                                              AND  belnr = @it_leading_object-belnr
                                              AND  buzei =  @it_leading_object-buzei
                                              AND  costobject = @it_leading_object-costobject
                                              AND  costcenter = @it_leading_object-costcenter
                                              AND  costelement = @it_leading_object-costelement
      INTO  TABLE @DATA(lt_managecostbase_row) .

** Do sum
    SELECT ryear,poper,fplv,sysid,legalentity,ccode,costobject,costcenter,
      SUM( hsl ) AS hsl,
      localcurr,
      SUM( ksl ) AS ksl,
      groupcurr,
      costind,
      usagecal,
      ccodedescription,
      legalentitydescription,
      costobjectdescription,
      costcenterdescription,
      costtypedescription,
      costinddescription,
      costdatasetdescription,
      usagecaldescription
      FROM @lt_managecostbase_row AS cb_li_1
      GROUP BY
      ryear,poper,fplv,sysid,legalentity,ccode,costobject,costcenter,
       localcurr,
      groupcurr,
      costind,
      usagecal,
      ccodedescription,
      legalentitydescription,
      costobjectdescription,
      costcenterdescription,
      costtypedescription,
      costinddescription,
      costdatasetdescription,
      usagecaldescription
    INTO TABLE @DATA(lt_cb_li_sum).


    LOOP AT lt_cb_li_sum INTO DATA(ls_cb_li_sum).
** General Information
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_cb_li_sum-legalentity } ({ ls_cb_li_sum-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_cb_li_sum-ccode } ({ ls_cb_li_sum-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ ls_cb_li_sum-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Posting Period</td> <td>  { ls_cb_li_sum-poper }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_cb_li_sum-costdatasetdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source)  </td> <td>  { ls_cb_li_sum-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_cb_li_sum-costcenter } ({ ls_cb_li_sum-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.




      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.


*Details of amount
      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Cost Base Amount Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cb_li_sum-hsl CURRENCY = ls_cb_li_sum-localcurr }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Amount (LC)</td> <td> { lv_price_str  } | & | { ls_cb_li_sum-localcurr } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_price = |{ ls_cb_li_sum-ksl CURRENCY = ls_cb_li_sum-groupcurr }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Amount (GC)</td> <td> { lv_price_str  } | & | { ls_cb_li_sum-groupcurr } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

    ENDLOOP.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.
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

      DATA(lv_legal_s) =   |{ ls_leading_object-legalentity }| & | ({ ls_le-description })|.
      DATA(lv_costobject_s) =   |{ ls_costobject-text }|.
      DATA(lv_costcenter_s) =   |{ ls_leading_object-costcenter }| & | ({ ls_cost_center-description })|.
      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_leading_object-poper }| .
* Description should be like
*Cost Center || 2021/003 || SERV || 007735
      CONCATENATE 'Cost Base Line Request ||' lv_costobject_s  '||'  lv_billing_period '||'  lv_legal_s '||'  lv_costcenter_s
                         INTO  ev_header SEPARATED BY space .


    ENDIF.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.

    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data      TYPE  /esrcc/s_split_workflow.

    lt_leading_object_inp = it_leading_object.

    SORT lt_leading_object_inp BY ryear poper fplv ccode sysid legalentity costobject costcenter .

    DELETE ADJACENT DUPLICATES FROM lt_leading_object_inp COMPARING ryear poper fplv ccode legalentity costobject costcenter.

    LOOP AT lt_leading_object_inp INTO DATA(ls_leading_object_cb_inp).
      CLEAR lt_leading_object_out.
      CLEAR ls_out_split_data.

      LOOP AT it_leading_object INTO DATA(ls_leading_object_cb)
        WHERE ryear  = ls_leading_object_cb_inp-ryear
        AND poper = ls_leading_object_cb_inp-poper
        AND fplv = ls_leading_object_cb_inp-fplv
        AND ccode = ls_leading_object_cb_inp-ccode
        AND sysid = ls_leading_object_cb_inp-sysid
        AND legalentity = ls_leading_object_cb_inp-legalentity
        AND costobject = ls_leading_object_cb_inp-costobject
        AND costcenter = ls_leading_object_cb_inp-costcenter.
        APPEND ls_leading_object_cb TO lt_leading_object_out.
      ENDLOOP.

      IF lt_leading_object_out IS NOT INITIAL.
        APPEND LINES OF lt_leading_object_out TO ls_out_split_data-segment.
        APPEND ls_out_split_data TO et_wf_split_data.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
