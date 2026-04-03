# AMBA APB UVM Verification Environment

A complete **UVM 1.2** testbench for an **AMBA APB (Advanced Peripheral Bus)** Slave Memory module. This environment demonstrates a professional verification architecture incorporating SystemVerilog Assertions (SVA), Functional Coverage, and Constrained-Random Verification (CRV).

## Environment Architecture

The environment follows a standard UVM class hierarchy with an integrated passive monitor and automated checking.

```text
apb_test
└── apb_env
    ├── apb_agent (Active: Driver + Sequencer + Monitor)
    │   └── apb_if (Virtual Interface)
    ├── apb_scoreboard (Reference Model using Associative Arrays)
    └── apb_coverage (Functional Coverage Collector)
```

## Protocol Verification (SVA)

Critical APB protocol rules are asserted within the `apb_if.sv` to detect timing violations:
- **Setup-to-Access Stability**: `PSEL` must rise before `PENABLE`.
- **Interlock Stability**: `PSEL` and `PENABLE` must remain stable until `PREADY` is asserted.
- **Control Integrity**: `PADDR` and `PWRITE` must be stable during the Setup phase.
- **Cycle Termination**: `PENABLE` must fall immediately after a successful `PREADY` handshake.

## Functional Coverage Metrics

Detailed coverage models ensure all architectural corner cases are exercised:
- **Operation Coverage**: Distribution of READ vs WRITE transfers.
- **Address Space Coverage**: Accesses categorized into Low, Mid, and High memory regions.
- **Data Pattern Analysis**: Verification of all-zeros, all-ones, walking-ones, and randomized data.
- **Error Injection**: Validates `PSLVERR` response under invalid access conditions.
- **Transition Coverage**: Back-to-back operation sequences (W-W, W-R, R-R, R-W).

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

## Simulation Requirements

The testbench is compatible with UVM 1.2 compliant simulators:
- **Cadence Xcelium** / **VCS** / **Questa**
- **EDA Playground** (Select Xcelium + UVM 1.2)

### Quick Run (makefile)
```bash
make compile  # Syntax lint only (iverilog)
```

## License
MIT License.
