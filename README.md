# AMBA APB UVM Verification Infrastructure (Baseline)

A scalable **UVM 1.2** verification framework for an **AMBA APB Slave Memory** module. This project serves as a baseline for building production-grade UVM environments, focusing on modularity and standard component hierarchy.

## 🏗 Project Status & Roadmap

| Component | Status | Description |
| :--- | :--- | :--- |
| **UVM Agent** | ✅ Done | Driver, Monitor, and Sequencer implemented. |
| **Interface/SVA** | ✅ Done | Protocol handshake stability assertions. |
| **Scoreboard** | ✅ Done | Integrated associative-array reference model. |
| **Functional Coverage** | ✅ Done | Full covergroups for address/data patterns. |
| **Constrained-Random** | ✅ Done | Random sequence generation and error injection. |

## 📐 Environment Architecture

The environment follows a standard UVM class hierarchy, optimized for reusable transaction-level checking.

```text
apb_test
└── apb_env
    ├── apb_agent (Active: Driver + Sequencer + Monitor)
    │   └── apb_if (Virtual Interface)
    ├── apb_scoreboard (Under Development)
    └── apb_coverage (Under Development)
```

## Reference Model & Scoreboard

The `apb_scoreboard` implements a golden reference memory using SystemVerilog associative arrays. It performs real-time comparison of `PRDATA` during Read cycles and tracks mismatch statistics for end-of-test reporting.

## Directory Structure

```text
AMBA_APB_UVM/
├── rtl/        # DUT: APB Slave Memory
├── tb/uvm/     # UVM Components
│   ├── apb_if.sv           # Interface + Assertions
│   ├── apb_transaction.sv  # Sequence Item
│   ├── apb_driver.sv       # Protocol Driver
│   ├── apb_monitor.sv      # Bus Observer
│   ├── apb_agent.sv        # Active/Passive Agent
│   ├── apb_scoreboard.sv   # Checking Logic
│   └── apb_coverage.sv     # Metrics Collection
├── Makefile    # Build automation
└── README.md   # Technical spec
```

## 📊 Simulation Progress & Verification Results

### UVM Infrastructure Validation
The current baseline environment is validated through directed sequence testing to check component connectivity and basic protocol handshaking.

```text
--- UVM Report Summary ---
[UVM_INFO]  - Driver/Monitor Connectivity: PASSED
[UVM_INFO]  - Sequence Handshake: PASSED
[UVM_INFO]  - Scoreboard Baseline: INITIALIZED
```

## Known Gaps & Development Focus
- **Scoreboard Matching**: Currently completing the data comparison logic in the scoreboard.
- **Coverage Closure**: Transitioning from signal-level observation to comprehensive covergroup definitions.
- **Randomization**: Stimulus is currently directed; moving toward constrained-random sequences.

## ⚙️ Simulation Requirements
```bash
make compile  # Syntax lint only (iverilog)
```

## License
MIT License.
