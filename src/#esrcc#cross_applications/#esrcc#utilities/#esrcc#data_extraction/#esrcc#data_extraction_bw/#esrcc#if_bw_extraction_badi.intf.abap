INTERFACE /esrcc/if_bw_extraction_badi PUBLIC.
  TYPES:
    periods_type        TYPE RANGE OF poper,
    legal_entities_type TYPE RANGE OF /esrcc/legalentity,
    cost_centers_type   TYPE RANGE OF /esrcc/costcenter,
    cost_elements_type  TYPE RANGE OF /esrcc/costelement,
    package_codes_type  TYPE RANGE OF /esrcc/package_code.

  INTERFACES:
    if_amdp_marker_hdb,
    if_badi_interface.


  METHODS:
    extract_data IMPORTING VALUE(extraction_type) TYPE /esrcc/extraction_object
                           VALUE(reporting_year)  TYPE /esrcc/ryear
                           VALUE(periods)         TYPE periods_type
                           VALUE(ledger)          TYPE /esrcc/ledger_de
                           VALUE(legal_entities)  TYPE legal_entities_type
                           VALUE(cost_centers)    TYPE cost_centers_type
                           VALUE(cost_elements)   TYPE cost_elements_type
                           VALUE(package_codes)   TYPE package_codes_type
                           VALUE(package_size)    TYPE i                   DEFAULT 10000
                           VALUE(simulation_mode) TYPE abap_boolean        DEFAULT abap_true
                 RAISING   cx_amdp_creation_error
                           cx_amdp_execution_error
                           cx_amdp_version_error.
ENDINTERFACE.
