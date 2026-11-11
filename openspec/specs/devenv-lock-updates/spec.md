# devenv-lock-updates Specification

## Purpose
The `update-coldlogic-devenv` workflow keeps this repository's `coldlogic-devenv` pin, and the inputs the module asks projects to share with it, on the module's latest revision, proposed as a pull request from the coldlogic-ai App that merges itself once approved and green.

## Requirements

### Requirement: Updates run weekly, by hand and when the module moves
The workflow SHALL run on Mondays at 06:17 UTC, on `workflow_dispatch`, and on a `repository_dispatch` of type `coldlogic-devenv-updated`. A newer run on the same ref SHALL cancel one in progress.

Tested by: none.

#### Scenario: The module's main moves
- **WHEN** coldlogic-devenv's dispatch workflow sends `coldlogic-devenv-updated`
- **THEN** the workflow runs on `main`

#### Scenario: Two runs overlap
- **WHEN** a run starts while another on the same ref is in progress
- **THEN** the earlier run is cancelled

### Requirement: The update job runs devenv without secrets
A first job SHALL check out without persisted credentials, install Nix and devenv, run `devenv update coldlogic-devenv`, and upload only `devenv.lock` as an artifact kept for one day. It SHALL have read-only contents permission and no access to the App's secrets.

Tested by: none.

#### Scenario: Update job output
- **WHEN** the update job finishes
- **THEN** its only output is the `devenv-lock` artifact holding `devenv.lock`

### Requirement: Only main's copy opens the pull request
The job that opens the pull request SHALL run only when the ref is `refs/heads/main`, in the `coldlogic-ai` environment that holds `COLDLOGIC_AI_CLIENT_ID` and `COLDLOGIC_AI_PRIVATE_KEY`. On any other ref it SHALL be skipped, not failed.

Tested by: none.

#### Scenario: Run from a branch
- **WHEN** the workflow is dispatched on a feature branch
- **THEN** the update job runs and the pull-request job is skipped

### Requirement: The new revision is checked before it is used
The pull-request job SHALL take only `rev`, `narHash` and `lastModified` from the uploaded lock, and SHALL fail, opening no pull request, unless the revision is 40 hex characters; GitHub's compare of it with coldlogic-devenv's `main` is `identical` or `ahead`; the current pin is 40 hex characters; the compare of the pin with the revision is `identical` or `ahead`; `narHash` matches `sha256-<base64>`; and `lastModified` is 1 to 12 digits.

Tested by: none.

#### Scenario: Malformed revision
- **WHEN** the uploaded lock's `rev` isn't 40 lowercase hex characters
- **THEN** the job fails with `bad revision`

#### Scenario: Revision off main
- **WHEN** the uploaded lock names a revision that GitHub's compare with `main` reports as `diverged`
- **THEN** the job fails with `revision <rev> is not on coldlogic-devenv's main (diverged)`

#### Scenario: Revision ahead of main
- **WHEN** the uploaded revision is ahead of `main`, so the compare reports `behind`
- **THEN** the job fails with `revision <rev> is not on coldlogic-devenv's main (behind)`

#### Scenario: Malformed current pin
- **WHEN** the repository's own `devenv.lock` pins a `rev` that isn't 40 hex characters
- **THEN** the job fails with `bad current revision`

#### Scenario: Rollback
- **WHEN** the uploaded revision is behind the current pin
- **THEN** the job fails with `revision <rev> is behind the current pin <current> (behind)`

#### Scenario: Malformed hash or time
- **WHEN** the uploaded `narHash` isn't `sha256-` followed by base64, or `lastModified` isn't 1 to 12 digits
- **THEN** the job fails with `bad narHash` or `bad lastModified`

### Requirement: The new lock is the repository's own with three values replaced
The job SHALL build the new `devenv.lock` from the checked-out one, replacing only the `coldlogic-devenv` node's `rev`, `narHash` and `lastModified`, written without a trailing newline as devenv writes it, and SHALL discard the uploaded lock.

Tested by: none.

#### Scenario: Uploaded lock with other changes
- **WHEN** the uploaded lock also changed `nixpkgs`
- **THEN** that change is not taken from it

### Requirement: Shared inputs are aligned with the module's lock
For each of `nixpkgs`, `rust-overlay`, `git-hooks` and `devenv`, the job SHALL copy the `locked` entry from the module's `devenv.lock` at the new revision, read from GitHub, when both locks have it as a direct input declared the same way (same `original` and `follows` shape). Otherwise it SHALL leave the input alone and say so.

Tested by: none.

#### Scenario: Same declaration
- **WHEN** both locks declare `nixpkgs` from `github:NixOS/nixpkgs/nixpkgs-unstable`
- **THEN** the repository's `nixpkgs` node takes the module's locked revision

#### Scenario: Declared differently
- **WHEN** the repository declares `nixpkgs` from another branch
- **THEN** the job logs `nixpkgs: declared differently from the module's, left alone` and keeps it

### Requirement: The change is proposed as the App, with auto-merge
The job SHALL commit `devenv.lock` to `chore/update-coldlogic-devenv` as `coldlogic-ai[bot]` (`chore(devenv): update coldlogic-devenv`). When that branch differs from `main`, it SHALL open or refresh a ready pull request titled `Update coldlogic-devenv` with review requested from `derekjw`, and SHALL turn on squash auto-merge whenever the action outputs a pull request number. The workflow SHALL NOT close a pull request whose branch no longer differs from `main`.

Tested by: none.

#### Scenario: Pin moved
- **WHEN** the module's `main` is ahead of the pin and no update pull request is open
- **THEN** a pull request titled `Update coldlogic-devenv` is opened with auto-merge on, authored and committed by `coldlogic-ai[bot]`

#### Scenario: Update pull request already open
- **WHEN** an earlier run's pull request is still open and this run computes the same `devenv.lock`
- **THEN** the branch isn't pushed, but the action still outputs that pull request's number, refreshes it, and the auto-merge step runs again

#### Scenario: Already current
- **WHEN** the computed `devenv.lock` is the same as `main`'s
- **THEN** the action outputs no pull request number, no pull request is opened, and the auto-merge step is skipped
