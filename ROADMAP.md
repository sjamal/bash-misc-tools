# Roadmap

Planned additions to the general-purpose bash utility collection.

---

## In Progress

_Nothing currently active._

---

## Planned

### System Health & Monitoring

- [ ] **system_health_check.sh** — One-shot host health summary: CPU load, memory usage, disk usage, swap, zombie processes, and failed systemd units. Colour-coded output. Useful as a pre-change checklist.
- [ ] **disk_usage_report.sh** — Report top N largest directories under a configurable path using `du`. Sortable output with human-readable sizes. Supports exclusion patterns.
- [ ] **log_tail_filter.sh** — Tail one or more log files with real-time filtering by keyword or regex. Highlights matches with colour. Wrapper around `tail -f | grep`.

### File & Archive Operations

- [ ] **archive_rotator.sh** — Compress a target directory into a timestamped tarball and delete archives older than N days. Designed for cron-based log or backup rotation.
- [ ] **batch_rename.sh** — Rename files in a directory by applying a sed expression to filenames. Dry-run mode shows changes before applying.
- [ ] **dir_sync_check.sh** — Compare two directories and report files present in one but not the other, and files that differ by checksum. Lightweight alternative to `rsync --dry-run`.

### Data Processing

- [ ] **csv_column_extractor.sh** — Extract one or more columns from a CSV by header name using `awk`. Handles quoted fields. Outputs to stdout for piping.
- [ ] **log_frequency_counter.sh** — Count occurrences of each unique line (or field) in a log file and output a sorted frequency table. Useful for quick error pattern analysis.

---

## Ideas / Backlog

- SSH multi-host command runner: run a command on a list of hosts in parallel and collect outputs
- Port scanner wrapper: iterate a host list and check a configurable set of ports with `nc`
- Cron schedule parser: read a crontab and output human-readable next-run times

---

## Notes

- All scripts should use `set -euo pipefail` and validate required arguments before execution.
- Support `--help` / `-h` flags with usage information.
- Test on both Linux (bash 4+) and macOS (bash 3 / zsh compatible where possible).
