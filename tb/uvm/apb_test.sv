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
        apb_wr_rd_seq wr_rd_seq;
        phase.raise_objection(this);
        #50;
        wr_rd_seq = apb_wr_rd_seq::type_id::create("wr_rd_seq");
        wr_rd_seq.addr = 32'h0000_0010;
        wr_rd_seq.data = 32'hDEADBEEF;
        `uvm_info("TEST", "Starting apb_base_test directed write/read", UVM_NONE)
        wr_rd_seq.start(env.agent.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass

class apb_random_test extends apb_base_test;
    `uvm_component_utils(apb_random_test)

    function new(string name = "apb_random_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_random_seq seq;
        phase.raise_objection(this);
        #50;
        seq = apb_random_seq::type_id::create("seq");
        seq.num_trans = 50;
        `uvm_info("TEST", "Starting apb_random_test", UVM_NONE)
        seq.start(env.agent.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass

class apb_error_test extends apb_base_test;
    `uvm_component_utils(apb_error_test)

    function new(string name = "apb_error_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_wr_rd_seq illegal_seq;
        phase.raise_objection(this);
        #50;
        illegal_seq = apb_wr_rd_seq::type_id::create("illegal_seq");
        illegal_seq.addr = 32'h0000_0400;
        illegal_seq.data = 32'hBAD0_0BAD;
        `uvm_info("TEST", "Starting apb_error_test invalid boundary access", UVM_NONE)
        illegal_seq.start(env.agent.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass

class apb_b2b_test extends apb_base_test;
    `uvm_component_utils(apb_b2b_test)

    function new(string name = "apb_b2b_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        apb_wr_rd_seq seq;
        phase.raise_objection(this);
        #50;
        for (int i = 0; i < 8; i++) begin
            seq = apb_wr_rd_seq::type_id::create($sformatf("b2b_seq_%0d", i));
            seq.addr = 32'(i * 4);
            seq.data = 32'hA5A5_0000 + i;
            seq.start(env.agent.seqr);
        end
        #100;
        phase.drop_objection(this);
    endtask
endclass

`endif
