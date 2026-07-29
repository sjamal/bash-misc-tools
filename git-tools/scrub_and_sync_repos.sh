#!/usr/bin/env bash
# ==============================================================================
# Script Name : scrub_and_sync_repos.sh
# Description : Iterates through all child Git repositories in the current directory,
#               rewrites author identity across all history using git-filter-repo,
#               re-links remote origin URLs (via git or gh CLI), and force-pushes
#               the clean history to GitHub.
# Author      : sjamal
# ==============================================================================
#
# USAGE:
#   ./scrub_and_sync_repos.sh [OPTIONS]
#
# OPTIONS:
#   -c, --config FILE   Path to identity config file (default: "$HOME/.gitconfig-github")
#   -u, --user USER     GitHub username for URL recovery (default: "sjamal")
#   -p, --push          Force-push updated histories to GitHub (default: true)
#   --no-push           Skip force-pushing to GitHub after scrubbing
#   -h, --help          Show this help message and exit
#
# EXAMPLES:
#   ./scrub_and_sync_repos.sh
#   ./scrub_and_sync_repos.sh -c ~/.gitconfig-personal
#   ./scrub_and_sync_repos.sh --no-push
# ==============================================================================

set -e

# --- Default Configurations ---
GITHUB_USER="sjamal"
GIT_CONFIG_FILE="$HOME/.gitconfig-github"
FORCE_PUSH=true

# --- Help Function ---
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Scrub commit history across all child Git repositories to align author identity
with your anonymous GitHub profile, restore remotes, and force-push to GitHub.

Options:
  -c, --config FILE   Path to identity config file (default: "$GIT_CONFIG_FILE")
  -u, --user USER     GitHub username for remote recovery (default: "$GITHUB_USER")
  -p, --push          Force-push changes to GitHub (default: true)
  --no-push           Scrub locally without force-pushing to remote
  -h, --help          Display this help menu and exit

Examples:
  $(basename "$0")
  $(basename "$0") -c ~/.gitconfig-personal
  $(basename "$0") --no-push

EOF
}

# --- Parse Command Line Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--config)
            GIT_CONFIG_FILE="$2"
            shift 2
            ;;
        -u|--user)
            GITHUB_USER="$2"
            shift 2
            ;;
        -p|--push)
            FORCE_PUSH=true
            shift
            ;;
        --no-push)
            FORCE_PUSH=false
            shift
            ;;
        *)
            echo "❌ Error: Unknown option $1"
            echo "Run '$(basename "$0") --help' for usage."
            exit 1
            ;;
    esac
done

# --- Fallback Config File Check ---
if [ ! -f "$GIT_CONFIG_FILE" ] && [ -f "$HOME/.gitconfig-personal" ]; then
    GIT_CONFIG_FILE="$HOME/.gitconfig-personal"
fi

# --- Load Identity from Git Config File ---
if [ -f "$GIT_CONFIG_FILE" ]; then
    echo "🔍 Reading identity from: $GIT_CONFIG_FILE"
    TARGET_NAME=$(git config -f "$GIT_CONFIG_FILE" user.name || echo "")
    TARGET_EMAIL=$(git config -f "$GIT_CONFIG_FILE" user.email || echo "")
else
    echo "⚠️  Warning: Config file $GIT_CONFIG_FILE not found. Falling back to global git settings."
    TARGET_NAME=$(git config --global user.name || echo "sjamal")
    TARGET_EMAIL=$(git config --global user.email || echo "3092856+sjamal@users.noreply.github.com")
fi

if [ -z "$TARGET_NAME" ] || [ -z "$TARGET_EMAIL" ]; then
    echo "❌ Error: Could not parse user.name or user.email from $GIT_CONFIG_FILE"
    exit 1
fi

echo "=================================================="
echo " 🛡️  GIT IDENTITY SCRUB & REMOTE SYNC UTILITY"
echo "=================================================="
echo "Target Name : $TARGET_NAME"
echo "Target Email: $TARGET_EMAIL"
echo "Force Push  : $FORCE_PUSH"
echo "--------------------------------------------------"

