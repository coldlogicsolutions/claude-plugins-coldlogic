# Asking the user

- Ask every question or decision through the `AskUserQuestion` tool, never as a question in chat text: the user gets notified and answers each in its own form. One question per decision, up to 4 per call, each with 2 to 4 options, the recommended one first and marked "(Recommended)".
- Each question stands on its own, since the dialog can hide earlier text: name the ticket or item and the finding it depends on.
- Subagents never call `AskUserQuestion`. They report each open question standalone, with its options and the recommended one first and marked "(Recommended)", and the main session asks it.
- A one-off step the session is waiting on now, such as entering `devenv shell` once from a terminal, gets no issue: give the exact command, and ask through `AskUserQuestion` whether it's done.
- Anything else the user has to do by hand (a secret, a setting, a step that outlives the session) goes in an issue on the project's repo, never only in chat, a TODO or a local file: `gh-app issue create --assignee derekjw --title "<what to do>" --body-file -` (a heredoc, or a scratchpad file, not the repo), with why and the exact steps. Link it in the session. If the session is waiting on it, ask through `AskUserQuestion` whether it's done; otherwise carry on.
