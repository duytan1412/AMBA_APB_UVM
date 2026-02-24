`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_transaction.sv"

class apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_scoreboard)

    uvm_analysis_imp#(apb_transaction, apb_scoreboard) ap_imp;

    // Golden reference memory using associative array
    logic [31:0] ref_mem [logic [31:0]];

    int num_matches;
    int num_mismatches;

    function new(string name = "apb_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
        num_matches = 0;
        num_mismatches = 0;
    endfunction

    // Write function called by the monitor via analysis port
    virtual function void write(apb_transaction tr);
        
        // Handle Write Transaction
        if (tr.pwrite) begin
            if (!tr.pslverr) begin
                // Update reference memory on successful write
                ref_mem[tr.paddr] = tr.pwdata;
                `uvm_info("APB_SCB", $sformatf("Stored PWDATA='h%08x to ADDR='h%08x in ref_mem", tr.pwdata, tr.paddr), UVM_HIGH)
            end else begin
                `uvm_info("APB_SCB", $sformatf("Ignored Write Error at ADDR='h%08x", tr.paddr), UVM_HIGH)
            end
        end 
        // Handle Read Transaction
        else begin
            if (!tr.pslverr) begin
                logic [31:0] expected_data;
                
                // If it's a valid read, compare PRDATA with our model
                if (ref_mem.exists(tr.paddr)) begin
                    expected_data = ref_mem[tr.paddr];
                end else begin
                    // Initial memory state is 0 for our RAM model
                    expected_data = 32'h00000000; 
                end

                if (tr.prdata === expected_data) begin
                    num_matches++;
                    `uvm_info("APB_SCB", $sformatf("MATCH! ADDR='h%08x PRDATA='h%08x Expected='h%08x", tr.paddr, tr.prdata, expected_data), UVM_LOW)
                end else begin
                    num_mismatches++;
                    `uvm_error("APB_SCB", $sformatf("MISMATCH! ADDR='h%08x PRDATA='h%08x Expected='h%08x", tr.paddr, tr.prdata, expected_data))
                end

            end else begin
                `uvm_info("APB_SCB", $sformatf("Ignored Read Error at ADDR='h%08x", tr.paddr), UVM_HIGH)
            end
        end
    endfunction
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("APB_SCB_REPORT", "========================================", UVM_NONE)
        `uvm_info("APB_SCB_REPORT", $sformatf("Total Matches   : %0d", num_matches), UVM_NONE)
        `uvm_info("APB_SCB_REPORT", $sformatf("Total Mismatches: %0d", num_mismatches), UVM_NONE)
        `uvm_info("APB_SCB_REPORT", "========================================", UVM_NONE)
        if (num_mismatches > 0) begin
            `uvm_error("TEST_FAILED", "Simulation completed with mismatches!")
        end else begin
            `uvm_info("TEST_PASSED", "Simulation completed successfully with 0 mismatches.", UVM_NONE)
        end
    endfunction

endclass

`endif
