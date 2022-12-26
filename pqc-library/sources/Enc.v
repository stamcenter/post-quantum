`timescale 1ns / 1ps

/** @module : Enc
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
*                                         Enc                                    *
*********************************************************************************/


module Enc(Enc_STATE, Enc_CNT, clk, reset, start, Gaussian_ready, Gaussian_in, key_ready, pub_key_a, pub_key_b, message, msg_ready, cipher_c0, cipher_c1, cipher_ready);
//////////////////////////////////////////////////////////////////////////////////
// 
// Encryption Algorithm:
// c0 = b*r0 + r2 + tm
// c1 = a*r0 + r1
// 
//////////////////////////////////////////////////////////////////////////////////

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
parameter [41:0] p = 1049089; 

// Polynomial length: # of coefficients in the polynomial
parameter N = 256;
parameter N_inv = 1044991; // 1/N mod p
parameter t = 524544; 
*/

parameter t = (p-1) / 2; 		// t = (p-1)/2

// Symbol (each element in a polynomial) bit width
parameter logP = $clog2(p); // ceiling of log_2 (p) = 21
// The counter size
parameter logN = $clog2(N); // log_2 (N) = 8



// ========= for FSM ============ //
parameter IDLE = 0;

// wait to see if Gaussian Noise Sampler is ready
parameter RCV = 1; 
// perform computations for c0 and c1
parameter STR_r0 = 2;        // we will do swap for NTT and r0'=r0*phi here 
parameter STR_r1 = 3;        //  
parameter STR_r2 = 4;        // 
parameter NTT_r0 = 5;        // R0' = NTT(r0')
parameter ADD_r2tm = 6;      // R2' = r2 + (t . m)
parameter STR_ab = 7;        // a is already swapped, NWCed and NTTed - so perform dot product with r0 i.e. A' = a.R0' and also swap A'
                             // b is swapped and NWCed while storing
parameter iNTT_ar0 = 8;      // C1' = iNTT(A')
parameter iNWC_ar0 = 9;      // c1' = iNWC(C1')
parameter ADD_ar0r1 = 10;    // c1 = c1' + r1
parameter NTT_b = 11;        // B' = NTT(b)
parameter DOT_MUL_br0 = 12;  // B = B' . R0' and also swap
parameter iNTT_br0 = 13;     // iNTT(B)
parameter iNWC_br0 = 14;     // iNWC(B)
parameter ADD_br0r2tm = 15;    // c0 = B + R2' (c0 = b.r0 + r2 + tm)
parameter CIPHER_OUT = 16;   // output all ciphers

// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input Gaussian_ready; // Gaussian noise ready
input key_ready; // Public key a and b are ready
input msg_ready; // plaintext message ready

//public key inputs
input [logP-1:0] pub_key_a;
input [logP-1:0] pub_key_b;

//plainttext message
input [N-1:0] message;   

// Gaussian distribution sampling 
// It takes N cycles to get the whole r0, r1, r2
// ---- Once we have the Gaussian module, they will become internal signals 
input [logP-1:0] Gaussian_in;

//----------------------------------- Outputs ------------------------------------ //
output reg [logP-1:0] cipher_c0, cipher_c1; 
output reg cipher_ready;

output [4:0] Enc_STATE;
output [logN-1:0] Enc_CNT;

//------------------------------------- Regs ------------------------------------- //
//
//  ********** Some regs can be reused to save space ***********
//
reg [logP-1:0] reg_b [0:N-1];
reg [logP-1:0] reg_r0 [0:N-1];
reg [logP-1:0] reg_r1 [0:N-1];
reg [logP-1:0] temp;
reg [logP-1:0] reg_r2 [0:N-1];
reg [logP-1:0] reg_ar0 [0:N-1];
reg [logP-1:0] reg_br0 [0:N-1];
reg [logP-1:0] reg_c0 [0:N-1];
reg [logP-1:0] reg_c1 [0:N-1];

// for NTT & NWC
reg [logP-1:0] phi [0:N-1];
reg [logP-1:0] iphi [0:N-1];    // inverse of phi

// for FSM
reg [4:0] STATE;
reg [logN-1:0] CNT;

// some hacks for reg_r1 to be inferred as BRAM 
//Without using CNT_tmp the value read from reg_r1 in first clock cycle in every state is x.  
wire [logN:0] CNT_Add_One;
wire [logN-1:0] CNT_tmp;

// for NTT


// when the regs finish storage
reg r0_ready, r1_ready, r2_ready, WAIT_key;


// ----------------------------------- Wires ------------------------------------- //
wire [logN-1:0] TNC;

// For NTT

// ---------------------------------- Functions ---------------------------------- //
// for the convenience of NTT & iNTT
function [logN-1:0] BitReverse;
	input [logN-1:0] CNT;
	integer i;
	
	begin
		for (i=0; i<logN; i=i+1)		
			BitReverse[logN-1-i] = CNT[i];
	end
endfunction



// ----------------------------------- Logic Starts-------------------------------- //

// for simulation
assign Enc_STATE = STATE; 
assign Enc_CNT = CNT;

// Reverse bits of CNT
assign TNC = BitReverse(CNT);


//CNT_tmp is used as the address so as to read correct value at CNT == 0.
//Let the CNT increment in previous state to N and that is why CNT_Add_one is N bits
//and then use N-1 bits out of the N bits and CNT_tmp is N-1 bits because of this.
assign CNT_Add_One = CNT + 1;
assign CNT_tmp = CNT_Add_One[logN-1:0];

// *************************************** for NTT **************************************//
//
//
reg [logP-1:0] w [0:N-1];
reg [logP-1:0] iw [0:N-1];  // inverse of w
reg [logN:0] STAGE;         // it will be convenient to have STAGE one bit larger than LogN, so that we can do if STAGE == logN

wire [logN-1:0] k_sft; 
wire [logN-2:0] k; // k will go at most N/2
wire [logN-1:0] CNT_h;


wire [logP-1:0] VAR_r0, VAR_b, VAR_ar0, VAR_br0; 


assign CNT_h = CNT ^ (1 << STAGE); // CNT_h = CNT +- h 

assign k_sft = (STAGE == 0) ? 0 : (CNT << (logN-STAGE)); 
assign k = k_sft[logN-1:1];

// VAR can be used for both NTT and iNTT, depending on inv
assign VAR_r0 = (CNT[STAGE]==0) ? (reg_r0[CNT_h]*w[k])%p : 0; //do nothing when CNT[STAGE]=0
assign VAR_b = (CNT[STAGE]==0) ? (reg_b[CNT_h]*w[k])%p : 0; //do nothing when CNT[STAGE]=0
assign VAR_ar0 = (CNT[STAGE]==0) ? (reg_ar0[CNT_h]*iw[k])%p : 0; // using iw[k] for iNTT
assign VAR_br0 = (CNT[STAGE]==0) ? (reg_br0[CNT_h]*iw[k])%p : 0; // using iw[k] for iNTT
//
//
// *************************************** end for NTT **************************************//


always @ (posedge clk)
begin
    if(reset)
    begin
        cipher_c0 <= 0; 
        cipher_c1 <= 0;
        cipher_ready <= 0;
        CNT <= 0;
        STAGE <= 0;
        STATE <= 0;

        r0_ready <= 0;
        r1_ready <= 0;
        r2_ready <= 0;
        WAIT_key <= 0;
    end    
    
    else 
        case (STATE)
            IDLE: // STATE 0
            begin
                if (start)
                begin
                    // initialization of phi[] and iphi[]
                    //                   w[]  and iw[]
                    `include "phi.vh"
                    `include "w.vh"
                    
                    STAGE <= 0;
                    
                    CNT <= 0;
                    r0_ready <= 0;
                    r1_ready <= 0;
                    r2_ready <= 0;
                    cipher_ready <= 0;
                    
                    STATE <= RCV;                           
                end
                
                else // keep all the regs unchanged
                    STATE <= IDLE;
            end // IDLE

            // to wait for incoming random numbers 
            RCV: // STATE 1
            begin
                if (key_ready && r0_ready && r1_ready && r2_ready && WAIT_key)
                begin
                    CNT <= 0;
                    STAGE <= 0;
                    STATE <= STR_ab;
                end
                else if (r0_ready && r1_ready && r2_ready && (!WAIT_key)) // if waiting for key now, do not come here again
                begin
                    STAGE <= 0;
                    CNT <= 0;
                    STATE <= NTT_r0; // STATE 5
                end
                else if (Gaussian_ready && !r0_ready)
                    STATE <= STR_r0;
                else if (Gaussian_ready && !r1_ready)
                    STATE <= STR_r1;
                else if (Gaussian_ready && !r2_ready)
                    STATE <= STR_r2;
                else
                    STATE <= RCV;
            end // RCV
        
            // To store the noise r0 vector from Gaussian Noise Sampler
            STR_r0: // STATE 2
            begin
                if (CNT < N)
                begin
                    // **** storage swap for NTT and NWC **** //
                    reg_r0[TNC] <= (Gaussian_in * phi[CNT]) % p; 
                    CNT <= CNT + 1;
                       
                    if (CNT == N-1)
                    begin
                        r0_ready <= 1;
                        CNT <= 0;
                        STATE <= RCV;
                    end
                end // if CNT
            end // STR_r0
            
            // To store the noise r1 from Gaussian noise sampler
            STR_r1: // STATE 3
            begin
                if (CNT < N)
                begin 
                    reg_r1[CNT] <= Gaussian_in; 
                    CNT <= CNT + 1;
                    
                    if (CNT == N-1)
                    begin
                        r1_ready <= 1;
                        CNT <= 0;
                        STATE <= RCV;
                    end
                end // if CNT              
            end // STR_r1
                    
            // To store the noise r2 from Gaussian noise sampler
            STR_r2: // STATE 4
            begin
                if (CNT < N)
                begin 
                    reg_r2[CNT] <= Gaussian_in; 
                    CNT <= CNT + 1;
                                
                    if (CNT == N-1)
                    begin
                        r2_ready <= 1;
                        CNT <= 0;
                        STATE <= RCV;
                    end
                end // if CNT              
            end // STR_r2
            
            // To perform butterfly NTT for r0
            NTT_r0: // STATE 5
            begin
                if (STAGE < logN)
                begin
                    if (CNT < N)
                    begin
                        CNT <= CNT + 1;
                        if (CNT == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                            STAGE <= STAGE + 1;
                                
                        // ***** The general NTT equation ****** //
                        // We will compute one pair of butterfly (+ -) each time
                        if (CNT[STAGE] == 0)
                        //begin
                            // compute add & sub of a pair at once
                            reg_r0[CNT_h] <= (reg_r0[CNT] >= VAR_r0) ? (reg_r0[CNT] - VAR_r0) : (p - VAR_r0 + reg_r0[CNT]); // so that no need of %p
                        else  if (CNT[STAGE] == 1)  
                            reg_r0[CNT_h]   <= (reg_r0[CNT_h] + VAR_r0 < p)? (reg_r0[CNT_h] + VAR_r0) : (reg_r0[CNT_h] + VAR_r0 - p); // so that no need of %p    
                        //end
                    end // if (CNT < N)         
                end // if (STAGE < logN)
                else if (STAGE == logN) // NTT_a done. This is why we set STAGE 1 bit bigger than [logN-1:0]
                begin
                    CNT <= 0;
                    STAGE <= 0;
                    STATE <= ADD_r2tm;
                end // else if 
            end // NTT_r0
            
            
            //perform computations t.m + r2
            ADD_r2tm: // STATE 6
            begin               // "msg_ready" has to be SET at the same time with "message"
                if(msg_ready)   // check if msg_ready to ensure message is the correct plaintext message for encryption
                begin
                    if (CNT < N)
                    begin
                        reg_r2[CNT] <= ((message[CNT] == 1) ? (t) : (0)) + reg_r2[CNT]; // if msg bit is 1 choose t else 0 and perform addition with r2 
                        CNT <= CNT + 1;

                        if (CNT == N-1)
                        begin
                            CNT <= 0;
                            STATE <= RCV; // now we wait for the keys
                            WAIT_key <= 1; // so that we will only do RCV -> STR_ab
                        end
                    end // if(CNT < N)   
                end // if(msg_ready)
                else
                    STATE <= ADD_r2tm; 
            end // ADD_r2tm
            
            
            //store a, b and compute a.r0
            STR_ab: // STATE 7
            begin
                if (CNT < N)
                begin
                    //b storage swapped and NCWed for NTT
                    reg_b[TNC] <= (pub_key_b * phi[CNT]) % p;
                    //a dot product with r0
                    reg_ar0[TNC] <= (pub_key_a * reg_r0[CNT]) % p;  
                    CNT <= CNT + 1;
                                
                    if (CNT == N-1)
                    begin
                        CNT <= 0;
                        STATE <= iNTT_ar0;
                    end
                end // if(CNT < N)   
            end // STR_ab
            
            
            //perform iNTT on the product ar0
            iNTT_ar0: // STATE 8
            begin
                if (STAGE < logN)
                begin
                    if (CNT < N)
                    begin
                        CNT <= CNT + 1;
                        
                        if (CNT == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                        STAGE <= STAGE + 1;
                               
                        // ***** The general iNTT equation ****** //
                        // We do one pair of butterfly (+ -) each time
                        if (CNT[STAGE] == 0)
                        //begin
                        // the rest is the same as NTT, except using iw[k]
                        // need to mul N_inv at the last stage. We will do this in the next STATE with iNWC
                            reg_ar0[CNT_h] <= (reg_ar0[CNT] >= VAR_ar0) ? (reg_ar0[CNT] - VAR_ar0) : (p - VAR_ar0 + reg_ar0[CNT]); // so that no need of %p
                        else if (CNT[STAGE] == 1)   
                            reg_ar0[CNT_h]   <= (reg_ar0[CNT_h] + VAR_ar0 < p)? (reg_ar0[CNT_h] + VAR_ar0) : (reg_ar0[CNT_h] + VAR_ar0 - p); // so that no need of %p    
                        //end
                    end // if (CNT < N)         
                end // if (STAGE < logN)
                        
                else if (STAGE == logN) // iNTT_as done
                begin
                    CNT <= 0;
                    STAGE <= 0;
                    STATE <= iNWC_ar0;
                end // else if            
            end // iNTT_ar0
            
            
            // do * 1/N for iNTT, and then iNWC for product ar0
            iNWC_ar0: // STATE 9
            begin
                if (CNT < N)
                begin // can be done by shift reg
                    reg_ar0[CNT] <= (reg_ar0[CNT] * N_inv * iphi[CNT]) % p;  
                    CNT <= CNT + 1;
                
                    if (CNT == N-1)
                    begin
                        CNT <= 0;
                        STATE <= ADD_ar0r1;
                    end
                end // if CNT                          
            end // iNWC_ar0
            
            
            // final step to get c1
            ADD_ar0r1: // STATE 10
            begin
                if (CNT < N) // can be done by shift reg
                begin // so that we don't have to do % p
                    //reg_c1[CNT] <= (reg_ar0[CNT] + reg_r1[CNT] < p) ? (reg_ar0[CNT] + reg_r1[CNT]) : (reg_ar0[CNT] + reg_r1[CNT] - p);  
                    reg_c1[CNT] <= (reg_ar0[CNT] + temp < p) ? (reg_ar0[CNT] + temp) : (reg_ar0[CNT] + temp - p); //reg_r1 replaced by temp for BRAM 
                    // try a*ro - r1 
                    //reg_c1[CNT] <= (reg_ar0[CNT] >= reg_r1[CNT]) ? (reg_ar0[CNT] - reg_r1[CNT]) : (p + reg_ar0[CNT] - reg_r1[CNT]); 
                    
                    CNT <= CNT + 1;
            
                    if (CNT == N-1)
                    begin
                       CNT <= 0;                    
                       STATE <= NTT_b;
                    end
                end // if CNT          
            end // ADD_ar0r1
            
            
            // To perform butterfly NTT for b
            NTT_b: // STATE 11
            begin
                if (STAGE < logN)
                begin
                    if (CNT < N)
                    begin
                        CNT <= CNT + 1;
                        
                        if (CNT == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                            STAGE <= STAGE + 1;
                                           
                        // ***** The general NTT equation ****** //
                        // We will compute one pair of butterfly (+ -) each time
                        if (CNT[STAGE] == 0)
                        //begin
                            // compute add & sub of a pair at once
                            reg_b[CNT_h] <= (reg_b[CNT] >= VAR_b) ? (reg_b[CNT] - VAR_b) : (p - VAR_b + reg_b[CNT]); // so that no need of %p
                        else if (CNT[STAGE] == 1)    
                            reg_b[CNT_h]   <= (reg_b[CNT_h] + VAR_b < p)? (reg_b[CNT_h] + VAR_b) : (reg_b[CNT_h] + VAR_b - p); // so that no need of %p    
                        //end
                    end // if (CNT < N)         
                end // if (STAGE < logN)
                else if (STAGE == logN) // NTT_a done. This is why we set STAGE 1 bit bigger than [logN-1:0]
                begin
                    CNT <= 0;
                    STAGE <= 0;
                    STATE <= DOT_MUL_br0;
                end // else if 
            end // NTT_b
            
            
            // After NTT, the convolution of two polynomials becomes the dot product of them being transformed 
            DOT_MUL_br0: // STATE 12
            begin
                if (CNT < N)
                begin // swap the output for iNTT
                    reg_br0[TNC] <= (reg_b[CNT] * reg_r0[CNT]) % p; 
                    CNT <= CNT + 1;
                
                    if (CNT == N-1)
                    begin
                        CNT <= 0;
                        STATE <= iNTT_br0;
                    end
                end // if CNT  
            end // DOT_MUL_br0
            
            
            //perform iNTT on the product br0
            iNTT_br0: // STATE 13
            begin
                if (STAGE < logN)
                begin
                    if (CNT < N)
                    begin
                        CNT <= CNT + 1;
                                    
                        if (CNT == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                            STAGE <= STAGE + 1;
                                           
                        // ***** The general iNTT equation ****** //
                        // We do one pair of butterfly (+ -) each time
                        if (CNT[STAGE] == 0)
                        //begin
                            // the rest is the same as NTT, except using iw[k]
                            // need to mul N_inv at the last stage. We will do this in the next STATE with iNWC
                            reg_br0[CNT_h] <= (reg_br0[CNT] >= VAR_br0) ? (reg_br0[CNT] - VAR_br0) : (p - VAR_br0 + reg_br0[CNT]); // so that no need of %p
                        else if (CNT[STAGE] == 1)    
                            reg_br0[CNT_h]   <= (reg_br0[CNT_h] + VAR_br0 < p)? (reg_br0[CNT_h] + VAR_br0) : (reg_br0[CNT_h] + VAR_br0 - p); // so that no need of %p    
                        //end
                    end // if (CNT < N)         
                end // if (STAGE < logN)
                                 
                else if (STAGE == logN) // iNTT_as done
                begin
                    CNT <= 0;
                    STAGE <= 0;
                    STATE <= iNWC_br0;
                end // else if            
            end // iNTT_br0
                        
                        
            // do * 1/N for iNTT, and then iNWC for product ar0
            iNWC_br0: // STATE 14
            begin
                if (CNT < N)
                begin // can be done by shift reg
                    reg_br0[CNT] <= (reg_br0[CNT] * N_inv * iphi[CNT]) % p;  
                    CNT <= CNT + 1;
                            
                    if (CNT == N-1)
                    begin
                        CNT <= 0;
                        STATE <= ADD_br0r2tm;
                    end
                end // if CNT                          
            end // iNWC_br0
                        
                        
            // final step to get c0
            ADD_br0r2tm: // STATE 15
            begin
                if (CNT < N) // can be done by shift reg
                begin // so that we don't have to do % p
                    reg_c0[CNT] <= (reg_br0[CNT] + reg_r2[CNT] < p) ? (reg_br0[CNT] + reg_r2[CNT]) : (reg_br0[CNT] + reg_r2[CNT] - p);  
                    CNT <= CNT + 1;
                        
                    if (CNT == N-1)
                    begin
                        CNT <= 0;
                        cipher_ready <= 1;                 
                        STATE <= CIPHER_OUT;
                    end
                end // if CNT          
            end // ADD_br0r2
            
            
            // to output all the keys
            CIPHER_OUT: // STATE 16
            begin
                //cipher_ready <= 1;
                if (CNT < N)
                begin
                    CNT <= CNT + 1;
                            
                    // Alice gets c0, c1 in N cycles
                    cipher_c0 <= reg_c0[CNT]; // c0 is in regular format
                    cipher_c1 <= reg_c1[CNT]; // c1 is in regular format
                                                        
                    if (CNT == N-1)
                    begin
                        CNT <= 0;
                        STATE <= IDLE;
                    end 
                end // if CNT
            end // CIPHER_OUT 
            
        endcase
end  //always 

always @ (posedge clk)
begin
    //CNT_tmp is used as the address so as to read correct value at CNT == 0. 
    //Without using CNT_tmp the value read from reg_r1 in first clock cycle in every state is x. 
    temp <= reg_r1[CNT_tmp]; 
end

endmodule
