CLASS zcl_zref_gitlab_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS publish_refresh
      IMPORTING
        is_profile        TYPE zif_zref_types=>ty_profile
        it_object_bundles TYPE zif_zref_types=>ty_object_bundle_tt
        io_log            TYPE REF TO zcl_zref_log
      RETURNING
        VALUE(rv_commit)  TYPE string
      RAISING
        cx_static_check.

  PRIVATE SECTION.
    METHODS build_publish_actions
      IMPORTING
        is_profile          TYPE zif_zref_types=>ty_profile
        it_object_bundles   TYPE zif_zref_types=>ty_object_bundle_tt
      RETURNING
        VALUE(rt_actions)   TYPE zif_zref_types=>ty_publish_action_tt.

    METHODS build_commit_message
      IMPORTING
        is_profile        TYPE zif_zref_types=>ty_profile
        it_object_bundles TYPE zif_zref_types=>ty_object_bundle_tt
      RETURNING
        VALUE(rv_text)    TYPE string.
ENDCLASS.

CLASS zcl_zref_gitlab_client IMPLEMENTATION.

  METHOD build_publish_actions.
    DATA lv_prefix TYPE string.
    DATA lv_json   TYPE string.
    DATA lv_csv    TYPE string.

    lv_prefix = |{ is_profile-repository_root }/systems/{ is_profile-system_folder }|.

    LOOP AT it_object_bundles ASSIGNING FIELD-SYMBOL(<ls_bundle>).
      LOOP AT <ls_bundle>-files ASSIGNING FIELD-SYMBOL(<ls_file>).
        APPEND VALUE zif_zref_types=>ty_publish_action(
          action       = 'upsert'
          file_path    = |{ lv_prefix }/{ <ls_file>-path }|
          content_type = <ls_file>-content_type
          content      = <ls_file>-text_content ) TO rt_actions.
      ENDLOOP.
    ENDLOOP.

    lv_json = zcl_zref_manifest=>build_latest_refresh_json(
      is_profile        = is_profile
      it_object_bundles = it_object_bundles ).

    APPEND VALUE zif_zref_types=>ty_publish_action(
      action       = 'upsert'
      file_path    = |{ lv_prefix }/manifests/latest-refresh.json|
      content_type = 'application/json'
      content      = lv_json ) TO rt_actions.

    lv_csv = zcl_zref_manifest=>build_object_index_csv( it_object_bundles ).
    APPEND VALUE zif_zref_types=>ty_publish_action(
      action       = 'upsert'
      file_path    = |{ lv_prefix }/indexes/object-index.csv|
      content_type = 'text/csv'
      content      = lv_csv ) TO rt_actions.

    lv_csv = zcl_zref_manifest=>build_package_index_csv( it_object_bundles ).
    APPEND VALUE zif_zref_types=>ty_publish_action(
      action       = 'upsert'
      file_path    = |{ lv_prefix }/indexes/package-index.csv|
      content_type = 'text/csv'
      content      = lv_csv ) TO rt_actions.
  ENDMETHOD.

  METHOD build_commit_message.
    rv_text = |SAP reference refresh { sy-sysid }/{ sy-mandt } package { is_profile-package_name } ({ lines( it_object_bundles ) } objects)|.
  ENDMETHOD.

  METHOD publish_refresh.
    DATA lt_actions TYPE zif_zref_types=>ty_publish_action_tt.
    DATA lv_message TYPE string.

    lv_message = build_commit_message(
      is_profile        = is_profile
      it_object_bundles = it_object_bundles ).

    lt_actions = build_publish_actions(
      is_profile        = is_profile
      it_object_bundles = it_object_bundles ).

    io_log->add_info(
      iv_category = 'PUBLISH'
      iv_object   = is_profile-project_id
      iv_message  = |Prepared GitLab commit: { lv_message } with { lines( lt_actions ) } actions| ).

    " TODO: Implement HTTPS client + GitLab commit API interaction.
    " Expected flow:
    " 1. Resolve token from secure config by alias
    " 2. Build create/update commit actions
    " 3. Submit one commit request
    " 4. Return resulting commit id
    rv_commit = 'TODO_COMMIT_ID'.
  ENDMETHOD.

ENDCLASS.
