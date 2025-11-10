CLASS lhc_/esrcc/i_hier4_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      augment FOR MODIFY
        IMPORTING
          entities_create FOR CREATE hierarchyall\_hierarchy
          entities_update FOR UPDATE hierarchy.
ENDCLASS.

CLASS lhc_/esrcc/i_hier4_s IMPLEMENTATION.
  METHOD augment.
    DATA: text_for_new_entity      TYPE TABLE FOR CREATE /esrcc/i_hier4\_hierarchytext,
          text_for_existing_entity TYPE TABLE FOR CREATE /esrcc/i_hier4\_hierarchytext,
          text_update              TYPE TABLE FOR UPDATE /esrcc/i_hier4text.
    DATA: relates_create TYPE abp_behv_relating_tab,
          relates_update TYPE abp_behv_relating_tab,
          relates_cba    TYPE abp_behv_relating_tab.
    DATA: text_tky_link TYPE STRUCTURE FOR READ LINK /esrcc/i_hier4\_hierarchytext,
          text_tky      LIKE text_tky_link-target.

    READ TABLE entities_create INDEX 1 INTO DATA(entity).
    LOOP AT entity-%target ASSIGNING FIELD-SYMBOL(<target>).
      APPEND 1 TO relates_create.
      INSERT VALUE #( %cid_ref = <target>-%cid
                      %is_draft = <target>-%is_draft
                        %key-hierarchy = <target>-%key-hierarchy
                      %target = VALUE #( (
                        %cid = |CREATETEXTCID{ sy-tabix }|
                        %is_draft = <target>-%is_draft
                        spras = sy-langu
                        description = <target>-description
                        %control-spras = if_abap_behv=>mk-on
                        %control-description = <target>-%control-description ) ) )
                   INTO TABLE text_for_new_entity.
    ENDLOOP.
    MODIFY AUGMENTING ENTITIES OF /esrcc/i_hier4_s
      ENTITY hierarchy
        CREATE BY \_hierarchytext
        FROM text_for_new_entity
        RELATING TO entities_create BY relates_create.

    IF entities_update IS NOT INITIAL.
      READ ENTITIES OF /esrcc/i_hier4_s
        ENTITY hierarchy BY \_hierarchytext
          FROM CORRESPONDING #( entities_update )
          LINK DATA(link).
      LOOP AT entities_update INTO DATA(update) WHERE %control-description = if_abap_behv=>mk-on.
        DATA(tabix) = sy-tabix.
        text_tky = CORRESPONDING #( update-%tky MAPPING
                                                        hierarchy = hierarchy
                                    ).
        text_tky-spras = sy-langu.
        IF line_exists( link[ KEY draft source-%tky  = CORRESPONDING #( update-%tky )
                                        target-%tky  = CORRESPONDING #( text_tky ) ] ).
          APPEND tabix TO relates_update.
          APPEND VALUE #( %tky = text_tky
                          %cid_ref = update-%cid_ref
                          description = update-description
                          %control = VALUE #( description = update-%control-description )
          ) TO text_update.
        ELSEIF line_exists(  text_for_new_entity[ KEY cid %is_draft = update-%is_draft
                                                          %cid_ref  = update-%cid_ref ] ).
          APPEND tabix TO relates_update.
          APPEND VALUE #( %tky = text_tky
                          %cid_ref = text_for_new_entity[ %is_draft = update-%is_draft
                          %cid_ref = update-%cid_ref ]-%target[ 1 ]-%cid
                          description = update-description
                          %control = VALUE #( description = update-%control-description )
          ) TO text_update.
        ELSE.
          APPEND tabix TO relates_cba.
          APPEND VALUE #( %tky = CORRESPONDING #( update-%tky )
                          %cid_ref = update-%cid_ref
                          %target  = VALUE #( (
                            %cid = |UPDATETEXTCID{ tabix }|
                            spras = sy-langu
                            %is_draft = text_tky-%is_draft
                            description = update-description
                            %control-spras = if_abap_behv=>mk-on
                            %control-description = update-%control-description
                          ) )
          ) TO text_for_existing_entity.
        ENDIF.
      ENDLOOP.
      IF text_update IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF /esrcc/i_hier4_s
          ENTITY hierarchytext
            UPDATE FROM text_update
            RELATING TO entities_update BY relates_update.
      ENDIF.
      IF text_for_existing_entity IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF /esrcc/i_hier4_s
          ENTITY hierarchy
            CREATE BY \_hierarchytext
            FROM text_for_existing_entity
            RELATING TO entities_update BY relates_cba.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
