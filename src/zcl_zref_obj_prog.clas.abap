CLASS zcl_zref_obj_prog DEFINITION
  PUBLIC
  INHERITING FROM zcl_zref_obj_base
  FINAL
  CREATE PUBLIC.
ENDCLASS.

CLASS zcl_zref_obj_prog IMPLEMENTATION.

  METHOD zif_zref_object_handler~supports.
    rv_result = boolc( is_object_key-obj_type = 'PROG' ).
  ENDMETHOD.

  METHOD zif_zref_object_handler~build_bundle.
    rs_bundle = create_basic_bundle( is_object_key ).
    rs_bundle-metadata_json =
      |{{"object_type":"PROG","object_name":"{ is_object_key-obj_name }","package":"{ is_object_key-devclass }"}}|.

    add_text_file(
      EXPORTING
        iv_path    = |objects/PROG/{ is_object_key-obj_name }/source.abap|
        iv_content = |* TODO: Read report/program source for { is_object_key-obj_name }.|
      CHANGING
        ct_files   = rs_bundle-files ).
  ENDMETHOD.

ENDCLASS.
