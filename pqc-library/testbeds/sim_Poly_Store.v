`timescale 1ns / 1ps

/** @module : sim_Poly_Store
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

/*********************************************************************************
*                              sim_Poly_Store                                    *
*********************************************************************************/

module sim_Poly_Store;


// ------------- Small test case ---------------- //
parameter p = 17; 
parameter N = 8;
parameter logN = 3;
parameter b = 5;
parameter Nb = N*b;


	// Inputs
    reg clk, reset, WRITE, data_in_ready, READ;
    reg [b-1:0] data_in;


    // Outputs
    wire data_out_ready;
    wire [b-1:0] data_out;
    wire [Nb-1:0] poly_reg;

    // Instantiate the Unit Under Test (UUT)
    Poly_Store storage1 (
        .clk(clk), 
        .reset(reset), 
        .WRITE(WRITE), 
        .data_in_ready(data_in_ready), 
        .data_in(data_in), 
        .READ(READ), 
        .data_out_ready(data_out_ready), 
        .data_out(data_out), 
        .poly_reg(poly_reg)
    );
    
    
    
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;


        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        WRITE = 1;
        data_in_ready = 1;
        
        #10;
        WRITE = 0;
        data_in = 1;
        #10;
        data_in = 2;
        #10;
        data_in = 3;
        #10;
        data_in = 4;
        #10;
        data_in = 5;
        #10;
        data_in = 6;
        #10;
        data_in = 7;
        #10;
        data_in = 8;        
               
        #30;
        READ = 1;
        
        #10;
        READ = 0;
       

       
         
                
                
        #100;
        // Add stimulus here

    end
    
endmodule
