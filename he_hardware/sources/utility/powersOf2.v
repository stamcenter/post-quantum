`timescale 1ns / 1ps

/** @module : powersOf2
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

module powersOf2(clk, reset, start, s_2, result);

input clk;
input reset;
input start;
input [9:0] s_2; //maximum element size will be 2^10 (length of polynomial) considering all the elements in s is 1

output reg [9:0] result;

reg [9:0] temp_s_2 [0:1023];
reg [9:0] temp_result [0:39][0:1023];

reg [9:0] count;
//number of times shift operations to be performed
// it should be 0 to k-1 (k is 40 in our case)
reg [5:0] shift_count;

//FSM
reg [1:0] STATE;

reg done;

parameter IDLE = 0;
parameter STORE = 1;
parameter COMPUTE = 2;
parameter OUTPUT = 3;

always @(posedge clk) begin
    if (reset) begin
        STATE <= 0;
        done <= 0;
        count <= 0;
        shift_count <= 0;
    end
    else begin
    case (STATE)
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
                temp_s_2[count] <= s_2;
                count <= count + 1;
                if (count == 1023) begin
                    count <= 0;
                    STATE <= COMPUTE;
                end
            end
        end
        
        COMPUTE:
        begin
            if (shift_count < 40) begin
                if (count < 1024) begin
                    temp_result[shift_count][count] <= (temp_s_2[count] << shift_count);
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        shift_count <= shift_count + 1;
                    end
                end
                if(shift_count == 39) begin
                    shift_count <= 0;
                    STATE <= OUTPUT;
                end
            end
        end
       
        OUTPUT:
        begin
            if (shift_count < 40) begin
                if (count < 1024) begin
                    result <= temp_s_2[shift_count][count];
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        shift_count <= shift_count + 1;
                    end
                end
                if(shift_count == 39) begin
                    shift_count <= 0;
                    done <= 1;
                    STATE <= IDLE;
                end
            end
        end
        
    endcase
    end

end

endmodule
