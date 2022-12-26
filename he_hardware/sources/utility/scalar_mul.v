`timescale 1ns / 1ps

/** @module : scalar_mul
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

module scalar_mul(clk, reset, start, message, t, result);
    
    input clk;
    input reset;
    input start;
    input [1023:0] message;
    input [29:0] t;
        
    output reg [29:0] result;
    
    reg [1023:0] temp_message;
    reg [29:0] temp_result [0:1023];
    
    reg [1:0] STATE;
    parameter IDLE = 0; 
    parameter STORE = 0;
    parameter COMPUTE = 1;
    parameter OUTPUT = 2;
    
    reg done;
        
    reg [9:0] count;
        
    always @(posedge clk) begin
        if (reset) begin
            STATE <= 0;
            count <= 0;
            done <= 0;
        end
        else begin
        case(STATE)
            IDLE:
            begin
                if (start && !done)
                    STATE <= STORE;
                else
                    STATE <= IDLE;
            end
            
            STORE:
            begin
                if (count < 1024) begin
                    temp_message[count] <= message;
                    count <= count + 1;
                    if (count == 1023) begin
                    count <= 0;
                        STATE <= COMPUTE;
                    end
                end
            end
                
            COMPUTE:  
            begin
                if (count < 1024) begin
                    temp_result[count] <= (temp_message[count] == 1) ? (t) : 0;
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        STATE <= OUTPUT;
                    end
                end
            end
                
            OUTPUT:
            begin
                if (count < 1024) begin
                    result <= temp_result[count];
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        done <= 1;
                        STATE <= IDLE;
                    end
                end
            end
        endcase
        end
    end
    
   
endmodule
