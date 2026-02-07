---
name: features-plan
description: Analyze user input and generate detailed feature specification files.
---

## Description

This command takes a user's feature request, analyzes it within the context of the project, and generates well-structured feature specification files in the `.features/` directory. Each feature gets its own markdown file that can be implemented using the `/features-work` command.

## Instructions

When this command is invoked:

1. **Gather Project Context**
   - **For Laravel projects**:
     - Use the `application-info` tool from Laravel Boost to gather comprehensive project information (PHP version, Laravel version, installed packages, models, etc.)
     - Read custom guidelines from `.ai/` directory files (if they exist) for project-specific conventions
     - Check for Laravel Roster integration (if available) for detailed project structure analysis
   - **For all projects**:
     - Read `README.md` in the project root to understand the project structure, technologies, and conventions
     - Read `CLAUDE.md` in the project root (if it exists) for additional project guidelines and context
     - Identify the tech stack, testing frameworks, and code formatting tools in use

2. **Analyze User Input**
   - Parse the user's request carefully
   - Consider the project context from README and CLAUDE.md
   - Ask clarifying questions if the request is ambiguous or lacks critical details
   - **Important**: Avoid guessing user intentions - ask for clarification when needed

3. **Break Down Into Features**
   - Decompose the user request into discrete, manageable features
   - Each feature should be independently implementable
   - Identify dependencies between features
   - Example breakdown:
     - User input: "add file downloads to the file manager and send zipped archive via email"
     - Feature 1: UI for selecting and downloading files
     - Feature 2: Backend for zipping files and queueing downloads
     - Feature 3: Email delivery system for zipped archives
     - (Feature 3 depends_on Feature 2)

4. **Generate Feature Specification Files**
   - Create `.features/` directory if it doesn't exist
   - Generate one markdown file per feature: `.features/<feature-name>.md`
   - Use kebab-case for feature file names (e.g., `file-download-ui.md`)
   
5. **Feature File Structure**

Each feature file must follow this template:

```markdown
---
name: <feature-name>
description: <concise one-line description>
depends_on: <comma-separated list of feature names this depends on, or null>
---

## Feature Description

<Detailed explanation of what this feature does and why it's needed>

## Implementation Plan

### Backend Components (if applicable)
- **Controllers**: <list controllers to create/modify>
- **Models**: <list models to create/modify with factories>
- **Actions**: <list Action classes following .ai/actions guidelines>
- **Services**: <list Service classes following .ai/services guidelines>
- **Form Requests**: <validation classes for request handling>
- **Routes/APIs**: <list endpoints with route names>
- **Database changes**: <migrations following .ai/migrations guidelines - no defaults, no enums>

### Frontend Components (if applicable)
- Pages: <list pages to create/modify>
- Components: <list React/Vue/etc components>
- State management: <Context, etc>
- Routing: <new routes or updates>
- Styling: <Shadcn components, Tailwind, etc>

### Configuration/Infrastructure (if applicable)
- Environment variables
- Third-party integrations
- Build/deployment changes

## Acceptance Criteria

- [ ] <Specific, testable criterion 1>
- [ ] <Specific, testable criterion 2>
- [ ] <Specific, testable criterion 3>
- [ ] All tests pass
- [ ] Code is formatted according to project standards

## Testing Strategy

### <Test Type Based on Project Setup>

**<Unit Tests / Feature Tests / Browser Tests>**
- Test file location: <path following project conventions>
- Key test cases:
  - <Test case 1>
  - <Test case 2>
  - <Test case 3>

<Repeat for each test type needed>

## Code Formatting

Format all code using: <formatting tool from project, e.g., "Prettier", "oxc", "pint", "gofmt">

Command to run: `<actual command, e.g., "pnpm run format">`

## Additional Notes

<Any special considerations, edge cases, or implementation notes>
```

6. **Determine Testing Approach**

Based on the project's language and setup:

- **Ruby/Rails projects**: 
  - Feature tests (RSpec/Capybara) for end-to-end flows
  - Request specs for API endpoints
  - Model specs for business logic
  
- **JavaScript/TypeScript projects**:
  - Unit tests (Vitest) for components and utilities
  - Integration tests for API routes
  - E2E tests (Playwright) for critical user flows
  
- **Laravel projects**:
  - Unit tests (Pest) for functions and classes in `tests/Unit/`
  - Feature tests (Pest) for complete features/flows in `tests/Feature/`
  - Browser tests (Pest Browser) for UI interactions in `tests/Browser/`
  - Follow Laravel Boost guidelines from `.ai/tests` for test structure and conventions

7. **Determine Formatting Tool**

