CLASS /esrcc/cl_badi_wf_chr DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CHR IMPLEMENTATION.


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
*CDS Name   /ESRCC/I_REC_COST
    CLEAR: et_task_desc.
    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.
*    DATA lt_rec_cost_row TYPE TABLE OF /esrcc/i_rec_cost.



    APPEND '<h3>General Information</h3>' TO et_task_desc.


** Keys for CDS
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
      receivingentity,
      ReceiverSysId,
      ReceiverCompanyCode,
      ReceiverCostObject,
      ReceiverCostCenter,
      costbase~currency,
      TotalChargeout,
      TotalRecMarkup,
      RecCostShare,
      RecValueadded,
      RecPassthrough,
      costbase~legalentitydescription,
      costbase~ccodedescription,
      costbase~costobjectdescription,
      costbase~costcenterdescription,
      costbase~costdatasetdescription,
*      billingfrequencydescription,
*      billingperioddescription,
      receivingentitydescription,
      serviceproductdescription,
      receiverchargeout~ccodedescription AS recccodedescription,
      receiverchargeout~costobjectdescription AS reccostobejctdescription,
      receiverchargeout~costcenterdescription AS reccostcenterdescription
      FROM /ESRCC/I_CostBaseStewardship AS costbase
           INNER JOIN /ESRCC/I_ServiceProductShare AS serviceproductshare
            ON costbase~uuid = serviceproductshare~ParentUUID
            AND costbase~Currencytype = serviceproductshare~Currencytype
           INNER JOIN /ESRCC/I_ReceiverChargeout AS receiverchargeout
            ON costbase~uuid = receiverchargeout~RootUUID
           AND serviceproductshare~uuid = receiverchargeout~ParentUUID
           AND costbase~Currencytype = receiverchargeout~Currencytype
      FOR ALL ENTRIES IN @it_leading_object WHERE
*                                                  fplv = @it_leading_object-fplv
*                                              AND ryear = @it_leading_object-ryear
*                                              AND  legalentity = @it_leading_object-legalentity
*                                              AND  ccode = @it_leading_object-ccode
*                                              AND  costobject = @it_leading_object-costobject
*                                              AND  costcenter = @it_leading_object-costcenter
*                                              AND  billingfrequqncy = @it_leading_object-billfrequency
*                                              AND  billingperiod = @it_leading_object-billingperiod
                                                   costbase~uuid = @it_leading_object-cc_uuid
                                              AND  serviceproduct = @it_leading_object-serviceproduct
                                              AND  receivingentity = @it_leading_object-receivingentity
                                              AND  costbase~currencytype = 'L'
      INTO  TABLE @DATA(lt_rec_cost_row).

** Do sum
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
*          ReceiverSysId,
*          ReceiverCompanyCode,
*          ReceiverCostObject,
*          ReceiverCostCenter,
          currency,
          SUM( TotalChargeout ) AS chargeoutforservice  ,
          SUM( TotalRecMarkup  ) AS totaludmarkupabs,
          SUM( RecCostShare ) AS totalcostbaseabs ,
          SUM( RecValueadded ) AS valuaddabs,
          SUM( RecPassthrough ) AS passthruabs  ,

          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
*          billingfrequencydescription,
*          billingperioddescription,
          receivingentitydescription,
          serviceproductdescription
*          recccodedescription,
*          reccostobejctdescription,
*          reccostcenterdescription
        FROM @lt_rec_cost_row AS rec_cost
        GROUP BY fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,
          serviceproduct,
          receivingentity,
*          ReceiverSysId,
*          ReceiverCompanyCode,
*          ReceiverCostObject,
*          ReceiverCostCenter,
          currency,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
*          billingfrequencydescription,
*          billingperioddescription,
          receivingentitydescription,
          serviceproductdescription
