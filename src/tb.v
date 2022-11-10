`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input clk,
    input shift,
    input [3:0] data_in,
    output [3:0] data_out
   );

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    wire [7:0] inputs = {2'b00, data_in, shift, clk};
    wire [7:0] outputs;
    assign data_out = outputs[3:0];

    // instantiate the DUT
    invalidopcode_simon_decrypt invalidopcode_simon_decrypt(
        .io_in  (inputs),
        .io_out (outputs)
        );

endmodule
