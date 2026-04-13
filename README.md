# abapgit-gitlab-lite

Mini corporate-friendly ABAP export tool inspired by `abapGit`.

## Goal

Build a lightweight ABAP report-based solution that:

- discovers selected custom ABAP objects from a package or explicit object list,
- serializes them into readable text files,
- pushes the export to a GitLab repository over HTTPS,
- creates a stable reference repository for AI skill packs and future enhancement work.

## Why A Mini Version

The original `abapGit` is a full Git client for ABAP systems. Our environment is more constrained:

- we can build ABAP reports and classes,
- we may be able to configure outbound HTTPS to GitLab,
- we do not have broad Basis/admin freedom in the corporate landscape.

That makes a one-way export tool a better fit than a full clone/pull/push UI.

## Current Decisions

- Direction: one-way `SAP -> GitLab`
- Initial target: custom development objects only
- Initial delivery model: executable ABAP report plus helper classes
- Git connectivity: HTTPS only

## Next Document

Detailed analysis, MVP scope, and feature categorization are in
`docs/abapgit-mini-analysis.md`.
