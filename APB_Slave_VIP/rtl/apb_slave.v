module apb_slave #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)(
  input  logic                  pclk,
  input  logic                  presetn,
  input  logic                  psel,
  input  logic                  penable,
  input  logic                  pwrite,
  input  logic [ADDR_WIDTH-1:0] paddr,
  input  logic [DATA_WIDTH-1:0] pwdata,
  output logic [DATA_WIDTH-1:0] prdata,
  output logic                  pready,
  output logic                  pslverr
);

  // Memory storage (Simple 256-depth for demo)
  logic [DATA_WIDTH-1:0] mem [0:255];

  // State machine for APB protocol handling
  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10
  } state_t;

  state_t state, next_state;

  // Internal signals
  logic [7:0] local_addr; // Use lower 8 bits for memory index

  assign local_addr = paddr[9:2]; // Word aligned assumption

  // 1. State Machine Register Logic
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // 2. Next State Logic
  always_comb begin
    next_state = state;
    case (state)
      IDLE: begin
        if (psel && !penable)
          next_state = SETUP;
      end
      SETUP: begin
        if (psel && penable)
          next_state = ACCESS;
        else 
          next_state = IDLE; // Should not happen in valid protocol
      end
      ACCESS: begin
        if (!psel)
          next_state = IDLE;
        else if (psel && !penable)
          next_state = SETUP; // Back-to-back transfer
      end
      default: next_state = IDLE;
    endcase
  end

  // 3. Output Logic & Memory Access
  // Use pslverr always 0 for simplicity in this basic version
  assign pslverr = 1'b0;
  
  // Handshake logic: Ready immediately in ACCESS phase
  // Note: Real designs might insert wait states here
  assign pready = (state == ACCESS);

  // Read/Write Logic
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      prdata <= '0;
    end else if (state == ACCESS && pready) begin
      if (pwrite) begin
        // Write operation
        mem[local_addr] <= pwdata;
      end else begin
        // Read operation
        prdata <= mem[local_addr];
      end
    end
  end

endmodule
