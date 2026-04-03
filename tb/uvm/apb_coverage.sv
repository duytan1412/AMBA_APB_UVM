`ifndef APB_COVERAGE_SV
`define APB_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_transaction.sv"

//=============================================================================
// Class: apb_coverage
// Description: Functional Coverage Collector for APB Protocol Verification
//              Subscribes to monitor's analysis port to collect transaction data
//=============================================================================
class apb_coverage extends uvm_subscriber#(apb_transaction);
    `uvm_component_utils(apb_coverage)

    apb_transaction item;

    //=========================================================================
    // APB Functional Coverage Model
    //=========================================================================
    covergroup cg_apb_protocol;

        // Cover read/write operations
        cp_operation: coverpoint item.pwrite {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        // Cover address ranges (aligned to 4-byte boundary for 32-bit bus)
        cp_addr_range: coverpoint item.paddr[7:2] {
            bins low_addr   = {[0:15]};    // Address 0x00-0x3C
            bins mid_addr   = {[16:31]};   // Address 0x40-0x7C
            bins high_addr  = {[32:63]};   // Address 0x80-0xFC
        }

        // Cover data patterns for write operations
        cp_write_data: coverpoint item.pwdata {
            bins all_zeros   = {32'h0000_0000};
            bins all_ones    = {32'hFFFF_FFFF};
            bins walking_one = {32'h0000_0001, 32'h0000_0002, 32'h0000_0004, 32'h0000_0008};
            bins random_data = default;
        }

        // Cover slave error response
        cp_slverr: coverpoint item.pslverr {
            bins NO_ERROR = {1'b0};
            bins ERROR    = {1'b1};
        }

        // Cross coverage: operation x address range
        cx_op_addr: cross cp_operation, cp_addr_range {
            // Ensure both READ and WRITE hit all address ranges
        }

        // Cross coverage: operation x error response
        cx_op_err: cross cp_operation, cp_slverr;

    endgroup

    //=========================================================================
    // Back-to-Back Transfer Coverage (Protocol Timing)
    //=========================================================================
    covergroup cg_apb_timing;

        // Cover consecutive operation types
        cp_b2b_ops: coverpoint item.pwrite {
            bins write_after_write = (1'b1 => 1'b1);
            bins read_after_write  = (1'b1 => 1'b0);
            bins write_after_read  = (1'b0 => 1'b1);
            bins read_after_read   = (1'b0 => 1'b0);
        }

    endgroup

    //=========================================================================
    // Constructor
    //=========================================================================
    function new(string name = "apb_coverage", uvm_component parent);
        super.new(name, parent);
        cg_apb_protocol = new();
        cg_apb_timing   = new();
    endfunction

    //=========================================================================
    // Write method - called by monitor's analysis port
    //=========================================================================
    virtual function void write(apb_transaction t);
        item = t;
        cg_apb_protocol.sample();
        cg_apb_timing.sample();

        `uvm_info("APB_COV",
            $sformatf("Coverage sampled: %s addr=0x%0h | Protocol=%0.1f%% Timing=%0.1f%%",
                item.pwrite ? "WRITE" : "READ",
                item.paddr,
                cg_apb_protocol.get_inst_coverage(),
                cg_apb_timing.get_inst_coverage()),
            UVM_HIGH)
    endfunction

    //=========================================================================
    // Report Phase - Print final coverage summary
    //=========================================================================
    virtual function void report_phase(uvm_phase phase);
        `uvm_info("APB_COV",
            $sformatf("\n========== COVERAGE REPORT ==========\n  APB Protocol Coverage: %0.2f%%\n  APB Timing Coverage:   %0.2f%%\n=====================================",
                cg_apb_protocol.get_inst_coverage(),
                cg_apb_timing.get_inst_coverage()),
            UVM_LOW)
    endfunction

endclass

`endif
