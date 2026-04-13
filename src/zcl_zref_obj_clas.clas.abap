CLASS zcl_zref_obj_clas DEFINITION
  PUBLIC
  INHERITING FROM zcl_zref_obj_base
  FINAL
  CREATE PUBLIC.
ENDCLASS.

CLASS zcl_zref_obj_clas IMPLEMENTATION.

  METHOD zif_zref_object_handler~supports.
    rv_result = boolc( is_object_key-obj_type = 'CLAS' ).
  ENDMETHOD.

  METHOD zif_zref_object_handler~build_bundle.
    DATA lv_source TYPE string.
    rs_bundle = create_basic_bundle( is_object_key ).

    lv_source = |* TODO: Read class source for { is_object_key-obj_name } from SAP repository APIs.| &&
      cl_abap_char_utilities=>newline.

    rs_bundle-metadata_json =
      |{{"object_type":"CLAS","object_name":"{ is_object_key-obj_name }","package":"{ is_object_key-devclass }"}}|.

    add_text_file(
      EXPORTING
        iv_path    = |objects/CLAS/{ is_object_key-obj_name }/source.abap|
        iv_content = lv_source
      CHANGING
        ct_files   = rs_bundle-files ).
  ENDMETHOD.

ENDCLASS.
