# System Architecture

```mermaid
flowchart TB
    subgraph CONFIG["CONFIGURATION LAYER"]
        direction LR
        CM["CLAUDE.md<br/><i>Global + Project</i>"]
        SJ["settings.json<br/><i>Hooks + Permissions</i>"]
        AM["Auto Memory<br/><i>Store Sessions</i>"]
        RU[".claude/rules<br/><i>Rules Files</i>"]
    end

    subgraph ENFORCE["ENFORCEMENT & ROUTING LAYER"]
        direction LR
        HL["Hooks Layer<br/><i>PreToolUse / PostToolUse<br/>Notification / Stop</i>"]
        TR["Threshold Router Skill<br/><i>Complexity Score<br/>Tier 1 / 2 / 3</i>"]
    end

    subgraph EXEC["EXECUTION LAYER"]
        direction LR
        T1["TIER 1<br/><b>Score 0-3</b><br/>Solo Agent<br/>Opus 4.6"]
        T2["TIER 2<br/><b>Score 4-7</b><br/>Lean Pipeline<br/>3 Subagents"]
        T3["TIER 3<br/><b>Score 8+</b><br/>Full Orchestra<br/>OCR + Codex"]
        TS["Turbo Skills<br/><b>60+ Workflows</b>"]
    end

    subgraph REVIEW["REVIEW AGENTS LAYER"]
        direction LR
        SEC["Security<br/><i>Sonnet 4.6</i>"]
        QA["Quality<br/><i>Sonnet 4.6</i>"]
        FIX["Fixer<br/><i>Opus 4.6</i>"]
        OCR["OCR Review<br/><i>Multi-Agent</i>"]
        CDX["Codex Review<br/><i>GPT-5.4</i>"]
    end

    CONFIG --> ENFORCE
    ENFORCE --> EXEC
    EXEC --> REVIEW
```

The orchestration system is organized into four layers that flow top-to-bottom. Configuration feeds into enforcement and routing, which determines the execution tier, which then dispatches to the appropriate review agents. Each layer is independently configurable and the tier selection governs how many review agents participate in any given task.
