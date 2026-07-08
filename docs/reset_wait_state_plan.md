# Reset And Wait-State Test Plan

## Reset Checks

- Assert reset during idle and confirm APB controls return to idle.
- Release reset on a clock edge and confirm the next transfer starts from setup phase.
- During reset, ignore protocol assertions with `disable iff (!presetn)`.

## Wait-State Checks

- Drive `psel=1` and `penable=1` while `pready=0` for one or more cycles.
- Require `psel`, `penable`, `paddr`, and `pwrite` to remain stable while waiting.
- Complete when `pready=1`, then require `penable` to deassert on the next transfer boundary.

## Coverage Intent

| Cover point | Bins |
|---|---|
| reset timing | reset before traffic, reset between tests |
| wait length | zero wait, one wait, multi-cycle wait |
| direction | read, write |
| response | OKAY, error |

## Evidence Needed Before Stronger Claims

- Simulator log showing each reset/wait-state test name and result.
- Waveform or signal trace around reset release and wait-state completion.
- Coverage report if numeric coverage is discussed.
