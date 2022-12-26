`timescale 1ns / 1ps

/** @module : modified_barret_reduction
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

module modified_barret_reduction(x, y);

parameter q = 65537;
parameter s = 8;
parameter mew = 256;
parameter div = 2 * s;

//k = ceil(log_2(q));
parameter k = $clog2(q);
//mul factor
//parameter [k:0] mul = 2 * k;
//r = floor((2^2*5)/q);
//2^2k will be k+1 bits
//parameter [k:0] r = (2 ** mul)/q;

//x max can be 2k bits(assuming it to be a result after multiplying two k-bit numbers)
input [2*k-1:0] x;
//output should be less than q and hence should be less than k-bits
output [k:0] y;

//t should be k+1 bits
wire [k:0] t;

assign t = (x >> div) * (mew >> s);

assign y = x - (t * q); 

endmodule
