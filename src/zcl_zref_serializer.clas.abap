CLASS zcl_zref_serializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS serialize
      IMPORTING
        it_object_keys     TYPE zif_zref_types=>ty_object_key_tt
        io_log             TYPE REF TO zcl_zref_log
      RETURNING
        VALUE(rt_bundles)  TYPE zif_zref_types=>ty_object_bundle_tt.

  PRIVATE SECTION.
    DATA mt_handlers TYPE STANDARD TABLE OF REF TO zif_zref_object_handler WITH DEFAULT KEY.
    METHODS register_default_handlers.
    METHODS add_reference_files
      CHANGING
        cs_bundle TYPE zif_zref_types=>ty_object_bundle.
    METHODS find_handler
      IMPORTING
        is_object_key       TYPE zif_zref_types=>ty_object_key
      RETURNING
        VALUE(ro_handler)   TYPE REF TO zif_zref_object_handler.
ENDCLASS.

CLASS zcl_zref_serializer IMPLEMENTATION.

  METHOD constructor.
    register_default_handlers( ).
  ENDMETHOD.

  METHOD register_default_handlers.
    APPEND NEW zcl_zref_obj_clas( ) TO mt_handlers.
    APPEND NEW zcl_zref_obj_intf( ) TO mt_handlers.
    APPEND NEW zcl_zref_obj_prog( ) TO mt_handlers.
    APPEND NEW zcl_zref_obj_dtel( ) TO mt_handlers.
    APPEND NEW zcl_zref_obj_doma( ) TO mt_handlers.
    APPEND NEW zcl_zref_obj_tabl( ) TO mt_handlers.
  ENDMETHOD.

  METHOD add_reference_files.
    DATA lv_root TYPE string.

    lv_root = |objects/{ cs_bundle-object_key-obj_type }/{ cs_bundle-object_key-obj_name }|.

    APPEND VALUE zif_zref_types=>ty_export_file(
      path         = |{ lv_root }/metadata.json|
      content_type = 'application/json'
      text_content = cs_bundle-metadata_json
      checksum     = ''
      status       = 'ACTIVE' ) TO cs_bundle-files.

    APPEND VALUE zif_zref_types=>ty_export_file(
      path         = |{ lv_root }/summary.md|
      content_type = 'text/markdown'
      text_content = cs_bundle-summary_markdown
      checksum     = ''
      status       = 'ACTIVE' ) TO cs_bundle-files.
  ENDMETHOD.

  METHOD find_handler.
    LOOP AT mt_handlers ASSIGNING FIELD-SYMBOL(<lo_handler>).
      IF <lo_handler>->supports( is_object_key ) = abap_true.
        ro_handler = <lo_handler>.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD serialize.
    DATA lo_handler TYPE REF TO zif_zref_object_handler.
    DATA ls_bundle  TYPE zif_zref_types=>ty_object_bundle.

    LOOP AT it_object_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      lo_handler = find_handler( <ls_key> ).
      IF lo_handler IS INITIAL.
        io_log->add_info(
          iv_category = 'SERIALIZE'
          iv_object   = |{ <ls_key>-obj_type } { <ls_key>-obj_name }|
          iv_message  = 'Unsupported object type skipped' ).
        CONTINUE.
      ENDIF.

      TRY.
          ls_bundle = lo_handler->build_bundle( <ls_key> ).
          ls_bundle-summary_markdown = zcl_zref_summary_builder=>build_summary( ls_bundle ).
          add_reference_files( CHANGING cs_bundle = ls_bundle ).
          APPEND ls_bundle TO rt_bundles.
        CATCH cx_static_check INTO DATA(lx_error).
          io_log->add_error(
            iv_category = 'SERIALIZE'
            iv_object   = |{ <ls_key>-obj_type } { <ls_key>-obj_name }|
            iv_message  = lx_error->get_text( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
