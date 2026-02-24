`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_transaction.sv"

class apb_driver extends uvm_driver#(apb_transaction);
    `uvm_component_utils(apb_driver)

    virtual apb_if vif;

    function new(string name = "apb_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    endfunction

    virtual task run_phase(uvm_phase phase);
        // Initialize bus
        vif.paddr   <= 0;
        vif.pwrite  <= 0;
        vif.psel    <= 0;
        vif.penable <= 0;
        vif.pwdata  <= 0;

        // Wait for reset to finish
        @(posedge vif.presetn);
        `uvm_info("APB_DRV", "Reset finished, starting driver loop", UVM_LOW)

        forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_transfer(apb_transaction req);
        // Setup Phase
        @(posedge vif.pclk);
        vif.paddr  <= req.paddr;
        vif.pwrite <= req.pwrite;
        if (req.pwrite)
            vif.pwdata <= req.pwdata;
        vif.psel   <= 1'b1;
        vif.penable<= 1'b0;

        // Access Phase
        @(posedge vif.pclk);
        vif.penable <= 1'b1;

        // Wait for PREADY
        // Using property checking, PREADY should be asserted by slave
        // We will sample continuously until PREADY is high
        forever begin
            @(posedge vif.pclk);
            if (vif.pready) begin
                if (!req.pwrite) begin
                    // Sample read data and error response
                    req.prdata = vif.prdata;
                    req.pslverr = vif.pslverr;
                end else begin
                    req.pslverr = vif.pslverr;
                end
                break;
            end
        end

        // End of Transfer
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;

        // Small delay logic for visualization, not strictly necessary for APB back-to-back 
        // but helps with clean waveforms initially
        // @(posedge vif.pclk); 
    endtask

endclass

`endif
