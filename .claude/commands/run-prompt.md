---
name: run-prompt
description: Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution
argument-hint: <prompt-number(s)-or-name> [--parallel|--sequential]
---

<objective>
Execute one or more prompts from `./prompts/` as delegated sub-tasks with fresh context. Intelligently routes code implementation tasks through the /coder workflow (with automatic quality gates) and non-code tasks through general-purpose agents. Supports single prompt execution, parallel execution of multiple independent prompts, and sequential execution of dependent prompts.
</objective>

<input>
The user will specify which prompt(s) to run via $ARGUMENTS, which can be:

**Single prompt:**

- Empty (no arguments): Run the most recently created prompt (default behavior)
- A prompt number (e.g., "001", "5", "42")
- A partial filename (e.g., "user-auth", "dashboard")

**Multiple prompts:**

- Multiple numbers (e.g., "005 006 007")
- With execution flag: "005 006 007 --parallel" or "005 006 007 --sequential"
- If no flag specified with multiple prompts, default to --sequential for safety
  </input>

<process>
<step1_parse_arguments>
Parse $ARGUMENTS to extract:
- Prompt numbers/names (all arguments that are not flags)
- Execution strategy flag (--parallel or --sequential)

<examples>
- "005" → Single prompt: 005
- "005 006 007" → Multiple prompts: [005, 006, 007], strategy: sequential (default)
- "005 006 007 --parallel" → Multiple prompts: [005, 006, 007], strategy: parallel
- "005 006 007 --sequential" → Multiple prompts: [005, 006, 007], strategy: sequential
</examples>
</step1_parse_arguments>

<step2_resolve_files>
For each prompt number/name:

- If empty or "last": Find with `!ls -t ./prompts/*.md | head -1`
- If a number: Find file matching that zero-padded number (e.g., "5" matches "005-_.md", "42" matches "042-_.md")
- If text: Find files containing that string in the filename

<matching_rules>

- If exactly one match found: Use that file
- If multiple matches found: List them and ask user to choose
- If no matches found: Report error and list available prompts
  </matching_rules>
  </step2_resolve_files>

<step2b_analyze_task_type>
For each resolved prompt file, determine the task type to choose the appropriate executor:

<frontmatter_detection>
Check if prompt has YAML frontmatter with executor specification:

```yaml
---
executor: coder | general-purpose
---
```

If frontmatter specifies executor explicitly, use that (skip auto-detection).
</frontmatter_detection>

<auto_detection>
If no frontmatter or no executor specified, analyze prompt content for task type indicators:

<code_task_indicators>
Count occurrences of code implementation keywords:
- Implementation verbs: "implement", "build", "create", "add feature", "develop", "code"
- Code modification: "modify", "edit", "update", "refactor", "fix bug"
- File operations: mentions of code files (.js, .ts, .py, .go, .java, .tsx, .jsx, etc.)
- Component/class creation: "component", "class", "function", "module", "API", "endpoint"
- Testing requirements: "test", "ensure tests pass", "add tests", "unit test"
- Code quality: "coding standards", "code conventions", "follow standards"
- Technical stack mentions: "React", "Node", "Django", "Go", "TypeScript", etc.
- Code structure tags: `<implementation>`, `<requirements>`, `<verification>` with code context

**Scoring**: Each indicator found = +1 point
</code_task_indicators>

<non_code_indicators>
Count occurrences of non-code task keywords:
- Research verbs: "research", "investigate", "explore", "analyze", "study"
- Documentation: "document", "write documentation", "create guide", "write README"
- Analysis: "analyze", "review", "assess", "evaluate", "compare"
- Data tasks: "gather data", "collect information", "compile", "summarize"
- Report generation: "create report", "generate summary", "write analysis"

**Scoring**: Each indicator found = +1 point
</non_code_indicators>

<decision_logic>
- If code_score >= 3: **Code task** → Use /coder workflow
- If non_code_score > code_score AND code_score < 3: **Non-code task** → Use general-purpose
- If code_score >= 2 AND mentions tests/standards: **Code task** → Use /coder workflow
- Default (ambiguous): **Code task** → Use /coder workflow (safer default for quality)

**Rationale**: When in doubt, route through /coder to ensure quality gates. The hooks will only trigger if actual code changes are made.
</decision_logic>
</auto_detection>

