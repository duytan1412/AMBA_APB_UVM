# AMBA APB UVM Verification Environment

![CI](https://github.com/duytan1412/AMBA_APB_UVM/actions/workflows/uvm-ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

This repository contains a complete **Universal Verification Methodology (UVM)** testbench developed from scratch to verify an **AMBA APB (Advanced Peripheral Bus)** Slave Memory module (`apb_ram.v`).

It demonstrates a professional "Verification-First" mindset, utilizing **SystemVerilog Assertions (SVA)**, **Functional Coverage**, and a **UVM-centric architecture**, tailored for Junior Design Verification Engineer roles.

---

## 🏗 System Architecture

### 1. The Design Under Test (DUT): APB RAM
The RTL (`rtl/apb_ram.v`) is a simplified memory mapped to an APB Interface.
*   **Protocol:** AMBA APB (Setup Phase & Access Phase).
*   **Data Width:** 32-bit `PWDATA` and `PRDATA`.
*   **Address Width:** 32-bit `PADDR` (Byte-addressable, word-aligned accesses).
*   **Features:** Zero wait-state `PREADY` generation, `PSLVERR` generation on unaligned addresses or out-of-bounds access.

### 2. The UVM Environment
The testbench (`tb/uvm/`) is structured strictly following UVM 1.2 class hierarchies:
*   **`apb_transaction.sv`**: Defines randomized APB Sequence Items with word-alignment constraints.
*   **`apb_sequence.sv`**: Generates Single Write, Single Read, Burst, and Write-Read verification scenarios.
*   **`apb_driver.sv`**: Translates UVM transactions into precise APB bus wiggles (driving `PSEL`, `PENABLE`, etc.).
*   **`apb_monitor.sv`**: Passively sniffs the APB bus and broadcasts captured transactions via an Analysis Port.
*   **`apb_agent.sv`**: Encapsulates the Driver, Sequencer, and Monitor.
*   **`apb_scoreboard.sv`**: Implements a *Reference Memory Model* using SystemVerilog Associative Arrays to predict and verify `PRDATA`.
*   **`apb_if.sv`**: The hardware interface, loaded with **SystemVerilog Assertions (SVA)** to catch APB protocol violations instantly.

---

## 🚀 Live Demo (EDA Playground)

The complete UVM testbench compiles and runs natively using **Cadence Xcelium 20.09**.

👉 **[Click Here to View & Run the Project on EDA Playground](#)** *(Add your public link here)*

### Simulation Log Results
*Expected Output:*
```text
[APB_SCB] MATCH! ADDR='h00000010 PRDATA='hdeadbeef Expected='hdeadbeef
...
[APB_SCB_REPORT] ========================================
[APB_SCB_REPORT] Total Matches   : [X]
[APB_SCB_REPORT] Total Mismatches: 0
[APB_SCB_REPORT] ========================================
[TEST_PASSED] Simulation completed successfully with 0 mismatches.
```

### APB Write/Read Waveforms (EPWave)
![APB Timing](docs/apb_waveform.png)

*(Note: The above diagram illustrates the `PSEL`, `PENABLE`, `PWRITE`, and `PREADY` handshake verified by SVA).*

---

## ⚙️ How to Setup (Local or Cloud)

Standard UVM 1.2 requires commercial simulators (like Cadence Xcelium or Synopsys VCS) for full class/macro support. 

To run this project for free, use **EDA Playground**:

1. Open [EDA Playground](https://edaplayground.com/).
2. **Testbench + Design files**: Upload or paste all the `.sv` and `.v` files into the left and right panes.
3. Configure settings on the left:
    *   **Languages & Libraries:** SystemVerilog / Verilog
    *   **UVM / OVM:** UVM 1.2
    *   **Tools & Simulators:** Cadence Xcelium 20.09
    *   **Run Options:** Leave default.
4. Set the "Top module" to `tb_top`.
5. Click **Run**.
6. Check the console log for UVM output indicating `Total Mismatches: 0`.

*(Alternatively, use `make all` if you have a UVM-patched version of Icarus Verilog or Verilator installed locally).*

---

## 🔬 Key Verification Features Highlighted

1.  **Assertion Based Verification (ABV):** 
    Embedded properties in the Interface guarantee standard compliance (e.g., `PENABLE` asserting 1 cycle after `PSEL`).
2.  **Reference Modeling:**
    Scoreboard independently tracks memory states and compares `PRDATA` in real-time against expected values.
3.  **Constrained-Random Verification (CRV):**
    Utilizes UVM sequences to blast random addresses and data, exposing edge-case failures.
4.  **Triage/Debug Ready:**
    Custom `convert2string()` methods and standard `uvm_info` macros trace exactly what the driver and monitor are transacting.

---

## 👨‍💻 Author
**Bì Duy Tân**
- LinkedIn: [linkedin.com/in/bi-duy-tan](https://linkedin.com/in/bi-duy-tan)
- Target Role: Design Verification Engineer

*Built to demonstrate bridging diagnostic "Root Cause" methodologies with complex EDA hardware verification.*
