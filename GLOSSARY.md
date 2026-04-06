# Glossary: Key Terms and Concepts

This glossary defines every key term used in the Claude Code Agent Orchestration guide. Entries are alphabetical. Each definition includes a brief note on where the term is most relevant in the guide.

---

**Agent Teams**
An experimental feature that enables parallel orchestration of multiple Claude Code agents working on independent subtasks simultaneously. Rather than a single agent handling everything sequentially, agent teams can split work across parallel branches (e.g., one agent writes the frontend while another writes the backend). This is distinct from subagents (which are spawned for review); agent teams are spawned for parallel implementation. Covered in the execution layer and advanced orchestration patterns.

**Auto Mode**
A Claude Code operating mode where the agent works autonomously with broad tool permissions, executing multi-step tasks without asking for confirmation at each step. Auto mode is governed by safety guardrails defined in `settings.json` (allow/deny lists), hooks (which fire before permission checks and can block operations), and rules files. The key design principle is defense-in-depth: even with broad permissions, multiple independent safety layers remain active. Covered in Layer 2 (Enforcement & Routing) and the hooks system documentation.

**CLAUDE.md**
A plain Markdown file that provides instructions to Claude Code. It is the primary mechanism for telling Claude about your project, coding standards, architecture decisions, and workflow preferences. CLAUDE.md files exist at three levels: global (`~/.claude/CLAUDE.md`, loaded for all projects), project (`./CLAUDE.md`, shared with the team via version control), and personal (`./CLAUDE.local.md`, your local overrides). All levels are additive -- they stack rather than override each other. The global file is typically around 50 lines and is reloaded after every compaction event. Covered in Layer 1 (Configuration).

**Codex**
OpenAI's CLI coding assistant, powered by GPT-5.4. In the orchestration system, Codex is used specifically for cross-model adversarial review during Tier 3 tasks. The rationale is that if Claude Opus generated the code and Claude Sonnet reviewed it, they may share similar reasoning blind spots due to coming from the same model family. Running the code through a completely different model architecture (GPT-5.4) provides a genuinely independent perspective. Covered in Layer 4 (Review Agents) and the Codex plugin setup phase.

**Compaction**
The process by which Claude Code compresses prior conversation messages to stay within its context window limits. When the conversation grows too long, older messages are summarized into a compact form. After compaction, CLAUDE.md files are reloaded to ensure critical instructions are not lost. This is why keeping your global CLAUDE.md concise (~50 lines) matters -- it is reloaded frequently. Covered in Layer 1 (Configuration) and context management best practices.

**Configuration Hierarchy**
The 6-level precedence system that determines which settings take effect when multiple sources define the same configuration. From lowest to highest precedence: (1) Claude defaults, (2) global `settings.json`, (3) global `CLAUDE.md`, (4) project `settings.json`, (5) project `CLAUDE.md`, (6) personal `CLAUDE.local.md`. Higher levels can add to but not remove instructions from lower levels. Covered in Layer 1 (Configuration).

**Defense-in-Depth**
A security philosophy where multiple independent layers of protection are stacked so that if any single layer fails, others still provide protection. In the orchestration system, defense-in-depth is achieved through the combination of hooks (which fire before permission checks), permission allow/deny lists (which gate tool access), path-scoped rules (which inject context-specific safety instructions), and worktree isolation (which prevents review agents from modifying the main repository). No single mechanism is relied upon exclusively. Covered in Layer 2 (Enforcement & Routing).

**Effort Level**
A setting that controls how deeply Claude reasons about each response. Options are `low` (fast, surface-level), `medium` (balanced, default for Tier 1), `high` (thorough), and `max` (deepest reasoning, used with `/ultrathink` in Tier 3). Higher effort levels consume more tokens and take longer but produce more thoughtful analysis. The threshold router adjusts effort level based on the tier: T1 uses medium, T3 uses max. Covered in Layer 3 (Execution) and the threshold router documentation.

**Fork (Context)**
Creating a parallel agent process that inherits the parent agent's full conversation context. Unlike spawning a fresh subagent (which starts with only the instructions you give it), a context fork gives the child agent everything the parent knows. This is useful when you want a reviewer to understand not just the code diff but also the reasoning and discussion that led to the changes. Context forks consume more tokens than fresh subagents. Covered in advanced orchestration patterns.

