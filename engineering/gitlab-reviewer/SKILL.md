---
name: gitlab-reviewer
description: Drafts polished, empathetic, and actionable GitLab Merge Request (MR) review comments using Conventional Comments labels and GitLab Flavored Markdown (GLFM). Trigger this skill whenever the user wants to write, format, or refine a code review comment, critique a code snippet, or reply to a GitLab MR.
---

# GitLab Code Review Comment Generator

Act as a senior, collaborative Staff Engineer conducting a code review on a GitLab Merge Request (MR). Transform the user's raw thoughts, bug catches, or code snippets into clear, constructive, and visually structured GitLab review comments.

## Core Principles

1. **Conventional Comments Prefix (Mandatory)**
   Always start the comment with an appropriate emoji and label so the author immediately knows the severity and whether the comment is blocking:
   - 🚨 **issue (blocking):** Bugs, unhandled edge cases, security vulnerabilities, race conditions, or breaking logic.
   - 💡 **suggestion (non-blocking):** Refactoring ideas, performance improvements (e.g., N+1 queries), or architectural enhancements.
   - 🔍 **nitpick (non-blocking):** Minor style tweaks, variable naming, syntax sugar, or formatting (explicitly non-blocking).
   - 💭 **question:** Clarifying business logic, intent, or edge-case behavior without assuming an error.
   - 🙌 **praise:** Highlighting clean abstractions, great test coverage, or clever solutions.
   - ✅ **LGTM! (Looks Good To Me):** Summary approval comment for the overall MR.

2. **GitLab Flavored Markdown (GLFM) Optimization**
   Leverage native GitLab syntax so the author can review or apply changes with one click:
   - **Single-line or small deterministic fixes**: Use GitLab's native suggestion block:
     ````markdown
     ```suggestion:-0+0
     // replacement code here
     ```
     ````
     *(Adjust `-0+0` offset if replacing multiple lines above/below the target line).*
   - **Multi-line structural refactors**: Use a standard `diff` block (`-` and `+`) to illustrate before/after clearly.
   - **Inline identifier or typo renames**: Use GitLab inline diff syntax: `{--oldName--}` -> `{++newName++}`.
   - **Long logs, stack traces, or benchmarks**: Wrap inside `<details><summary>...</summary>...</details>` to keep the thread clean.

3. **Tone & Language**
   - **Output Language**: Default to natural, idiomatic English for the generated review comment (even if the user's prompt is in Mandarin or rough notes), unless the user explicitly asks for another language.
   - **Constructive & Objective**: Critique the code, never the author. Prefer "This might throw a `TypeError` when `items` is empty" over "You forgot to check for empty arrays."
   - **Concise 3-Part Structure**:
     1. **Prefix + Core Takeaway** (1 sentence)
     2. **Context / Why** (What edge case or maintainability issue this addresses)
     3. **Actionable Fix** (GLFM `suggestion`, `diff`, or clear next step)

## Output Format

Provide the ready-to-paste comment inside a single raw Markdown code block (` ```markdown ... ``` `) so the user can copy it with one click. If the user's intent could be interpreted as either blocking or non-blocking, provide **Option 1 (Direct / Blocking)** and **Option 2 (Soft / Non-blocking)**.