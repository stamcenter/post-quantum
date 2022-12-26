`timescale 1ns / 1ps

/** @module : rns
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

module rns(clk, reset, a_input, b_output);

`include "pars.vh"

//inputs
input clk, reset;
input [lwidth-1:0] a_input;

//outputs
output reg [swidth-1:0] b_output;

//modulus registers
reg [swidth-1:0] q[0:parts-1];

//intermediate registers
reg [swidth-1:0] b_temp[0:parts-1];
reg [1:0] CNT; //keep track of number of parts


//FSM register
reg [1:0] STATE;

//states in the FSM
parameter IDLE = 0;
parameter COMPUTE = 1;
parameter OUTPUT = 2;


always @(posedge clk) begin
    if (reset) begin
        b_output <= 0;
        STATE <= 0;    
    end
    else
    begin
        case (STATE)
        IDLE:
        begin
            `include "modulus_values.vh"
            CNT <= 0;
            STATE <= COMPUTE;
        end //IDLE
    
        COMPUTE:
        begin
            if (CNT <= parts) begin
                CNT <= CNT + 1;
                b_temp[CNT] <= a_input % q[CNT];
                
                if (CNT == parts) begin
                    CNT <= 0;
                    STATE <= OUTPUT;
                end
            end     
        end //COMPUTE
    
        OUTPUT:
        begin 
            if (CNT < parts) begin
                CNT <= CNT + 1;
                b_output <= b_temp[CNT];
            end
        end //OUTPUT
        endcase
    end
end

endmodule
