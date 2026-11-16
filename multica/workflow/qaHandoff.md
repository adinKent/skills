
# Jira QA Handoff

Trigger: Multica issue enters Done.

Your responsibility is to synchronize the completed
development work to Jira and hand it over to QA.

## 1. Collect Information

Read:
- Multica issue title and description
- Jira issue key
- GitLab MR and its changes
- Source branch and commits
- Actual implementation changes

Use the GitLab MCP to inspect the MR diff
and commits when necessary.

## 2. Determine Fix Version

- Identify the intended release version from the
  issue, project configuration, or explicitly
  configured release mapping.
- Verify that the Fix Version exists in Jira.
- Update the Jira Fix Version.
- Never invent a version or automatically select
  an arbitrary latest version.
- If the version cannot be determined, stop and
  report the missing information.

## 3. Transition Jira Issue

- Check the current Jira status.
- If already in Test, do not transition again.
- Otherwise, transition the issue to Test.
- Verify that the transition succeeded.

## 4. Generate QA Handoff Comment

Inspect the actual code changes and generate
a QA handoff comment containing:

### Release Information
- Fix Version
- GitLab MR URL
- Source branch

### Update Scope
- Features added or changed
- Bug fixes
- Relevant behavior changes

### Suggested Test Cases
- Main functional scenarios
- Boundary and error cases
- Regression test scenarios
- Relevant integration tests

### Expected Results
Describe the expected behavior for each
important test scenario.

### QA Action Required
Ask QA to execute the suggested tests
and report unexpected behavior.

Do not invent functionality or test results.
If information is unavailable, explicitly
state that it requires confirmation.

## 5. Add Jira Comment

- Add the QA handoff comment to Jira.
- Avoid creating duplicate comments on retries.
- Include the GitLab MR URL.

## 6. Verify and Report

Verify:
- Fix Version was updated.
- Jira status is Test.
- QA comment was successfully created.

Report the Jira issue URL and synchronization
results back to the Multica issue.

## Restrictions

- Do not modify source code.
- Do not create commits or push branches.
- Do not perform code review.
- Do not merge the MR.
- Do not transition Jira to Done.
- Do not report success for any failed operation.
- If a step fails, report exactly which steps
  succeeded and which failed.
