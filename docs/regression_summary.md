# APB regression summary

| Test | Intent | Expected result | Evidence status |
|---|---|---|---|
| `apb_base_test` | directed write/read smoke | scoreboard match | implemented |
| `apb_random_test` | random legal traffic | no mismatches | implemented |
| `apb_error_test` | invalid boundary behavior | error response evidence | implemented |
| `apb_b2b_test` | back-to-back accesses | setup/access timing preserved | implemented |

This is a human-readable summary. Regenerate logs with `scripts/run_regression.ps1` and a UVM-capable simulator before presenting fresh regression closure.
