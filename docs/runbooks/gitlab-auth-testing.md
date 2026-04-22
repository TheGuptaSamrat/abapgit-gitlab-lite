# GitLab Auth Testing Runbook

## Purpose

This runbook explains how to:

1. find the GitLab project identifier from the UI,
2. choose between numeric project ID and URL-encoded project path,
3. test GitLab API authentication from SAP using the existing SM59 destination,
4. interpret the result.

Use this runbook when validating that the SAP exporter can authenticate to the
target GitLab repository through `ZTR_GITLAB_REPO`.

## Recommended Choice

Use the **numeric GitLab project ID** whenever possible.

Why:

- no encoding mistakes
- simpler ABAP test input
- more stable than manually encoded path values

Use URL-encoded path only if your team explicitly prefers it.

## Part 1: Find the Project ID in GitLab UI

### Exact UI clicks

1. Log in to GitLab.
2. In the left navigation, click `Search or go to`.
3. Open the target project.
4. In the project left menu, click `Settings`.
5. Under `Settings`, click `General`.
6. Stay on the `General` page and look near the top section of project details.
7. Find `Project ID`.
8. Copy the numeric value.

Example:

- `Project ID: 12345`

That means your API path can use:

```text
/api/v4/projects/12345
```

## Part 2: Find the Raw Project Path in GitLab UI

If you still want the path form:

### Exact UI clicks

1. Log in to GitLab.
2. Open the target project.
3. Look at the browser URL.

Example:

```text
https://gitlab.company.com/corp/platform/sap-ai-reference
```

The raw project path is:

```text
corp/platform/sap-ai-reference
```

You can also confirm it from the breadcrumb or from:

1. `Settings`
2. `General`
3. `Advanced`
4. `Change path`

Do not change anything there. Just read the current path.

## Part 3: Convert Raw Project Path to URL-Encoded Project Path

Replace each `/` with `%2F`.

Example:

```text
corp/platform/sap-ai-reference
```

becomes:

```text
corp%2Fplatform%2Fsap-ai-reference
```

Then the API path becomes:

```text
/api/v4/projects/corp%2Fplatform%2Fsap-ai-reference
```

## Part 4: What You Need Before SAP Testing

Make sure you have all of the following:

- SM59 destination: `ZTR_GITLAB_REPO`
- GitLab project token or group token
- project ID or URL-encoded path
- branch name, usually `main`

## Part 5: Safest API Test Sequence

Run the tests in this exact order.

### Test 1: Project metadata

This is the safest first test because it avoids branch-name mistakes.

Endpoint:

```text
/api/v4/projects/<project-id>
```

or

```text
/api/v4/projects/<url-encoded-project-path>
```

Expected success:

- `200 OK`

What it proves:

- token is accepted
- project is visible
- destination and auth setup are working

### Test 2: Branch metadata

Only do this after Test 1 succeeds.

Endpoint:

```text
/api/v4/projects/<project-id>/repository/branches/main
```

Expected success:

- `200 OK`

What it proves:

- token can read repository metadata
- branch is visible
- repo-level access is good

## Part 6: SAP Execution Steps

### Option A: Temporary ABAP report

Create a small temporary report such as `ZTEST_GITLAB_AUTH`.

Use these inputs:

- destination = `ZTR_GITLAB_REPO`
- project = numeric project ID preferred
- token = GitLab project/group token
- branch = `main`

### ABAP sample

```abap
REPORT ztest_gitlab_auth.

PARAMETERS p_dest TYPE rfcdest DEFAULT 'ZTR_GITLAB_REPO' OBLIGATORY.
PARAMETERS p_proj TYPE string LOWER CASE OBLIGATORY.
PARAMETERS p_tok  TYPE string LOWER CASE OBLIGATORY.
PARAMETERS p_br   TYPE string LOWER CASE DEFAULT 'main'.

DATA: lo_client TYPE REF TO if_http_client,
      lv_status TYPE i,
      lv_reason TYPE string,
      lv_body   TYPE string,
      lv_uri    TYPE string.

START-OF-SELECTION.

  lv_uri = |/api/v4/projects/{ p_proj }|.

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

  lo_client->request->set_method( if_http_request=>co_request_method_get ).

  lo_client->request->set_header_field(
    name  = '~request_uri'
    value = lv_uri ).

  lo_client->request->set_header_field(
    name  = 'PRIVATE-TOKEN'
    value = p_tok ).

  lo_client->request->set_header_field(
    name  = 'Accept'
    value = 'application/json' ).

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
  WRITE: / 'Response   :'.
  WRITE: / lv_body(500).

  lo_client->close( ).
```

## Part 7: How to Run the ABAP Test

1. Open `SE38`.
2. Create or open `ZTEST_GITLAB_AUTH`.
3. Paste the sample code.
4. Activate it.
5. Execute it.
6. Fill:
   - `P_DEST = ZTR_GITLAB_REPO`
   - `P_PROJ = <project ID>` preferred
   - `P_TOK = <GitLab token>`
7. Execute.

If Test 1 succeeds, change this line:

```abap
lv_uri = |/api/v4/projects/{ p_proj }|.
```

to:

```abap
lv_uri = |/api/v4/projects/{ p_proj }/repository/branches/{ p_br }|.
```

Then re-run to validate branch access.

## Part 8: Result Interpretation

### `200 OK`

Meaning:

- destination works
- token works
- project is readable
- you are ready to move toward real exporter integration

### `401 Unauthorized`

Meaning:

- token is invalid
- token expired
- wrong token type
- wrong header style

Action:

- verify token value
- reissue token if needed
- confirm `PRIVATE-TOKEN` header is accepted

### `403 Forbidden`

Meaning:

- token is recognized
- but it does not have sufficient scope or permission

Action:

- confirm API/repository read permission on the token

### `404 Not Found`

Meaning:

- wrong project ID
- wrong encoded path
- wrong branch
- token cannot see the project

Action:

- retry using numeric project ID
- confirm branch name

### `SEND failed` or `RECEIVE failed`

Meaning:

- connectivity, proxy, TLS, or destination issue

Action:

- recheck destination
- involve Basis if this starts happening after the earlier HTTP 200 test

## Part 9: Evidence to Capture

Record all of these:

- project ID used
- endpoint used
- HTTP status
- reason text
- first 200 to 500 characters of response

This gives enough evidence to troubleshoot without repeating all steps.

## Part 10: Ready-for-Implementation Criteria

You are ready to wire `ZTR_GITLAB_REPO` into the exporter when both succeed:

1. project metadata returns `200`
2. branch metadata returns `200`

At that point the next safe step is a controlled write test to a scratch file path.
