`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../../rtl/apb_ram.v"
`include "apb_if.sv"
`include "apb_test.sv"

module tb_top;

    // Clock and Reset Signals
    logic pclk;
    logic presetn;

    // Clock Generation
    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk; // 100MHz clock
    end

    // Reset Generation
    initial begin
        presetn = 0;
        #20 presetn = 1; // De-assert reset after 20ns
    end

    // Interface Instantiation
    apb_if vif(
        .pclk(pclk),
        .presetn(presetn)
    );

    // DUT Instantiation
    apb_ram #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .MEM_SIZE(256)
    ) dut (
        .PCLK(vif.pclk),
        .PRESETn(vif.presetn),
        .PADDR(vif.paddr),
        .PWDATA(vif.pwdata),
        .PSEL(vif.psel),
        .PENABLE(vif.penable),
        .PWRITE(vif.pwrite),
        .PRDATA(vif.prdata),
        .PREADY(vif.pready),
        .PSLVERR(vif.pslverr)
    );

    // Initial Block for UVM Config and Run
    initial begin
        // Pass interface to UVM configuration database
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.agent*", "vif", vif);
        
        // Setup Waveform dumping for Xcelium/VCS/Iverilog
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        // Run UVM
        run_test("apb_base_test");
    end

endmodule
