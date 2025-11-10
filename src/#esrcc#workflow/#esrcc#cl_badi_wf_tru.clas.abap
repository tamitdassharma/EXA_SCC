CLASS /esrcc/cl_badi_wf_tru DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_TRU IMPLEMENTATION.


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
    DATA trueupamount       TYPE /esrcc/amount.
    DATA finaltrueupamount  TYPE /esrcc/amount.
    DATA standardamount     TYPE /esrcc/amount.
    DATA recalculatedamount TYPE /esrcc/amount.
    DATA lt_trueup        TYPE TABLE OF /esrcc/trueup.
    DATA ls_trueup        TYPE /esrcc/trueup.
*    DATA lt_rec_cost_row TYPE TABLE OF /esrcc/i_rec_cost.



    APPEND '<h3>General Information</h3>' TO et_task_desc.

    IF it_leading_object is NOT INITIAL.
    DATA(refpoper) = it_leading_object[ 1 ]-refpoper.
    ENDIF.

*   Get the recalculated chargeouts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           trueup~RefPoper,
           trueup~currency,
           ccodedescription,
           legalentitydescription,
           costobjectdescription,
           costcenterdescription,
           sum( TotalChargeoutAmount ) as TotalChargeoutAmount
       FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
        WHERE  trueup~RefPoper     = @refpoper
        AND  ProcessType           = @/esrcc/if_calculate_chargeout=>recalprocesstype
        AND  Currencytype          = 'L'   "sender local currency
        GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid,
          trueup~RefPoper,
          trueup~currency,
          ccodedescription,
          legalentitydescription,
          costobjectdescription,
          costcenterdescription
        INTO TABLE @DATA(lt_recalculated).

*   Get the standard chargeouts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           sum( TotalChargeoutAmount ) as TotalChargeoutAmount
       FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE trueup~poper          <= @refpoper
        AND  ProcessType           = @/esrcc/if_calculate_chargeout=>standardprocesstype
        AND  Currencytype          = 'L'   "sender local currency
        GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid
        INTO TABLE @DATA(lt_standard).

*   Get the true up amounts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           sum( amount_l ) as TotalTrueupAmount
       FROM /esrcc/trueup AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE recalrefpoper         < @refpoper
       GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid
        INTO TABLE @DATA(lt_trueups).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_recalculated ASSIGNING FIELD-SYMBOL(<recalculated>).
      READ TABLE lt_standard ASSIGNING FIELD-SYMBOL(<standard>)
                               WITH KEY ryear          = <recalculated>-ryear
*                                        poper          = <recalculated>-poper
                                        sysid          = <recalculated>-sysid
                                        Legalentity    = <recalculated>-Legalentity
                                        ccode          = <recalculated>-ccode
                                        costobject     = <recalculated>-costobject
                                        costcenter     = <recalculated>-Costcenter.

      IF sy-subrc = 0.
        CLEAR trueupamount.
        LOOP AT lt_trueups INTO DATA(trueup)
                             WHERE ryear               = <recalculated>-ryear
                               AND sysid               = <recalculated>-sysid
                               AND Legalentity         = <recalculated>-Legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-Costcenter.

          trueupamount = trueup-totaltrueupamount + trueupamount.
        ENDLOOP.

        recalculatedamount = <recalculated>-TotalChargeoutAmount  + recalculatedamount.
        standardamount     = ( <standard>-TotalChargeoutAmount + trueupamount ) + standardamount.
        finaltrueupamount  = finaltrueupamount + ( <recalculated>-TotalChargeoutAmount - ( <standard>-TotalChargeoutAmount + trueupamount ) ).

      ENDIF.




