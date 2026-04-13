CLASS zcl_zref_profile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS build_from_selection
      IMPORTING
        iv_profile_id          TYPE char30
        iv_package_name        TYPE devclass
        iv_include_subpackages TYPE abap_bool
        iv_preview_only        TYPE abap_bool
        iv_force_refresh       TYPE abap_bool
      RETURNING
        VALUE(rs_profile)      TYPE zif_zref_types=>ty_profile.
ENDCLASS.

CLASS zcl_zref_profile IMPLEMENTATION.

  METHOD build_from_selection.
    CLEAR rs_profile.

    rs_profile-profile_id          = iv_profile_id.
    rs_profile-package_name        = iv_package_name.
    rs_profile-include_subpackages = iv_include_subpackages.
    rs_profile-preview_only        = iv_preview_only.
    rs_profile-force_refresh       = iv_force_refresh.

    " TODO: Replace hardcoded placeholders with secure customizing lookup.
    rs_profile-gitlab_base_url = 'https://gitlab.example.corp'.
    rs_profile-project_id      = 'sap-ai-reference'.
    rs_profile-branch_name     = 'main'.
    rs_profile-repository_root = 'reference'.
    rs_profile-system_folder   = sy-sysid.
    rs_profile-token_alias     = 'DEFAULT'.
  ENDMETHOD.

ENDCLASS.
