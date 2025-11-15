# Prompts Directory Git Strategy

## Overview

The `prompts/` directory has a hybrid git strategy that balances sharing prompt templates with keeping the repository clean.

## What Gets Committed

✅ **Template prompts** (`prompts/*.md`)
- Prompt templates that teams can share
- Useful for CI/CD pipelines
- Reusable prompts for common tasks
- Examples and patterns for the team

## What Gets Ignored

❌ **Completed prompts** (`prompts/completed/`)
- Prompts that have been executed by `/run-prompt`
- Archived prompts with execution metadata
- Temporary files from prompt execution

## Directory Structure

```
prompts/
├── 001-implement-user-auth.md      ✅ Committed (template)
├── 002-research-database-options.md ✅ Committed (template)
├── 003-quick-prototype.md           ✅ Committed (template)
└── completed/                       ❌ Gitignored
    ├── 001-implement-user-auth.md   ❌ Not committed (executed)
    └── 002-research-database.md     ❌ Not committed (executed)
```

## Automatic Configuration

The `/create-prompt` command automatically ensures `.gitignore` is configured correctly:

1. **Creates `.gitignore`** if it doesn't exist
2. **Adds `prompts/completed/`** to gitignore if not already present
3. **Keeps template prompts** in git for sharing

## Manual Configuration

If you need to manually configure, add this to `.gitignore`:

```gitignore
# Prompts - completed/executed prompts (temporary)
prompts/completed/
```

## Rationale

### Why Keep Templates in Git?

1. **Team Collaboration**: Share effective prompt patterns across the team
2. **CI/CD Integration**: Use pre-made prompts in automated pipelines
3. **Documentation**: Prompts serve as living documentation of tasks
4. **Consistency**: Everyone uses the same well-crafted prompts

### Why Ignore Completed Prompts?

1. **Temporary Nature**: Completed prompts are execution artifacts
2. **Reduce Clutter**: Don't pollute git history with execution records
3. **Local Execution**: Each developer's execution is independent
4. **Metadata Bloat**: Execution metadata isn't useful to commit

## Sensitive Prompts

If a prompt contains sensitive information (API keys, credentials, business secrets), you have two options:

### Option 1: Naming Convention (Recommended)

Name sensitive prompts with a pattern and add to `.gitignore`:

```gitignore
# Sensitive prompts (naming convention)
prompts/*-private-*.md
prompts/*-secret-*.md
prompts/*-internal-*.md
```

Example:
- `prompts/042-private-api-migration.md` ❌ Gitignored
- `prompts/043-secret-credentials-rotation.md` ❌ Gitignored

### Option 2: Separate Directory

Keep sensitive prompts in a separate directory:

```gitignore
# Sensitive prompts directory
prompts/private/
```

Then store:
- Public prompts: `prompts/*.md` ✅ Committed
- Private prompts: `prompts/private/*.md` ❌ Gitignored

## Usage Examples

### Example 1: Team Sharing (Committed Templates)

```bash
# Developer A creates a prompt
/create-prompt Implement user authentication
# Prompt saved to: prompts/005-implement-user-auth.md

# Developer A commits and pushes
git add prompts/005-implement-user-auth.md
git commit -m "Add auth implementation prompt template"
git push

# Developer B pulls and uses
git pull
/run-prompt 005  # Uses the shared template
# Completed prompt goes to prompts/completed/ (gitignored)
```

### Example 2: CI/CD Pipeline (Pre-Made Prompts)

```yaml
# .github/workflows/automated-tasks.yml
- name: Run authentication implementation
  run: |
    claude-code "/run-prompt 005"  # Uses prompts/005-implement-user-auth.md
    # Completed prompt gitignored automatically
```

### Example 3: Local Experimentation (Not Committed)

```bash
# Create experimental prompt
/create-prompt Try experimental AI model integration
# Saved to: prompts/999-experimental-ai.md

# Don't commit (optional)
# Just execute locally
/run-prompt 999

# Delete when done (or let it stay uncommitted)
rm prompts/999-experimental-ai.md
```

## Best Practices

### ✅ DO:
- Commit well-crafted, reusable prompt templates
- Keep prompts generic (no hardcoded credentials)
- Use descriptive filenames for prompts
- Document what each prompt does in the prompt content
- Let `/create-prompt` handle gitignore configuration automatically

### ❌ DON'T:
- Commit `prompts/completed/` directory
- Include sensitive data in committed prompts
- Commit one-off experimental prompts
- Hardcode environment-specific values in prompts
- Manually edit `.gitignore` for prompts (let tooling handle it)

## Migration Guide

### If You Already Have Uncommitted Prompts

```bash
# Review existing prompts
ls prompts/

# Decide which to commit (templates) vs ignore (executed/sensitive)
git add prompts/001-good-template.md  # Commit templates
# Leave prompts/042-one-time-task.md uncommitted

# Ensure gitignore is configured
grep 'prompts/completed/' .gitignore  # Should exist after next /create-prompt
```

### If You Already Committed `prompts/completed/`

```bash
# Remove from git but keep locally
git rm -r --cached prompts/completed/

# Ensure gitignore is updated
grep 'prompts/completed/' .gitignore || echo 'prompts/completed/' >> .gitignore

# Commit the removal
git commit -m "Stop tracking completed prompts"
```

## Summary

| Directory | Status | Purpose |
|-----------|--------|---------|
| `prompts/*.md` | ✅ Committed | Shareable templates for team/CI |
| `prompts/completed/` | ❌ Gitignored | Execution artifacts (temporary) |
| `prompts/*-private-*.md` | ❌ Optional ignore | Sensitive prompts (if using naming convention) |

This strategy keeps your repository clean while enabling team collaboration and CI/CD automation.
