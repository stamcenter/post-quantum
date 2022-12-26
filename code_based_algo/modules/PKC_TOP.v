`timescale 1ns / 1ps

/** @module : PKC_TOP
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

module PKC_TOP(clk, reset, start, generator_ready, S_ready, P_ready, 
                generator, S, P, message, error,
                parity_ready, parity_check_row, parity_check_col, 
                S_inv_ready, S_inv, P_inv_ready, P_inv, 
                dec_message, dec_msg_ready);
                
// ============================== PKC parameters ================================ //
                `include "pars.vh"
                
                parameter n = q * q;
                parameter N = 2 * t * q;
                parameter K = n + N;
                
                // ------------------------------------ Inputs ---------------------------------- //
                //Common system inputs
                input clk, start, reset;
                input generator_ready, S_ready, P_ready; 
                input [K-1:0] generator;
                input [n-1:0] S;
                input [K-1:0] P;
                input [n-1:0] message;
                input [K-1:0] error;
                input parity_ready, S_inv_ready, P_inv_ready;
                input [K-1:0] parity_check_row; 
                input [N-1:0] parity_check_col;
                input [n-1:0] S_inv; 
                input [K-1:0] P_inv;
                
                
                //----------------------------------- Outputs ------------------------------------ //
                output [n-1:0] dec_message; 
                output dec_msg_ready;
                
                //output [3:0] KeyGen_STATE;
                //output [4:0] Enc_STATE;
                
                //output [logN-1:0] KeyGen_CNT, Enc_CNT;
                
                
                //----------------------------------- Wires-- ------------------------------------ //                                                                               
                wire key_ready, cipher_ready;
                wire [n-1:0] pub_key;
                wire [K-1:0] cipher;
                
                
                // ----------------------------------- Logic Starts-------------------------------- //
                keyGen Alice_KeyGen(clk, reset, start, generator_ready, generator, S_ready, S, P_ready, P, pub_key, key_ready);
                Encryption BOB_Enc(clk, reset, start, key_ready, pub_key, message, error, cipher, cipher_ready);
                Decryption Alice_Dec(clk, reset, start, cipher_ready, cipher, parity_ready, parity_check_row, parity_check_col, S_inv_ready, S_inv, P_inv_ready, P_inv, dec_message, dec_msg_ready);

endmodule
