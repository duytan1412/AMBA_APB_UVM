`ifndef APB_IF_SV
`define APB_IF_SV

`timescale 1ns/1ps

interface apb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic pclk,
    input logic presetn
);

    // APB Bus Signals
    logic [ADDR_WIDTH-1:0] paddr;
    logic                  pwrite;
    logic                  psel;
    logic                  penable;
    logic [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH-1:0] prdata;
    logic                  pready;
    logic                  pslverr;

    // Modports (Optional but good practice)
    modport master (
        input  pclk, presetn, prdata, pready, pslverr,
        output paddr, pwrite, psel, penable, pwdata
    );

    modport slave (
        input  pclk, presetn, paddr, pwrite, psel, penable, pwdata,
        output prdata, pready, pslverr
    );

    // =========================================================================
    // SystemVerilog Assertions (SVA) for APB Protocol Checking
    // =========================================================================

    // Property 1: PENABLE must go high exactly 1 cycle after PSEL goes high
    property p_penable_after_psel;
        @(posedge pclk) disable iff (!presetn)
        ($rose(psel) |=> penable);
    endproperty
    assert property (p_penable_after_psel) else
        $error("APB Protocol Violation: PENABLE did not assert 1 cycle after PSEL.");

    // Property 2: PSEL and PENABLE must remain high until PREADY is high
    property p_stable_until_ready;
        @(posedge pclk) disable iff (!presetn)
        (psel && penable && !pready) |=> (psel && penable);
    endproperty
    assert property (p_stable_until_ready) else
        $error("APB Protocol Violation: PSEL/PENABLE dropped before PREADY.");

    // Property 3: PADDR and PWRITE must be stable during PENABLE phase
    // Note: They can change when PSEL goes low, but during PSEL && PENABLE, they must hold.
    property p_controls_stable_during_access;
        @(posedge pclk) disable iff (!presetn)
        (psel && !penable) |=> (paddr == $past(paddr) && pwrite == $past(pwrite));
    endproperty
    assert property (p_controls_stable_during_access) else
        $error("APB Protocol Violation: PADDR or PWRITE changed during access phase.");

    // Property 4: PENABLE must fall in the cycle after PREADY goes high during access
    property p_penable_fall_after_ready;
        @(posedge pclk) disable iff (!presetn)
        (penable && pready) |=> (!penable);
    endproperty
    assert property (p_penable_fall_after_ready) else
        $error("APB Protocol Violation: PENABLE did not de-assert after PREADY.");

endinterface

`endif
