`timescale 1ns / 1ps

/** @module : PKC_TOP_serial
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
*                                 PKC_TOP_serial                                 *
*********************************************************************************/



module PKC_TOP_serial(  KeyGen_STATE, Enc_STATE, KeyGen_CNT, Enc_CNT,                                   // for simulation
                        clk, reset, start,                                                              // for all
                        KeyGen_TRNG_ready, KeyGen_Gaussian_ready, KeyGen_TRNG_in, KeyGen_Gaussian_in,   // for KeyGen
                        Enc_Gaussian_ready, Enc_Gaussian_in, message, msg_ready,                        // for Enc
                        dec_msg_ready, dec_message                                                      // for Dec
                      );



// ------------------------------- PKC parameters ------------------------------- //






////////////////////////////////////////////////////////
//
//
//     p must be double sized if modding a product !      
//     otherwise the mod can go wrong!
//
///////////////////////////////////////////////////////

`include "pars.vh"

/*
// Ring element size
// Make p this size so that the (A * B) % p will be correct
parameter [41:0] p = 1049089; 

// Polynomial length: # of coefficients in the polynomial
parameter N = 256;
parameter N_inv = 1044991; // 1/N mod p
*/

// Symbol (each element in a polynomial) bit width
parameter logP = $clog2(p); // ceiling of log_2 (p) = 21
// The counter size
parameter logN = $clog2(N); // log_2 (N) = 8






// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input KeyGen_TRNG_ready, KeyGen_Gaussian_ready; // random number and Gaussian noise for KeyGen
input Enc_Gaussian_ready;                       // Gaussian noise for Enc
input msg_ready;

// The random numbers and Gaussian distribution sampling 
// It takes N cycles to get the whole a, s, e, r0, r1, r2
// ---- Once we have the TRNG & Gaussian modules, they will become internal signals 
input [logP-1:0] KeyGen_TRNG_in, KeyGen_Gaussian_in;
input [logP-1:0] Enc_Gaussian_in;
input [N-1:0] message;


//----------------------------------- Outputs ------------------------------------ //
output [N-1:0] dec_message; 
output dec_msg_ready;

output [3:0] KeyGen_STATE;
output [4:0] Enc_STATE;

output [logN-1:0] KeyGen_CNT, Enc_CNT;


//----------------------------------- Wires-- ------------------------------------ //                                                                               
wire key_ready, cipher_ready;

wire [logP-1:0] pub_key_a, pub_key_b, sec_key_s;
wire [logP-1:0] cipher_c0, cipher_c1;




// ----------------------------------- Logic Starts-------------------------------- //
KeyGen Alice_KeyGen (KeyGen_STATE, KeyGen_CNT, clk, reset, start, KeyGen_TRNG_ready, KeyGen_TRNG_in, KeyGen_Gaussian_ready, KeyGen_Gaussian_in, pub_key_a, pub_key_b, sec_key_s, key_ready);
Enc Bob_Enc (Enc_STATE, Enc_CNT, clk, reset, start, Enc_Gaussian_ready, Enc_Gaussian_in, key_ready, pub_key_a, pub_key_b, message, msg_ready, cipher_c0, cipher_c1, cipher_ready);
Dec Alice_Dec (clk, reset, start, cipher_ready, cipher_c0, cipher_c1, key_ready, sec_key_s, dec_msg_ready, dec_message);




endmodule
