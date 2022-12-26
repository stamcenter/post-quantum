`timescale 1ns / 1ps

/** @module : sim_Enc
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
*                                     sim_Enc                                    *
*********************************************************************************/


module sim_Enc;

//////////////////////////////////////////////////////////////////////////////////
// 
// Encryption Algorithm:
// c0 = b*r0 + r2 + tm
// c1 = a*r0 + r1
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
reg clk, start, reset, Gaussian_ready, key_ready, msg_ready;
reg [logP-1:0] Gaussian_in, pub_key_a, pub_key_b;
reg [N-1:0] message;

// Outputs
wire cipher_ready;
wire [logP-1:0] cipher_c0, cipher_c1;


// Instantiate the Unit Under Test (UUT)
Enc Enc_DUT ( 
    .clk(clk), 
    .reset(reset), 
    .start(start),
    .Gaussian_ready(Gaussian_ready),
    .Gaussian_in(Gaussian_in),
    .key_ready(key_ready),
    .pub_key_a(pub_key_a),
    .pub_key_b(pub_key_b),
    .message(message),
    .msg_ready(msg_ready),
    .cipher_c0(cipher_c0),
    .cipher_c1(cipher_c1),
    .cipher_ready(cipher_ready)
);



always #5 clk = ~clk;

//reg [logN-1:0] counter;

initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    start = 0;
    key_ready = 0;
    msg_ready = 0;
    Gaussian_ready = 0;

    // Wait 100 ns for global reset to finish
    #100;
    reset = 0;
            
    #100;
    // Add stimulus here
    start = 1;
    Gaussian_ready = 1;
  
    //r0 = (1,1,1,0,0,0,0,1)
    #20; Gaussian_in = 1; start = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
             
    //r1 = (1, 0, 0, 1, 0, 0, 0, 0)
    #20; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    
    //r2 = (0, 1, 0, 1, 0, 0, 0, 0)
    #20; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 1;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;
    #10; Gaussian_in = 0;    
    
    #20; msg_ready = 1;
         message = {1'b0,1'b0,1'b1,1'b1,1'b0,1'b0,1'b1,1'b1};
    
    #350; key_ready = 1;
    
    //public key a,b
    #10; pub_key_a = 5; pub_key_b = 15;
    #10; pub_key_a = 9; pub_key_b = 4;
    #10; pub_key_a = 13; pub_key_b = 1;
    #10; pub_key_a = 5; pub_key_b = 10;
    #10; pub_key_a = 0; pub_key_b = 10;
    #10; pub_key_a = 11; pub_key_b = 2;
    #10; pub_key_a = 8; pub_key_b = 4;
    #10; pub_key_a = 8; pub_key_b = 16;
    
   
    #1235;
    $finish;

end


endmodule
