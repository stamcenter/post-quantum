
/** @module : gaussian_smul_16_18_sadd_37.v - Signed multiplier 16-bit x 18-bit follows signed adder 37-bit, delay 3 cycles.
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


module gaussian_smul_16_18_sadd_37 (
    // System signals
    input clk,                  // system clock

    // Data interface
    input [15:0] a,             // multiplicand
    input [17:0] b,             // multiplicator
    input [36:0] c,             // adder
    output [37:0] p             // result
);

// Behavioral model
reg signed [15:0] a_reg;
reg signed [17:0] b_reg;
reg signed [36:0] c_reg;
reg signed [33:0] prod;
wire signed [37:0] sum;
reg [37:0] result;

always @ (posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    c_reg <= c;
end

always @ (posedge clk) begin
    prod <= a_reg * b_reg;
end

assign sum = c_reg + prod;

always @ (posedge clk) begin
    result <= sum;
end

assign p = result;


endmodule
