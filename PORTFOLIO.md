# Scholarship Portfolio Summary

## IC Design Relevance
This repository demonstrates a reusable UVM verification environment for an AMBA APB slave memory. It is directly relevant to digital IC design verification because it covers protocol checking, constrained-random stimulus, scoreboard-based data integrity, functional coverage, and error-response validation.

## Verification Architecture
- UVM active agent: sequencer, driver, and monitor.
- Scoreboard: golden reference memory using SystemVerilog associative arrays.
- Assertions: APB protocol checks for PSEL/PENABLE sequencing, PREADY completion, and stable controls.
- Coverage: address-space, data-pattern, timing, operation/error cross coverage.
- Error injection: unmapped address access validates PSLVERR behavior.

## Evidence Map
| Evidence | File |
| --- | --- |
| DUT RTL | `rtl/apb_ram.sv` |
| Protocol interface and SVA | `tb/uvm/apb_if.sv` |
| Functional coverage | `tb/uvm/apb_coverage.sv` |
| Scoreboard | `tb/uvm/apb_scoreboard.sv` |
| Directed/random sequences | `tb/uvm/apb_sequence.sv` |
| Simulation evidence | `sim_results/simulation.log` |

## Test Plan Summary
| Test | Goal | Evidence |
| --- | --- | --- |
| Random R/W | Exercise legal address and data combinations | Scoreboard matches in `simulation.log` |
| Targeted write-read | Confirm memory integrity at a fixed address | `apb_wr_rd_seq` in `tb/uvm/apb_sequence.sv` |
| Error access | Validate PSLVERR for unmapped access | `!!! ERROR Detected: PSLVERR = 1 !!!` in `simulation.log` |
| Back-to-back timing | Stress PSEL/PENABLE/PREADY sequencing | SVA in `tb/uvm/apb_if.sv` and timing coverage |

## Scholarship Positioning
For Synopsys IC Design Scholarship review, this project should be presented as a digital verification project that demonstrates UVM architecture, assertion-based verification, coverage-driven thinking, and AMBA protocol knowledge.

