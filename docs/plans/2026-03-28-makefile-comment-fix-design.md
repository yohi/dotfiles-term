# Makefile Comment Fix Design

## Goal
Update the path in the `Makefile` comment to match the actual symlink targets in `_mk/`.

## Architecture
- Source file: `Makefile`
- Context: `_mk/core.mk` and `_mk/help.mk` are symlinked to `../../../common-mk/core.mk` and `../../../common-mk/help.mk`.
- Action: Update the comment in `Makefile` which currently incorrectly refers to `../../common-mk/`.

## Proposed Changes
- Replace `../../common-mk/` with `../../../common-mk/` in the `Makefile` comment.

## Verification Strategy
- Read the file again to ensure the change is applied correctly.
- Verify the path matches the actual symlink targets in `_mk/`.
