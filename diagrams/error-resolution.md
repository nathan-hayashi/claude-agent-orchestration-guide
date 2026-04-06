# Error Resolution Flowchart

```mermaid
flowchart TD
    START(["Common Failure<br/>Encountered"])

    ERR1{"Settings Error:<br/>Invalid JSON?"}
    FIX1["<b>Fix:</b> Remove // comments<br/>and trailing commas.<br/>JSON does not allow them."]

    ERR2{"Model field corrupt?<br/><code>claude-opus-4-6[1m]</code>"}
    FIX2["<b>Fix:</b> ANSI escape code<br/>injected into config.<br/>Correct to: <code>claude-opus-4-6</code>"]

    ERR3{"autoMode.environment<br/>not accepting string?"}
    FIX3["<b>Fix:</b> Value must be an<br/>array of strings, not<br/>a single string."]

    ERR4{"Threshold router<br/>not firing T1/T2?"}
    FIX4["<b>Fix:</b> Add mandatory<br/>'Threshold Router' section<br/>to CLAUDE.md with tier rules."]

    ERR5{"Rules path not<br/>detected by Claude?"}
    FIX5["<b>Fix:</b> Symlink<br/>~/.claude/rules into<br/>project .claude/ directory."]

    ERR6{"GitHub push protection<br/>blocked push?"}
    FIX6["<b>Fix:</b> Hardcoded OAuth token<br/>found in .mcp.json.<br/>Replace with ${GH_TOKEN}."]

    START --> ERR1
    ERR1 -->|"Yes"| FIX1
    ERR1 -->|"No"| ERR2
    ERR2 -->|"Yes"| FIX2
    ERR2 -->|"No"| ERR3
    ERR3 -->|"Yes"| FIX3
    ERR3 -->|"No"| ERR4
    ERR4 -->|"Yes"| FIX4
    ERR4 -->|"No"| ERR5
    ERR5 -->|"Yes"| FIX5
    ERR5 -->|"No"| ERR6
    ERR6 -->|"Yes"| FIX6

    style FIX1 fill:#22cc66,color:#fff,stroke:#119944
    style FIX2 fill:#22cc66,color:#fff,stroke:#119944
    style FIX3 fill:#22cc66,color:#fff,stroke:#119944
    style FIX4 fill:#22cc66,color:#fff,stroke:#119944
    style FIX5 fill:#22cc66,color:#fff,stroke:#119944
    style FIX6 fill:#22cc66,color:#fff,stroke:#119944

    style ERR1 fill:#ffaa22,color:#fff,stroke:#cc8800
    style ERR2 fill:#ffaa22,color:#fff,stroke:#cc8800
    style ERR3 fill:#ffaa22,color:#fff,stroke:#cc8800
    style ERR4 fill:#ffaa22,color:#fff,stroke:#cc8800
    style ERR5 fill:#ffaa22,color:#fff,stroke:#cc8800
    style ERR6 fill:#ffaa22,color:#fff,stroke:#cc8800
```

These six errors represent the most common failure modes encountered during orchestration setup. Each one has a specific root cause and a deterministic fix -- no guesswork required. The ANSI escape code corruption (error 2) and the GitHub push protection block (error 6) are particularly insidious because they silently modify config values or block operations without obvious error messages pointing to the real cause.
