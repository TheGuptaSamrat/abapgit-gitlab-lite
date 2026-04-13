INTERFACE zif_zref_object_handler PUBLIC.

  METHODS supports
    IMPORTING
      is_object_key    TYPE zif_zref_types=>ty_object_key
    RETURNING
      VALUE(rv_result) TYPE abap_bool.

  METHODS build_bundle
    IMPORTING
      is_object_key       TYPE zif_zref_types=>ty_object_key
    RETURNING
      VALUE(rs_bundle)    TYPE zif_zref_types=>ty_object_bundle
    RAISING
      cx_static_check.

ENDINTERFACE.
