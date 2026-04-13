REPORT zabapref_export.

PARAMETERS p_prof TYPE char30 DEFAULT 'DEFAULT'.
PARAMETERS p_pack TYPE devclass OBLIGATORY.
PARAMETERS p_sub  AS CHECKBOX DEFAULT abap_false.
PARAMETERS p_prev AS CHECKBOX DEFAULT abap_true.
PARAMETERS p_full AS CHECKBOX DEFAULT abap_false.

START-OF-SELECTION.

  DATA ls_profile TYPE zif_zref_types=>ty_profile.
  DATA lt_keys    TYPE zif_zref_types=>ty_object_key_tt.
  DATA lt_bundles TYPE zif_zref_types=>ty_object_bundle_tt.
  DATA lt_msgs    TYPE zif_zref_types=>ty_log_message_tt.
  DATA lo_log     TYPE REF TO zcl_zref_log.
  DATA lo_coll    TYPE REF TO zcl_zref_object_collector.
  DATA lo_ser     TYPE REF TO zcl_zref_serializer.
  DATA lo_gitlab  TYPE REF TO zcl_zref_gitlab_client.
  DATA lv_commit  TYPE string.

  CREATE OBJECT lo_log.
  CREATE OBJECT lo_coll.
  CREATE OBJECT lo_ser.
  CREATE OBJECT lo_gitlab.

  ls_profile = zcl_zref_profile=>build_from_selection(
    iv_profile_id          = p_prof
    iv_package_name        = p_pack
    iv_include_subpackages = p_sub
    iv_preview_only        = p_prev
    iv_force_refresh       = p_full ).

  lt_keys = lo_coll->collect(
    is_profile = ls_profile
    io_log     = lo_log ).

  lt_bundles = lo_ser->serialize(
    it_object_keys = lt_keys
    io_log         = lo_log ).

  IF ls_profile-preview_only = abap_false.
    lv_commit = lo_gitlab->publish_refresh(
      is_profile        = ls_profile
      it_object_bundles = lt_bundles
      io_log            = lo_log ).

    WRITE: / 'GitLab commit id:', lv_commit.
  ELSE.
    WRITE: / 'Preview mode only. No GitLab publish executed.'.
  ENDIF.

  lt_msgs = lo_log->get_messages( ).
  LOOP AT lt_msgs ASSIGNING FIELD-SYMBOL(<ls_msg>).
    WRITE: / <ls_msg>-severity, <ls_msg>-category, <ls_msg>-object, <ls_msg>-message.
  ENDLOOP.