Identify from project files:
- **Laravel projects**: Use `vendor/bin/pint` (Laravel Pint) as specified in Laravel Boost guidelines
- `package.json` → Look for prettier, eslint, oxc
- `composer.json` → Laravel Pint for `./vendor/bin/pint --parallel`
- `.gofmt` or `go.mod` → gofmt for Go

8. **Laravel-Specific Planning** (if applicable)

For Laravel projects, ensure feature specifications:
- **Follow Action Pattern**: Business logic should use Action classes in `app/Actions/`
- **Use Service Classes**: External system interactions should use Service classes in `app/Services/`
- **Follow Migration Guidelines**: Never use `->default()` or `->enum()` in migrations (per `.ai/migrations`)
- **Test Structure**:
  - Unit tests in `tests/Unit/` for individual classes
  - Feature tests in `tests/Feature/` for complete workflows
  - Browser tests in `tests/Browser/` for UI interactions
- **Factory Usage**: All models should have factories, use them in tests
- **Formatting**: Always use Laravel Pint (`vendor/bin/pint`) for PHP code

9. **Provide Summary**

After generating all feature files:
- List all created feature files
- Show the dependency tree if features depend on each other
- Suggest the implementation order
- For Laravel projects: Remind about Action pattern, Service usage, and custom guidelines
- Remind user to use `/features-work <feature-name>` to implement each feature

## Important Notes

- **For Laravel projects**:
  - Use `application-info` tool from Laravel Boost to understand the project's package versions and conventions
  - Follow custom guidelines from `.ai/` directory (actions, services, migrations, tests, etc.)
  - Never reference or rely on "Spec" files - use Laravel Boost's tools and custom guidelines instead
  - When Laravel Roster is available, use it for detailed project structure information
- **For all projects**:
  - **Always** read README.md and CLAUDE.md before analyzing the request
  - **Never guess** - ask clarifying questions when requirements are unclear
  - Ensure feature names are descriptive but concise (4-10 words)
  - Keep features focused - one feature should do one thing well
  - Specify realistic acceptance criteria that can be verified
  - Include error handling and edge cases in the implementation plan
  - Consider backwards compatibility if modifying existing features
  - Note security implications if handling sensitive data
  - Mention performance considerations for data-heavy operations

## Example Usage

### Laravel Project Example

```
/features-plan add user profile page with avatar upload and bio editing
```

**Process**:
1. Calls `application-info` tool to gather Laravel project context
2. Reads `.ai/` custom guidelines and CLAUDE.md
3. Identifies project is Laravel with Inertia.js React frontend
4. Creates two feature files:
   - `.features/user-profile-page.md` - Profile page UI
   - `.features/avatar-upload.md` - Avatar upload and storage
5. Sets `avatar-upload` as dependency for `user-profile-page`
6. Includes Pest feature tests and browser tests following `.ai/tests` guidelines
7. Specifies Laravel Pint and Prettier for formatting

### Non-Laravel Project Example

```
/features-plan add user authentication with email verification
```

**Process**:
1. Reads README.md and CLAUDE.md
2. Identifies project is a Rails app with React frontend
3. Creates feature files following project conventions
4. Includes RSpec feature tests and Jest component tests
5. Specifies RuboCop and Prettier for formatting

## Common Patterns

### Feature Dependency Examples

**Sequential dependencies**:
```
Feature A → Feature B → Feature C
(B depends_on A, C depends_on B)
```

**Parallel with shared dependency**:
```
      Feature A
       ↙    ↘
Feature B  Feature C
(Both B and C depend_on A)
```

**Independent features**:
```
Feature A    Feature B    Feature C
(No dependencies)
```

### Naming Conventions

- Use kebab-case: `user-authentication.md`
- Be descriptive: `admin-dashboard-analytics.md`
- Avoid abbreviations: `notification-system.md` not `notif-sys.md`
- Include scope if needed: `api-rate-limiting.md`

## Troubleshooting

**For Laravel projects without Laravel Boost**:
- If `application-info` tool is unavailable, read `composer.json` to identify packages and versions
- Check `.ai/` directory for custom guidelines manually
- Fall back to README.md and CLAUDE.md for project context

**If README.md doesn't exist**:
- For Laravel projects: Use `application-info` tool to gather context
- For other projects: Ask the user about project structure and tech stack
- Request basic project information before proceeding

**If user request is too vague**:
- Ask specific questions about:
  - User interface requirements
  - Data models and relationships
  - Business logic and rules
  - Performance requirements
  - Security considerations

**If feature breakdown is unclear**:
- Propose the breakdown to the user
- Ask for confirmation before creating files
- Allow user to adjust scope or dependencies

**Laravel Roster Integration** (Future):
- When Laravel Roster becomes available, use it to:
  - Analyze project structure automatically
  - Identify existing patterns and conventions
  - Detect available models, controllers, and services
  - Generate more accurate implementation plans
