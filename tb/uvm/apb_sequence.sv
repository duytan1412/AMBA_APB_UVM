`ifndef APB_SEQUENCE_SV
`define APB_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_transaction.sv"

// Base APB Sequence
class apb_base_seq extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_base_seq)

    function new(string name = "apb_base_seq");
        super.new(name);
    endfunction
endclass

// Single Write Sequence
class apb_write_seq extends apb_base_seq;
    `uvm_object_utils(apb_write_seq)

    rand logic [31:0] waddr;
    rand logic [31:0] wdata;

    function new(string name = "apb_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction req;
        // uvm_create and uvm_randomize
        req = apb_transaction::type_id::create("req");
        start_item(req);
        if(!req.randomize() with {
            pwrite == 1'b1;
            paddr == waddr;
            pwdata == wdata;
        }) `uvm_error("APB_SEQ", "Randomization failed for write transaction")
        finish_item(req);
    endtask
endclass

// Single Read Sequence
class apb_read_seq extends apb_base_seq;
    `uvm_object_utils(apb_read_seq)

    rand logic [31:0] raddr;

    function new(string name = "apb_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction req;
        req = apb_transaction::type_id::create("req");
        start_item(req);
        if(!req.randomize() with {
            pwrite == 1'b0;
            paddr == raddr;
        }) `uvm_error("APB_SEQ", "Randomization failed for read transaction")
        finish_item(req);
    endtask
endclass

// Write followed by Read Sequence (to same address)
class apb_wr_rd_seq extends apb_base_seq;
    `uvm_object_utils(apb_wr_rd_seq)

    rand logic [31:0] addr;
    rand logic [31:0] data;

    function new(string name = "apb_wr_rd_seq");
        super.new(name);
    endfunction

    virtual task body();
        apb_write_seq wr_seq;
        apb_read_seq  rd_seq;

        `uvm_info("APB_SEQ", $sformatf("Starting WR_RD sequence to ADDR='h%08x DATA='h%08x", addr, data), UVM_LOW)

        // Write
        wr_seq = apb_write_seq::type_id::create("wr_seq");
        if(!wr_seq.randomize() with {
            waddr == addr;
            wdata == data;
        }) `uvm_error("APB_SEQ", "Randomization failed")
        wr_seq.start(m_sequencer, this);

        // Read
        rd_seq = apb_read_seq::type_id::create("rd_seq");
        if(!rd_seq.randomize() with {
            raddr == addr;
        }) `uvm_error("APB_SEQ", "Randomization failed")
        rd_seq.start(m_sequencer, this);

    endtask
endclass

// Random Burst Sequence
class apb_random_seq extends apb_base_seq;
    `uvm_object_utils(apb_random_seq)

    rand int num_trans;

    constraint c_num_trans { num_trans inside {[10:50]}; }

    function new(string name = "apb_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction req;
        `uvm_info("APB_SEQ", $sformatf("Starting Random sequence with %0d transactions", num_trans), UVM_LOW)
        
        for (int i=0; i < num_trans; i++) begin
            req = apb_transaction::type_id::create("req");
            start_item(req);
            if(!req.randomize())
                `uvm_error("APB_SEQ", "Randomization failed")
            finish_item(req);
        end
    endtask
endclass

`endif
