# abapgit-gitlab-lite

Lightweight ABAP export utility for publishing a static GitLab reference repository
of custom SAP code and metadata for AI skill packs.

## Purpose

This project is not trying to replace version control or transport management.
It creates a readable reference repository that developers refresh manually when
they want AI-assisted support for:

- understanding existing custom developments,
- proposing fixes,
- suggesting enhancements,
- analyzing technical patterns and dependencies,
- giving better recommendations from skill packs like `abap` and `amdp`.

## Product Direction

- Source of truth: SAP system
- Reference target: corporate GitLab
- Runtime model: manual developer-triggered refresh
- Integration model: HTTPS + GitLab project/group token
- Export style: snapshot refresh with internal delta optimization
- Retention model: soft-retain old references by default

## Repository Contents

- `docs/`
  Architecture, comparison tables, one-pager, implementation guide
- `src/`
  ABAP report, interfaces, classes, and object-handler scaffolding

## Key Documents

- `docs/abapgit-mini-analysis.md`
- `docs/options-comparison.md`
- `docs/architecture-one-pager.md`
- `docs/implementation-guide.md`

## Initial ABAP Scope

The v1 scaffold targets these custom object types:

- `CLAS`
- `INTF`
- `PROG`
- `DTEL`
- `DOMA`
- `TABL`

## Current Status

This repository now contains:

- design and architecture documentation,
- an implementation scaffold for the ABAP exporter,
- ABAP class/interface boundaries for the first delivery slice.
