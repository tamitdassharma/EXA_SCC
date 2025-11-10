INTERFACE /esrcc/if_bc_copy_feature
  PUBLIC .

  INTERFACES if_badi_interface .

  TYPES:
    BEGIN OF ts_validity,
      from TYPE /esrcc/validfrom,
      to   TYPE /esrcc/validto,
    END OF ts_validity.

  METHODS:
    auto_adjust_child_validity
      IMPORTING
        is_parent_validity        TYPE ts_validity
        is_parent_target_validity TYPE ts_validity
      CHANGING
        cs_child_validity         TYPE ts_validity.
ENDINTERFACE.
