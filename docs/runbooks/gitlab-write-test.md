# GitLab Write Test Runbook

## Purpose

This runbook explains how to perform the **first safe write test** from SAP to
GitLab using:

- SM59 destination: `ZTR_GITLAB_REPO`
- GitLab project ID: `388660`
- GitLab project token

The goal is to verify that SAP can create or update **one harmless scratch
file** through the GitLab API before the real exporter is wired to publish
reference artifacts.

## Safety Rules

This test is intentionally designed to avoid touching real reference content.

Use only:

- target branch: `main` only if your team accepts it for this scratch test,
  otherwise use a dedicated test branch
- scratch file path:

```text
reference/systems/<SYSID>/connectivity-test.txt
```

Example:

```text
reference/systems/DEV/connectivity-test.txt
```

Recommended content:

- short timestamped test line
- no business or production data

## Prerequisite Checks

Do this write test only after both of these succeeded:

1. project metadata read test returned `200`
2. branch metadata read test returned `200`

Those checks are documented in:

- `docs/runbooks/gitlab-auth-testing.md`

## What This Test Proves

If successful, this proves:

- the token has write-capable API permissions
- the destination can be used for authenticated GitLab write calls
- the project and branch are writable through the chosen auth model

## Current Known Values

Use these unless changed later:

- destination: `ZTR_GITLAB_REPO`
- project ID: `388660`
- branch: `main`

## GitLab API Endpoint For The Write Test

Use the GitLab commit API:

```text
/api/v4/projects/388660/repository/commits
```

This API supports creating one commit containing one or more file actions.

## Commit Payload Design

Use a single `create` or `update` action for one file only.

### First attempt

Use action:

```text
create
```

File path:

```text
reference/systems/<SYSID>/connectivity-test.txt
```

### If the file already exists

Repeat the test with action:

```text
update
```

That keeps the test idempotent.

## Exact Beginner Steps In SAP GUI

### Step 1. Open SE38

1. Log in to SAP GUI.
2. In the command field, enter `SE38`.
3. Press `Enter`.

### Step 2. Create a temporary write-test report

1. In the `Program` field, enter:

```text
ZTEST_GITLAB_WRITE
```

2. Click `Create`.
3. If prompted, fill:
   - Title: `GitLab Write Test`
   - Type: `Executable Program`
4. Save it according to your team practice.

### Step 3. Paste the ABAP sample

Paste this code into the report:

```abap
REPORT ztest_gitlab_write.

PARAMETERS p_dest TYPE rfcdest DEFAULT 'ZTR_GITLAB_REPO' OBLIGATORY.
PARAMETERS p_proj TYPE string LOWER CASE OBLIGATORY DEFAULT '388660'.
PARAMETERS p_tok  TYPE string LOWER CASE OBLIGATORY.
PARAMETERS p_br   TYPE string LOWER CASE DEFAULT 'main'.
PARAMETERS p_act  TYPE string LOWER CASE DEFAULT 'create'.

DATA: lo_client   TYPE REF TO if_http_client,
      lv_status   TYPE i,
      lv_reason   TYPE string,
      lv_body     TYPE string,
      lv_uri      TYPE string,
      lv_payload  TYPE string,
      lv_file     TYPE string,
      lv_message  TYPE string,
      lv_content  TYPE string,
      lv_ts       TYPE timestampl.

START-OF-SELECTION.

  GET TIME STAMP FIELD lv_ts.

  lv_file = |reference/systems/{ sy-sysid }/connectivity-test.txt|.
  lv_message = |SAP connectivity write test { sy-sysid }/{ sy-mandt }|.
  lv_content = |Connectivity write test from SAP system { sy-sysid } client { sy-mandt } at { lv_ts }|.

  lv_uri = |/api/v4/projects/{ p_proj }/repository/commits|.

  lv_payload =
    |{{| &&
    |"branch":"{ p_br }",| &&
    |"commit_message":"{ lv_message }",| &&
    |"actions":[{{| &&
    |"action":"{ p_act }",| &&
    |"file_path":"{ lv_file }",| &&
    |"content":"{ lv_content }"| &&
    |}}]| &&
    |}}|.

  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = p_dest
    IMPORTING
      client                   = lo_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.

  IF sy-subrc <> 0.
    WRITE: / 'create_by_destination failed:', sy-subrc.
    RETURN.
  ENDIF.

  lo_client->request->set_method( if_http_request=>co_request_method_post ).

  lo_client->request->set_header_field(
    name  = '~request_uri'
    value = lv_uri ).

  lo_client->request->set_header_field(
    name  = 'PRIVATE-TOKEN'
    value = p_tok ).

  lo_client->request->set_header_field(
    name  = 'Content-Type'
    value = 'application/json' ).

  lo_client->request->set_header_field(
    name  = 'Accept'
    value = 'application/json' ).

  lo_client->request->set_cdata( lv_payload ).

  CALL METHOD lo_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5.

  IF sy-subrc <> 0.
    lo_client->get_last_error(
      IMPORTING
        code    = DATA(lv_err_code_1)
        message = DATA(lv_err_msg_1) ).
    WRITE: / 'SEND failed:', lv_err_code_1, lv_err_msg_1.
    RETURN.
  ENDIF.

  CALL METHOD lo_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  IF sy-subrc <> 0.
    lo_client->get_last_error(
      IMPORTING
        code    = DATA(lv_err_code_2)
        message = DATA(lv_err_msg_2) ).
    WRITE: / 'RECEIVE failed:', lv_err_code_2, lv_err_msg_2.
    RETURN.
  ENDIF.

  lo_client->response->get_status(
    IMPORTING
      code   = lv_status
      reason = lv_reason ).

  lv_body = lo_client->response->get_cdata( ).

  WRITE: / 'HTTP status:', lv_status.
  WRITE: / 'Reason     :', lv_reason.
  WRITE: / 'Request URI:' , lv_uri.
  WRITE: / 'File path  :' , lv_file.
  WRITE: / 'Action     :' , p_act.
  WRITE: / 'Response   :'.
  WRITE: / lv_body(1000).

  lo_client->close( ).
```

