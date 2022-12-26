`timescale 1ns / 1ps

/** @module : sim_KeyGen
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
*                                  sim_KeyGen                                    *
*********************************************************************************/

module sim_KeyGen;
//////////////////////////////////////////////////////////////////////////////////
// 
// KeyGen Algorithm:
// b = a*s + e
// 
// MUL Algorthm: convolution c = a $ b  ($ is convolution)
// a' = a*phi; b' = b*phi
// A' = NTT(a'); B' = NTT(b')
// C' = A' . B'                         (. is dot product)
// c' = iFFT(C')
// c = c'*phi_inv
// 
//////////////////////////////////////////////////////////////////////////////////




// ------------------------------- PKC parameters ------------------------------- //

// ------------- Small test case ---------------- //
parameter p = 17; 
parameter logP = 5;
parameter N = 8;
parameter logN = 3;
parameter N_inv = 15; // 1/N mod p




// Inputs
reg clk, start, reset, TRNG_ready, Gaussian_ready;
reg [logP-1:0] TRNG_in, Gaussian_in;



// Outputs
wire key_ready;
wire [logP-1:0] pub_key_a, pub_key_b, sec_key_s;


// Instantiate the Unit Under Test (UUT)
KeyGen KeyGen1 (
    .clk(clk), 
    .reset(reset), 
    .start(start),
    .TRNG_ready(TRNG_ready),
    .TRNG_in(TRNG_in),
    .Gaussian_ready(Gaussian_ready),
    .Gaussian_in(Gaussian_in),
    .pub_key_a(pub_key_a),
    .pub_key_b(pub_key_b),
    .sec_key_s(sec_key_s),
    .key_ready(key_ready)
);



always #5 clk = ~clk;

//reg [logN-1:0] counter;

initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    start = 0;
    TRNG_ready = 0;
    Gaussian_ready = 0;


    // Wait 100 ns for global reset to finish
    #100;
    reset = 0;
            
    #100;
    // Add stimulus here
    start = 1;
    TRNG_ready = 1;
    
    // All numbers go:
    // small -> large as left -> right
    // public_key a = 1,2,3,4,5,6,7,8
    #20;
    start = 0;
    TRNG_in = 1;
  
    #10;TRNG_in = 2;  
    
    #10;TRNG_in = 3;
    
    #10;TRNG_in = 4;
    
    #10;TRNG_in = 5;
    
    #10;TRNG_in = 6;  

    #10;TRNG_in = 7;
    
    #10;TRNG_in = 8;
    Gaussian_ready = 1;
    
    
    // secreat key s = (0,1,0,1,0,1,0,1)
    #20; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    
    #10; Gaussian_in = 0;
             
    
    // noise e = (1, 1, 0, 1, 1, 0, 0, 0)
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    //#10; Gaussian_in = 0;    
    
    // the pub_key_b should be:
    // b = [15, 4, 1, 10, 10, 2, 4, 16]
    
    #2000;
    $finish;

end

endmodule
