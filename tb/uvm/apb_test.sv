`ifndef APB_TEST_SV
`define APB_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_env.sv"
`include "apb_sequence.sv"

class apb_base_test extends uvm_test;
    `uvm_component_utils(apb_base_test)

    apb_env env;

    function new(string name = "apb_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_random_seq seq;
        
        phase.raise_objection(this);
        
        // Short delay before driving
        #50;

        seq = apb_random_seq::type_id::create("seq");
        seq.num_trans = 20; // Generate 20 random transactions

        `uvm_info("TEST", "Starting apb_random_seq", UVM_NONE)
        seq.start(env.agent.seqr);
        `uvm_info("TEST", "Finished apb_random_seq", UVM_NONE)

        // Add additional targeted sequences if desired
        // e.g. Write-Read to same address
        begin
            apb_wr_rd_seq wr_rd_seq = apb_wr_rd_seq::type_id::create("wr_rd_seq");
            wr_rd_seq.addr = 32'h0000_0010; // 16 (4 words deep)
            wr_rd_seq.data = 32'hDEADBEEF;
            `uvm_info("TEST", "Starting targeted apb_wr_rd_seq", UVM_NONE)
            wr_rd_seq.start(env.agent.seqr);
            `uvm_info("TEST", "Finished targeted apb_wr_rd_seq", UVM_NONE)
        end
        
        // Allow time for final transactions to drain and scoreboard to evaluate
        #100;

        phase.drop_objection(this);
    endtask

endclass

`endif
