# Prerequisites and Setup

## Short Answer

This can be implemented **mostly** by a developer, but **not always fully with
developer access alone**.

### Usually possible with developer access

- create the ABAP report, interfaces, and classes
- implement object collection and serialization logic
- implement preview mode
- generate manifests, summaries, and publish actions
- test internal ABAP logic that does not require external connectivity

### Usually not guaranteed with developer access alone

- outbound HTTPS connectivity from SAP application server to corporate GitLab
- SSL certificate trust if GitLab certificate chain is not already trusted
- proxy/network routing if corporate traffic requires it
- secure storage and governance of the GitLab token
- any SM59 or security setup if your company requires it

## What Must Be True Before End-to-End Publish Works

1. SAP application server must be able to reach the GitLab URL over HTTPS
2. GitLab certificate chain must be trusted by SAP
3. A GitLab project or group token must exist and be approved
4. The SAP-side token storage approach must be accepted
5. The target GitLab repository and branch must already exist

## Setup Ownership Matrix

| Setup Item | Developer | Basis / Security | GitLab Owner |
|---|---|---|---|
| ABAP report/classes/interfaces | Yes | No | No |
| Object extraction logic | Yes | No | No |
| Preview mode and local testing | Yes | No | No |
| GitLab repository creation | Maybe | No | Yes |
| Project/group token creation | No | No | Yes |
| HTTPS reachability from SAP | Maybe | Yes | No |
| SSL trust / certificate handling | No | Yes | No |
| Proxy/network path | No | Yes | No |
| Secure token storage approval | Maybe | Yes | No |

## Recommended Setup Path

### Path A: You already have generic HTTPS outbound working

If your SAP system can already call corporate HTTPS endpoints and GitLab is
trusted, a developer can do almost everything else.

Steps:

1. Create the GitLab reference repository and branch
2. Create a GitLab project/group token with minimum required API write scope
3. Implement the ABAP exporter objects
4. Configure profile values:
   - GitLab base URL
   - project id/path
   - branch
   - repository root
   - token alias
5. Implement secure token lookup
6. Run preview mode from SAP GUI
7. Validate object selection, manifests, and artifact paths
8. Switch to publish mode
9. Validate files and commit in GitLab

### Path B: HTTPS and trust are not yet available

If SAP cannot yet call GitLab, developer work can continue only up to preview
and publish-action generation.

Additional steps needed:

1. Basis confirms outbound HTTPS to GitLab host from SAP app server
2. Basis/security confirms SSL trust chain
3. Basis confirms proxy routing if required
4. Developer retests with a lightweight connectivity call
5. Developer then enables real publish mode

## Detailed Step-by-Step Setup

### Step 1. Confirm target repository in GitLab

Owner:
- GitLab owner or team lead

Required:
- repository created
- default branch created, usually `main`
- repository visibility decided
- service account / token policy agreed

### Step 2. Create the GitLab token

Owner:
- GitLab owner

Recommended:
- project token or group token
- minimum required scope for API-based file commit
- not a personal token unless this is only a pilot

Developer dependency:
- token alias and usage contract
- not necessarily the raw token value itself if secure storage is delegated

### Step 3. Confirm SAP-to-GitLab connectivity

Owner:
- Basis / Security

Checks:
- DNS resolution for GitLab host
- outbound HTTPS reachability
- proxy path if required
- TLS handshake success

Without this, developer-only work can continue only in preview/simulation mode.

### Step 4. Confirm SSL trust

Owner:
- Basis / Security

Checks:
- GitLab certificate chain trusted by SAP
- no TLS error on outbound call

Without this, real publish will fail even if ABAP code is correct.

### Step 5. Decide SAP-side token storage

Owner:
- Developer plus Security

Options:
- protected customizing table
- protected parameter storage
- destination/credential pattern if allowed in your landscape

Recommendation:
- use a small protected config object with authorization checks and no token
  exposure in logs

### Step 6. Create ABAP development objects

Owner:
- Developer

Objects to create:
- `ZABAPREF_EXPORT`
- `ZIF_ZREF_TYPES`
- `ZIF_ZREF_OBJECT_HANDLER`
- profile, collector, serializer, manifest, log, GitLab client classes
- first object handlers for `CLAS`, `INTF`, `PROG`, `DTEL`, `DOMA`, `TABL`

### Step 7. Implement preview mode first

Owner:
- Developer

Preview mode should:
- collect objects
- build export bundles
- build metadata and summaries
- build manifest and indexes
- show what would be published
- not call GitLab

This is the safest point to validate logic with developer access only.

### Step 8. Validate artifact shape

Owner:
- Developer

Check:
- object folders are stable and readable
- `metadata.json` exists
- `summary.md` exists
- source or definition file exists
- object and package indexes look correct
- manifest is valid JSON

### Step 9. Implement and test publish mode

Owner:
- Developer after connectivity is confirmed

Publish mode should:
- resolve token securely
- build GitLab commit payload
- submit one commit per refresh
- log success or failure without exposing secrets

### Step 10. Run a controlled first publish

Owner:
- Developer

Recommended first publish scope:
- one small custom package
- preview first
- then publish
- validate commit and file paths in GitLab

## Can This Be Done With Developer Access Only?

### Yes, if all of the following are already true

- SAP already has working outbound HTTPS
- GitLab certificate is already trusted
- no extra proxy setup is needed
- token storage approach is already accepted
- a GitLab token can be provisioned without additional admin work

### No, if any of the following are still missing

- HTTPS reachability is not available
- SSL trust is not available
- proxy path is not available
- secure secret storage is blocked
- token provisioning is blocked

## Practical Recommendation

Treat the work in two tracks:

### Developer-only track

- build and test object collection
- build and test artifact generation
- build and test preview mode
- build and test commit payload assembly

### Basis/Security dependency track

- confirm HTTPS connectivity
- confirm SSL trust
- confirm proxy path
- confirm secure token storage approach

This lets progress continue even if infrastructure approval takes longer.
