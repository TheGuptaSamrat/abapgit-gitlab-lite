INTERFACE zif_zref_types PUBLIC.

  TYPES:
    BEGIN OF ty_object_key,
      obj_type TYPE tadir-object,
      obj_name TYPE tadir-obj_name,
      devclass TYPE tadir-devclass,
    END OF ty_object_key.

  TYPES ty_object_key_tt TYPE STANDARD TABLE OF ty_object_key WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_export_file,
      path         TYPE string,
      content_type TYPE string,
      text_content TYPE string,
      checksum     TYPE string,
      status       TYPE string,
    END OF ty_export_file.

  TYPES ty_export_file_tt TYPE STANDARD TABLE OF ty_export_file WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_object_bundle,
      object_key        TYPE ty_object_key,
      system_id         TYPE syst-sysid,
      client_id         TYPE mandt,
      changed_by        TYPE syuname,
      changed_at        TYPE timestampl,
      is_active         TYPE abap_bool,
      summary_markdown  TYPE string,
      metadata_json     TYPE string,
      relation_hint_csv TYPE string,
      files             TYPE ty_export_file_tt,
    END OF ty_object_bundle.

  TYPES ty_object_bundle_tt TYPE STANDARD TABLE OF ty_object_bundle WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_profile,
      profile_id          TYPE char30,
      gitlab_base_url     TYPE string,
      project_id          TYPE string,
      branch_name         TYPE string,
      repository_root     TYPE string,
      system_folder       TYPE string,
      token_alias         TYPE char30,
      package_name        TYPE devclass,
      include_subpackages TYPE abap_bool,
      preview_only        TYPE abap_bool,
      force_refresh       TYPE abap_bool,
    END OF ty_profile.

  TYPES:
    BEGIN OF ty_publish_action,
      action       TYPE string,
      file_path    TYPE string,
      content_type TYPE string,
      content      TYPE string,
    END OF ty_publish_action.

  TYPES ty_publish_action_tt TYPE STANDARD TABLE OF ty_publish_action WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_log_message,
      severity TYPE char1,
      category TYPE string,
      object   TYPE string,
      message  TYPE string,
    END OF ty_log_message.

  TYPES ty_log_message_tt TYPE STANDARD TABLE OF ty_log_message WITH DEFAULT KEY.

ENDINTERFACE.
