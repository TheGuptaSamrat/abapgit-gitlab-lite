# Options Comparison

## Purpose

This table is the decision summary for the AI reference repository approach.

| Area | Option | Pros | Cons | Recommendation |
|---|---|---|---|---|
| Repository purpose | Static AI reference repo | Matches support and maintenance use case, easy for skill packs | Not a full change history product | Yes |
| Repository purpose | Development/version repo | Stronger lifecycle management | Confuses this tool with transport/version management | No |
| Refresh model | Manual developer refresh | Fits corporate setup, predictable, low operational overhead | Not always current | Yes |
| Refresh model | Scheduled automatic refresh | More current | Needs more basis/ops control and error handling | Later only |
| GitLab auth | Project/group token via API | Non-interactive, stable, shared utility model | Needs secure token storage | Yes |
| GitLab auth | User PAT via API | Easy for pilot | Person-dependent and harder to govern | Backup only |
| GitLab auth | Interactive SSO from SAP | User-specific | Complex and fragile in ABAP/SAP GUI | No |
| Git write model | GitLab REST commit API | Simple ABAP integration, easier diagnostics | Less Git-native than raw protocol | Yes |
| Git write model | Raw Git protocol | Closer to abapGit internals | High complexity and risk | No for v1 |
| Export behavior | Snapshot refresh with delta optimization | Keeps repo stable and efficient | Needs checksum logic | Yes |
| Export behavior | Full export every run | Simpler logic | Noisy commits and larger payloads | Optional fallback |
| Delete behavior | Soft-retain missing objects | Preserves reference value for AI | Repo grows over time | Yes |
| Delete behavior | Hard delete missing objects | Keeps repo tidy | Risk of losing useful reference context | No by default |
| Repository shape | One consolidated repo | Best for cross-skill search and discovery | Needs clear folder structure | Yes |
| Repository shape | Repo per system/domain | Better isolation | More maintenance overhead | Later if needed |

## Chosen Baseline

- Static AI reference repository
- Manual refresh
- GitLab project/group token
- GitLab REST commit API
- Snapshot refresh with delta optimization
- Soft-retention of missing objects
- One consolidated repository
