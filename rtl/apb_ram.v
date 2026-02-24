`timescale 1ns/1ps

module apb_ram #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE = 256 // Fixed small size for verification
)(
    input  logic                   PCLK,
    input  logic                   PRESETn,
    input  logic [ADDR_WIDTH-1:0]  PADDR,
    input  logic [DATA_WIDTH-1:0]  PWDATA,
    input  logic                   PSEL,
    input  logic                   PENABLE,
    input  logic                   PWRITE,
    output logic [DATA_WIDTH-1:0]  PRDATA,
    output logic                   PREADY,
    output logic                   PSLVERR
);

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    // APB State Machine logic
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ACCESS = 2'b10
    } apb_state_t;

    apb_state_t current_state, next_state;

    // Registers for internal processing
    logic [ADDR_WIDTH-1:0] addr_reg;
    logic [DATA_WIDTH-1:0] rdata_reg;
    logic                  ready_reg;
    logic                  slverr_reg;

    assign PRDATA  = rdata_reg;
    assign PREADY  = ready_reg;
    assign PSLVERR = slverr_reg;

    // Word aligned address check (assuming 32-bit words, lower 2 bits must be zero)
    wire valid_address = (PADDR[ADDR_WIDTH-1:2] < MEM_SIZE) && (PADDR[1:0] == 2'b00);

    // State Transition
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (PSEL && !PENABLE)
                    next_state = SETUP;
            end
            SETUP: begin
                if (PSEL && PENABLE)
                    next_state = ACCESS;
                else
                    next_state = IDLE;
            end
            ACCESS: begin
                // Transition out of ACCESS happens in 1 cycle for zero wait state
                // Or when PREADY is asserted for wait state implementations.
                // Assuming 0 wait states for APB RAM to simply be ready immediately.
                if (PSEL && !PENABLE)
                    next_state = SETUP; // Back-to-back
                else if (!PSEL)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output and Memory Access Logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rdata_reg <= '0;
            ready_reg <= 1'b0;
            slverr_reg <= 1'b0;
            addr_reg <= '0;
            for (int i = 0; i < MEM_SIZE; i++) begin
                mem[i] <= '0;
            end
        end else begin
            case (current_state)
                IDLE: begin
                    ready_reg <= 1'b0;
                    slverr_reg <= 1'b0;
                end
                
                SETUP: begin
                    addr_reg <= PADDR;
                    if (valid_address) begin
                        slverr_reg <= 1'b0; // No error if address is valid
                    end else begin
                        slverr_reg <= 1'b1; // Error for out of bounds or misaligned
                    end
                end

                ACCESS: begin
                    ready_reg <= 1'b1; // 0 wait state response
                    
                    if (valid_address) begin
                        if (PWRITE) begin
                            // Handle write
                            mem[PADDR[ADDR_WIDTH-1:2]] <= PWDATA;
                        end else begin
                            // Handle read
                            rdata_reg <= mem[PADDR[ADDR_WIDTH-1:2]];
                        end
                    end
                end
            endcase
            
            // Clear ready and error immediately after ACCESS phase completes
            if (current_state == ACCESS && ready_reg) begin
                ready_reg <= 1'b0;
                slverr_reg <= 1'b0;
            end
        end
    end

endmodule
