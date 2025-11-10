CLASS /esrcc/cl_badi_wf_roy DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_wf_roy IMPLEMENTATION.


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
    DATA : lv_price       TYPE c LENGTH 50.
    DATA : lv_price_str   TYPE string.
    DATA : lv_text_concat TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.


    APPEND '<h3>General Information</h3>' TO et_task_desc.


    SELECT * FROM /esrcc/i_read_royalty
    FOR ALL ENTRIES IN @it_leading_object
    WHERE uuid = @it_leading_object-cc_uuid
    INTO TABLE @DATA(royalties).

    LOOP AT royalties ASSIGNING FIELD-SYMBOL(<royalty>).

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Base Value Version for Royalty</td> <td>  { <royalty>-BaseVersionDescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ <royalty>-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Period </td> <td>{ <royalty>-poper }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Licensee) </td> <td> { <royalty>-Licenseesysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity (Licensee) </td> <td>  { <royalty>-Licenseelegalentity } ({ <royalty>-Licenseelegalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code (Licensee)</td> <td>  { <royalty>-Licenseeccode } ({ <royalty>-LicenseeCompanyCodeDescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Licensee) </td> <td>  { <royalty>-Licenseecostobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Licensee) </td> <td>  { <royalty>-Licenseecostcenter } ({ <royalty>-Licenseecostcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>License </td> <td>  { <royalty>-License } ({ <royalty>-licensedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Licensor) </td> <td> { <royalty>-Licensorsysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity (Licensor) </td> <td>  { <royalty>-Licensorlegalentity } ({ <royalty>-Licensorlegalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code (Licensor)</td> <td>  { <royalty>-Licensorccode } ({ <royalty>-LicensorCompanyCodeDescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Licensor) </td> <td>  { <royalty>-Licensorcostobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Licensor) </td> <td>  { <royalty>-Licensorcostcenter } ({ <royalty>-Licensorcostcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Royalty Computation Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Royalty Computation Method </td> <td>  { <royalty>-RoyaltyComputationMethodDesc } </td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      IF <royalty>-amountvalue <> 0.
        lv_cost_decimal_2 = <royalty>-amountvalue.
        lv_price = |{ lv_cost_decimal_2 CURRENCY = <royalty>-currency }|.
        lv_price_str  = lv_price.
        lv_text_concat =   |<tr> <td>Royalty Base Value</td> <td> { lv_price_str  } | & | { <royalty>-currency } </td> </tr>| .
        APPEND lv_text_concat TO et_task_desc.
      ELSE.
*        lv_cost_decimal_2 = <royalty>-unitvalue.
*        lv_price = |{ lv_cost_decimal_2 }|.
*        lv_price_str  = lv_price.
        lv_text_concat =   |<tr> <td>Royalty Base Value</td> <td> { <royalty>-unitvalue  } | & | { <royalty>-uom } </td> </tr>| .
        APPEND lv_text_concat TO et_task_desc.
      ENDIF.

      CLEAR lv_text_concat.
      IF <royalty>-paramamount <> 0.
        lv_cost_decimal_2 = <royalty>-paramamount.
        lv_price = |{ lv_cost_decimal_2 CURRENCY = <royalty>-paramcurrency }|.
        lv_price_str  = lv_price.
        lv_text_concat =   |<tr> <td>Base Key Value</td> <td> { lv_price_str  } | & | { <royalty>-paramcurrency } </td> </tr>| .
        APPEND lv_text_concat TO et_task_desc.
      ELSE.
*        lv_cost_decimal_2 = <royalty>-paramvalue.
*        lv_price = |{ lv_cost_decimal_2 }|.
*        lv_price_str  = lv_price.
        lv_text_concat =   |<tr> <td>Base Key Value</td> <td> { <royalty>-paramvalue  } | & | { '( % )' } </td> </tr>| .
        APPEND lv_text_concat TO et_task_desc.
      ENDIF.

      CLEAR lv_text_concat.
      lv_cost_decimal_2 = <royalty>-chargeoutamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <royalty>-invoicecurrency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Charge-out Amount</td> <td> { lv_price_str  } | & | { <royalty>-invoicecurrency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

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

    SELECT ryear,
           poper,
           licensorlegalentity,
           licenseelegalentity,
           license,
           LicenseDescription,
           LicenseeLegalEntityDescription,
           LicensorLegalEntityDescription
           FROM /esrcc/i_read_royalty
    FOR ALL ENTRIES IN @it_leading_object
    WHERE uuid = @it_leading_object-cc_uuid
    INTO TABLE @DATA(royalties).

    LOOP AT royalties ASSIGNING FIELD-SYMBOL(<royalty>).

      DATA(lv_legal_s) =   |{ <royalty>-licensorlegalentity }| & | ({ <royalty>-LicensorLegalEntityDescription })|.
      DATA(lv_legal_rec) = |{ <royalty>-licenseelegalentity }| & | ({ <royalty>-LicenseeLegalEntityDescription })|.
      DATA(lv_billing_period) =   |{ <royalty>-ryear }/| & |{ <royalty>-poper }| .
      DATA(lv_srv_prod_s) =   |{ <royalty>-license }| & | ({ <royalty>-LicenseDescription })|.
      CONCATENATE 'Royalty Calc. Request ||' lv_legal_rec '||'  lv_billing_period '||'  lv_legal_s '||'  lv_srv_prod_s
                        INTO  ev_header SEPARATED BY space .

    ENDLOOP.
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.
* Group based on Legal Entity and Cost Center Service Product and Receiving Entity
    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data      TYPE /esrcc/s_split_workflow.

    lt_leading_object_inp = it_leading_object.

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
