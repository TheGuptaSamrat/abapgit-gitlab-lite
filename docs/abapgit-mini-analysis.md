# abapGit Mini Analysis

## 1. What Was Set Up

- GitHub working repo: `https://github.com/TheGuptaSamrat/abapgit-gitlab-lite`
- GitHub fork for source study: `https://github.com/TheGuptaSamrat/abapGit`
- Local source reference checked out from fork commit `3241ed0a`

## 2. What abapGit Is Doing Architecturally

From the checked-out `abapGit` source, the main building blocks are:

- Main UI/report shell in `zabapgit.prog.abap`
- Repository abstraction and refresh/state handling in `src/repo/zcl_abapgit_repo.clas.abap`
- Object discovery and local serialization orchestration in `src/objects/core/zcl_abapgit_serialize.clas.abap`
- Object-type-specific serializers in `src/objects/...`
- Git pack/push/pull logic in `src/git/zcl_abapgit_git_porcelain.clas.abap`
- HTTP transport handling in `src/http/zcl_abapgit_http_client.clas.abap`
- Staging model in `src/repo/stage/zcl_abapgit_stage.clas.abap`
- Persistence, settings, favorites, labels, and UI flows in several `persist`, `ui`, `background`, and `git_platform` packages

## 3. What Matters Most For Our Mini Version

The most reusable ideas for our scenario are:

1. TADIR/package-based object discovery
2. Object serializer-per-type pattern
3. File-oriented output with deterministic names
4. Status/checksum thinking to avoid needless exports
5. HTTP-based Git transport patterns

The parts that are much less important for us:

1. Full interactive UI
2. Pull/clone/deserialize from Git back into SAP
3. Branch and tag administration
4. Merge conflict handling
5. Favorites, labels, repo registry, background jobs, transport-to-branch flows

## 4. Recommended Product Direction

Build a focused export utility rather than a reduced clone of all abapGit behavior.

Recommended product statement:

> "Export selected custom ABAP repository objects into a readable GitLab repository structure that downstream AI skill packs can index and use as reference material."

## 5. Recommended MVP Scope

### 5.1 Core user flow

1. User runs an ABAP report
2. User selects package, subpackage mode, object filters, and target GitLab project/branch
3. Report reads custom objects from TADIR
4. Report serializes supported objects into text/XML/JSON files
5. Report builds a manifest with metadata and checksums
6. Report pushes changed files to GitLab over HTTPS
7. Report shows export log and errors

### 5.2 First object types to support

Start with the highest-value custom object types for reuse/reference:

- `CLAS`
- `INTF`
- `PROG`
- `FUGR`
- `DTEL`
- `DOMA`
- `TABL`
- `TTYP`
- `VIEW` or CDS-related objects if your landscape uses them heavily

Optional early additions:

- `MSAG`
- `XSLT`
- `ENHO`/`ENHC`
- `DDLS`

### 5.3 Output model

Use a predictable repository structure such as:

```text
/manifest/export-run.json
/objects/CLAS/ZCL_MY_CLASS/
/objects/INTF/ZIF_MY_API/
/objects/PROG/ZMY_REPORT/
/objects/DTEL/ZMY_FIELD/
/objects/DOMA/ZMY_DOMAIN/
/objects/TABL/ZMY_TABLE/
```

Each object folder should contain:

- source file(s)
- metadata file
- object summary for AI usage

Example:

```text
/objects/CLAS/ZCL_MY_CLASS/source.abap
/objects/CLAS/ZCL_MY_CLASS/metadata.json
/objects/CLAS/ZCL_MY_CLASS/object.xml
```

## 6. Proposed Technical Design

### 6.1 ABAP components

- `ZABAPGIT_GL_EXPORT`
  Executable report and selection screen

- `ZCL_ZAGL_CONFIG`
  Reads target GitLab URL, branch, token alias, package defaults

- `ZCL_ZAGL_OBJECT_COLLECTOR`
  Reads TADIR and builds filtered export list

- `ZCL_ZAGL_SERIALIZER`
  Main serialization coordinator

- `ZIF_ZAGL_OBJECT_HANDLER`
  Interface for object-type-specific serializers

- `ZCL_ZAGL_OBJ_CLAS`, `..._INTF`, `..._PROG`, `..._DTEL`, `..._DOMA`, `..._TABL`
  Object handlers

- `ZCL_ZAGL_MANIFEST`
  Builds export manifest, checksums, timestamps, package/object inventory

- `ZCL_ZAGL_GITLAB_CLIENT`
  HTTPS client for GitLab repository write APIs

- `ZCL_ZAGL_LOG`
  Application log + export result summary

