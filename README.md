# AMBA APB UVM Verification Environment

![CI](https://github.com/duytan1412/AMBA_APB_UVM/actions/workflows/uvm-ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![UVM](https://img.shields.io/badge/UVM-1.2-green.svg)
![Tool](https://img.shields.io/badge/Cadence-Xcelium%2020.09-orange.svg)

A complete **Universal Verification Methodology (UVM 1.2)** testbench developed from scratch to verify an **AMBA APB (Advanced Peripheral Bus)** Slave Memory module.

Demonstrates a professional "**Verification-First**" mindset: **SystemVerilog Assertions (SVA)**, **Functional Coverage**, **Constrained-Random Verification**, and a full **UVM class hierarchy**.

---

## 🏗 UVM Environment Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                        apb_test                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                      apb_env                            │  │
│  │                                                         │  │
│  │  ┌─────────────────┐   ┌──────────────┐                │  │
│  │  │    apb_agent     │   │ apb_scoreboard│                │  │
│  │  │  ┌─────────────┐│   │ (Ref Model)  │                │  │
│  │  │  │ apb_driver   ││   └──────────────┘                │  │
│  │  │  ├─────────────┤│                                    │  │
│  │  │  │ apb_sequencer││   ┌──────────────┐                │  │
│  │  │  ├─────────────┤│   │ apb_coverage  │                │  │
│  │  │  │ apb_monitor  ││   │ (Func Cov)   │                │  │
│  │  │  └─────────────┘│   └──────────────┘                │  │
│  │  └─────────────────┘                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
│                         ↕ apb_if (4 SVA Properties)           │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              DUT: apb_ram (APB Slave Memory)            │  │
│  │         32-bit data | 32-bit addr | PSLVERR support     │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

### Component Details

| File | Role | Key Features |
|------|------|-------------|
| `apb_transaction.sv` | Sequence Item | Randomized R/W, word-alignment constraints |
| `apb_sequence.sv` | Test Scenarios | Single Write, Single Read, Burst, Write-Read-Back |
| `apb_driver.sv` | Bus Driver | APB Setup/Access phase protocol, PREADY wait |
| `apb_monitor.sv` | Passive Observer | Analysis port broadcast to scoreboard & coverage |
| `apb_agent.sv` | Agent Container | Encapsulates Driver + Sequencer + Monitor |
| `apb_scoreboard.sv` | Self-Checking | Associative array ref model, mismatch counter |
| `apb_coverage.sv` | Coverage Collector | R/W x Addr cross, data patterns, B2B timing |
| `apb_if.sv` | HW Interface + SVA | 4 protocol assertions (PENABLE, PREADY, stability) |

---

## 🔬 Key Verification Features

### 1. Assertion-Based Verification (ABV)
4 SVA properties embedded in `apb_if.sv`:
```systemverilog
// PENABLE must rise 1 cycle after PSEL
($rose(psel) |=> penable);

// PSEL/PENABLE stable until PREADY
(psel && penable && !pready) |=> (psel && penable);

// Control signals stable during access phase
(psel && !penable) |=> ($stable(paddr) && $stable(pwrite));

// PENABLE falls after PREADY
(penable && pready) |=> (!penable);
```

### 2. Reference Model Scoreboard
- Uses SystemVerilog **associative arrays** as golden memory model
- Real-time comparison of `PRDATA` vs expected values
- Final report with match/mismatch statistics

### 3. Functional Coverage (`apb_coverage.sv`)
```
Coverage Groups:
├── cg_apb_protocol
│   ├── cp_operation:   READ / WRITE
│   ├── cp_addr_range:  Low (0x00-0x3C) / Mid (0x40-0x7C) / High (0x80+)
│   ├── cp_write_data:  All-zeros / All-ones / Walking-one / Random
│   ├── cp_slverr:      No Error / Error
│   ├── cx_op_addr:     CROSS (operation × address)
│   └── cx_op_err:      CROSS (operation × error)
└── cg_apb_timing
    └── cp_b2b_ops:     W→W / R→W / W→R / R→R transitions
```

### 4. Constrained-Random Verification (CRV)
UVM sequences generate randomized traffic with constraints ensuring word-aligned addresses and valid coin/data patterns.

---

## 📂 Project Structure

```
AMBA_APB_UVM/
├── rtl/
│   └── apb_ram.sv              # DUT: APB Slave Memory (SystemVerilog)
├── tb/
│   └── uvm/
│       ├── apb_if.sv           # Interface + 4 SVA Assertions
│       ├── apb_transaction.sv  # Randomized Sequence Item
│       ├── apb_sequence.sv     # Test Scenarios
│       ├── apb_driver.sv       # APB Protocol Driver
│       ├── apb_monitor.sv      # Passive Bus Monitor
│       ├── apb_agent.sv        # Agent (Driver + Sequencer + Monitor)
│       ├── apb_scoreboard.sv   # Self-Checking Reference Model
│       ├── apb_coverage.sv     # Functional Coverage Collector
│       ├── apb_env.sv          # Environment
│       └── tb_top.sv           # Top-level Test Module
├── docs/
│   └── apb_waveform.png        # EPWave timing diagram
├── .github/workflows/
│   └── uvm-ci.yml              # CI: Syntax lint (iverilog)
├── Makefile
└── README.md
```

---

## ⚙️ How to Run

### Option 1: EDA Playground (Recommended)

> Full UVM 1.2 requires commercial simulators. Use EDA Playground for free.

1. Open [EDA Playground](https://edaplayground.com/)
2. Upload all `.sv` files into testbench/design panes
3. Configure:
   - **Languages:** SystemVerilog/Verilog
   - **UVM:** UVM 1.2
   - **Simulator:** Cadence Xcelium 20.09
   - **Top Module:** `tb_top`
4. Click **Run**
5. Verify: Console shows `Total Mismatches: 0`

### Option 2: Local (Syntax Check Only)

```bash
make compile    # Requires iverilog with -g2012 support
```

> ⚠️ CI badge runs **syntax lint only** via iverilog. Full UVM simulation requires Xcelium/VCS.

---

## 🎯 CI Pipeline

| Step | Tool | What it checks |
|------|------|---------------|
| RTL Lint | iverilog -g2012 | `apb_ram.sv` syntax |
| Interface Lint | iverilog -g2012 | `apb_if.sv` SVA syntax |
| Transaction Lint | iverilog -g2012 | `apb_transaction.sv` model |
| Full UVM Sim | Xcelium 20.09 | Complete testbench (EDA Playground) |

---

## 👨‍💻 Author

**Bì Duy Tân**
- LinkedIn: [linkedin.com/in/bi-duy-tan](https://linkedin.com/in/bi-duy-tan)
- Target Role: Design Verification Engineer

*Built to demonstrate bridging diagnostic "Root Cause" methodologies with complex EDA hardware verification.*