<task_type_output>
Store for each prompt:
- file_path: "./prompts/XXX-name.md"
- executor: "coder" | "general-purpose"
- detection_method: "frontmatter" | "auto-detected" | "default"
</task_type_output>
</step2b_analyze_task_type>

<step3_execute>
<single_prompt>

1. Read the complete contents of the prompt file
2. Analyze task type (step2b) to determine executor
3. Route based on executor type:

   <code_task_routing>
   If executor == "coder":
   - Invoke SlashCommand tool: `/coder [prompt content]`
   - This triggers the full /coder workflow:
     * Coder agent implements the task
     * SubagentStop hook signals orchestrator
     * Orchestrator invokes coding-standards-checker
     * SubagentStop hook signals orchestrator
     * Orchestrator invokes tester
   - Wait for complete workflow to finish
   - All quality gates applied automatically via hooks
   </code_task_routing>

   <general_task_routing>
   If executor == "general-purpose":
   - Invoke Task tool with subagent_type="general-purpose"
   - Delegate prompt content as-is
   - No quality gate hooks triggered
   - Wait for completion
   </general_task_routing>

4. Archive prompt to `./prompts/completed/` with metadata (include executor type used)
5. Return results with execution summary
   </single_prompt>

<parallel_execution>

1. Read all prompt files
2. Analyze task type for each prompt (step2b) to determine executors
3. **Execute all prompts in PARALLEL in a SINGLE MESSAGE**:

   <mixed_executor_parallel>
   For each prompt, route based on its executor:

   - Code tasks: Use SlashCommand `/coder [content]`
   - General tasks: Use Task tool with subagent_type="general-purpose"

   **CRITICAL**: All tool invocations (SlashCommand and Task) MUST be in a single message for true parallel execution.

   <example>
   Single message with multiple tool calls:
   - SlashCommand `/coder [prompt 005 content]` (code task)
   - Task tool for prompt 006 (general task)
   - SlashCommand `/coder [prompt 007 content]` (code task)

   All execute simultaneously!
   </example>
   </mixed_executor_parallel>

   <important_note>
   - Code tasks routed through /coder will trigger their own quality gate workflows independently
   - Each /coder invocation gets its own hook-driven standards check → test cycle
   - General tasks complete without quality gates
   - All tasks execute in parallel regardless of executor type
   </important_note>

4. Wait for ALL to complete
5. Archive all prompts with metadata (include executor type for each)
6. Return consolidated results with execution summary per prompt
   </parallel_execution>

<sequential_execution>

1. Read first prompt file
2. Analyze task type (step2b) to determine executor
3. Route based on executor:
   - If "coder": Invoke SlashCommand `/coder [content]` → wait for full workflow (implementation → standards → tests)
   - If "general-purpose": Invoke Task tool → wait for completion
4. Archive first prompt with metadata
5. Read second prompt file
6. Analyze task type for second prompt
7. Route based on executor (same as step 3)
8. Wait for completion
9. Archive second prompt
10. Repeat for remaining prompts in sequence
11. Return consolidated results with execution summary per prompt

<sequential_benefits>
- Each prompt completes fully (including quality gates for code tasks) before next starts
- Dependencies between prompts are respected
- Clear progression through workflow
- Easier debugging if one prompt fails
</sequential_benefits>
    </sequential_execution>
    </step3_execute>
    </process>

<context_strategy>
By delegating to a sub-task, the actual implementation work happens in fresh context while the main conversation stays lean for orchestration and iteration.
</context_strategy>

<output>
<single_prompt_output>
✓ Executed: ./prompts/005-implement-feature.md
✓ Executor: coder (auto-detected)
✓ Quality gates: Standards ✓ | Tests ✓
✓ Archived to: ./prompts/completed/005-implement-feature.md

<results>
[Summary of what the sub-task accomplished]
</results>
</single_prompt_output>

<parallel_output>
✓ Executed in PARALLEL:

- ./prompts/005-implement-auth.md (executor: coder, quality gates applied)
- ./prompts/006-research-competitors.md (executor: general-purpose)
- ./prompts/007-implement-ui.md (executor: coder, quality gates applied)

✓ All archived to ./prompts/completed/

