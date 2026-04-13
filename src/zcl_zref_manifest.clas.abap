CLASS zcl_zref_manifest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS build_latest_refresh_json
      IMPORTING
        is_profile        TYPE zif_zref_types=>ty_profile
        it_object_bundles TYPE zif_zref_types=>ty_object_bundle_tt
      RETURNING
        VALUE(rv_json)    TYPE string.

    CLASS-METHODS build_object_index_csv
      IMPORTING
        it_object_bundles TYPE zif_zref_types=>ty_object_bundle_tt
      RETURNING
        VALUE(rv_csv)     TYPE string.

    CLASS-METHODS build_package_index_csv
      IMPORTING
        it_object_bundles TYPE zif_zref_types=>ty_object_bundle_tt
      RETURNING
        VALUE(rv_csv)     TYPE string.
ENDCLASS.

CLASS zcl_zref_manifest IMPLEMENTATION.

  METHOD build_latest_refresh_json.
    rv_json =
      |{| &&
      |"profile":"{ is_profile-profile_id }",| &&
      |"package":"{ is_profile-package_name }",| &&
      |"system":"{ sy-sysid }",| &&
      |"client":"{ sy-mandt }",| &&
      |"object_count":{ lines( it_object_bundles ) }| &&
      |}|.
  ENDMETHOD.

  METHOD build_object_index_csv.
    DATA lv_newline TYPE string.

    lv_newline = cl_abap_char_utilities=>newline.
    rv_csv = |obj_type,obj_name,package,system,client| && lv_newline.

    LOOP AT it_object_bundles ASSIGNING FIELD-SYMBOL(<ls_bundle>).
      rv_csv = rv_csv &&
        |{ <ls_bundle>-object_key-obj_type },{ <ls_bundle>-object_key-obj_name },| &&
        |{ <ls_bundle>-object_key-devclass },{ <ls_bundle>-system_id },{ <ls_bundle>-client_id }| &&
        lv_newline.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_package_index_csv.
    DATA lv_newline TYPE string.
    DATA lv_count   TYPE i.
    DATA lv_package TYPE devclass.

    FIELD-SYMBOLS <ls_bundle> TYPE zif_zref_types=>ty_object_bundle.

    lv_newline = cl_abap_char_utilities=>newline.
    rv_csv = |package,object_count,system,client| && lv_newline.

    LOOP AT it_object_bundles ASSIGNING <ls_bundle>.
      AT NEW object_key-devclass.
        lv_package = <ls_bundle>-object_key-devclass.
        lv_count = 0.
      ENDAT.

      lv_count = lv_count + 1.

      AT END OF object_key-devclass.
        rv_csv = rv_csv &&
          |{ lv_package },{ lv_count },{ <ls_bundle>-system_id },{ <ls_bundle>-client_id }| &&
          lv_newline.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
