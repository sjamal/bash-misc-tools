# File Operations Scripts

Scripts for file manipulation and organization tasks.

## Scripts

### split_with_number_prefix.sh
Renames files created by the `split` command with zero-padded numeric suffixes.

**Key Features:**
- Converts alphabetic suffixes (aa, ab, ac) to numeric (001, 002, 003)
- Zero-pads numeric suffixes for consistent naming
- Configurable padding length

**Usage:**
```bash
# Split a large file
split -l 1000 largefile.txt chunk_

# Rename with numeric prefixes
./split_with_number_prefix.sh chunk_
```

**Result:**
```
Before: chunk_aa, chunk_ab, chunk_ac
After:  chunk_001, chunk_002, chunk_003
```

## Configuration

Edit the script to change suffix padding length:
- 2 = `01, 02, 03...`
- 3 = `001, 002, 003...` (default)
- 4 = `0001, 0002, 0003...`

## Requirements

- Standard POSIX utilities (mv, printf)
- Write permissions in the target directory