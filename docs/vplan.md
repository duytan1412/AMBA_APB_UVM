# APB Slave Verification Plan

## Scope

Verify APB setup/access sequencing, legal read/write data integrity, invalid boundary handling, and back-to-back transfer behavior for an APB slave memory.

## Traceability Matrix

| Requirement | Method | Test | Coverage / Check | Evidence |
|---|---|---|---|---|
| Setup phase precedes access phase | SVA + monitor | all tests | PSEL/PENABLE timing checks | `tb/uvm/apb_if.sv` |
| Legal writes read back correctly | scoreboard | `apb_base_test`, `apb_random_test`, `apb_b2b_test` | reference memory compare | `tb/uvm/apb_scoreboard.sv` |
| Invalid boundary access is detected | directed sequence | `apb_error_test` | PSLVERR/error log evidence | `sim_results/simulation.log` |
| Back-to-back transactions keep sequencing stable | directed loop | `apb_b2b_test` | no SVA errors, no mismatches | `docs/regression_summary.md` |
| Address/data/timing space is sampled | coverage subscriber | all tests | covergroups in source | `tb/uvm/apb_coverage.sv` |

## Limitations

- Numeric coverage closure is not claimed without simulator-generated coverage artifacts.
- Open-source CI is lint-only; full UVM regression needs VCS, Xcelium, or Questa.
