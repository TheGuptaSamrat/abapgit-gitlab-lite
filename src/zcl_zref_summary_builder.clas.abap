CLASS zcl_zref_summary_builder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS build_summary
      IMPORTING
        is_bundle         TYPE zif_zref_types=>ty_object_bundle
      RETURNING
        VALUE(rv_summary) TYPE string.
ENDCLASS.

CLASS zcl_zref_summary_builder IMPLEMENTATION.

  METHOD build_summary.
    rv_summary =
      |# { is_bundle-object_key-obj_type } { is_bundle-object_key-obj_name }| && cl_abap_char_utilities=>newline &&
      cl_abap_char_utilities=>newline &&
      |## Purpose| && cl_abap_char_utilities=>newline &&
      |Reference snapshot exported from SAP for AI-assisted maintenance and enhancement analysis.| &&
      cl_abap_char_utilities=>newline && cl_abap_char_utilities=>newline &&
      |## Confirmed metadata| && cl_abap_char_utilities=>newline &&
      |- Package: `{ is_bundle-object_key-devclass }`| && cl_abap_char_utilities=>newline &&
      |- System: `{ is_bundle-system_id }` Client `{ is_bundle-client_id }`| && cl_abap_char_utilities=>newline &&
      |- Active: `{ is_bundle-is_active }`| && cl_abap_char_utilities=>newline &&
      cl_abap_char_utilities=>newline &&
      |## Notes| && cl_abap_char_utilities=>newline &&
      |- This summary is generated from exported evidence only.| && cl_abap_char_utilities=>newline &&
      |- Business meaning should be inferred only from visible identifiers and source content.|.
  ENDMETHOD.

ENDCLASS.
