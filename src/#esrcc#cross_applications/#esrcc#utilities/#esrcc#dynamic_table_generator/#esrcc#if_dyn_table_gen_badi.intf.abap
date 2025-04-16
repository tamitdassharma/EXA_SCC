interface /ESRCC/IF_DYN_TABLE_GEN_BADI
  public .


  interfaces IF_BADI_INTERFACE .

  methods ENRICH_TABLE_COMPONENTS
    changing
      !COMPONENTS type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE .
endinterface.
