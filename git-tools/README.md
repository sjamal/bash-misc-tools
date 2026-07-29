# Bash Misc Tools

A collection of utility scripts for managing Git repositories, enforcing anonymous commit identities, standardizing workspace configurations, and maintaining clean history across GitHub projects.

---

## Utility Index

| Script | Description |
| :--- | :--- |
| **`init_repo.sh`** | Initializes a new repository with standardized folders, `.cursorrules`, anonymous identity from `~/.gitconfig-github`, and sets GitHub topics. |
| **`scrub_and_sync_repos.sh`** | Sweeps child Git repositories, rewrites commit logs using `git-filter-repo` to use anonymous credentials, re-links remotes, and force-pushes to GitHub. |

---

## `init_repo.sh`

Initializes a new local repository with standard directories (`src/`, `tests/`, `docs/`, `data/`), configures anonymous Git credentials, creates `.cursorrules` and `.gitignore`, and provisions a private GitHub repository with assigned topics.

### Usage
```bash
./init_repo.sh [OPTIONS] <repo_name>
```

### Options
-u, --user USER : GitHub username or organization (default: sjamal).

-t, --topics TOPICS : Comma-separated list of GitHub topics (default: python,ai,machine-learning).

-c, --config FILE : Path to identity gitconfig file (default: ~/.gitconfig-github).

-h, --help : Show help menu and usage details.

### Example
```bash
./init_repo.sh -t "python,llm,pytorch,transformers" llm-experiment
```

---

## `scrub_and_sync_repos.sh`

Iterates through all child Git repositories in the active directory, rewrites commit logs using git-filter-repo with anonymous identity from ~/.gitconfig-github, restores wiped origin remote URLs via gh CLI, and force-pushes all updated branches and tags.

### Usage

```bash
./scrub_and_sync_repos.sh [OPTIONS]
```

### Options

-c, --config FILE : Path to identity config file (default: ~/.gitconfig-github).

-u, --user USER : GitHub username for remote recovery (default: sjamal).

-p, --push : Force-push updated histories to GitHub (default: true).

--no-push : Scrub commit history locally without pushing to remote.

-h, --help : Show help menu and exit.

## Example
```bash
./scrub_and_sync_repos.sh --no-push
```

---

