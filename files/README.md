# Tree-to-Workspace Generator

A lightweight, defensive Bash/Zsh script to convert a plaintext folder/file tree visualization into an actual physical directory layout on your system.

## Features

- **Conflict Prevention**: Never overwrites existing work. It skips existing items safely.
- **Conflict Highlighting**: Explicitly flags structural conflicts (e.g., if a name exists as a file, but your tree file tries to place it as a directory).
- **Format-Aware**: Uses trailing slashes (`/`) to distinguish files from folders, ensuring extensionless files like `LICENSE` or `.env` are generated correctly.
- **Custom Targets**: Supports generating structures inside specific directories without altering your terminal's current location.

---

## Setup

1. Save the generator script as `recreate_tree.sh`.
2. Give it execution permissions:
   ```bash
   chmod +x recreate_tree.sh
   ```
3. Save your targeted tree layout into a plaintext file (e.g., `structure.txt`).

---

## Usage Examples

### Example 1: Standard Execution (Current Directory)
To build the project tree directly inside your active working directory:

```bash
./recreate_tree.sh < structure.txt
```

### Example 2: Target Execution (Specific Folder)
To build the tree somewhere else safely (e.g., a scratchpad directory on your Desktop), use the `-t` option. The script will dynamically handle or generate that destination directory for you:

```bash
./recreate_tree.sh -t ~/Desktop/new-project < structure.txt
```

### Example 3: Handling Conflicts (Demonstration)
If you run the script a second time on the same `structure.txt` file, or run it in a space where files already exist, the script stops actions on those nodes and logs information safely:

```text
ℹ️  [SKIPPED] Folder already exists: /Users/dev/llm-from-scratch/.github
ℹ️  [SKIPPED] File already exists: /Users/dev/llm-from-scratch/.github/workflows/ci.yml
⚠️  [CONFLICT] Name exists as FILE but tree expects FOLDER: /Users/dev/llm-from-scratch/tests

🎯 Execution complete. Items Created: 0 | Items Skipped/Conflicted: 3
```

---

## Expected Tree Syntax Structure

The script is built specifically around standard `tree` output mapping blocks where paths use spacing indents of **4 spaces** per level and mark directories cleanly with a trailing `/`:

```text
my-app/
├── src/
│   ├── main.py
│   └── utils.py
├── LICENSE
└── README.md
```

---

To undo the changes and completely remove the files and folders that were just created, you can run a dry-run first to see what will be deleted, and then execute the actual cleanup.Since the original script always prints exact lines starting with 📁 [CREATED] Folder: and 📄 [CREATED] File:, you can parse your script's output (or feed the tree file into a modified command) to selectively remove only the items that were just created, without touching your other files.Here is the safest way to back out your changes.Step 1: Preview what will be deleted (Dry Run)Run your tree file back through the script, but filter out the [CREATED] lines and print them. This lets you double-check exactly what is about to be deleted:
```bash 
bash-misc-tools/files/recreate_tree.sh < tree.txt | grep "\[CREATED\]" | awk '{print $NF}'
```

Use code with caution.(Replace tree.txt with the actual name of your input text file).Step 2: Delete the created files and foldersIf the preview looks correct, run this command. It will read the paths created by your script and safely delete them (files first, then empty folders):bash# 1. Delete all the created files
```bash 
bash-misc-tools/files/recreate_tree.sh < tree.txt | grep "📄 \[CREATED\]" | awk '{print $NF}' | xargs rm -f
```

# 2. Delete the created folders (only if they are empty)
```bash 
bash-misc-tools/files/recreate_tree.sh < tree.txt | grep "📁 \[CREATED\]" | awk '{print $NF}' | sort -r | xargs rmdir 2>/dev/null
```

Use code with caution.Why this approach is safe:rm -f targeted only the explicit files output by the script.sort -r reverses the folder list so that the deepest subfolders are deleted first.rmdir is used instead of rm -rf. rmdir will only delete a folder if it is completely empty. If you had pre-existing files inside any of those folders, it safely skips them instead of wiping out unrelated data.




