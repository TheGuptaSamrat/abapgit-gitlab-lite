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
    METHODS build_commit_message
      IMPORTING
        is_profile        TYPE zif_zref_types=>ty_profile
        it_object_bundles TYPE zif_zref_types=>ty_object_bundle_tt
      RETURNING
        VALUE(rv_text)    TYPE string.
ENDCLASS.

CLASS zcl_zref_gitlab_client IMPLEMENTATION.

  METHOD build_commit_message.
    rv_text = |SAP reference refresh { sy-sysid }/{ sy-mandt } package { is_profile-package_name } ({ lines( it_object_bundles ) } objects)|.
  ENDMETHOD.

  METHOD publish_refresh.
    DATA lv_message TYPE string.

    lv_message = build_commit_message(
      is_profile        = is_profile
      it_object_bundles = it_object_bundles ).

    io_log->add_info(
      iv_category = 'PUBLISH'
      iv_object   = is_profile-project_id
      iv_message  = |Prepared GitLab commit: { lv_message }| ).

    " TODO: Implement HTTPS client + GitLab commit API interaction.
    " Expected flow:
    " 1. Resolve token from secure config by alias
    " 2. Build create/update commit actions
    " 3. Submit one commit request
    " 4. Return resulting commit id
    rv_commit = 'TODO_COMMIT_ID'.
  ENDMETHOD.

ENDCLASS.
