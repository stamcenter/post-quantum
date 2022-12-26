`timescale 1ns / 1ps

/** @module : sim_PKC_TOP_serial
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
*                               sim_PKC_TOP_serial                               *
*********************************************************************************/

module sim_PKC_TOP_serial;


// ------------------------------- PKC parameters ------------------------------- //

`include "pars.vh"

/*
parameter [41:0] p = 1049089; 
parameter N_inv = 1044991;  // 1/N mod p
parameter N = 256;
*/

parameter logP = $clog2(p); // ceiling of log_2 (p) = 21
parameter logN = $clog2(N); // log_2 (N) = 8



// ---------- for simulation ------------

// the smaller N_qrt is, the more likely decryption will be correct 
parameter N_qrt = N / 1;

//parameter msg = 8'hAB;
//parameter msg = 8'hCD;
//parameter msg = 8'hEF;

//parameter msg = 16'hBABE;
//parameter msg = 16'hFACE;
//parameter msg = 16'hACED;

//parameter msg = 32'hBABE_FACE;
//parameter msg = 32'hACED_CAFE;
//parameter msg = 32'hDEAD_BEAF;

//parameter msg = 64'hBABE_FACE_ACED_CAFE;
//parameter msg = 64'hDEAD_BEEF_DEAF_FADE;
parameter msg = 64'hBEAD_DEED_CEDE_FEED;

//parameter msg = 128'hBABE_FACE_ACED_CAFE_DEAD_BEEF_DEAF_FADE;
//parameter msg = 128'hBABE_BEAD_BEEF_CAFE_DEED_FACE_FADE_FEED;
//parameter msg = 128'hDEAD_DEAF_ACED_CEDE_CAFE_DEED_FACE_BABE;

//parameter msg = 256'hBABE_BEAD_BEEF_CAFE_DEED_FACE_FADE_FEED_DEAD_DEAF_ACED_CEDE_CAFE_DEED_FACE_BABE;

// for Gaussian sampling, MAX err_rate = (p*0.07) / sqrt(2*pi)
// for uniform sampling,  MAX err_rate = (p*0.02) / sqrt(2*pi)
parameter err_rate = 8;









// Inputs
reg clk, start, reset;
reg KeyGen_TRNG_ready, KeyGen_Gaussian_ready;
reg Enc_Gaussian_ready;
reg msg_ready;
reg [logP-1:0] KeyGen_TRNG_in, KeyGen_Gaussian_in, Enc_Gaussian_in;
reg [N-1:0] message;




// Outputs
wire dec_msg_ready;
wire [N-1:0] dec_message;
wire [3:0] KeyGen_STATE;
wire [4:0] Enc_STATE;
wire [logN-1:0] KeyGen_CNT;
wire [logN-1:0] Enc_CNT;

// for simulation

wire Success;


// Instantiate the Unit Under Test (UUT)
PKC_TOP_serial PKC_TOP_serial_1 (
    .KeyGen_STATE(KeyGen_STATE), 
    .Enc_STATE(Enc_STATE),                              
    .KeyGen_CNT(KeyGen_CNT), 
    .Enc_CNT(Enc_CNT),                                  // for simulation
    
    .clk(clk),                                          // for all
    .reset(reset), 
    .start(start),
    
    .KeyGen_TRNG_ready(KeyGen_TRNG_ready),              // for KeyGen
    .KeyGen_Gaussian_ready(KeyGen_Gaussian_ready),
    .KeyGen_TRNG_in(KeyGen_TRNG_in),
    .KeyGen_Gaussian_in(KeyGen_Gaussian_in),
    
    .Enc_Gaussian_ready(Enc_Gaussian_ready),            // for Enc
    .Enc_Gaussian_in(Enc_Gaussian_in),
    .message(message),                                  
    .msg_ready(msg_ready),
    
    .dec_msg_ready(dec_msg_ready),                      // for Dec
    .dec_message(dec_message)
);


assign Success = (message == dec_message) ? 1 : 0;


always #5 clk = ~clk;

always @ (posedge clk)
begin      
    if (reset)
    begin
        KeyGen_TRNG_in = 0;
    end
    
    else  // if reset == 0
    begin
        KeyGen_TRNG_in = $urandom % p;      // a can be anything
        
        
        // s and e
        if (KeyGen_STATE == 3 || KeyGen_STATE == 4)
        begin
            KeyGen_Gaussian_in = (KeyGen_CNT <= N_qrt) ? ($urandom % err_rate) : 0;  // only give small values to the lower digits
        end 
        
        else
            KeyGen_Gaussian_in = 0;
        
        
        // r0, r1, r2
        if (Enc_STATE == 2 || Enc_STATE == 3 || Enc_STATE == 4)
            begin
                Enc_Gaussian_in = (Enc_CNT <= N_qrt) ? ($urandom % err_rate) : 0;  // only give small values to the lower digits
            end 
            
            else
                Enc_Gaussian_in = 0;
         
    end // else
    
end



initial begin
    // Initialize Inputs
    
    clk = 0;
    reset = 1;
    start = 0;
    KeyGen_TRNG_ready = 0;
    KeyGen_Gaussian_ready = 0;
    Enc_Gaussian_ready = 0;
    msg_ready = 0;
    //message = 0;

    #100;
    reset = 0;

    #100;
    // Add stimulus here
    start = 1;
    KeyGen_TRNG_ready = 1;
    KeyGen_Gaussian_ready = 1;
    Enc_Gaussian_ready = 1;
    
    
    //KeyGen_Gaussian_in = 7; // e, s 
    //Enc_Gaussian_in = 7;    // r0, r1, r2
    
    
    msg_ready = 1;
    
    // msg to encrypt
    message = msg;

    #20; start = 0;
         
    
    
    // a  = [1,2,3,4,5,6,7,8]
    // r0 = [1,1,1,0,0,0,0,1]
    /*
    #20; start = 0;
         KeyGen_TRNG_in = 1; Enc_Gaussian_in = 1;
    #10; KeyGen_TRNG_in = 2; Enc_Gaussian_in = 1;
    #10; KeyGen_TRNG_in = 3; Enc_Gaussian_in = 1;
    #10; KeyGen_TRNG_in = 4; Enc_Gaussian_in = 0;  
    #10; KeyGen_TRNG_in = 5; Enc_Gaussian_in = 0;   
    #10; KeyGen_TRNG_in = 6; Enc_Gaussian_in = 0;
    #10; KeyGen_TRNG_in = 7; Enc_Gaussian_in = 0;
    #10; KeyGen_TRNG_in = 8; Enc_Gaussian_in = 1;
    */
    
    
    /*
    #20; start = 0;
        
         Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 0;  
    #10; Enc_Gaussian_in = 0;   
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 1;
    */
    
    // s = (0,1,0,1,0,1,0,1)
    // r1 = (1,0,0,1,0,0,0,0)
    /*
    #20; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 1;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 1;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 0;
    */
    /*
    #20; Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    */
    
    
    // e  = (1,1,0,1,1,0,0,0)
    // r2 = (0,1,0,1,0,0,0,0)
    /*
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 1;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 1;
    #10; KeyGen_Gaussian_in = 1; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    #10; KeyGen_Gaussian_in = 0; Enc_Gaussian_in = 0;
    */
    
    /*
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 1;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    #10; Enc_Gaussian_in = 0;
    */
    
    
    
    
    end


endmodule
