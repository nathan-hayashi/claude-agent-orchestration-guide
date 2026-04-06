# Threshold Escalation Flowchart

```mermaid
flowchart TD
    START(["User Prompt Received"])
    ANALYZE["Analyze Prompt<br/><i>Files, Dirs, Keywords,<br/>Paths, Diff</i>"]
    COMPUTE["Compute Complexity Score"]

    SIGNALS["<b>Scoring Signals</b><br/>+1 per 3 files touched<br/>+1 per 2 directories<br/>+3 security-sensitive paths<br/>+2 trigger keywords<br/>+2 infra files (Terraform, Docker)<br/>+1 per 100 lines changed"]

    DECIDE{{"Score Range?"}}

    T1["<b>TIER 1: Solo</b><br/>Score 0-3<br/>/effort medium<br/>Single Opus 4.6 agent"]
    T2["<b>TIER 2: Lean Pipeline</b><br/>Score 4-7<br/>Implement, then spawn<br/>3 review subagents"]
    T3["<b>TIER 3: Full Orchestra</b><br/>Score 8+<br/>/ultrathink planning<br/>OCR + Codex review"]

    OVERRIDE["<b>Manual Override</b><br/><i>'just do it'</i> = downgrade 1 tier<br/><i>'full review'</i> = upgrade to T3"]

    START --> ANALYZE
    ANALYZE --> COMPUTE
    COMPUTE -.-> SIGNALS
    COMPUTE --> DECIDE

    DECIDE -->|"0 - 3"| T1
    DECIDE -->|"4 - 7"| T2
    DECIDE -->|"8+"| T3

    OVERRIDE -.->|"applies to"| DECIDE

    style T1 fill:#22cc66,color:#fff,stroke:#119944
    style T2 fill:#ffaa22,color:#fff,stroke:#cc8800
    style T3 fill:#ff4444,color:#fff,stroke:#cc0000
    style SIGNALS fill:#f0f0f0,color:#333,stroke:#999
    style OVERRIDE fill:#333,color:#fff,stroke:#666
```

Every user prompt is analyzed for complexity signals before any work begins. The scoring formula weighs file count, directory spread, security sensitivity, and change volume to produce a numeric score. That score determines which tier executes the task, though users can manually override with "just do it" (downgrade) or "full review" (force T3).
