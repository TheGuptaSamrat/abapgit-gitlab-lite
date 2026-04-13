CLASS zcl_zref_obj_intf DEFINITION
  PUBLIC
  INHERITING FROM zcl_zref_obj_base
  FINAL
  CREATE PUBLIC.
ENDCLASS.

CLASS zcl_zref_obj_intf IMPLEMENTATION.

  METHOD zif_zref_object_handler~supports.
    rv_result = boolc( is_object_key-obj_type = 'INTF' ).
  ENDMETHOD.

  METHOD zif_zref_object_handler~build_bundle.
    DATA lv_root TYPE string.
    rs_bundle = create_basic_bundle( is_object_key ).
    lv_root = build_object_root( is_object_key ).
    rs_bundle-metadata_json =
      |{{"object_type":"INTF","object_name":"{ is_object_key-obj_name }","package":"{ is_object_key-devclass }"}}|.

    add_text_file(
      EXPORTING
        iv_path    = |{ lv_root }/source.abap|
        iv_content = |* TODO: Read interface source for { is_object_key-obj_name }.|
      CHANGING
        ct_files   = rs_bundle-files ).
  ENDMETHOD.

ENDCLASS.
