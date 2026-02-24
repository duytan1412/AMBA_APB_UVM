`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_transaction.sv"

class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;
    uvm_analysis_port#(apb_transaction) ap;

    function new(string name = "apb_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_transaction tr;
        
        // Wait for reset to finish
        @(posedge vif.presetn);
        `uvm_info("APB_MON", "Reset finished, starting monitor loop", UVM_LOW)

        forever begin
            @(posedge vif.pclk);
            
            // Only sample data when a transfer is complete: PENABLE and PREADY are both high
            if (vif.psel && vif.penable && vif.pready) begin
                tr = apb_transaction::type_id::create("tr");
                tr.paddr   = vif.paddr;
                tr.pwrite  = vif.pwrite;
                tr.pslverr = vif.pslverr;
                
                if (vif.pwrite)
                    tr.pwdata = vif.pwdata;
                else
                    tr.prdata = vif.prdata;
                
                `uvm_info("APB_MON", {"Sampled transaction: ", tr.convert2string()}, UVM_HIGH)
                ap.write(tr);
            end
        end
    endtask

endclass

`endif
