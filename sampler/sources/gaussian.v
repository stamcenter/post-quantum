/** @module : gaussian.v  - Gaussian noise generator
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


module gaussian #(
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
    output valid_out,             // output data valid
    output [15:0] data_out        // output data, s<16,11>
);

// Local variables
wire valid_out_ctg;
wire [63:0] data_out_ctg;


// Instances
gaussian_ctg #(
    .INIT_Z1(INIT_Z1),
    .INIT_Z2(INIT_Z2),
    .INIT_Z3(INIT_Z3)
) u_gaussian_ctg (
    .clk(clk),
    .rstn(rstn),
    .ce(ce),
    .valid_out(valid_out_ctg),
    .data_out(data_out_ctg)
);

gaussian_interp u_gaussian_interp (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_ctg),
    .data_in(data_out_ctg),
    .valid_out(valid_out),
    .data_out(data_out)
);


endmodule