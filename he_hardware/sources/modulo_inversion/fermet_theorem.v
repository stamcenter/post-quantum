`timescale 1ns / 1ps

/** @module : fermet_theorem
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

module fermet_theorem(clk, reset, result);

//initialize the parameter file
`include "pars.vh"

//defines bitwidth for the intermediate registers 
parameter index = $clog2(b);

//input
input clk, reset;
//input [3:0] a, b;

//output
output reg [index-1:0] result;

//a^y modulo b
reg [index-1:0] y [0:index-1];
//holds intermediate computations
reg [2*index-1:0] p;
reg [2*index-1:0] temp_p;
//indexes into y
reg [index-1:0] CNT;
//defines states for the state machine
reg [2:0] STATE;
//output is ready
reg done;

//initialize the count 
parameter CNT_INIT = $clog2(b); 

//STATES in FSM
parameter IDEAL = 0;
parameter INITIAL_Y = 1;
parameter COMPUTE1 = 2;
parameter COMPUTE2 = 3;
parameter OUTPUT = 4;

reg done1;

always @ (posedge clk) begin
    if (reset) begin
        result <= 0;
        //initializing p to 0 doesnot work
        p <= 1;
        temp_p <= 1;
        CNT <= CNT_INIT - 1;
        done <= 0;
        STATE <= IDEAL;
    end
    else 
    case (STATE)
        IDEAL:
        begin
            //start assinging values from b-2
            if ((b % 2 == 0) & (CNT_INIT % 2 == 0))
                y[CNT] <= b - 1;
            else
                y[CNT] <= b - 2;
            STATE <= INITIAL_Y;
        end // IDEAL
        
        INITIAL_Y:
        begin
            if (CNT != 0) begin
                //start assinging values from b-2 to 1
                //CNT indexes from high to low 
                y[CNT-1] <= y[CNT] >> 1;
                CNT <= CNT - 1;  
            end
            else begin
                CNT <= 0;
                STATE <= COMPUTE1; 
            end
        end // INITIAL_Y
    
        COMPUTE1:
        begin
            if (CNT < CNT_INIT) begin
                //CNT = CNT + 1;
                if (y[CNT] == 1) begin
                    p <= 1;
                end
                temp_p = (p * p) % b;
                STATE = COMPUTE2;
            end
            else begin
                done <= 1;
                CNT <= 0;
                STATE <= OUTPUT;
            end
        end // COMPUTE1
        
        COMPUTE2:
        begin
            if (y[CNT] % 2 != 0) begin //y[CNT]
                p = (a * temp_p) % b;
                done1 = 0;
            end
            else begin
                p = temp_p;
                done1 = 1;
                
            end
            CNT = CNT + 1;
            STATE <= COMPUTE1;
        end
    
        OUTPUT:
        begin
            if (done)
                result <= p;
            else
                STATE <= OUTPUT;
        end // OUTPUT
    
    endcase //case
end // always block

endmodule
