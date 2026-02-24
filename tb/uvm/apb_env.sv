`ifndef APB_ENV_SV
`define APB_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_agent.sv"
`include "apb_scoreboard.sv"

class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)

    apb_agent       agent;
    apb_scoreboard  scbd;

    function new(string name = "apb_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = apb_agent::type_id::create("agent", this);
        scbd  = apb_scoreboard::type_id::create("scbd", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect the Monitor's Analysis Port to Scoreboard's Analysis Imp
        agent.mon.ap.connect(scbd.ap_imp);
    endfunction

endclass

`endif
