# Configuration Hierarchy

```mermaid
flowchart TB
    L1["<b>1. Managed Policy</b><br/><i>Cannot be overridden</i>"]
    L2["<b>2. CLI Arguments</b><br/><i>Session-only flags</i>"]
    L3["<b>3. Local Settings</b><br/><i>.claude/settings.local.json</i>"]
    L4["<b>4. Project Settings</b><br/><i>.claude/settings.json (Git committed)</i>"]
    L5["<b>5. User Settings</b><br/><i>~/.claude/settings.json</i>"]
    L6["<b>6. Defaults</b><br/><i>Built-in</i>"]

    L1 -->|"overrides"| L2
    L2 -->|"overrides"| L3
    L3 -->|"overrides"| L4
    L4 -->|"overrides"| L5
    L5 -->|"overrides"| L6

    style L1 fill:#ff4444,color:#fff,stroke:#cc0000
    style L2 fill:#ff8844,color:#fff,stroke:#cc6600
    style L3 fill:#ffcc44,color:#000,stroke:#cc9900
    style L4 fill:#44cc44,color:#fff,stroke:#009900
    style L5 fill:#4488ff,color:#fff,stroke:#0044cc
    style L6 fill:#8844ff,color:#fff,stroke:#5500cc

    NOTE["<b>Note:</b> Hooks MERGE across all levels.<br/>CLAUDE.md is ADDITIVE (not overriding)."]
    style NOTE fill:#333,color:#fff,stroke:#666
```

Configuration follows a strict 6-level precedence where higher levels override lower ones. Managed Policy at the top cannot be overridden by anything below it, while built-in defaults serve as the baseline. The key exception is that hooks merge across all levels rather than replacing, and CLAUDE.md instructions are additive -- they accumulate from every level rather than overriding.
