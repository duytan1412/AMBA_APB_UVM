`ifndef APB_TRANSACTION_SV
`define APB_TRANSACTION_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_transaction extends uvm_sequence_item;
    
    // Configurable parameters based on APB spec
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // Randomizable APB fields
    rand logic [ADDR_WIDTH-1:0] paddr;
    rand logic                  pwrite;
    rand logic [DATA_WIDTH-1:0] pwdata;
    
    // Output from slave
    logic [DATA_WIDTH-1:0]      prdata;
    logic                       pslverr;
    
    // Constraints
    // 1. Address must be aligned to 4 bytes (32-bit word)
    constraint c_addr_align {
        paddr[1:0] == 2'b00;
        paddr < 256; // Limit address range to valid RAM size (MEM_SIZE = 256 words -> Max Addr = 255*4 = 1020)
    }

    // UVM Factory Registration and Field Macros
    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(paddr,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pwrite, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(pwdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(prdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pslverr, UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "apb_transaction");
        super.new(name);
    endfunction

    // Custom convert2string for easier debug
    virtual function string convert2string();
        string s;
        if (pwrite)
            s = $sformatf("WRITE: ADDR='h%08x DATA='h%08x ERR=%b", paddr, pwdata, pslverr);
        else
            s = $sformatf("READ:  ADDR='h%08x RDATA='h%08x ERR=%b", paddr, prdata, pslverr);
        return s;
    endfunction

endclass

`endif
