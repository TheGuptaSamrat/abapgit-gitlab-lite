CLASS zcl_zref_object_collector DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS collect
      IMPORTING
        is_profile            TYPE zif_zref_types=>ty_profile
        io_log                TYPE REF TO zcl_zref_log
      RETURNING
        VALUE(rt_object_keys) TYPE zif_zref_types=>ty_object_key_tt.
ENDCLASS.

CLASS zcl_zref_object_collector IMPLEMENTATION.

  METHOD collect.
    DATA lt_tadir TYPE STANDARD TABLE OF tadir WITH DEFAULT KEY.
    DATA ls_key   TYPE zif_zref_types=>ty_object_key.

    SELECT *
      FROM tadir
      INTO TABLE lt_tadir
      WHERE devclass = is_profile-package_name
        AND pgmid    = 'R3TR'
        AND obj_name LIKE 'Z%'
        AND delflag  = space.

    LOOP AT lt_tadir ASSIGNING FIELD-SYMBOL(<ls_tadir>).
      CLEAR ls_key.
      ls_key-obj_type = <ls_tadir>-object.
      ls_key-obj_name = <ls_tadir>-obj_name.
      ls_key-devclass = <ls_tadir>-devclass.
      APPEND ls_key TO rt_object_keys.
    ENDLOOP.

    io_log->add_info(
      iv_category = 'COLLECT'
      iv_object   = is_profile-package_name
      iv_message  = |Collected { lines( rt_object_keys ) } candidate objects| ).
  ENDMETHOD.

ENDCLASS.
