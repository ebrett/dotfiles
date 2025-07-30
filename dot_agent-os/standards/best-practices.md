# Development Best Practices

## Context

Global development guidelines for Agent OS projects.

<conditional-block context-check="core-principles">
IF this Core Principles section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Core Principles already in context"
ELSE:
  READ: The following principles

## Core Principles

### Keep It Simple
- Implement code in the fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions

### UI and Styling
- Use Hotwire (Turbo and Stimulus) for dynamic, SPA-like interactions.
- Implement responsive design with Tailwind CSS.
- Use Rails view helpers and partials to keep views DRY.
  
### Test Driven Development
#### (TDD) Workflow
  - Always write a failing test before writing production code.
  - Only write the minimal code required to make the current test pass.
  - Write code one test at a time:  
    - Write the test  
    - Ensure it compiles  
    - Make it pass  
    - Refactor/tidy if needed

#### Committing and Test Integrity
  - Only commit when all tests are passing.
  - Always commit all changed files.
  - Never delete or alter tests just to get a commit to pass (unless fixing a genuine bug, which must be noted in the commit message).
  - If you fake an implementation, clearly state this in the commit message.

#### Test Plan and Tracking
  - Create and maintain a test plan, listing all required tests.
  - As you implement, add any missing tests to the plan at the appropriate place.
  - Cross off tests from the plan as they are completed.

#### Code and Commit Structure
  - Separate commits that change behavior from those that only refactor or tidy code.
  - If you realize you've written too much code for a test, use `git revert --hard` and try again.

#### General Practices
  - Never delete tests without explicit permission.
  - If a test is genuinely incorrect, fix it and document the reason in the commit message.
  - Consider tidying code before making behavioral changes if it will make the change easier.
</conditional-block>

<conditional-block context-check="dependencies" task-condition="choosing-external-library">
IF current task involves choosing an external library:
  IF Dependencies section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Dependencies guidelines already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Dependencies section not relevant to current task

## Dependencies

### Choose Libraries Wisely
When adding third-party dependencies:
- Select the most popular and actively maintained option
- Check the library's GitHub repository for:
  - Recent commits (within last 6 months)
  - Active issue resolution
  - Number of stars/downloads
  - Clear documentation
</conditional-block>