<results>
Prompt 005 (coder): [Implementation summary with quality gate results]
Prompt 006 (general-purpose): [Research summary]
Prompt 007 (coder): [Implementation summary with quality gate results]
</results>
</parallel_output>

<sequential_output>
✓ Executed SEQUENTIALLY:

1. ./prompts/005-setup-database.md → Success (executor: coder, quality gates ✓)
2. ./prompts/006-create-migrations.md → Success (executor: coder, quality gates ✓)
3. ./prompts/007-seed-data.md → Success (executor: coder, quality gates ✓)

✓ All archived to ./prompts/completed/

<results>
[Consolidated summary showing progression through each step with quality gate results]
</results>
</sequential_output>
</output>

<critical_notes>

<execution_rules>
- For parallel execution: ALL tool calls (SlashCommand and Task) MUST be in a single message
- For sequential execution: Wait for each prompt to complete fully (including quality gates) before starting next
- Archive prompts only after successful completion
- If any prompt fails, stop sequential execution and report error
- Provide clear, consolidated results for multiple prompt execution
</execution_rules>

<routing_rules>
- ALWAYS analyze task type before execution (frontmatter check → auto-detection)
- Code tasks → `/coder` workflow (triggers hooks: standards → tests)
- Non-code tasks → `general-purpose` agent (no hooks)
- When in doubt → route to `/coder` (safer default for quality)
- Respect explicit frontmatter executor specifications
</routing_rules>

<quality_gate_behavior>
- `/coder` invocations automatically trigger SubagentStop hooks
- Hooks signal orchestrator to invoke coding-standards-checker
- Then hooks signal orchestrator to invoke tester
- This happens automatically for ALL code tasks
- General-purpose tasks skip quality gates entirely
- Mixed parallel execution: Code tasks get quality gates, general tasks don't
</quality_gate_behavior>

<frontmatter_usage>
To explicitly control executor, add to top of prompt file:

```yaml
---
executor: coder
---
```

or

```yaml
---
executor: general-purpose
---
```

This overrides auto-detection.
</frontmatter_usage>
  </critical_notes>

<benefits>

<intelligent_routing>
✅ **Automatic Quality Gates**: Code tasks automatically get standards checks and tests via /coder workflow
✅ **Lightweight Non-Code Tasks**: Research, documentation, analysis tasks skip unnecessary quality gates
✅ **Flexible Control**: Frontmatter allows explicit executor control when needed
✅ **Smart Defaults**: Auto-detection means prompts "just work" without manual configuration
✅ **CI/CD Ready**: Autonomous execution with appropriate quality gates per task type
</intelligent_routing>

<workflow_integration>
✅ **Leverages /coder Infrastructure**: Reuses existing hooks, agents, and quality gate workflows
✅ **Consistent Quality**: Code changes always go through the same rigorous process
✅ **Hook-Driven**: SubagentStop hooks automatically coordinate quality gates
✅ **No Duplication**: Routing through /coder means one source of truth for code quality workflow
</workflow_integration>

<examples>

<example_auto_detection_code>
Prompt content:
"Implement a React component for user authentication with JWT tokens. Ensure tests pass and code follows standards."

Auto-detection:
- Keywords found: "implement" (1), "component" (1), "React" (1), "authentication" (1), "tests" (1), "standards" (1)
- Code score: 6
- Decision: Route to /coder ✓
- Quality gates applied: Standards check ✓ | Tests ✓
</example_auto_detection_code>

<example_auto_detection_research>
Prompt content:
"Research competitor APIs and document their authentication approaches. Create a comparison report."

Auto-detection:
- Keywords found: "research" (1), "document" (1), "report" (1)
- Non-code score: 3, Code score: 0
- Decision: Route to general-purpose ✓
- Quality gates: None (not needed for research)
</example_auto_detection_research>

<example_frontmatter_override>
Prompt with frontmatter:
```yaml
---
executor: general-purpose
---

Build a quick prototype for internal testing only. Skip quality checks.
```

Execution:
- Frontmatter detected: executor = general-purpose
- Auto-detection skipped (frontmatter takes precedence)
- Routed to: general-purpose agent ✓
- Quality gates: None
</example_frontmatter_override>

</examples>

</benefits>