`timescale 1ns / 1ps

/** @module : gcd_binary
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

module gcd_binary(clk, reset, x, y, result);

input clk, reset;
input [39:0] x, y;
output reg [39:0] result;

reg [39:0] temp_x, temp_y;
reg done;
//reg parity_x, parity_y;

always @ (posedge clk) begin
    if (reset) begin
        result <= 1;
        temp_x <= x;
        temp_y <= y;
        done <= 0;
        //parity_x <= ~^x;
        //parity_y <= ~^y;
    end
    else 
    begin
        if (temp_x == temp_y & done == 0) begin
            result <= temp_x * result;
            done <= 1;
        end
        else if (temp_x[0] == 0 & temp_y[0] == 0 & done == 0) begin
            temp_x <= temp_x >> 1;
            temp_y <= temp_y >> 1;
            result <= result * 2;
        end
        else if (temp_x[0] == 0 & done == 0)
            temp_x <= temp_x >> 1;
        else if (temp_y[0] == 0 & done == 0)
            temp_y <= temp_y >> 1;
        else if (temp_x > temp_y & done == 0)
            temp_x <= (temp_x - temp_y) >> 1;
        else if (temp_x < temp_y & done == 0)
            temp_y <= (temp_y - temp_x) >> 1;
    end
end

endmodule
