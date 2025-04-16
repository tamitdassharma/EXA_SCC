INTERFACE /esrcc/if_calculate_chargeout
  PUBLIC .

  CONSTANTS: costbase                      TYPE /esrcc/application_type_de VALUE 'CBS',
             serviceshare                  TYPE /esrcc/application_type_de VALUE 'SCM',
             chargeout                     TYPE /esrcc/application_type_de VALUE 'CHR',

             approved                      TYPE /esrcc/chargeoutstatus     VALUE 'A',
             inprocess                     TYPE /esrcc/chargeoutstatus     VALUE 'P',
             draft                         TYPE /esrcc/chargeoutstatus     VALUE 'D',
             finalized                     TYPE /esrcc/chargeoutstatus     VALUE 'F',
             approval_pending              TYPE /esrcc/chargeoutstatus     VALUE 'W',
             rejected                      TYPE /esrcc/chargeoutstatus     VALUE 'R',

             chargeout_notpossible         TYPE /esrcc/process_status_de   VALUE '00',
             chargeout_allowed             TYPE /esrcc/process_status_de   VALUE '01',
             chargeout_inprocess           TYPE /esrcc/process_status_de   VALUE '02',
             chargeout_pending             TYPE /esrcc/process_status_de   VALUE '03',
             chargeout_approved            TYPE /esrcc/process_status_de   VALUE '04',
             chargeout_fin_inprocess       TYPE /esrcc/process_status_de   VALUE '05',
             chargeout_finalized           TYPE /esrcc/process_status_de   VALUE '06',
             chargeout_reopen_inprocess    TYPE /esrcc/process_status_de   VALUE '07',
             chargeout_rejected            TYPE /esrcc/process_status_de   VALUE '08',
             chargeout_failed              TYPE /esrcc/process_status_de   VALUE '09',

             lineitemsnot_available        TYPE /esrcc/process_status_de   VALUE '01',
             lineitems_drafft              TYPE /esrcc/process_status_de   VALUE '02',
             lineitems_inapproval          TYPE /esrcc/process_status_de   VALUE '03',
             costbase_allowed              TYPE /esrcc/process_status_de   VALUE '04',
             costbase_inprocess            TYPE /esrcc/process_status_de   VALUE '05',
             costbase_pending              TYPE /esrcc/process_status_de   VALUE '06',
             costbase_approved             TYPE /esrcc/process_status_de   VALUE '07',
             costbase_fin_inprocess        TYPE /esrcc/process_status_de   VALUE '08',
             costbase_finalized            TYPE /esrcc/process_status_de   VALUE '09',
             costbase_reopen_inprocess     TYPE /esrcc/process_status_de   VALUE '10',
             costbase_lineitemsrej         TYPE /esrcc/process_status_de   VALUE '11',
             costbase_rejected             TYPE /esrcc/process_status_de   VALUE '12',
             costbase_failed               TYPE /esrcc/process_status_de   VALUE '13',

             serviceshare_notpossible      TYPE /esrcc/process_status_de   VALUE '00',
             serviceshare_allowed          TYPE /esrcc/process_status_de   VALUE '01',
             serviceshare_inprocess        TYPE /esrcc/process_status_de   VALUE '02',
             serviceshare_pending          TYPE /esrcc/process_status_de   VALUE '03',
             serviceshare_approved         TYPE /esrcc/process_status_de   VALUE '04',
             serviceshare_fin_inproces     TYPE /esrcc/process_status_de   VALUE '05',
             serviceshare_finalized        TYPE /esrcc/process_status_de   VALUE '06',
             serviceshare_reopen_inprocess TYPE /esrcc/process_status_de   VALUE '07',
             serviceshare_rejected         TYPE /esrcc/process_status_de   VALUE '08',
             serviceshare_failed           TYPE /esrcc/process_status_de   VALUE '09',

             scc_valuesource               TYPE /esrcc/ce_value_source     VALUE 'SCC',
             adhocprocesstype              TYPE /esrcc/process_type        VALUE 'A',
             standardprocesstype           TYPE /esrcc/process_type        VALUE 'S'.

  CONSTANTS: action_calculate_costbase      TYPE /esrcc/actions VALUE '01',
             action_finalize_costbase       TYPE /esrcc/actions VALUE '02',
             action_reopen_costbase         TYPE /esrcc/actions VALUE '03',
             action_calculat_serviceproduct TYPE /esrcc/actions VALUE '04',
             action_finalize_serviceproduct TYPE /esrcc/actions VALUE '05',
             action_reopen_serviceproduct   TYPE /esrcc/actions VALUE '06',
             action_calculat_chargeout      TYPE /esrcc/actions VALUE '07',
             action_finalize_chargeout      TYPE /esrcc/actions VALUE '08',
             action_reopen_chargeout        TYPE /esrcc/actions VALUE '09',
             action_sequential_chargeout    TYPE /esrcc/actions VALUE '10',
             action_reopenseq_chargeout     TYPE /esrcc/actions VALUE '11'.

ENDINTERFACE.
