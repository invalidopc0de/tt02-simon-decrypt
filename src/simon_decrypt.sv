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

  // SIMON decrypt module registers
  typedef struct packed {
    logic [4:0] lfsr;
    logic [63:0] key;
    logic [31:0] round;
  } simon_reg_t;

  simon_reg_t r, rin;

  wire [15:0] round_shift_1, round_shift_8, round_shift_2;

  // Left ciruclar shift by 1 bit
  assign round_shift_1 = {r.round[30:16],r.round[31]};
  // Left ciruclar shift by 8 bits
  assign round_shift_8 = {r.round[23:16],r.round[31:24]};
  // Left ciruclar shift by 2 bits
  assign round_shift_2 = {r.round[29:16],r.round[31:30]};

  // Output round data when shifting
  assign data_out = r.round[3:0];

// Combinational logic 
always @(shift,data_in,data_out,r) begin 
  rin = r;

  // LFSR for key scheduling
  rin.lfsr[4] = r.lfsr[3];
  rin.lfsr[3] = r.lfsr[2];
  rin.lfsr[2] = r.lfsr[4] ^ r.lfsr[1];
  rin.lfsr[1] = r.lfsr[0];
  rin.lfsr[0] = r.lfsr[4] ^ r.lfsr[0];

  // Key scheduling

  // Decrypt
  // x
  rin.round[31:16] = r.round[15:0];

  // y
  rin.round[15:0] = r.round[31:16]                      // x
    ^ ((round_shift_1 & round_shift_8) ^ round_shift_2) // f(y)
    ^ r.key[15:0];                                      // k

  // Shift mode
  if (shift == 1'b1) begin 
    // Reset the lfsr 
    rin.lfsr = 5'b00001;

    // Read key from data pins
    rin.key = {data_in, r.key[63:4]};

    // Read overflow from the key register
    rin.round = {r.key[3:0], r.round[31:4]};
  end
end

// Register clocking
always_ff @(posedge clk) begin
  r <= rin;
end

endmodule 