### 6.2 GitLab write strategy

Preferred approach for the MVP:

- use GitLab REST API over HTTPS,
- commit files directly through the API,
- avoid implementing full raw Git pack protocol at first.

Why this is better than copying abapGit push logic first:

- simpler to secure,
- easier to debug in a corporate network,
- better fit for limited infrastructure access,
- no need to fully reproduce low-level Git behavior in phase 1.

## 7. Feature Categorization By Feasibility

This is the key view for your environment.

### A. Feasible now with developer-only access

- ABAP report selection screen
- package or explicit object list export
- custom object filtering
- serializer framework for selected object types
- readable repository folder structure
- JSON/XML metadata files
- manifest generation
- export logs and error summary
- dry run mode
- checksum calculation inside ABAP
- export only changed objects if prior manifest/checksums are stored
- skill-pack-friendly summary files per object

### B. Feasible if HTTPS to GitLab can be set up

- direct push to GitLab through REST API
- branch-specific export
- personal access token or project token based auth
- repository bootstrap if branch exists already
- commit message conventions
- commit one run as one atomic export
- optional pull of existing manifest for delta comparison

### C. Feasible but higher effort, still possible without Basis-heavy setup

- support for many additional ABAP object types
- object dependency manifest
- package-level incremental export optimization
- branch-per-feature export mode
- object-level diff summary in report output
- structured run history in custom tables
- selective export profiles by team/domain
- AI-focused summaries and embeddings-ready sidecar files

### D. Not recommended in phase 1

- full `clone/pull/deserialize` from Git back into SAP
- full raw Git protocol implementation
- merge resolution inside SAP
- branch and tag management UI
- generic support for all abapGit-supported object types
- complete abapGit-style repository registry/favorites UI
- transport request to git branch automation

### E. Likely blocked or risky in a corporate no-Basis model

- anything that depends on broad ICM/SSL/proxy changes outside what is already allowed
- heavy background scheduling/infrastructure assumptions
- inbound webhook/event-based server integration
- system-wide trust configuration changes without Basis support
- large-scale bi-directional synchronization with conflict handling

## 8. Original abapGit Functionalities To Choose From

Below is the longer menu from original abapGit, translated into our decision frame.

### Strong candidates for our mini product

- package scanning and object discovery
- supported object type registry
- per-object serialization
- readable repository file naming
- checksum/status calculation
- logging and error handling
- remote HTTP abstraction patterns

### Optional candidates if you want a richer exporter

- ignore/exclusion rules similar to `.abapgit`
- multilingual text handling
- package hierarchy awareness
- object activation order awareness
- parallel serialization
- ZIP export as an alternative to direct GitLab push

### Probably unnecessary for our use case

- online repo registry inside SAP
- offline repo concept
- favorites and labels
- branch/tag creation and deletion
- pull request enumeration
- full staging UI
- advanced diff UI
- transport integration flows
- background pull jobs
- end-user HTML UI pages

### Usually out of scope unless strategy changes

- import from Git into SAP
- conflict handling and merge support
- full bidirectional Git client behavior

## 9. Suggested Delivery Phases

### Phase 0: technical spike

- prove outbound HTTPS to GitLab
- prove one file commit through GitLab API
- prove object discovery for one custom package
- prove serialization for `CLAS`, `PROG`, `DTEL`

### Phase 1: MVP

- report-based export
- support 5 to 8 core object types
- manifest and checksum
- branch commit to GitLab
- run log and error handling

### Phase 2: quality and scale

- incremental export
- richer metadata
- dependency summaries
- more object types
- export profiles by package/team

### Phase 3: AI-optimized reference repo

- object summaries for prompts
- domain tagging
- enhancement history notes
- cross-object relationship manifests
- optional skill-pack-specific derived outputs

## 10. Recommended First Build Target

If we want the fastest path to value, the first implementation should be:

> An ABAP report that exports `CLAS`, `INTF`, `PROG`, `DTEL`, `DOMA`, and `TABL` from a chosen custom package to a GitLab branch over HTTPS, with manifest and checksum support.

That gets you a useful reference repository without trying to reproduce all of abapGit.

## 11. Decisions To Make Next

Please choose:

1. Push method:
   `GitLab REST commit API` or `full Git protocol later`

2. Initial object list:
   narrow `CLAS/INTF/PROG/DTEL/DOMA/TABL` or broader

3. Export target:
   one repository per SAP system/domain or one consolidated repository

4. Delta behavior:
   full export every run or checksum-based changed-only export

5. Metadata depth:
   minimal manifest only or AI-oriented sidecar summaries too
