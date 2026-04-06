# Phase Dependency Graph

```mermaid
flowchart LR
    P0(["<b>P0</b><br/>Pre-Flight"])
    P1(["<b>P1</b><br/>CLAUDE.md<br/>+ Config"])
    P2(["<b>P2</b><br/>Hooks<br/>System"])
    P3(["<b>P3</b><br/>Threshold<br/>Engine"])

    P4(["<b>P4</b><br/>Turbo<br/>Skills"])
    P5(["<b>P5</b><br/>OCR"])
    P6(["<b>P6</b><br/>Codex"])

    P7(["<b>P7</b><br/>Custom<br/>Subagents"])
    P8(["<b>P8</b><br/>Skills<br/>Library"])

    P9(["<b>P9</b><br/>Auto Mode"])
    P10(["<b>P10</b><br/>Integration<br/>Test"])

    P0 -->|"SEQUENTIAL"| P1
    P1 -->|"GATE"| P2
    P2 -->|"GATE"| P3

    P3 -->|"PARALLEL"| P4
    P3 -->|"PARALLEL"| P5
    P3 -->|"PARALLEL"| P6

    P3 --> P7
    P3 --> P8

    P7 --> P9
    P8 --> P9

    P4 --> P10
    P5 --> P10
    P6 --> P10
    P7 --> P10
    P8 --> P10
    P9 --> P10

    style P0 fill:#4488ff,color:#fff
    style P1 fill:#4488ff,color:#fff
    style P2 fill:#4488ff,color:#fff
    style P3 fill:#ff4444,color:#fff

    style P4 fill:#22cc66,color:#fff
    style P5 fill:#22cc66,color:#fff
    style P6 fill:#22cc66,color:#fff

    style P7 fill:#ffaa22,color:#fff
    style P8 fill:#ffaa22,color:#fff
    style P9 fill:#8844ff,color:#fff
    style P10 fill:#ff4488,color:#fff
```

Phases P0 through P3 form a strict sequential gate -- each must complete before the next begins, as later phases depend on the configuration and infrastructure established earlier. After P3 (Threshold Engine), phases P4, P5, and P6 can execute in parallel since they are independent integration targets. Phase P9 (Auto Mode) requires both P7 (Custom Subagents) and P8 (Skills Library), while P10 (Integration Test) cannot begin until every other phase has completed.
