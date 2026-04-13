CLASS zcl_zref_obj_doma DEFINITION
  PUBLIC
  INHERITING FROM zcl_zref_obj_base
  FINAL
  CREATE PUBLIC.
ENDCLASS.

CLASS zcl_zref_obj_doma IMPLEMENTATION.

  METHOD zif_zref_object_handler~supports.
    rv_result = boolc( is_object_key-obj_type = 'DOMA' ).
  ENDMETHOD.

  METHOD zif_zref_object_handler~build_bundle.
    DATA lv_root TYPE string.
    rs_bundle = create_basic_bundle( is_object_key ).
    lv_root = build_object_root( is_object_key ).
    rs_bundle-metadata_json =
      |{{"object_type":"DOMA","object_name":"{ is_object_key-obj_name }","package":"{ is_object_key-devclass }"}}|.

    add_text_file(
      EXPORTING
        iv_path    = |{ lv_root }/definition.txt|
        iv_content = rs_bundle-metadata_json
      CHANGING
        ct_files   = rs_bundle-files ).
  ENDMETHOD.

ENDCLASS.
