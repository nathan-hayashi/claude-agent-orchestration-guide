# Before vs After Workflow

```mermaid
flowchart TB
    subgraph BEFORE["BEFORE: Manual Workflow"]
        direction TB
        B1["Developer writes code"]
        B2["Manually runs linter"]
        B3["Manually reviews own code<br/><i>(confirmation bias)</i>"]
        B4["Commits without<br/>security check"]
        B5["Hopes for the best<br/>on PR review"]
        B6["Reviewer finds issues<br/><b>24 hrs later</b>"]
        BSTAT["Time: 24-48 hrs<br/>Security gaps: HIGH"]

        B1 --> B2 --> B3 --> B4 --> B5 --> B6
        B6 -.-> BSTAT
    end

    subgraph AFTER["AFTER: Orchestrated Workflow"]
        direction TB
        A1["Developer writes code"]
        A2["Auto-format via<br/>PostToolUse hook"]
        A3["Threshold router<br/>scores complexity"]
        A4["Subagents auto-review<br/><i>Security + Quality</i>"]
        A5["Fixer steelmans<br/>findings"]
        A6["OCR discourse phase<br/><i>(T3 only)</i>"]
        A7["Codex adversarial<br/>challenge <i>(T3)</i>"]
        ASTAT["Time: 5-15 min<br/>Security gaps: MINIMAL"]

        A1 --> A2 --> A3 --> A4 --> A5 --> A6 --> A7
        A7 -.-> ASTAT
    end

    style BSTAT fill:#ff4444,color:#fff,stroke:#cc0000
    style ASTAT fill:#22cc66,color:#fff,stroke:#119944
    style BEFORE fill:#fff5f5,color:#333,stroke:#ff4444
    style AFTER fill:#f5fff5,color:#333,stroke:#22cc66
```

The manual workflow relies on the developer to self-review and catch issues, introducing confirmation bias and leaving security gaps until a human reviewer is available hours or days later. The orchestrated workflow automates formatting, scoring, and multi-agent review within minutes, catching security and quality issues before they ever reach a human reviewer. The T3 tier adds OCR multi-persona discourse and Codex adversarial challenge for the highest-risk changes.
