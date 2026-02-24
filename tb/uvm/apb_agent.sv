`ifndef APB_AGENT_SV
`define APB_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_transaction.sv"

class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_driver    drv;
    apb_monitor   mon;
    uvm_sequencer#(apb_transaction) seqr;

    function new(string name = "apb_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        mon = apb_monitor::type_id::create("mon", this);
        
        if (get_is_active() == UVM_ACTIVE) begin
            drv  = apb_driver::type_id::create("drv", this);
            seqr = uvm_sequencer#(apb_transaction)::type_id::create("seqr", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

endclass

`endif
