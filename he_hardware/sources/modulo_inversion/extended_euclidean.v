`timescale 1ns / 1ps

/** @module : extended_euclidean
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

module extended_euclidean(clk, reset, a, b, result);

input clk, reset;
input [4:0] a, b;
output reg [4:0] result;

reg [4:0] temp_a, temp_b;
reg [4:0] prevx, x;
reg [4:0] prevy, y;
reg [4:0] q;
reg [1:0] STATE;
parameter IDLE = 0;
parameter INITIAL = 1;
parameter COMPUTE = 2;
parameter OUTPUT = 3;

always @ (posedge clk) begin
    if (reset) begin
        result <= 0;
        STATE <= 0;
        temp_a <= a;
        temp_b <= b;
        q <= a/b;
    end
    else 
    case (STATE)
        IDLE:
        begin
            prevx <= 1;
            x <= 0;
            prevy <= 0;
            y = 1;
            temp_a <= temp_b;
            temp_b <= temp_a % temp_b;
            STATE <= INITIAL;
        end
        INITIAL:
        begin
            if (temp_b != 0)
                q <= temp_a/temp_b;
            STATE <= COMPUTE;
        end
        COMPUTE:
        begin
            if (temp_b != 0) begin
                x <= prevx - q * x;
                prevx <= x;
                y <= prevy - q * y;
                prevy <= y;
                temp_a <= temp_b;
                temp_b <= temp_a % temp_b;
                STATE <= INITIAL;
            end
            else
                STATE <= OUTPUT;
        end
        OUTPUT:
        begin
            result <= prevx % b;
        end
    endcase
end

endmodule
