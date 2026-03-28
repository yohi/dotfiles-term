# Makefile Comment Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the path in the `Makefile` comment to match the actual symlink targets in `_mk/`.

**Architecture:** Update `Makefile` around lines 1-4 to change `../../common-mk/` to `../../../common-mk/`.

**Tech Stack:** `Makefile`, `git`.

---

## Task 1: Update Makefile Comment

**Files:**
- Modify: `Makefile:1-4`

**Step 1: Write the replacement**

Current:
```makefile
# Orchestrator core configuration
# Note: These are symlinked from ../../common-mk/ when managed by dotfiles-core
```

New:
```makefile
# Orchestrator core configuration
# Note: These are symlinked from ../../../common-mk/ when managed by dotfiles-core
```

**Step 2: Apply the replacement using the `replace` tool**

Instruction: Update the comment to correctly refer to `../../../common-mk/`.

**Step 3: Run `read_file` to verify the change**

Run: `read_file {file_path: "Makefile", start_line: 1, end_line: 5}`
Expected: The comment shows `../../../common-mk/`.

**Step 4: Commit**

```bash
git add Makefile
git commit -m "fix(Makefile): update common-mk path in comment to match symlinks"
```

## Task 2: Verify Symlink Targets Consistency

**Step 1: Run `ls -l _mk/` and compare with the updated comment**

Run: `ls -l _mk/`
Expected: `core.mk` and `help.mk` point to `../../../common-mk/...`.
Verify: The paths match.

## Task 3: Claim Verification Before Completion

**Step 1: Invoke `verification-before-completion` skill**
- Use the evidence gathered in Task 2 to confirm the fix is correct.