*          recccodedescription,
*          reccostobejctdescription,
*          reccostcenterdescription
        INTO TABLE @DATA(lt_rec_cost_sum).


    LOOP AT lt_rec_cost_sum INTO DATA(ls_rec_cost_sum).
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_rec_cost_sum-costdatasetdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ ls_rec_cost_sum-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Period </td> <td>{ ls_rec_cost_sum-poper }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Billing Frequency </td> <td> { ls_rec_cost_sum-billingfrequencydescription }</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.
*
*
*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Billing Period</td> <td> { ls_rec_cost_sum-billingperioddescription }</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { ls_rec_cost_sum-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_rec_cost_sum-legalentity } ({ ls_rec_cost_sum-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_rec_cost_sum-ccode } ({ ls_rec_cost_sum-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { ls_rec_cost_sum-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_rec_cost_sum-costcenter } ({ ls_rec_cost_sum-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Service Product </td> <td>  { ls_rec_cost_sum-serviceproduct } ({ ls_rec_cost_sum-serviceproductdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiving Entity </td> <td>  { ls_rec_cost_sum-receivingentity } ({ ls_rec_cost_sum-receivingentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr> <td>Receiver Company Code</td> <td>  { ls_rec_cost_sum-ReceiverCompanyCode } ({ ls_rec_cost_sum-recccodedescription })</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.
*
*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Receiver Cost Object Type (Source) </td> <td>  { ls_rec_cost_sum-reccostobejctdescription }</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.
*
*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Receiver Cost Object Number (Source) </td> <td>  { ls_rec_cost_sum-costcenter } ({ ls_rec_cost_sum-reccostcenterdescription })</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.



      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Charge-Out to Receivers Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-chargeoutforservice TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-chargeoutforservice.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Charge-Out Received</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totaludmarkupabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-totaludmarkupabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Mark-up</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totalcostbaseabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-totalcostbaseabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost (Initial)</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-valuaddabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-valuaddabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Value-Add</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-passthruabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-passthruabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Pass-Through</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.



    ENDLOOP.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.
*CDS Name   /ESRCC/I_REC_COST
    CLEAR: ev_header.
    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc EQ 0.

*Get Legal Entity Description
      SELECT SINGLE legalentity, description FROM /esrcc/i_legalentityall_f4
         WHERE legalentity = @ls_leading_object-legalentity INTO @DATA(ls_le).

*Get Reciving  Entity Description
      SELECT SINGLE legalentity, description FROM /esrcc/i_legalentityall_f4
         WHERE legalentity = @ls_leading_object-receivingentity INTO @DATA(ls_le_rec).

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

*Get Service Product Description
      SELECT SINGLE serviceproduct,description FROM /esrcc/i_serviceproduct_f4
     WHERE serviceproduct =  @ls_leading_object-serviceproduct
     INTO @DATA(ls_srv_product).



      DATA(lv_legal_s) =   |{ ls_leading_object-legalentity }| & | ({ ls_le-description })|.
      DATA(lv_legal_rec) = |{ ls_leading_object-receivingentity }| & | ({ ls_le_rec-description })|.
      DATA(lv_costobject_s) =   |{ ls_costobject-text }|.
      DATA(lv_costcenter_s) =   |{ ls_leading_object-costcenter }| & | ({ ls_cost_center-description })|.
*      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_billing_frequency-text }/| & |{ ls_billing_period-text }| .
      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_leading_object-poper }| .
      DATA(lv_srv_prod_s) =   |{ ls_leading_object-serviceproduct }| & | ({ ls_srv_product-description })|.
* Description should be like
**Cost Center || 2021/M/March || SERV || 007735
*      CONCATENATE lv_costobject_s  '||'  lv_billing_period '||'  lv_legal_rec '||'  lv_srv_prod_s
*                       '||'  lv_legal_s  INTO  ev_header SEPARATED BY space .
*Cost Center || 2021/M/March || SERV || 007735
      CONCATENATE lv_legal_rec '||'  lv_billing_period '||'  lv_legal_s '||'  lv_srv_prod_s
                        INTO  ev_header SEPARATED BY space .

    ENDIF.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
* Group based on Legal Entity and Cost Center Service Product and Receiving Entity
    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data         TYPE  /esrcc/s_split_workflow.

    lt_leading_object_inp = it_leading_object.

    SORT lt_leading_object_inp BY fplv ryear ccode costobject legalentity serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    DELETE ADJACENT DUPLICATES FROM lt_leading_object_inp COMPARING fplv ryear ccode costobject legalentity serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    LOOP AT lt_leading_object_inp INTO DATA(ls_leading_object_cb_inp).
      CLEAR lt_leading_object_out.
      CLEAR ls_out_split_data.

      LOOP AT it_leading_object INTO DATA(ls_leading_object)
        WHERE
        fplv = ls_leading_object_cb_inp-fplv
        AND  ryear = ls_leading_object_cb_inp-ryear
        AND ccode = ls_leading_object_cb_inp-ccode
        AND  costobject = ls_leading_object_cb_inp-costobject
        AND legalentity = ls_leading_object_cb_inp-legalentity
        AND  serviceproduct = ls_leading_object_cb_inp-serviceproduct
        AND  receivingentity = ls_leading_object_cb_inp-receivingentity
        AND  recsysid = ls_leading_object_cb_inp-recsysid
        AND  recccode = ls_leading_object_cb_inp-recccode
        AND  reccostobject = ls_leading_object_cb_inp-reccostobject
        AND  reccostcenter = ls_leading_object_cb_inp-reccostcenter.
        APPEND ls_leading_object TO lt_leading_object_out.
      ENDLOOP.

      IF lt_leading_object_out IS NOT INITIAL.
        APPEND LINES OF lt_leading_object_out TO ls_out_split_data-segment.
        APPEND ls_out_split_data TO et_wf_split_data.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
