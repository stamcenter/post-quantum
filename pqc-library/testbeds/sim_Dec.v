`timescale 1ns / 1ps

/** @module : sim_Dec
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
*                                     sim_Dec                                    *
*********************************************************************************/


module sim_Dec;

//////////////////////////////////////////////////////////////////////////////////
// 
// Dec Algorithm:
// m = [(c0 - c1*s)/t], where [] means taking the nearest binary interger
//
// 
// MUL Algorthm: convolution c = a $ b  ($ is convolution)
// a' = a*phi; b' = b*phi
// A' = NTT(a'); B' = NTT(b')
// C' = A' . B'                         (. is dot product)
// c' = iFFT(C')
// c = c'*phi_inv
// 
//
// [] operator:
// t = (q-1)/2   
// [u/t] = (|u-t| < t/2) ? 1 : 0;
//
//////////////////////////////////////////////////////////////////////////////////





// ------------------------------- PKC parameters ------------------------------- //

// ------------- Small test case ---------------- //
parameter p = 17; 
parameter N = 8;
parameter t = 8; 		// t = (p-1)/2
parameter t_half = 4;	// t/2
parameter N_inv = 15; // 1/N mod p
parameter logP = $clog2(p);
parameter logN = $clog2(N);




// Inputs
reg clk, start, reset, cipher_ready, sec_key_ready;
reg [logP-1:0] c0_in, c1_in, sec_key_s;



// Outputs
wire message_ready;
wire [logP-1:0] message;


// Instantiate the Unit Under Test (UUT)
Dec Dec1 (
    .clk(clk), 
    .reset(reset), 
    .start(start),
    .cipher_ready(cipher_ready),
    .c0_in(c0_in),
    .c1_in(c1_in),
    .sec_key_ready(sec_key_ready),
    .sec_key_s(sec_key_s),
    .message_ready(message_ready),
    .message(message)
);



always #5 clk = ~clk;

//reg [logN-1:0] counter;

initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    start = 0;
    cipher_ready = 0;
    sec_key_ready = 0;
    
    c0_in <= 0;
    c1_in <= 0;
    sec_key_s <= 0;

    // Wait 100 ns for global reset to finish
    #100;
    reset = 0;
            
    #100;
    // Add stimulus here
    start = 1;
    sec_key_ready = 1;
    
    // All numbers go:
    // small -> large as left -> right
    // sec_key_s = 12, 1, 1, 12, 5, 16, 16, 5
    #20;
    start = 0;
    sec_key_s = 12;
  
    #10;sec_key_s = 1;  
    
    #10;sec_key_s = 1;
    
    #10;sec_key_s = 12;
    
    #10;sec_key_s = 5;
    
    #10;sec_key_s = 16;  

    #10;sec_key_s = 16;
    
    #10;sec_key_s = 5;
    
    cipher_ready = 1;
    
    
    // c0 = [16,11,10,6,10,9,0,3]
    // c1 = [2,9,2,5,6,8,10,5]
    #20; c0_in = 16;    c1_in = 2;
    #10; c0_in = 11;    c1_in = 9;
    #10; c0_in = 10;    c1_in = 2;
    #10; c0_in = 6;     c1_in = 5;
    #10; c0_in = 10;    c1_in = 6;
    #10; c0_in = 9;     c1_in = 8;
    #10; c0_in = 0;     c1_in = 10;
    #10; c0_in = 3;     c1_in = 5;
    // done
    #10; c0_in = 0;     c1_in = 0;
             
    

    
    // the message should be:
    // (15, 4, 1, 10, 10, 2, 4, 16)
    
    #2000;
    $finish;

end

endmodule
