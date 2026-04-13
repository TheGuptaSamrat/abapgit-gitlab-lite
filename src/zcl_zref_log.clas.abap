CLASS zcl_zref_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS add_info
      IMPORTING
        iv_category TYPE string
        iv_object   TYPE string
        iv_message  TYPE string.
    METHODS add_error
      IMPORTING
        iv_category TYPE string
        iv_object   TYPE string
        iv_message  TYPE string.
    METHODS get_messages
      RETURNING
        VALUE(rt_messages) TYPE zif_zref_types=>ty_log_message_tt.
    METHODS has_errors
      RETURNING
        VALUE(rv_result) TYPE abap_bool.

  PRIVATE SECTION.
    DATA mt_messages TYPE zif_zref_types=>ty_log_message_tt.
ENDCLASS.

CLASS zcl_zref_log IMPLEMENTATION.

  METHOD add_info.
    APPEND VALUE zif_zref_types=>ty_log_message(
      severity = 'I'
      category = iv_category
      object   = iv_object
      message  = iv_message ) TO mt_messages.
  ENDMETHOD.

  METHOD add_error.
    APPEND VALUE zif_zref_types=>ty_log_message(
      severity = 'E'
      category = iv_category
      object   = iv_object
      message  = iv_message ) TO mt_messages.
  ENDMETHOD.

  METHOD get_messages.
    rt_messages = mt_messages.
  ENDMETHOD.

  METHOD has_errors.
    rv_result = abap_false.
    READ TABLE mt_messages WITH KEY severity = 'E' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
