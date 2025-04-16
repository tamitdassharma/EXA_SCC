CLASS /esrcc/invoicegenerator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/create_invoice_badi .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/INVOICEGENERATOR IMPLEMENTATION.


  METHOD /esrcc/create_invoice_badi~create_invoice.

    DATA lv_xml TYPE xstring.
    DATA lv_value TYPE string.
    FIELD-SYMBOLS:
      <invoice_data> TYPE /esrcc/build_invoice_retreat=>invoice_detail.

    ASSIGN invoice_dto->* TO <invoice_data>.

    IF <invoice_data> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    TRY.
        "Initialize Template Store Client
        DATA(lo_store) = NEW /ESRCC/tmpl_store_client(
          iv_name = 'adoberestapi'
          iv_service_instance_name = 'SAP_COM_0276'
        ).

* Get Schema from store
        TRY.
            lo_store->get_schema_by_name( iv_form_name = 'Exa_SCCForm' ).
          CATCH /ESRCC/cx_fp_tmpl_store_error INTO DATA(lo_tmpl_error).
            IF lo_tmpl_error->mv_http_status_code = 404.
            ELSE.
            ENDIF.
        ENDTRY.

*Fetch Template
        DATA(ls_template) = lo_store->get_template_by_name(
          iv_get_binary     = abap_true
          iv_form_name      = 'Exa_SCCForm'
          iv_template_name  = 'Exa_SCC_Template'
        ).

        DATA(lo_ixml) = cl_ixml_core=>create(
         ).

        DATA(lo_ixml_document) = lo_ixml->create_document( ).
*
        DATA ir_data TYPE REF TO data.
        ASSIGN ir_data->* TO FIELD-SYMBOL(<data>).
        DATA(lo_node) = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'Form' ) ) ##NO_TEXT.


        DATA(components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                           '/ESRCC/ENTITY_DETAILS' ) )->get_components( ).
**--------------------------------
        DATA(lo_struct_node) = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'RECEIVER' ) ).

        LOOP AT components ASSIGNING FIELD-SYMBOL(<component>).
*
          ASSIGN COMPONENT <component>-name OF STRUCTURE <invoice_data>-receiver TO FIELD-SYMBOL(<lv_receiver>).
          DATA(lo_element_node) = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = <component>-name ) ).
          IF <lv_receiver> IS ASSIGNED.
            lv_value = <lv_receiver>.
            lo_element_node->set_value(
              EXPORTING
                value = lv_value
            ).
          ELSE.
            lo_element_node->set_value(
              EXPORTING
                value = ''
            ).
          ENDIF.
          lo_struct_node->append_child( lo_element_node ).
        ENDLOOP.


        lo_node->append_child( lo_struct_node ).

        components = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                              '/ESRCC/ENTITY_DETAILS' ) )->get_components( ).
**--------------------------------
        lo_struct_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'SENDER' ) ).

        LOOP AT components ASSIGNING <component>.
*
          ASSIGN COMPONENT <component>-name OF STRUCTURE <invoice_data>-sender TO FIELD-SYMBOL(<lv_sender>).
          lo_element_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = <component>-name ) ).
          IF <lv_sender> IS ASSIGNED.
            lv_value = <lv_sender>.
            lo_element_node->set_value(
              EXPORTING
                value = lv_value
            ).
          ELSE.
            lo_element_node->set_value(
              EXPORTING
                value = ''
            ).
          ENDIF.
          lo_struct_node->append_child( lo_element_node ).
        ENDLOOP.

        lo_node->append_child( lo_struct_node ).

        components = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                              '/ESRCC/ENTITY_BANK_DETAIL' ) )->get_components( ).
**--------------------------------
        lo_struct_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'BANK_DETAIL' ) ).

        LOOP AT components ASSIGNING <component>.

          ASSIGN COMPONENT <component>-name OF STRUCTURE <invoice_data>-bank_information TO FIELD-SYMBOL(<lv_bank>).
          lo_element_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = <component>-name ) ).
          IF <lv_bank> IS ASSIGNED.
            lv_value = <lv_bank>.
            lo_element_node->set_value(
              EXPORTING
                value = lv_value
            ).
          ELSE.
            lo_element_node->set_value(
              EXPORTING
                value = ''
            ).
          ENDIF.
          lo_struct_node->append_child( lo_element_node ).
        ENDLOOP.

        lo_node->append_child( lo_struct_node ).
