# Safe System Cleanup Tool

> A safer, interactive, log-enabled Windows batch script that previews and confirms deletions, logs actions, and reports space freed.

---

## Table of Contents

* [Overview](#overview)
* [Features](#features)
* [Requirements](#requirements)
* [Files](#files)
* [Installation](#installation)
* [Usage](#usage)
* [Examples](#examples)
* [How the "Space Freed" Report Works](#how-the-space-freed-report-works)
* [Log File](#log-file)
* [Running as Administrator (recommended)](#running-as-administrator-recommended)
* [Safety Notes & Best Practices](#safety-notes--best-practices)
* [Troubleshooting](#troubleshooting)
* [FAQ](#faq)
* [Changelog](#changelog)
* [Contributing](#contributing)
* [License](#license)

---

## Overview

This batch script (`SafeCleanup.bat`) is designed to safely clean up temporary Windows files, recent items, and prefetch data. It also optionally runs Windows system-repair utilities (`DISM` and `sfc`). The script shows a preview of files to be deleted, asks for confirmation for each step, logs all actions to a log file, and reports how many bytes were freed by each cleanup step.

It is **intended for Windows 10/11** and aims to avoid accidental deletions through confirmations and previewing.

---

## Features

* Interactive menu with options for granular cleanup
* Preview mode (lists files that would be deleted)
* Per-step **Yes / No** confirmation
* Action logging to `cleanup_log.txt`
* Space freed calculation (displayed in bytes)
* Optional system repair (DISM and SFC)
* Menu loop so you can run multiple operations in one session

---

## Requirements

* Windows 10 or Windows 11
* Command Prompt (cmd.exe)
* `choice`, `dir`, `del`, `DISM`, and `sfc` available (standard in modern Windows)
* **Administrator privileges are recommended** for full cleanup and to run DISM/SFC without access errors

---

## Files

* `SafeCleanup.bat` — main script
* `cleanup_log.txt` — created automatically in the script folder (contains the log and freed-bytes entries)

---

## Installation

1. Save the provided script as `SafeCleanup.bat` into a folder you control (e.g., `C:\Tools\SafeCleanup`).
2. (Optional) Pin it to Start or create a desktop shortcut for quick access.

---

## Usage

1. **Open** the script location in File Explorer.
2. **Right-click** `SafeCleanup.bat` and choose **Run as administrator** (recommended).
3. Choose an option from the menu:

   * `1` – Temporary files only
   * `2` – Temporary files + Recent items
   * `3` – Full cleanup (Temp, Recent, Prefetch)
   * `4` – Full cleanup + System repairs (DISM & SFC)
   * `5` – Exit
4. For each step the script will:

   * Show a preview list of items it plans to delete (using `dir`)
   * Ask **Y** (yes) or **N** (no) to proceed
   * If confirmed, it will delete the files and record actions in `cleanup_log.txt`
   * Display the number of **bytes freed** for that step
5. When finished, the script returns to the menu so you may run another task or exit.

---

## Examples

**Run full cleanup with repairs:**

1. Run `SafeCleanup.bat` as Administrator.
2. Press `4` and confirm each step when prompted.
3. After completion, open `cleanup_log.txt` to inspect actions and freed bytes.

**Run only temporary files cleanup:**

* Choose `1`, preview the temp folders, press `Y` to confirm, and review the freed bytes.

---

## How the "Space Freed" Report Works

* The script calculates folder sizes *before* deletion using `dir /s` parsing, then runs the deletion commands, and calculates sizes *after* deletion.
* The script then computes `freed = before - after` and prints the result in **bytes**.
* The value is appended to `cleanup_log.txt` so you can tally results across runs.

> Note: The script reports raw bytes. If you'd prefer human-friendly units (KB/MB/GB), you can request a small update to convert and format these values.

---

## Log File

* `cleanup_log.txt` is created in the same folder as the script.
* The log includes timestamps, actions taken, and the number of bytes freed for each cleanup step.
* Example log entries:

```
Cleanup Log - 2025-08-15 16:00:00
======================================
--- Temp Files ---
Temp files cleaned – Freed 1245123 bytes
--- Recent Items ---
Recent items cleared – Freed 1024 bytes
```

---

## Running as Administrator (recommended)

* To gain full access to `C:\Windows\Temp` and to run `DISM`/`sfc` properly, run the script with elevated privileges.
* Right-click the batch file and select **Run as administrator**.
* Alternatively, create a scheduled task that runs the script with highest privileges.

---

## Safety Notes & Best Practices

* **Save your work and close applications** before running the script — some applications store temporary state in `%TEMP%`.
* The script **does not** delete documents in `Documents`, `Desktop`, or other user folders — it targets only temp, recent, and prefetch directories.
* Deleted files are not moved to the Recycle Bin.
* Keep regular backups if you need to preserve unusual files that may temporarily live in `%TEMP%`.

---

## Troubleshooting

* **DISM / SFC fails or reports errors:**

  * Re-run the script from an elevated prompt. If failures persist, run `DISM /Online /Cleanup-Image /RestoreHealth` manually and examine the output for network or component store issues.

* **Script cannot access a folder (permission errors):**

  * Ensure you are running as Administrator. If it still fails, check that antivirus or other protection software is not blocking access.

* **No space freed reported (freed = 0) even though files were deleted:**

  * Some files are in use and cannot be deleted. The script will skip files locked by running processes. Try closing apps or rebooting and run again.

---

## FAQ

**Q: Will this script delete my personal files?**

A: No. It only targets temporary directories, Recent items, and Prefetch. However, if you or an application intentionally stored data inside `%TEMP%`, those will be removed.

**Q: Is it safe to clear Prefetch?**

A: Yes. Windows will rebuild prefetch entries. You may notice slightly slower start-up for a short time until cache repopulates.

**Q: How long does the "System repairs" option take?**

A: Typically 10–30 minutes depending on system speed and whether DISM needs to download replacement files. Plan accordingly.

---

## Changelog

* **v2.1** — Added space freed report and improved size calculation
* **v2.0** — Added preview mode, confirmations, logging, and menu loop
* **v1.0** — Initial safe cleanup script

---

## Contributing

Contributions are welcome. Suggested improvements:

* Human-friendly formatting of space-freed values (KB/MB/GB)
* Optional Recycle Bin routing instead of permanent delete
* Exclude lists (allow user to specify files/folders to keep)

If you open a PR or share changes, include test results and examples.

---

## License

This project is provided **as-is** under the MIT License. Use at your own risk. No warranty is provided.

---

If you'd like, I can also:

* Convert byte values to readable units (KB/MB/GB) in the script and README,
* Generate a downloadable ZIP containing `SafeCleanup.bat` and this `README.md`, or
* Add an "exclude list" option so specific file patterns are never deleted.

Which of those would you prefer next?
