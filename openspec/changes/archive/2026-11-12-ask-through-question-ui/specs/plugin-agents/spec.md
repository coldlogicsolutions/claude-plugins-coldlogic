## ADDED Requirements

### Requirement: Agents report open questions for the main session to ask
Every agent's body SHALL say to report each open question, or each thing it stops to report, as a standalone question with 2 to 4 options, the recommended one first, and never to call `AskUserQuestion`. No agent's body SHALL name the user; it says "the user".

Tested by: none (review only).

#### Scenario: An open question from a subagent
- **WHEN** any of the five agents has something only the user can settle
- **THEN** it reports it as a standalone question with 2 to 4 options, the recommended one first, without calling `AskUserQuestion`
- **AND** the main session asks it through `AskUserQuestion`