**Frontmatter**
YAML metadata placed at the top of a Markdown file, enclosed between `---` markers. In the orchestration system, frontmatter is used in skill files (to define the skill name, description, and trigger conditions), rules files (to define `paths:` glob patterns for conditional activation), and agent persona files (to define the agent's role and capabilities). Example: a rules file with `paths: ["src/auth/**"]` in its frontmatter only activates when editing authentication code. Covered in Layer 1 (Configuration) for rules and Layer 3 (Execution) for skills.

**Gate Check**
A prerequisite verification step that must pass before the system proceeds to the next phase. Gate checks are used throughout the orchestration pipeline: the build must pass before deployment, tests must pass before committing, the type checker must succeed before claiming a task is complete. Gate checks prevent cascading failures by catching problems early. In the threshold router, gate checks verify that prior-tier work is solid before escalating to more expensive review processes. Covered in Layer 2 (Enforcement & Routing) and the finalize workflow.

**Hooks**
Shell scripts configured in `settings.json` that fire automatically on specific Claude Code events. The 5 event types are PreToolUse (before a tool runs), PostToolUse (after success), PostToolUseFail (after failure), Notification (on alerts), and Stop (when Claude finishes a turn). Hooks receive context via environment variables and return JSON responses to allow, deny, or modify operations. The critical design property is that hooks fire BEFORE permission checks, making them the first line of defense even in auto mode. Covered in Layer 2 (Enforcement & Routing).

**MCP (Model Context Protocol)**
An open standard (donated to the Linux Foundation by Anthropic in 2025) for connecting AI models to external tools and data sources. MCP servers expose capabilities (tools, resources, prompts) that Claude Code can discover and invoke. Examples include GitHub integration (read/write PRs, issues, files), browser automation (Playwright), and documentation lookup (Context7). MCP provides a standardized interface so that tool integrations work consistently regardless of the specific service. Covered in the integration layer and MCP server configuration.

**Memory (Auto Memory)**
Claude Code's persistent, file-based memory system that stores learnings across conversation sessions. When Claude discovers something about your project -- a naming convention, an architectural pattern, a preference you expressed -- it can save that observation to `~/.claude/projects/<project>/memory/`. These memory files are plain text, human-readable, and loaded automatically in future sessions. You can inspect, edit, or delete them at any time. Memory reduces the need to re-explain project context in every session. Covered in Layer 1 (Configuration).

**OCR (Open Code Review)**
A multi-agent code review plugin that simulates a structured peer review with multiple specialized reviewer personas. In a typical OCR session, 3 reviewers (principal, security, quality) independently analyze the changes, then engage in 2 rounds of discourse where they challenge each other's findings and raise new concerns. The discourse format is more thorough than independent reviews because reviewers build on each other's observations. OCR is used in Tier 3 tasks and can also be invoked directly via `/ocr:review`. Covered in Layer 4 (Review Agents).

**Path-Scoped Rules**
Instruction files stored in `.claude/rules/*.md` that activate conditionally based on which files are being edited. Each rule file has YAML frontmatter with a `paths:` field containing glob patterns (e.g., `["src/auth/**", "src/iam/**"]`). When you edit a file matching any of those patterns, the rule's instructions are loaded into Claude's context. When you are editing unrelated files, the rule stays dormant, saving context tokens. This mechanism enables domain-specific instructions without bloating the base prompt. Covered in Layer 1 (Configuration).

**Plugin**
A third-party extension for Claude Code that adds capabilities beyond the built-in tool set. Plugins are installed via the plugin marketplace (`/plugin marketplace add`) and can provide new tools, review workflows, or integrations with external services. Notable plugins in the orchestration system include OCR (multi-agent code review) and the Codex bridge (cross-model review). Plugins are configured in `.claude/plugins/` with their own settings and persona files. Covered in Layer 4 (Review Agents) and the plugin setup phases.

**Prompt Caching**
An Anthropic API feature that reduces cost when the same context (CLAUDE.md files, system prompts, conversation history) is sent repeatedly across API calls. Cached prompts cost approximately 10% of the full price. In practice, the orchestration system achieves approximately 92% cache hit rates because CLAUDE.md content, rules, and skill definitions are stable across calls within a session. This makes multi-agent orchestration significantly cheaper than the raw per-call pricing would suggest. Covered in token economics and cost optimization.

**Rules Files**
See "Path-Scoped Rules" above. The terms are used interchangeably in the guide.

**Skill**
A reusable instruction file stored in `.claude/skills/` that defines a workflow Claude can invoke via a slash command. Skills are Markdown files with frontmatter (name, description, trigger) and a body containing step-by-step instructions. Skills are composable: one skill can invoke another. The orchestration system includes 60+ turbo skills covering workflows like `/finalize` (post-implementation quality pipeline), `/ship` (commit + push + PR), `/investigate` (systematic debugging), and `/self-improve` (extract lessons into reusable rules). Covered in Layer 3 (Execution).

**Steelman**
A reasoning technique where you give the strongest possible interpretation of an argument before deciding whether to reject it. In the orchestration system, the fixer agent uses steelmanning when evaluating review findings: before dismissing a finding as a false positive, it first considers the strongest case for why the finding might be valid. This reduces the chance of accidentally ignoring real issues. The opposite of a strawman argument. Covered in Layer 4 (Review Agents), specifically the fixer agent's evaluation process.

**Subagent**
A child Claude process spawned by the main agent for a specific, scoped task. Subagents receive focused instructions (e.g., "review this diff for security vulnerabilities") and return their findings to the parent. They can run in parallel with each other. In the orchestration system, subagents are used for security review, quality review, and fixing. Subagents typically run in Git worktree isolation (read-only access to an isolated repo copy) to prevent them from accidentally modifying the main codebase. Covered in Layer 3 (Execution) and Layer 4 (Review Agents).

**Threshold Router**
A skill that runs on every single user prompt to compute a complexity score (0-10) and route the task to the appropriate execution tier. Scoring factors include the number of files likely affected, whether security-sensitive code is involved, whether cross-cutting changes are needed, and the overall architectural impact. Score 0-3 routes to Tier 1 (solo agent), 4-7 to Tier 2 (implement + 3 reviewers), and 8-10 to Tier 3 (full orchestra). Users can override with "just do it" (downgrade) or "full review" (upgrade to T3). Covered in Layer 2 (Enforcement & Routing).

**Tier 1 (T1)**
The simplest execution tier for tasks scoring 0-3 on the complexity scale. A single Opus 4.6 agent handles the task directly with `/effort medium`. No subagents are spawned. Appropriate for simple bug fixes, small refactors, documentation updates, and straightforward feature additions. Most day-to-day development tasks fall into this tier. Covered in Layer 3 (Execution).

**Tier 2 (T2)**
The moderate execution tier for tasks scoring 4-7. The primary agent implements the changes first (while conversation context is fresh), then spawns 3 parallel subagents: a security reviewer, a quality reviewer, and a fixer that evaluates and applies valid findings. Appropriate for multi-file features, API endpoints, database changes, and anything touching auth. Covered in Layer 3 (Execution).

**Tier 3 (T3)**
The maximum execution tier for tasks scoring 8-10. The full workflow includes ultrathink planning (deep reasoning before coding), implementation with verification, OCR multi-agent discourse review (3 reviewers debating over 2 rounds), and Codex cross-model adversarial review (GPT-5.4). Reserved for major architectural changes, security-critical implementations, and cross-cutting refactors. Covered in Layer 3 (Execution).

**Token Economics**
The practice of optimizing cost in multi-agent AI systems by choosing the right model for each role and leveraging prompt caching. Key principles: use cheaper models (Sonnet) for focused review tasks and expensive models (Opus) only where deeper reasoning is needed; exploit prompt caching (92% hit rate) to reduce repeated context costs; avoid spawning agents unnecessarily (the threshold router prevents Tier 3 costs on Tier 1 tasks). Anthropic pricing (2026): Opus 4.6 at $5/$25 per million input/output tokens, Sonnet 4.6 at $3/$15, Haiku 4.5 at $1/$5. Covered in cost optimization and the component inventory.

**Turbo**
A collection of 60+ composable development workflow skills for Claude Code. These are NOT related to Turborepo or Vercel's Turbo product. Turbo skills are Markdown instruction files in `.claude/skills/` that define repeatable workflows (finalize, review, ship, investigate, audit, etc.). They are called "turbo" because they accelerate common development patterns into single-command workflows. Skills can invoke other skills, enabling pipeline composition. Covered in Layer 3 (Execution).

**Worktree Isolation**
A security mechanism that uses Git worktrees to give subagents an isolated copy of the repository. A Git worktree is a separate working directory linked to the same repository, allowing multiple branches to be checked out simultaneously. In the orchestration system, review subagents (security reviewer, quality reviewer) run in worktrees with read-only access. Even if a subagent's behavior were somehow manipulated, it cannot modify the actual codebase because it is operating on an isolated copy. Covered in Layer 4 (Review Agents) and the defense-in-depth security model.

**WSL 2 (Windows Subsystem for Linux)**
Microsoft's Linux compatibility layer that runs a full Linux kernel inside Windows. The orchestration system described in the guide runs on WSL 2 (Ubuntu 24.04). WSL 2 achieves 87-95% of native Linux performance for most workloads, but cross-filesystem operations (accessing Windows files from Linux or vice versa) drop to approximately 6% of native speed. All development should stay within the Linux filesystem (`~/` not `/mnt/c/`) for optimal performance. Covered in the environment setup and WSL performance considerations.