**--------------------------------
        components = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                              '/ESRCC/INVOICE_DETAIL' ) )->get_components( ).

        lo_struct_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'INVOICE_DETAIL' ) ).

        LOOP AT components ASSIGNING <component>.
*
          ASSIGN COMPONENT <component>-name OF STRUCTURE <invoice_data>-invoice_information TO FIELD-SYMBOL(<lv_invoicedata>).
          lo_element_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = <component>-name ) ).
          IF <lv_invoicedata> IS ASSIGNED.
            lv_value = <lv_invoicedata>.
            lo_element_node->set_value(
              EXPORTING
                value = lv_value
            ).
          ELSE.
            lo_element_node->set_value(
              EXPORTING
                value = ''
            ).
          ENDIF.
          lo_struct_node->append_child( lo_element_node ).
        ENDLOOP.
        lo_node->append_child( lo_struct_node ).
*-----------------------------------------------------------
        components = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                               '/ESRCC/TOTAL' ) )->get_components( ).

        lo_struct_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'TOTALS' ) ).

        LOOP AT components ASSIGNING <component>.
*
          ASSIGN COMPONENT <component>-name OF STRUCTURE <invoice_data>-totals TO FIELD-SYMBOL(<lv_total>).
          lo_element_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = <component>-name ) ).
          IF <lv_invoicedata> IS ASSIGNED.
            lv_value = <lv_total>.
            lo_element_node->set_value(
              EXPORTING
                value = lv_value
            ).
          ELSE.
            lo_element_node->set_value(
              EXPORTING
                value = ''
            ).
          ENDIF.
          lo_struct_node->append_child( lo_element_node ).
        ENDLOOP.
        lo_node->append_child( lo_struct_node ).
**--------------------------------
        lo_struct_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'ITEMS' ) ).
        components = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name(
                                                              '/ESRCC/ITEM' ) )->get_components( ).

        LOOP AT <invoice_data>-items ASSIGNING FIELD-SYMBOL(<item>).
          DATA(lo_child_struct_node) = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = 'DATA' ) ).

          LOOP AT components ASSIGNING <component>.
*
            ASSIGN COMPONENT <component>-name OF STRUCTURE <item> TO FIELD-SYMBOL(<lv_item>).
            lo_element_node = CAST if_ixml_node( lo_ixml_document->create_element_ns( name = <component>-name ) ).
            IF <lv_item> IS ASSIGNED.
              lv_value = <lv_item>.
              lo_element_node->set_value(
                EXPORTING
                  value = lv_value
              ).
            ELSE.
              lo_element_node->set_value(
                EXPORTING
                  value = ''
              ).
            ENDIF.
            lo_child_struct_node->append_child( lo_element_node ).
          ENDLOOP.
          lo_struct_node->append_child( lo_child_struct_node ).
        ENDLOOP.

*
        lo_node->append_child( lo_struct_node ).
*-----------------------------------------------------------
        lo_ixml_document->append_child( lo_node ).
        lo_ixml->create_renderer(
            document = lo_ixml_document
            ostream  = lo_ixml->create_stream_factory( )->create_ostream_xstring( lv_xml )
        )->render( ).

        cl_fp_ads_util=>render_pdf(
           EXPORTING
             iv_xml_data     = lv_xml
             iv_xdp_layout   = ls_template-xdp_template
             iv_locale       = 'en_US'
           IMPORTING
             ev_pdf          = DATA(lv_pdf)
             ev_pages        = DATA(lv_pages)
             ev_trace_string = DATA(lv_trace_data)
         ).

        IF lv_pdf IS NOT INITIAL.
          raw_pdf = lv_pdf.
        ENDIF.

      CATCH cx_fp_fdp_error /ESRCC/cx_fp_tmpl_store_error cx_fp_ads_util INTO DATA(lo_err).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
