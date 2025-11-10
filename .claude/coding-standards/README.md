# Coding Standards

This directory contains language-specific coding standards and conventions that all code implementations must follow.

## Purpose

These standards ensure consistency, maintainability, and quality across the codebase. The coder agent will reference these files when implementing tasks.

## Structure

- `general.md` - Language-agnostic coding principles
- `python.md` - Python-specific standards
- `typescript.md` - TypeScript-specific standards
- `golang.md` - Go-specific standards
- `dotnetcore.md` - .NET Core/C#-specific standards

## Usage

The coder agent will:
1. First check byterover MCP server (if available) for project-specific rules
2. Then read the appropriate language-specific standards file
3. Apply both sets of rules during implementation

## Adding New Languages

Create a new `{language}.md` file following the template structure used in existing files.
