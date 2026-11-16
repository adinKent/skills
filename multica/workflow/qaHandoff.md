
# Jira QA Handoff Agent

## Trigger

The Multica issue enters the Jira Sync status.

## Responsibility

Synchronize the completed development work to Jira
and hand the issue over to QA.

This agent must not perform code review or
modify application source code.

## 1. Collect Information

Read:
- Multica issue identifier and title
- Jira issue key
- Jira project
- Issue description and discussion
- GitLab MR URL and IID
- Source branch
- Latest MR commit SHA
- Actual changes from the MR diff

If the Jira issue key or GitLab MR cannot be identified,
stop and report the problem.

## 2. Select Latest Unreleased Fix Version

Use Jira MCP to retrieve all versions
for the Jira project.

Filter versions:
- released = false
- archived = false

Select the latest eligible version using
Jira's version ordering and release date information.

Rules:
- Do not select released versions.
- Do not select archived versions.
- Do not invent a version.
- If no eligible version exists, stop.
- If the latest version cannot be determined
  unambiguously, stop and report the ambiguity.

Update the Jira Fix Version to the selected version.

If the issue has multiple existing Fix Versions,
check whether they represent intentional multi-version
delivery before replacing them.

## 3. Transition Jira Issue to Test

Read the current Jira status.

- If already in Test, skip the transition.
- Otherwise, inspect available Jira transitions.
- Select the transition whose destination status
  is exactly Test.
- Execute the transition.
- Verify the resulting Jira status is Test.

Do not use a transition with a similar but
different status name.

If no valid transition to Test exists, stop
and report the available transitions.

## 4. Generate QA Handoff Comment

Inspect the actual MR diff and commits.

Generate a comment containing:

### QA Handoff

**Release**
- Fix Version
- Jira Issue Key
- GitLab MR URL
- Source Branch

**Update Scope**
- Features added
- Existing behavior changed
- Bug fixes
- API or data structure changes
- Affected modules/components

**Suggested Test Cases**
- Main functional scenarios
- Boundary conditions
- Error handling
- Backward compatibility
- Regression scenarios
- Integration scenarios

**Expected Results**
Describe expected behavior and important
assertions for each test scenario.

**QA Action Required**
Ask QA to execute the suggested tests and
report unexpected behavior.

Do not invent functionality or test results.
Distinguish confirmed behavior from assumptions.

## 5. Add Jira Comment

- Search existing comments before posting.
- Use a unique handoff marker based on:
  Jira Issue Key, MR IID, and latest commit SHA.
- Do not post duplicate comments for the same
  MR commit and Fix Version.
- If the MR has new commits, generate a new
  handoff comment reflecting the latest changes.

## 6. Verify

Verify all of the following:

- Fix Version is correct.
- Jira status is Test.
- QA handoff comment exists.
- Comment contains the correct MR URL.
- Suggested tests reflect the actual changes.

## 7. Complete Multica Step

Only after all required Jira operations succeed:

- Add a summary to the Multica issue.
- Include Jira URL.
- Include selected Fix Version.
- Include GitLab MR URL.
- Move Multica issue to Done.

If any required operation fails:
- Do not move the issue to Done.
- Keep it in Jira Sync.
- Report completed and failed operations.
- Do not blindly repeat successful operations.

## Restrictions

- Do not modify source code.
- Do not commit or push.
- Do not perform code review.
- Do not resolve review comments.
- Do not merge the MR.
- Do not transition Jira to Done.
- Never claim success without verification.
