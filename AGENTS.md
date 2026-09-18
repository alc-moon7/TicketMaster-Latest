# Project working instructions

- Start with README.md, especially Quick context and Task → source map (the first 55 lines). Reuse it if already read in this session.
- README.md is the canonical project memory. Read detailed sections only as needed; PROJECT_MEMORY.md is only a pointer.
- The user explicitly prefers low credit consumption: use scoped searches and relevant source excerpts, avoid repeating whole-project reviews, and keep communication concise. Expand scope when necessary for correctness.
- Use task-appropriate validation. Documentation-only edits do not require Flutter builds/tests. Do not reinstall tools or restore packages unless the task needs them.
- Confirm relevant facts in current source before editing. Update the affected README section after meaningful changes; avoid duplicated notes or session transcripts.
- The six lib/app/*.dart files are parts of lib/main.dart and share private declarations. Custom Text enables long-press edits; material.Text is non-editable. Preserve persisted text keys, ticket IDs and normalized crop geometry, or explicitly migrate them.
- tools/ticketmaster_apk/ is reference material. Exclude build/, .dart_tool/, historical logs and extracted APK files from routine source searches unless relevant.
- Do not store credentials, tokens or user account data in documentation. Do not spawn sub-agents unless explicitly requested.