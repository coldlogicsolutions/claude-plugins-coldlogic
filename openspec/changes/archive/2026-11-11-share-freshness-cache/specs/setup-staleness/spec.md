## ADDED Requirements

### Requirement: The remote HEAD is cached for an hour, shared with the shell
The pin check SHALL use the cache file `.devenv/state/coldlogic-freshness` in the project, whose one line is `<epoch seconds> <remote> <rev>`, the format coldlogic-devenv's `coldlogic:setup-freshness` task uses. It SHALL skip `git ls-remote` only when the entry's remote is the lock's, its rev is the locked rev and it is under 3600 seconds old, and SHALL write the entry after each successful lookup.

Tested by: none (exercised by hand when this change was made).

#### Scenario: Fresh entry says the lock is current
- **WHEN** the cache holds an entry written 10 minutes ago for the lock's remote and the locked revision
- **THEN** the hook doesn't run `git ls-remote` and reports no finding for the pin

#### Scenario: Entry older than an hour
- **WHEN** the matching entry was written 2 hours ago
- **THEN** the hook runs `git ls-remote` and, on success, replaces the entry with the new time and `HEAD`

#### Scenario: Entry records a newer HEAD
- **WHEN** a fresh entry's rev differs from the locked revision
- **THEN** the hook ignores it and runs `git ls-remote`, so an update just made is never reported as behind from a stale entry

#### Scenario: Cache missing, malformed or unwritable
- **WHEN** the cache file is absent, its time isn't a number, or it can't be written
- **THEN** the hook runs `git ls-remote` as if there were no cache, and still exits 0
