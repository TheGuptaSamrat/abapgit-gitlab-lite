CLASS zcl_zref_obj_base DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_zref_object_handler.

  PROTECTED SECTION.
    METHODS build_object_root
      IMPORTING
        is_object_key    TYPE zif_zref_types=>ty_object_key
      RETURNING
        VALUE(rv_path)   TYPE string.

    METHODS create_basic_bundle
      IMPORTING
        is_object_key       TYPE zif_zref_types=>ty_object_key
      RETURNING
        VALUE(rs_bundle)    TYPE zif_zref_types=>ty_object_bundle.

    METHODS add_text_file
      IMPORTING
        iv_path    TYPE string
        iv_content TYPE string
      CHANGING
        ct_files   TYPE zif_zref_types=>ty_export_file_tt.
ENDCLASS.

CLASS zcl_zref_obj_base IMPLEMENTATION.

  METHOD build_object_root.
    rv_path = |objects/{ is_object_key-obj_type }/{ is_object_key-obj_name }|.
  ENDMETHOD.

  METHOD create_basic_bundle.
    CLEAR rs_bundle.
    rs_bundle-object_key = is_object_key.
    rs_bundle-system_id  = sy-sysid.
    rs_bundle-client_id  = sy-mandt.
    rs_bundle-changed_by = sy-uname.
    GET TIME STAMP FIELD rs_bundle-changed_at.
    rs_bundle-is_active = abap_true.
  ENDMETHOD.

  METHOD add_text_file.
    APPEND VALUE zif_zref_types=>ty_export_file(
      path         = iv_path
      content_type = 'text/plain'
      text_content = iv_content
      checksum     = ''
      status       = 'ACTIVE' ) TO ct_files.
  ENDMETHOD.

ENDCLASS.
