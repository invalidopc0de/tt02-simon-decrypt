`default_nettype none

module invalidopcode_simon_decrypt (
  input [7:0] io_in,
  output [7:0] io_out
);
  assign io_out[7:4] = 4'b0;

  simon_decrypt simon_decrypt0 (
    .clk(io_in[0]),
    .shift(io_in[1]),
    .data_in(io_in[5:2]),
    .data_out(io_out[3:0])
  );
endmodule

module simon_decrypt(
  input clk,
  input shift,
  input [3:0] data_in,
  output [3:0] data_out
);

  // Module registers
  typedef struct packed {
    logic [4:0] lfsr;
    logic [63:0] key;
    logic [31:0] round;
  } simon_reg_t;

  simon_reg_t r, rin;

// Combinational logic 
always_comb begin 
  rin = r;
  // LFSR
  if (shift == 1'b1) 
    rin.lfsr = 5'b00001;
  else begin 
    rin.lfsr[4] = r.lfsr[3];
    rin.lfsr[3] = r.lfsr[2];
    rin.lfsr[2] = r.lfsr[4] ^ r.lfsr[1];
    rin.lfsr[1] = r.lfsr[0];
    rin.lfsr[0] = r.lfsr[4] ^ r.lfsr[0];
  end 

  // Key scheduling 
  rin.key = {data_in, r.key[63:4]};
  

  // Decrypt
  rin.round = {r.key[3:0], r.round[31:4]};
end

// Register clocking
always_ff @(posedge clk) begin
  r <= rin;
end

endmodule 