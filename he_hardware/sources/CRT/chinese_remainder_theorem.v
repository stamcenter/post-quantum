`timescale 1ns / 1ps

/** @module : chinese_remainder_theorem
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
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 *
 */

module chinese_remainder_theorem(clk, reset, m, x, result);

input clk, reset;
input [15:0] m, x;
output [15:0] result;

//wires to store the updated m and x values 
//while performing computations
wire [29:0] temp_m; //[8:0]
wire [26:0] temp_x; //[7:0]

//to keep track of number of zeroes to be padded
wire [1:0] zero_padding; 

//assign initial values
assign zero_padding = 2'b0;
assign temp_m[3:0] = 4'b0;
assign temp_x[3:0] = 4'b0;

//outputs from the modulo_inverse modules
wire [3:0] temp_result1, temp_result2;
wire [4:0] temp_result11, temp_result21;
wire [5:0] temp_result111, temp_result211;

//wires for intermediate computations
wire [11:0] temp1, temp2;
wire [11:0] temp11, temp21;
wire [15:0] temp111, temp211;

//wires for intermediate x values
wire [3:0] temp_x1;


genvar i;

for(i = 0; i < 3; i=i+1) begin
    if (i == 0) begin
        //width = 4
        modulo_inverse #(.index(4)) m1(clk, reset, m[i+8-1:i+4], m[i+4-1:i], temp_result1);
        modulo_inverse #(.index(4)) m2(clk, reset, m[i+4-1:i], m[i+8-1:i+4], temp_result2);
        assign temp1 = (temp_result1 * x[(i*4)+4-1:i*4] * m[(i*4)+8-1:(i*4)+4]) + (temp_result2 * x[(i*4)+8-1:(i*4)+4] * m[(i*4)+4-1:i*4]);
        assign temp2 = m[(i*4)+4-1:i*4] * m[(i*4)+8-1:(i*4)+4];
        assign temp_x[i+8-1:i+4] = temp1 % temp2;
        assign temp_m[i+8:i+4] = temp2;
    end
    else if(i == 1)
    begin
        //width = 5
        modulo_inverse #(.index(i+4)) m1(clk, reset, {zero_padding[i-1:0],m[(i*4)+8-1:(i*4)+4]}, temp_m[(i*4)+4:i*4], temp_result11);
        modulo_inverse #(.index(i+4)) m2(clk, reset, temp_m[(i*4)+4:i*4], {zero_padding[i-1:0],m[(i*4)+8-1:(i*4)+4]}, temp_result21);
        assign temp11 = (temp_result11 * temp_x[(i*4)+4-1:i*4] * m[(i*4)+8-1:(i*4)+4]) + (temp_result21 * x[(i*4)+8-1:(i*4)+4] * temp2);
        assign temp21 = temp_m[(i*4)+4:i*4] * m[(i*4)+8-1:(i*4)+4];
        assign temp_x[(i*8)+8-1:(i*4)+4] = temp11 % temp21; //width becomes 8 bit
        assign temp_m[(i*8)+8:(i*4)+4+i] = temp21; 
    end
    else
    begin
        //width = 8
        modulo_inverse #(.index(i+6)) m1(clk, reset, {zero_padding[i-1:0],m[(i*4)+8-1:(i*4)+4]}, temp_m[(i*8):(i*5)-1], temp_result111);
        modulo_inverse #(.index(i+6)) m2(clk, reset, temp_m[(i*8):(i*5)-1], {zero_padding[i-1:0],m[(i*4)+8-1:(i*4)+4]}, temp_result211);
        assign temp111 = (temp_result111 * temp_x[(i*4)+8-1:i*4] * m[(i*4)+8-1:(i*4)+4]) + (temp_result211 * x[(i*4)+8-1:(i*4)+4] * temp21);
        assign temp211 = temp_m[(i*8):(i*5)-1] * m[(i*4)+8-1:(i*4)+4];
        assign temp_x[(i*8)+10:(i*4)+8] = temp111 % temp211;  //width becomes 11 bits
        assign temp_m[(i*8)+13:(i*8)+1] = temp211; //width becomes 12 bits
    end
end

assign result = temp_x[26:16];

endmodule
