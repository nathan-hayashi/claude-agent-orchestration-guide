# Decision Matrix

```mermaid
block-beta
    columns 7
    HEADER["<b>Task Type</b>"]:1 COL1["<b>Solo<br/>T1</b>"]:1 COL2["<b>Lean Pipeline<br/>T2</b>"]:1 COL3["<b>Full Orchestra<br/>T3</b>"]:1 COL4["<b>OCR<br/>Review</b>"]:1 COL5["<b>Codex<br/>Adversarial</b>"]:1 COL6["<b>Turbo<br/>/finalize</b>"]:1

    R1["Single file edit"]:1 R1C1["Always"]:1 R1C2["Never"]:1 R1C3["Never"]:1 R1C4["Never"]:1 R1C5["Never"]:1 R1C6["Sometimes"]:1
    R2["Feature (2-4 files)"]:1 R2C1["Usually"]:1 R2C2["Sometimes"]:1 R2C3["Never"]:1 R2C4["Never"]:1 R2C5["Never"]:1 R2C6["Usually"]:1
    R3["Multi-module feature"]:1 R3C1["Never"]:1 R3C2["Always"]:1 R3C3["Sometimes"]:1 R3C4["Sometimes"]:1 R3C5["Never"]:1 R3C6["Always"]:1
    R4["Refactor / migration"]:1 R4C1["Never"]:1 R4C2["Usually"]:1 R4C3["Sometimes"]:1 R4C4["Sometimes"]:1 R4C5["Rarely"]:1 R4C6["Always"]:1
    R5["IAM policy changes"]:1 R5C1["Never"]:1 R5C2["Rarely"]:1 R5C3["Always"]:1 R5C4["Always"]:1 R5C5["Always"]:1 R5C6["Always"]:1
    R6["Architecture redesign"]:1 R6C1["Never"]:1 R6C2["Never"]:1 R6C3["Always"]:1 R6C4["Always"]:1 R6C5["Always"]:1 R6C6["Always"]:1
    R7["Terraform modules"]:1 R7C1["Rarely"]:1 R7C2["Usually"]:1 R7C3["Sometimes"]:1 R7C4["Sometimes"]:1 R7C5["Sometimes"]:1 R7C6["Always"]:1
    R8["Docker / Compose"]:1 R8C1["Sometimes"]:1 R8C2["Usually"]:1 R8C3["Rarely"]:1 R8C4["Sometimes"]:1 R8C5["Rarely"]:1 R8C6["Always"]:1
    R9["PowerShell scripts"]:1 R9C1["Usually"]:1 R9C2["Sometimes"]:1 R9C3["Rarely"]:1 R9C4["Rarely"]:1 R9C5["Never"]:1 R9C6["Usually"]:1
    R10["n8n workflows"]:1 R10C1["Usually"]:1 R10C2["Sometimes"]:1 R10C3["Rarely"]:1 R10C4["Never"]:1 R10C5["Never"]:1 R10C6["Sometimes"]:1

    style COL1 fill:#22cc66,color:#fff
    style COL2 fill:#ffaa22,color:#fff
    style COL3 fill:#ff4444,color:#fff
    style COL4 fill:#8844ff,color:#fff
    style COL5 fill:#ff4488,color:#fff
    style COL6 fill:#4488ff,color:#fff
```

This matrix maps ten common task types to six orchestration components, indicating how frequently each component is engaged. Simple edits stay in T1 solo mode, while security-sensitive work like IAM policies always escalates to the full T3 orchestra with OCR and Codex adversarial review. The Turbo /finalize step is used for nearly every task type that touches more than a single file.