*    LOOP AT lt_recalculated INTO DATA(ls_rec_cost_sum).
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_rec_cost_sum-costdatasetdescription }</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ <recalculated>-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> True-up Ref Period </td> <td>{ | 001 - | && |{ <recalculated>-RefPoper }| }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { <recalculated>-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { <recalculated>-legalentity } ({ <recalculated>-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { <recalculated>-ccode } ({ <recalculated>-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { <recalculated>-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { <recalculated>-costcenter } ({ <recalculated>-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Service Product </td> <td>  { ls_rec_cost_sum-serviceproduct } ({ ls_rec_cost_sum-serviceproductdescription })</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.
*
*      CLEAR lv_text_concat.
*      lv_text_concat =   |<tr><td>Receiving Entity </td> <td>  { ls_rec_cost_sum-receivingentity } ({ ls_rec_cost_sum-receivingentitydescription })</td></tr> | .
*      APPEND lv_text_concat TO et_task_desc.

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
      lv_text_concat =   |<h3>True-up Calculation Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-chargeoutforservice TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = recalculatedamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Re-calculated Charge-out Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.
*
      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totaludmarkupabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = standardamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Standard Charge-out Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.
*
      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totalcostbaseabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = finaltrueupamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total True-up Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.



    ENDLOOP.
*    ENDLOOP.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.
*CDS Name   /ESRCC/I_REC_COST
    CLEAR: ev_header.
    DATA : lv_price              TYPE c LENGTH 50.
    DATA : lv_price_str          TYPE string.
    DATA : lv_text_concat        TYPE string.

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc EQ 0.

*Get Legal Entity Description
      SELECT SINGLE legalentity, description FROM /esrcc/i_legalentityall_f4
         WHERE legalentity = @ls_leading_object-legalentity INTO @DATA(ls_le).

**Get Reciving  Entity Description
*      SELECT SINGLE legalentity, description FROM /esrcc/i_legalentityall_f4
*         WHERE legalentity = @ls_leading_object-receivingentity INTO @DATA(ls_le_rec).

*Get Cost objects
      SELECT SINGLE costobject,text FROM /esrcc/i_costobjects
        WHERE costobject =  @ls_leading_object-costobject INTO @DATA(ls_costobject).

*Get Cost Center Description
      SELECT SINGLE sysid,costcenter,costobject,description FROM /esrcc/i_coscen_f4
          WHERE costcenter =  @ls_leading_object-costcenter
        AND sysid =  @ls_leading_object-sysid
        AND costobject = @ls_leading_object-costobject
        INTO @DATA(ls_cost_center).

*Get Service Product Description
      SELECT SINGLE serviceproduct,description FROM /esrcc/i_serviceproduct_f4
     WHERE serviceproduct =  @ls_leading_object-serviceproduct
     INTO @DATA(ls_srv_product).



      DATA(lv_legal_s) =   |{ ls_leading_object-legalentity }| & | ({ ls_le-description })|.
*      DATA(lv_legal_rec) = |{ ls_leading_object-receivingentity }| & | ({ ls_le_rec-description })|.
      DATA(lv_costobject_s) =   |{ ls_costobject-text }|.
      DATA(lv_costcenter_s) =   |{ ls_leading_object-costcenter }| & | ({ ls_cost_center-description })|.
*      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_billing_frequency-text }/| & |{ ls_billing_period-text }| .
      DATA(lv_billing_period) =   |{ ls_leading_object-ryear }/| & |{ ls_leading_object-refpoper }| .
*      DATA(lv_srv_prod_s) =   |{ ls_leading_object-serviceproduct }| & | ({ ls_srv_product-description })|.
* Description should be like
**Cost Center || 2021/M/March || SERV || 007735
*      CONCATENATE lv_costobject_s  '||'  lv_billing_period '||'  lv_legal_rec '||'  lv_srv_prod_s
*                       '||'  lv_legal_s  INTO  ev_header SEPARATED BY space .
*Cost Center || 2021/M/March || SERV || 007735
      CONCATENATE 'True-up Recalcualtion Request ||' lv_legal_s '||'  lv_billing_period '||'  lv_costcenter_s
                         INTO  ev_header SEPARATED BY space .

    ENDIF.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
* Group based on Legal Entity and Cost Center Service Product and Receiving Entity
    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data      TYPE /esrcc/s_split_workflow.

** Keys for CDS
*    SELECT
*          costbase~uuid as cc_uuid,
*          fplv,
*          ryear,
*          poper,
*          sysid,
*          legalentity,
*          ccode,
*          costobject,
*          costcenter
**          serviceproduct,
**          receivingentity,
**          ReceiverSysId as recsysid,
**          ReceiverCompanyCode as recccode,
**          ReceiverCostObject as reccostobject,
**          ReceiverCostCenter as reccostcenter
*      FROM /ESRCC/I_CostBaseStewardship AS costbase
*           INNER JOIN /ESRCC/I_ServiceProductShare AS serviceproductshare
*            ON costbase~uuid = serviceproductshare~ParentUUID
*            AND costbase~Currencytype = serviceproductshare~Currencytype
*           INNER JOIN /ESRCC/I_ReceiverChargeout AS receiverchargeout
*            ON costbase~uuid = receiverchargeout~RootUUID
*           AND serviceproductshare~uuid = receiverchargeout~ParentUUID
*           AND costbase~Currencytype = receiverchargeout~Currencytype
*      FOR ALL ENTRIES IN @it_leading_object WHERE  costbase~uuid = @it_leading_object-cc_uuid
*                                              AND  costbase~currencytype = 'L'
*      INTO  CORRESPONDING FIELDS OF TABLE @lt_leading_object_inp.

    lt_leading_object_inp = it_leading_object.

    SORT lt_leading_object_inp BY fplv ryear sysid ccode costobject legalentity costobject costcenter. " serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    DELETE ADJACENT DUPLICATES FROM lt_leading_object_inp COMPARING fplv ryear sysid ccode costobject legalentity costobject costcenter. " serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    LOOP AT lt_leading_object_inp INTO DATA(ls_leading_object_cb_inp).
      CLEAR lt_leading_object_out.
      CLEAR ls_out_split_data.

      LOOP AT it_leading_object INTO DATA(ls_leading_object)
        WHERE
         cc_uuid = ls_leading_object_cb_inp-cc_uuid.
*        fplv = ls_leading_object_cb_inp-fplv
*        AND  ryear = ls_leading_object_cb_inp-ryear
*        AND ccode = ls_leading_object_cb_inp-ccode
*        AND  costobject = ls_leading_object_cb_inp-costobject
*        AND legalentity = ls_leading_object_cb_inp-legalentity
*        AND  serviceproduct = ls_leading_object_cb_inp-serviceproduct
*        AND  receivingentity = ls_leading_object_cb_inp-receivingentity
*        AND  recsysid = ls_leading_object_cb_inp-recsysid
*        AND  recccode = ls_leading_object_cb_inp-recccode
*        AND  reccostobject = ls_leading_object_cb_inp-reccostobject
*        AND  reccostcenter = ls_leading_object_cb_inp-reccostcenter.
        APPEND ls_leading_object_cb_inp TO lt_leading_object_out.
      ENDLOOP.

      IF lt_leading_object_out IS NOT INITIAL.
        APPEND LINES OF lt_leading_object_out TO ls_out_split_data-segment.
        APPEND ls_out_split_data TO et_wf_split_data.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
