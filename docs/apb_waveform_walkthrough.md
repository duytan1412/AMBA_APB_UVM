# APB Waveform Walkthrough

## Scope

This note explains what to inspect in `docs/waveform.png` and how it maps back to the APB vPlan.

## Signal Order

- `pclk`, `presetn`: clock and active-low reset.
- `psel`: transfer selected.
- `penable`: access phase indicator.
- `pwrite`: write/read direction.
- `paddr`, `pwdata`, `prdata`: address and data payload.
- `pready`, `pslverr`: slave completion and error response.

## Expected APB Transfer Shape

| Phase | Expected behavior | Evidence hook |
|---|---|---|
| Reset | `presetn=0` returns DUT and TB-visible controls to idle | `tb/uvm/apb_if.sv` reset-disabled assertions |
| Setup | `psel=1`, `penable=0`, stable address/control | `p_penable_after_psel` |
| Access | `psel=1`, `penable=1`, controls stable until `pready` | `p_stable_until_ready`, `p_controls_stable_during_access` |
| Complete | `pready=1`; read data or write response becomes observable | scoreboard compare in `tb/uvm/apb_scoreboard.sv` |
| Return | `penable` falls after completed access | `p_penable_fall_after_ready` |

## Debug Questions

- If no transaction appears: did sequence start, did driver call `get_next_item`, and is virtual interface binding correct?
- If assertion fails: identify whether the DUT, driver, or monitor sampled the wrong APB phase.
- If scoreboard fails: compare monitor-observed transaction against waveform, then check reference memory latency.

## Interview Story

Use this repo as evidence that APB checking is not only syntax. The verification target is setup/access sequencing, stable controls, data integrity, and honest evidence through logs and waveform review.
