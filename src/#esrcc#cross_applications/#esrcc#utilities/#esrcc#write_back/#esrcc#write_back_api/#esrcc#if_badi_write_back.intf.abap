INTERFACE /esrcc/if_badi_write_back PUBLIC .
  INTERFACES if_badi_interface .

  METHODS:
    adapt_filters CHANGING filters TYPE /esrcc/if_write_back=>filters_type,
    pre_exit,
    post_exit.
ENDINTERFACE.
