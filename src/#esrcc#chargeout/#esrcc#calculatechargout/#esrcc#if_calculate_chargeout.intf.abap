INTERFACE /esrcc/if_calculate_chargeout
  PUBLIC .

  CONSTANTS: chargeout                      TYPE /esrcc/application_type_de VALUE 'CHR',
             stdchargeout                   TYPE /esrcc/application_type_de VALUE 'STD',
             trueuprecal                    TYPE /esrcc/application_type_de VALUE 'TRU',
             writeback                      TYPE /esrcc/application_type_de VALUE 'WRB',
             adhoc                          TYPE /esrcc/application_type_de VALUE 'ADH',

             approved                       TYPE /esrcc/chargeoutstatus     VALUE 'A',
             inprocess                      TYPE /esrcc/chargeoutstatus     VALUE 'P',
             draft                          TYPE /esrcc/chargeoutstatus     VALUE 'D',
             finalized                      TYPE /esrcc/chargeoutstatus     VALUE 'F',
             finalizedbyadhoc               TYPE /esrcc/chargeoutstatus     VALUE 'K',
             finalizedbyRecalculation       TYPE /esrcc/chargeoutstatus     VALUE 'O',
             approval_pending               TYPE /esrcc/chargeoutstatus     VALUE 'W',
             rejected                       TYPE /esrcc/chargeoutstatus     VALUE 'R',

             lineitemsnot_available         TYPE /esrcc/process_status_de   VALUE '01',
             lineitems_drafft               TYPE /esrcc/process_status_de   VALUE '02',
             lineitems_inapproval           TYPE /esrcc/process_status_de   VALUE '03',
             stdchargeout_allowed           TYPE /esrcc/process_status_de   VALUE '04',
             stdchargeout_inprocess         TYPE /esrcc/process_status_de   VALUE '05',
             stdchargeout_pending           TYPE /esrcc/process_status_de   VALUE '06',
             stdchargeout_approved          TYPE /esrcc/process_status_de   VALUE '07',
             stdchargeout_fin_inprocess     TYPE /esrcc/process_status_de   VALUE '08',
             stdchargeout_finalized         TYPE /esrcc/process_status_de   VALUE '09',
             stdchargeout_reopen_inprocess  TYPE /esrcc/process_status_de   VALUE '10',
             stdchargeout_lineitemsrej      TYPE /esrcc/process_status_de   VALUE '11',
             stdchargeout_rejected          TYPE /esrcc/process_status_de   VALUE '12',
             stdchargeout_failed            TYPE /esrcc/process_status_de   VALUE '13',

             recalculation_notpossible      TYPE /esrcc/process_status_de   VALUE '00',
             recalculation_allowed          TYPE /esrcc/process_status_de   VALUE '01',
             recalculation_inprocess        TYPE /esrcc/process_status_de   VALUE '02',
             recalculation_pending          TYPE /esrcc/process_status_de   VALUE '03',
             recalculation_approved         TYPE /esrcc/process_status_de   VALUE '04',
             recalculation_fin_inproces     TYPE /esrcc/process_status_de   VALUE '05',
             recalculation_finalized        TYPE /esrcc/process_status_de   VALUE '06',
             recalculation_reopen_inprocess TYPE /esrcc/process_status_de   VALUE '07',
             recalculation_rejected         TYPE /esrcc/process_status_de   VALUE '08',
             recalculation_failed           TYPE /esrcc/process_status_de   VALUE '09',

             chargeout_notpossible          TYPE /esrcc/process_status_de   VALUE '00',
             chargeout_allowed              TYPE /esrcc/process_status_de   VALUE '01',
             chargeout_inprocess            TYPE /esrcc/process_status_de   VALUE '02',
             chargeout_pending              TYPE /esrcc/process_status_de   VALUE '03',
             chargeout_approved             TYPE /esrcc/process_status_de   VALUE '04',
             chargeout_fin_inprocess        TYPE /esrcc/process_status_de   VALUE '05',
             chargeout_finalized            TYPE /esrcc/process_status_de   VALUE '06',
             chargeout_reopen_inprocess     TYPE /esrcc/process_status_de   VALUE '07',
             chargeout_rejected             TYPE /esrcc/process_status_de   VALUE '08',
             chargeout_failed               TYPE /esrcc/process_status_de   VALUE '09',

             scc_valuesource                TYPE /esrcc/ce_value_source     VALUE 'SCC',
             adhocprocesstype               TYPE /esrcc/process_type        VALUE 'A',
             standardprocesstype            TYPE /esrcc/process_type        VALUE 'S',
             recalprocesstype               TYPE /esrcc/process_type        VALUE 'R'.

  CONSTANTS: calculate_stdchargeout      TYPE /esrcc/actions VALUE '01',
             finalize_stdchargeout       TYPE /esrcc/actions VALUE '02',
             reopen_stdchargeout         TYPE /esrcc/actions VALUE '03',
             calculate_stdseqchargeout   TYPE /esrcc/actions VALUE '04',
             finalize_stdseqchargeout    TYPE /esrcc/actions VALUE '05',
             reopen_stdseqchargeout      TYPE /esrcc/actions VALUE '06',
             calculate_recalchargeout    TYPE /esrcc/actions VALUE '07',
             finalize_recalchargeout     TYPE /esrcc/actions VALUE '08',
             reopen_recalchargeout       TYPE /esrcc/actions VALUE '09',
             calculate_recalseqchargeout TYPE /esrcc/actions VALUE '10',
             finalize_recalseqchargeout  TYPE /esrcc/actions VALUE '11',
             reopen_recalseqchargeout    TYPE /esrcc/actions VALUE '12'.


ENDINTERFACE.
