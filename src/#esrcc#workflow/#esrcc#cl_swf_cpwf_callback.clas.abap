CLASS /esrcc/cl_swf_cpwf_callback DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_swf_cpwf_callback .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_SWF_CPWF_CALLBACK IMPLEMENTATION.


  METHOD if_swf_cpwf_callback~workflow_instance_completed.

  TRY.
        DATA(cpwf_api_instance) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).

        Data(wf_id) = cpwf_api_instance->get_workflow_id( iv_cpwf_handle = iv_cpwf_handle ).

*    CATCH cx_swf_cpwf_api.
      CATCH cx_swf_cpwf_api into DATA(cx_cpwf_api).
        DATA(error) = cx_cpwf_api->get_longtext(  ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
