---
name: features-work
description: Build a feature from a markdown specification file.
---

## Description

This command reads a feature specification from a markdown file located in ./.features/<original-markdown-path>.md in the project root and implements it completely, including:
- Backend components (controllers, models, actions, etc.)
- Frontend components (React pages, components)
- Tests (feature, unit, browser)
- Code formatting
- Moving the completed feature file to `.features/done/`

## Instructions

When this command is invoked:

1. **Check Feature Dependencies**
   - Read the markdown file provided as an argument: `.features/<feature-name>.md`
   - Parse the frontmatter to extract the `depends_on` field
   - If `depends_on` is not null:
     - Split the comma-separated list of dependency feature names
     - For each dependency, check if it exists in `.features/done/<dependency-name>.md`
     - If any dependency is NOT in `.features/done/`:
       - **Notify the user**: "⚠️ Cannot work on `<feature-name>` yet. It depends on `<dependency-name>` which is not completed. Working on `<dependency-name>` first..."
       - Recursively check the dependency's dependencies by reading `.features/<dependency-name>.md`
       - Continue drilling down until you find a feature with:
         - `depends_on: null` (no dependencies), OR
         - All dependencies are in `.features/done/`
       - Work on that foundational feature instead
   - If all dependencies are satisfied or `depends_on` is null, proceed with the requested feature
   - **Notify the user** about the final decision: "✅ Working on `<actual-feature-name>`" (if different from requested)
    - **Claim the feature**: before implementing, atomically claim the feature so no other agent starts it.
       - If `[.features/done/<feature>.md]` exists, do NOT claim — the feature is already completed.
       - If `[.features/working/<feature>.md]` exists, notify: "⚠️ `<feature>` is already claimed by another agent." and choose another feature.
       - Otherwise, create the working directory and move the feature file into it:

          ```bash
          mkdir -p .features/working
          mv .features/<original-markdown-path>.md .features/working/
          ```

       - This moves the specification to `.features/working/` as a lock while implementing.
       - If implementation fails or is aborted, either move the file back to `.features/` or delete the working file to release the claim.

2. **Read the Feature Specification**
   - Read the markdown file for the feature that will be implemented (may be different from the one originally requested)
   - Parse the feature description and implementation plan
   - Identify all tasks that need to be completed

3. **Create a Comprehensive Todo List**
   - Use the TodoWrite tool to create a detailed task list based on the specification
   - Break down complex tasks into smaller, manageable steps
   - Mark the first task as in_progress before starting

4. **Implement the Feature**
   - Follow the implementation plan in the markdown file exactly
   - Create all required components

5. **Test the Implementation**
   - Create feature tests following the established conventions in the project
   - Create unit tests when appropriate
   - Create browser tests for UI flows when specified
   - Run tests and fix any failures
   - Ensure all tests pass before proceeding

6. **Code Quality**
   - Format all code with the formatting tool setup in the repository
   - Ensure code follows best practices
   - Verify all files follow project conventions

7. **Complete the Feature**
   - Update the TodoWrite tool to mark all tasks as completed
   - Move the feature markdown file from `.features/working/` to `.features/done/` directory when finished:
    ```bash
    mkdir -p .features/done
    mv .features/working/<original-markdown-path>.md .features/done/
    ```
   - Ensure the working lock is removed (the file should no longer exist in `.features/working/`).
   - Provide a summary of what was implemented

## Important Notes

- **Dependency Resolution**: Always check and resolve dependencies before starting work. Never work on a feature with incomplete dependencies.
- Always follow the exact implementation plan in the markdown file
- Ask the user as many questions as possible when you are getting blocked or are you sure about the specifications. Avoid guessing what the user wants. This is important
- Ensure tests mirror the namespace structure of the code being tested
- Run tests frequently and fix failures immediately

## Dependency Resolution Examples

**Example 1: Simple dependency chain**
```
User runs: /features-work email-notifications
email-notifications depends_on: notification-queue
notification-queue depends_on: null

Result: Works on notification-queue first, then email-notifications
User sees: "⚠️ Cannot work on email-notifications yet. It depends on notification-queue which is not completed. Working on notification-queue first..."
```

**Example 2: Deep dependency chain**
```
User runs: /features-work admin-dashboard
admin-dashboard depends_on: user-roles
user-roles depends_on: user-authentication
user-authentication depends_on: null

Result: Works on user-authentication first
User sees: "⚠️ Cannot work on admin-dashboard yet. Drilling down dependencies... Working on user-authentication first..."
```

**Example 3: All dependencies satisfied**
```
User runs: /features-work payment-processing
payment-processing depends_on: user-authentication
user-authentication.md exists in .features/done/

Result: Works on payment-processing as requested
User sees: "✅ All dependencies satisfied. Working on payment-processing"
```

## Example

```
/features-work user-authentication
```

This would read `.features/user-authentication.md`, implement all specified features, test them, format the code, and move the file to `.features/done/`.