# --- Main Repository Loop ---
for d in */.git; do
  # Skip loop if no matching directories exist
  [ -e "$d" ] || continue

  repo="${d%/.git}"
  echo ""
  echo "📂 REPO: $repo"

  # 1. Check working directory status
  uncommitted=$(git -C "$repo" status --porcelain)
  if [ -n "$uncommitted" ]; then
    echo "  ⚠️  Working tree has uncommitted changes:"
    echo "$uncommitted" | sed 's/^/      /'
    echo "  ⏳ Stashing tracked changes temporarily..."
    git -C "$repo" stash -m "Auto-stashed by scrub script"
    STASHED=true
  else
    echo "  ✅ Working tree: Clean"
    STASHED=false
  fi

  # 2. Capture existing remote origin URL before filter-repo wipes it
  ORIGIN_URL=$(git -C "$repo" remote get-url origin 2>/dev/null || echo "")
  if [ -n "$ORIGIN_URL" ]; then
    echo "  🔗 Captured remote origin: $ORIGIN_URL"
  else
    echo "  ⚠️  No remote origin URL found."
  fi

  # Fallback: If missing, recover via gh CLI using repo name or lowercase variant
  if [ -z "$ORIGIN_URL" ] && command -v gh &> /dev/null; then
    ORIGIN_URL=$(gh repo view "${GITHUB_USER}/$repo" --json url -q .url 2>/dev/null || echo "")
    
    if [ -z "$ORIGIN_URL" ]; then
      lower_repo=$(echo "$repo" | tr '[:upper:]' '[:lower:]')
      ORIGIN_URL=$(gh repo view "${GITHUB_USER}/$lower_repo" --json url -q .url 2>/dev/null || echo "")
    fi

    if [ -n "$ORIGIN_URL" ]; then
      echo "  🔍 Recovered remote URL from GitHub CLI: $ORIGIN_URL"
    fi
  fi

  # 3. Execute git-filter-repo to rewrite history
  echo "  🔄 Rewriting commit history..."
  (
    cd "$repo"
    git filter-repo --force \
      --name-callback "return b\"$TARGET_NAME\"" \
      --email-callback "return b\"$TARGET_EMAIL\""
  )

  # 4. Restore remote origin URL (since filter-repo strips remotes)
  if [ -n "$ORIGIN_URL" ]; then
    echo "  🔌 Restoring remote origin..."
    git -C "$repo" remote add origin "$ORIGIN_URL" 2>/dev/null || git -C "$repo" remote set-url origin "$ORIGIN_URL"
  fi

  # 5. Pop stashed changes if any were saved
  if [ "$STASHED" = true ]; then
    echo "  📦 Restoring stashed changes..."
    git -C "$repo" stash pop || echo "  ⚠️  Stash pop had conflicts. Please resolve manually in $repo."
  fi

  # 6. Verify final identities remaining in history
  unique_identities=$(git -C "$repo" log --all --format="     • %an <%ae>" | sort -u)
  echo "  👥 Current identities in log:"
  echo "$unique_identities"

  # 7. Force-push rewritten branches and tags to GitHub
  if [ "$FORCE_PUSH" = true ]; then
    if git -C "$repo" remote get-url origin &>/dev/null; then
      echo "  🚀 Force-pushing updated history to GitHub..."
      git -C "$repo" push origin --force --all
      git -C "$repo" push origin --force --tags || true
      echo "  ✅ GitHub fully updated for $repo!"
    else
      echo "  ⚠️  Skipping push: No valid remote origin found for $repo."
    fi
  else
    echo "  ⏸️  Skipping push: --no-push option specified."
  fi

  echo "  ✅ Finished processing $repo"
done

echo ""
echo "=================================================="
echo "🎉 Scrub and synchronization complete!"
echo "=================================================="
