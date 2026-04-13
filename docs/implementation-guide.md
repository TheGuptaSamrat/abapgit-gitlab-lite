# Implementation Guide

## Delivery Goal

Implement a small ABAP utility that exports selected custom objects into GitLab
as reference artifacts for AI skill packs.

## Scope

### In scope

- manual execution from SAP GUI
- package-based custom object discovery
- export of `CLAS`, `INTF`, `PROG`, `DTEL`, `DOMA`, `TABL`
- metadata, summaries, manifest, and indexes
- GitLab publish through REST API

### Out of scope

- import back into SAP
- transport management
- branch/merge workflows
- automatic scheduling
- raw Git protocol

## Implementation Steps

### 1. Report and profile layer

- build `ZABAPREF_EXPORT`
- provide simple selection-screen inputs:
  - profile
  - package
  - include subpackages
  - object type filter
  - preview mode
  - force refresh

### 2. Object collection

- read TADIR for selected package scope
- keep only supported custom objects
- log unsupported object types explicitly

### 3. Serialization

- route objects to handler classes by object type
- build one normalized export bundle per object
- normalize output to UTF-8

### 4. Artifact building

- emit `metadata.json`
- emit `summary.md`
- emit main source file
- build object, package, and relation indexes
- build refresh manifest

### 5. Delta and retention

- compare current artifacts to current GitLab baseline when available
- publish only changed files
- mark missing objects as inactive instead of deleting them

### 6. Publish

- use GitLab commit API
- send one commit per refresh
- mask token values from logs

## Artifact Rules

### `metadata.json`

Include:

- object identity
- package
- system and client
- exported files
- last changed by/at when available
- activation status when available
- refresh timestamp

### `summary.md`

Include:

- object purpose
- visible technical role
- important methods/structures/fields
- dependency hints
- likely enhancement points
- explicit assumptions

## Error Handling

Classify:

- collection error
- unsupported type
- serializer error
- metadata read error
- GitLab auth error
- GitLab write error
- SSL/proxy/network error

## Validation Checklist

- first-time publish works into empty repo
- repeated refresh without changes has low churn
- missing objects are soft-retained
- exported structure is readable without SAP access
- skill packs can use manifests, indexes, and summaries predictably