## How To Execute The Write Test

### Step 4. Activate the report

1. Click `Activate`.
2. Ensure there are no syntax errors.

### Step 5. Run the first write attempt

1. Click `Execute`.
2. Fill these values:
   - `P_DEST = ZTR_GITLAB_REPO`
   - `P_PROJ = 388660`
   - `P_TOK = <your GitLab project token>`
   - `P_BR = main`
   - `P_ACT = create`
3. Execute.

## How To Interpret The Result

### If you get `201 Created`

This is the best result.

It means:

- write access works
- the token can create commits
- the destination and auth model are good for the exporter

Next action:

- open GitLab
- verify the file exists at:

```text
reference/systems/<SYSID>/connectivity-test.txt
```

### If you get `400 Bad Request`

Possible reasons:

- malformed JSON payload
- invalid branch
- invalid action

Action:

- check branch name
- check payload quoting
- check whether the endpoint path is correct

### If you get `401 Unauthorized`

Meaning:

- token invalid or expired

### If you get `403 Forbidden`

Meaning:

- token is recognized
- but write scope/permission is missing

### If you get `404 Not Found`

Meaning:

- wrong project id
- wrong endpoint path
- token cannot see the project

### If you get `409 Conflict`

Meaning:

- file already exists while using `create`

Action:

Run again with:

- `P_ACT = update`

### If you get `422 Unprocessable Entity`

Possible reasons:

- branch does not exist
- invalid file path
- invalid action content

## Recommended Retry Logic

Use this sequence:

1. First run with:
   - `P_ACT = create`
2. If file already exists and you get conflict:
   - rerun with `P_ACT = update`

Do not test on business files. Keep using only the connectivity test path.

## How To Verify In GitLab UI

1. Open the target GitLab project.
2. Click `Code`.
3. Browse to:

```text
reference
  /systems
    /<SYSID>
      /connectivity-test.txt
```

4. Confirm that:
   - the file exists
   - the commit message looks correct
   - only the scratch file changed

## Evidence To Capture

Record:

- destination used
- project id used
- branch used
- action used
- file path used
- HTTP status
- reason text
- first part of the response body
- GitLab commit id if visible in the response

## Success Criteria

You can consider write access validated when:

1. read test for project metadata returned `200`
2. read test for branch metadata returned `200`
3. write test returned `201` or successful equivalent
4. the scratch file is visible in GitLab

## After This Test

Once this succeeds, the next implementation step is to update the exporter
scaffold so `ZCL_ZREF_GITLAB_CLIENT` uses:

- destination `ZTR_GITLAB_REPO`
- project `388660`
- GitLab commit API payload assembly
- manifest/index/object file actions

instead of the current placeholder logic.
