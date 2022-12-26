/** @module : gaussian_ctg.v
 *  @author : Secure Trusted and Assured Microelectronics (STAM) Center

 *  Copyright (c) 2023 PQC.Secure (STAM/SCAI/ASU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

`timescale 1 ns / 1 ps


module gaussian_ctg #(
    parameter INIT_Z1 = 64'd5030521883283424767,
    parameter INIT_Z2 = 64'd18445829279364155008,
    parameter INIT_Z3 = 64'd18436106298727503359
)
(
    // System signals
    input clk,                    // system clock
    input rstn,                   // system synchronous reset, active low

    // Data interface
    input ce,                     // clock enable
    output reg valid_out,         // output data valid
    output reg [63:0] data_out    // output data
);

// Local variables
reg [63:0] z1, z2, z3;
wire [63:0] z1_next, z2_next, z3_next;


// Update state
assign z1_next = {z1[39:1], z1[58:34] ^ z1[63:39]};
assign z2_next = {z2[50:6], z2[44:26] ^ z2[63:45]};
assign z3_next = {z3[56:9], z3[39:24] ^ z3[63:48]};

always @ (posedge clk) begin
    if (!rstn) begin
        z1 <= INIT_Z1;
        z2 <= INIT_Z2;
        z3 <= INIT_Z3;
    end
    else if (ce) begin
        z1 <= z1_next;
        z2 <= z2_next;
        z3 <= z3_next;
    end
end


// Output data
always @ (posedge clk) begin
    if (!rstn)
        valid_out <= 1'b0;
    else
        valid_out <= ce;
end

always @ (posedge clk) begin
    if (!rstn)
        data_out <= 64'd0;
    else
        data_out <= z1_next ^ z2_next ^ z3_next;
end


endmodule
