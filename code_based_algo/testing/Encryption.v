`timescale 1ns / 1ps

/** @module : Encryption
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

module Encryption(clk, reset, start, key_ready, pub_key, message, error, cipher, cipher_ready);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Encryption Algorithm:
//q is the chosen prime number, defined in pars.vh
//t is number of bits that can be error corrected, defined in pars.vh
//N = 2 * t * q
//m is of order 1 x n where n is q * q
//G' is of order n x K where K is n + N
//codeword = m * G'
//cipher = codeword + error
//generated cipher will be of order 1 x K 
/////////////////////////////////////////////////////////////////////////////////////////////////////////


// ============================== PKC parameters ================================ //
//`include "pars.vh"
parameter q = 199;
parameter t = 100;
parameter n = q * q;
parameter N = 2 * t * q;
parameter K = n + N;
parameter cnt_max = n * K;
parameter cnt_bw = $clog2(cnt_max);
parameter logK = $clog2(K);

// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input key_ready; // Public key is ready
//input msg_ready; // plaintext message ready

//plainttext message 1 x n
input [n-1:0] message;
//error vector 1 x K
input [K-1:0] error;
//public key column wise i.e. n bits from n x K   
input [n-1:0] pub_key;

//----------------------------------- Outputs ------------------------------------ //
output reg [K-1:0] cipher; 
output reg cipher_ready;

//----------------------------------- Registers ----------------------------------- //
//public key G' of order n x K
//reg [cnt_max-1:0] reg_gdash;

//intermediate results in matrix multiplication & addition
reg [n-1:0] reg_sum;
reg [K-1:0] reg_codeword;
reg [K-1:0] reg_cipher;

// for FSM
reg [2:0] STATE;
reg [cnt_bw-1:0] CNT;
reg [logK-1:0] j;

// =================================== for FSM ===================================== //
//starting state for the FSM
parameter IDLE = 0;
//get the public key gdash
parameter RCV = 1;
//multiply gdash(matrix) and message(vector) 
parameter MUL_mgdash = 2; 
//add result of multiplication to error vector
parameter ADD_mgdashe = 3;
//output the cipher
parameter CIPHER_OUT = 4;


always @ (posedge clk)
begin
    if(reset)
    begin
        cipher <= 0; 
        cipher_ready <= 0;
        STATE <= 0;
        CNT <= 0;
        j <= 0;
    end
    else
        case (STATE)
            IDLE: //STATE 0
            begin
                if (start && key_ready)
                begin
                    j <= 0;
                    CNT <= 0;
                    cipher <= 0;
                    cipher_ready <= 0;
                    reg_sum <= 0;
                    reg_codeword <= 0;
                    reg_cipher <= 0;
                    STATE <= MUL_mgdash;
                end
                else
                    STATE <= IDLE;
            end //STATE 0
            /*
            RCV: //STATE 1, takes K cycles
            begin
                if (CNT <= cnt_max)
                begin
                    //store the values column wise i.e. 0 to K-1
                    //helpful to perform multiplication operation in the next state 
                    reg_gdash[CNT+:n] <= pub_key;
                    CNT <= CNT + n; //increment by n which is equal to number of rows
                    
                    if (CNT == cnt_max)
                    begin
                        CNT <= 0;
                        STATE <= MUL_mgdash;
                        j <= K;
                    end
                end              
            end //STATE 1
            */
            MUL_mgdash: //STATE 2, takes K cycles
            begin
                //j <= n - 1;
                if (CNT <= cnt_max)
                begin
                    //perform gdash(matrix) and message(vector) multiplication
                    //gdash dimension is n x K
                    //message dimension is 1 x n
                    //since both matrix and vector is binary
                    //and required result is in binary
                    //hence we perform AND operation instead of mul
                    //and XOR operation instead of add
                    reg_sum <= pub_key & message;
                    reg_codeword[j] <= ^reg_sum;
                    CNT <= CNT + n;
                    j <= j - 1;
                    
                    if (CNT == cnt_max)
                    begin
                        CNT <= 0;
                        j <= 0;
                        STATE <= ADD_mgdashe;
                    end
                end
                
            end //STATE 2
            
            ADD_mgdashe: //STATE 3, takes K cycles
            begin
                if (CNT < K) //dimension of codeword and cipher is 1 x K
                begin
                    //add error to the generated codeword for obfuscation
                    reg_cipher[CNT] <= reg_codeword[CNT] ^ error[CNT];
                    CNT <= CNT + 1;
                    
                    if (CNT == K-1)
                    begin
                        CNT <= 0;
                        cipher_ready <= 1;
                        STATE <= CIPHER_OUT; //output the cipher in next clock cycle after cipher_ready is active
                    end
                end                
            end //STATE 3
            
            CIPHER_OUT: //STATE 4
            begin
                cipher <= reg_cipher;
            end //STATE 4
            
        endcase    
    
end

endmodule
