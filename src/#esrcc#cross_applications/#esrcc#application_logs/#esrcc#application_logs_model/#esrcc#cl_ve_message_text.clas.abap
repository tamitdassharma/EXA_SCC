CLASS /esrcc/cl_ve_message_text DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_VE_MESSAGE_TEXT IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA original_data TYPE STANDARD TABLE OF /esrcc/c_applicationlogshier WITH EMPTY KEY.

    original_data = CORRESPONDING #( it_original_data ).

    LOOP AT original_data ASSIGNING FIELD-SYMBOL(<original_data>).
      " TODO: variable is assigned but never used; add pragma ##NEEDED (ABAP cleaner)
      IF <original_data>-messageid IS NOT INITIAL AND <original_data>-messagenumber IS NOT INITIAL AND <original_data>-MessageType IS NOT INITIAL
        AND ( <original_data>-MessageType = 'Error' OR <original_data>-MessageType = 'Information' OR <original_data>-MessageType = 'Warning' OR <original_data>-MessageType = 'Success' ).
        MESSAGE ID <original_data>-messageid TYPE <original_data>-messagetype NUMBER <original_data>-messagenumber
          INTO <original_data>-messagetext WITH <original_data>-messagev1 <original_data>-messagev2 <original_data>-messagev3 <original_data>-messagev4.
      ELSEIF <original_data>-hierarchylevel = 0.
        MESSAGE ID '/ESRCC/APPL_LOGS' TYPE 'I' NUMBER 001 INTO <original_data>-messagetext WITH <original_data>-applicationdescription <original_data>-subapplicationdescription.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( original_data ).
*    ct_calculated_data = original_data.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    APPEND LINES OF VALUE if_sadl_exit_calc_element_read=>tt_elements( ( CONV #( 'APPLICATION' ) )
                                                                       ( CONV #( 'SUBAPPLICATION' ) )
                                                                       ( CONV #( 'HIERARCHYLEVEL' ) )
                                                                       ( CONV #( 'MESSAGEID' ) )
                                                                       ( CONV #( 'MESSAGENUMBER' ) )
                                                                       ( CONV #( 'MESSAGEV1' ) )
                                                                       ( CONV #( 'MESSAGEV2' ) )
                                                                       ( CONV #( 'MESSAGEV3' ) )
                                                                       ( CONV #( 'MESSAGEV4' ) ) ) TO et_requested_orig_elements.
  ENDMETHOD.
ENDCLASS.
