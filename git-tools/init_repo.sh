#!/usr/bin/env bash
# ==============================================================================
# Script Name : init_repo.sh
# Description : Initializes a standardized Git project structure, applies 
#               anonymous GitHub identity from ~/.gitconfig-github, sets up 
#               AI guidelines (.cursorrules), creates remote repository on GitHub,
#               and assigns repository topics.
# Author      : sjamal
# ==============================================================================
#
# USAGE:
#   ./scripts/init_repo.sh [OPTIONS] <repo_name>
#
# OPTIONS:
#   -u, --user USER       GitHub username (default: "sjamal")
#   -t, --topics TOPICS   Comma-separated list of topics (e.g. "python,ai,llm")
#   -c, --config FILE     Path to gitconfig file (default: "$HOME/.gitconfig-github")
#   -h, --help            Show this help message and exit
#
# EXAMPLES:
#   ./scripts/init_repo.sh my-new-project
#   ./scripts/init_repo.sh -u sjamal -t "python,pytorch,llm" llm-tools
#   ./scripts/init_repo.sh -c ~/.gitconfig-personal -t "r,statistics" r-stats
# ==============================================================================

set -e

# --- Default Configurations ---
GITHUB_USER="sjamal"
GIT_CONFIG_FILE="$HOME/.gitconfig-github"
TOPICS="python,ai,machine-learning"
REPO_NAME=""

# --- Help Function ---
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <repo_name>

Initializes a new Git repository with standardized workspace structure, 
anonymous credentials, .cursorrules, and GitHub CLI settings.

Options:
  -u, --user USER       GitHub username/org (default: "$GITHUB_USER")
  -t, --topics TOPICS   Comma-separated GitHub topics (default: "$TOPICS")
  -c, --config FILE     Path to identity config file (default: "$GIT_CONFIG_FILE")
  -h, --help            Display this help menu and exit

Examples:
  $(basename "$0") llm-from-scratch
  $(basename "$0") -t "python,deep-learning,nlp" llm-experiment
  $(basename "$0") -u sjamal -c ~/.gitconfig-personal -t "r,stats" r-analysis

EOF
}

# --- Parse Command Line Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--user)
            GITHUB_USER="$2"
            shift 2
            ;;
        -t|--topics)
            TOPICS="$2"
            shift 2
            ;;
        -c|--config)
            GIT_CONFIG_FILE="$2"
            shift 2
            ;;
        -*)
            echo "❌ Error: Unknown option $1"
            echo "Run '$(basename "$0") --help' for usage."
            exit 1
            ;;
        *)
            REPO_NAME="$1"
            shift
            ;;
    esac
done

# --- Validate Required Arguments ---
if [ -z "$REPO_NAME" ]; then
    echo "❌ Error: Repository name is required."
    echo ""
    show_help
    exit 1
fi

# Fallback: Check ~/.gitconfig-personal if ~/.gitconfig-github does not exist
if [ ! -f "$GIT_CONFIG_FILE" ] && [ -f "$HOME/.gitconfig-personal" ]; then
    GIT_CONFIG_FILE="$HOME/.gitconfig-personal"
fi

# --- Load Identity from Git Config File ---
if [ -f "$GIT_CONFIG_FILE" ]; then
    echo "🔍 Reading identity from: $GIT_CONFIG_FILE"
    ANON_NAME=$(git config -f "$GIT_CONFIG_FILE" user.name || echo "")
    ANON_EMAIL=$(git config -f "$GIT_CONFIG_FILE" user.email || echo "")
else
    echo "⚠️  Warning: Config file $GIT_CONFIG_FILE not found. Falling back to global git settings."
    ANON_NAME=$(git config --global user.name || echo "sjamal")
    ANON_EMAIL=$(git config --global user.email || echo "12345678+sjamal@users.noreply.github.com")
fi

if [ -z "$ANON_NAME" ] || [ -z "$ANON_EMAIL" ]; then
    echo "❌ Error: Could not parse user.name or user.email from $GIT_CONFIG_FILE"
    exit 1
fi

echo "=================================================="
echo " 🚀 INITIALIZING REPOSITORY: ${REPO_NAME}"
echo "=================================================="
echo "Identity : $ANON_NAME <$ANON_EMAIL>"
echo "Owner    : $GITHUB_USER"
echo "Topics   : $TOPICS"
echo "--------------------------------------------------"

# --- Step 1: Create Directory Structure ---
echo "📁 Creating folder hierarchy..."
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"
mkdir -p src/ tests/ scripts/ docs/ data/ .github/prompts/

# --- Step 2: Create .gitignore ---
echo "📄 Writing .gitignore..."
cat << 'EOF' > .gitignore
# Personal & Local AI Notes / Prompts
.prompts
*.local.md

# Python Bytecode & Caches
__pycache__/
*.py[cod]
.pytest_cache/

# Virtual Environments
.venv/
venv/
ENV/

# Build & Distribution Artifacts
build/
dist/
*.egg-info/

# OS Specific Files
.DS_Store
Thumbs.db

# Personal IDE Settings
.vscode/
.idea/
*.swp
EOF

# --- Step 3: Create Workspace .cursorrules ---
echo "🤖 Writing .cursorrules..."
cat << 'EOF' > .cursorrules
# Project AI Guidelines

## Branching & Release Model
- Default Branch: `develop`
- Production Branch: `main`
- Workflow: Feature branches (`feature/<issue-desc>`) -> Merge to `develop` (`--no-ff`).

## Privacy & Security Rules
- NEVER include local absolute file paths, hostnames, or personal details in commits or docs.

## Code Standards
- Modular structure in `src/`, unit tests in `tests/` using `pytest`.
- Maintain technical specifications in `docs/ARCHITECTURE.md` and `docs/MATHEMATICS.md`.
EOF

# --- Step 4: Create Initial Documentation Files ---
touch docs/ARCHITECTURE.md docs/MATHEMATICS.md README.md src/__init__.py tests/__init__.py

# --- Step 5: Initialize Git & Local Identity ---
echo "⚙️  Initializing Git repository and setting local identity..."
git init -b main
git config local user.name "$ANON_NAME"
git config local user.email "$ANON_EMAIL"

git add .
git commit -m "chore: initialize project structure, .gitignore, and AI rules"

# --- Step 6: Create Develop Branch ---
git checkout -b develop

# --- Step 7: Create GitHub Repository & Assign Topics ---
if command -v gh &> /dev/null; then
    echo "🌐 Creating remote GitHub repository..."
    gh repo create "${GITHUB_USER}/${REPO_NAME}" --private --source=. --remote=origin --push || true
    
    echo "🔀 Setting default remote branch to develop..."
    gh repo edit "${GITHUB_USER}/${REPO_NAME}" --default-branch develop || true
    
    if [ -n "$TOPICS" ]; then
        echo "🏷️  Setting repository topics: ${TOPICS}..."
        gh repo edit "${GITHUB_USER}/${REPO_NAME}" --add-topic "${TOPICS}" || true
    fi
else
    echo "⚠️  gh CLI not detected. Skipping remote GitHub creation and topic assignment."
fi

echo "=================================================="
echo "🎉 Repository '${REPO_NAME}' initialized successfully!"
echo "Local Identity : $(git config user.name) <$(git config user.email)>"
echo "Active Branch  : $(git branch --show-current)"
echo "=================================================="
