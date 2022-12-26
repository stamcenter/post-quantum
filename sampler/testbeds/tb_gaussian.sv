/** @module : tb_gaussian
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


module tb_gaussian;

// Parameters
parameter ClkPeriod = 10.0;
parameter Dly = 1.0;
parameter N = 1000000;


// Local variables
logic clk;
logic rstn;
logic ce;
logic valid_out;
logic [15:0] data_out;


// Instances
gaussian #(
   .INIT_Z1(64'd5030521883283424767),
   .INIT_Z2(64'd18445829279364155008),
   .INIT_Z3(64'd18436106298727503359)
)
u_gaussian (.*);


// System signals
initial begin
    clk <= 1'b0;
    forever #(ClkPeriod/2) clk = ~clk;
end

initial begin
    rstn <= 1'b0;
    #(ClkPeriod*2) rstn = 1'b1;
end


// Main process
int fpOut;

initial begin
    fpOut = $fopen("gaussian_data_out.txt", "w");

    ce = 0;

    #(ClkPeriod*10)
    repeat (N) begin
        @(posedge clk);
        #(Dly);
        ce = 1;
    end
    @(posedge clk);
    #(Dly);
    ce = 0;

    #(ClkPeriod*20)
    $fclose(fpOut);
    $stop;
end


// Record data
always_ff @ (negedge clk) begin
    if (valid_out)
        $fwrite(fpOut, "%0d\n", $signed(data_out));
end


endmodule
