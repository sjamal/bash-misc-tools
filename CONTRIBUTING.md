# Contributing

## Purpose

This repository is small, but changes still benefit from a predictable workflow. The goal is to keep standalone utility scripts easy to review, easy to test, and easy to trace in version control.

Scripts are organized by domain under `network/`, `certificates/`, `files/`, and `data/`. New utilities should be added to the closest matching folder. A new top-level folder should be introduced only when an existing category is no longer a reasonable fit.

## Branch Model

- `main` should represent the stable published state.
- `develop` should be the default integration branch for upcoming changes.
- Short-lived feature branches should be created from `develop`.

Recommended branch naming examples:

- `feature/add-connectivity-docs`
- `fix/quote-file-arguments`
- `docs/update-readme`

## Change Process

1. Update the local repository and switch to `develop`.
2. Create a focused feature branch from `develop`.
3. Keep the branch scoped to one logical change set.
4. Run lightweight validation appropriate to the scripts that changed.
5. Open a pull request into `develop`.
6. Merge into `main` only after the `develop` change is reviewed and considered stable.

## Commit Expectations

- Use small, descriptive commits.
- Keep unrelated cleanup out of the same commit when possible.
- Update documentation when adding, renaming, or materially changing a script.

Example commit subjects:

- `Add TCP connectivity check script`
- `Document certificate helper scripts`
- `Harden connectivity script argument handling`

## Review Guidance

Reviews should check the following:

- Whether shell arguments are quoted correctly
- Whether external command dependencies are documented
- Whether file-modifying behavior is explicit
- Whether operational assumptions are stated in the README or script header

## Merge Strategy

- Squash merging is appropriate for most small branches in this repository.
- Preserve a clear pull request title and summary so the squash commit remains meaningful.
- Rebase or merge from `develop` before final merge if the branch has drifted.

## Script Organization

Keep the domain-based layout intact when adding or moving scripts. If a script depends on a non-obvious environment, include that assumption in the script header and in the top-level README entry.