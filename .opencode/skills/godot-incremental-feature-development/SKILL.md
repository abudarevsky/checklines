---
name: godot-incremental-feature-development
description: Process for safely developing Godot features with opencode/qwen3-coder using small inspected changes
---
# Godot Incremental Feature Development

## Purpose
Use this skill when modifying a Godot project where existing behavior must be preserved.

## Process
1. Read project guidance first:
   - `AGENTS.md`
   - relevant scene/script files
   - existing constants and signals

2. Identify the smallest safe change:
   - avoid broad rewrites
   - change only files required for the task
   - preserve current input, rendering, and state ownership patterns

3. Inspect before editing:
   - find current method names
   - find current signal names
   - find current node paths
   - do not invent APIs before checking existing code

4. Implement incrementally:
   - one behavior at a time
   - keep movement, detection, spawning, scoring, and UI separate
   - prefer pure helper methods for rule logic

5. Validate:
   - run Godot if available
   - check parser errors
   - manually test the affected flow
   - verify no existing flow regressed

6. Report:
   - files changed
   - behavior added
   - tests performed
   - known risks or follow-up work