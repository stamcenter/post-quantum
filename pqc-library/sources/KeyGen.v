`timescale 1ns / 1ps

/** @module : KeyGen
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
*                                         KeyGen                                 *
*********************************************************************************/



module KeyGen(KeyGen_STATE, KeyGen_CNT, clk, reset, start, TRNG_ready, TRNG_in, Gaussian_ready, Gaussian_in, pub_key_a, pub_key_b, sec_key_s, key_ready);
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



////////////////
//
// Notes:
// pub_key_a and sec_key_s as outputs, are already swapped, NWCed, and NTTed
// pub_key_b is in its regular format 
//
//
////////////////



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
*/


// Symbol (each element in a polynomial) bit width
parameter logP = $clog2(p); // ceiling of log_2 (p) = 21
// The counter size
parameter logN = $clog2(N); // log_2 (N) = 8






// ========= for FSM ============ //
parameter IDLE = 0;

// wait to see which is ready first: TRNG or Gaussian
parameter RCV = 1; 

// c = a $ b
parameter STR_a = 2;        // we will do swap for NTT and a'=a*phi here 
parameter STR_s = 3;        // we will do swap for NTT and s'=s*phi here 
parameter STR_e = 4;        // 
parameter NTT_a = 5;        // A' = NTT(a')
parameter NTT_s = 6;        // S' = NTT(s')
parameter DOT_MUL_as = 7;   // C' = A' . S', and also Swap
parameter iNTT_as = 8;      // c' = iNTT(C')
parameter iNWC_as = 9;      // c = c'*phi_inv

parameter ADD_ase = 10;     // b = c + e
parameter KEY_OUT = 11;     // to output all the keys

// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input TRNG_ready, Gaussian_ready; // random number and Gaussian noise ready


// The random numbers and Gaussian distribution sampling 
// It takes N cycles to get the whole a, s, e, r0, r1, r2
// ---- Once we have the TRNG & Gaussian modules, they will become internal signals 
input [logP-1:0] TRNG_in;
input [logP-1:0] Gaussian_in;



//----------------------------------- Outputs ------------------------------------ //
output reg [logP-1:0] pub_key_a, pub_key_b; 
output reg [logP-1:0] sec_key_s;
output reg key_ready;

output [3:0] KeyGen_STATE;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
output [logN-1:0] KeyGen_CNT;   

//------------------------------------- Regs ------------------------------------- //
//
//  ********** Some regs can be reused to save space ***********
//

// if we can use SystemVerilog, we can use double packed array so that we can do shift
/*
reg [0:N-1] [logP-1:0] reg_a;
reg [0:N-1] [logP-1:0] reg_s;
reg [0:N-1] [logP-1:0] reg_e;

reg [0:N-1] [logP-1:0] reg_as;

reg [0:N-1] [logP-1:0] reg_b;

// for NTT & NWC
reg [0:N-1] [logP-1:0] phi;
reg [0:N-1] [logP-1:0] iphi;    // inverse of phi
*/

// But in Verilog, we have to do:
reg [logP-1:0] reg_a [0:N-1];
//reg [logP-1:0] reg_a1 [0:N-1];
reg [logP-1:0] reg_s [0:N-1];
//(* ram_style = "block" *) 
reg [logP-1:0] reg_e [0:N-1];
reg [logP-1:0] temp;
reg [logP-1:0] reg_as [0:N-1];

reg [logP-1:0] reg_b [0:N-1];

// for NTT & NWC
reg [logP-1:0] phi [0:N-1];
reg [logP-1:0] iphi [0:N-1];    // inverse of phi


// for FSM
reg [3:0] STATE;
reg [logN-1:0] CNT;

// some hacks for reg_e to be inferred as BRAM 
//Without using CNT_tmp the value read from reg_e in first clock cycle in every state is x.  
wire [logN:0] CNT_Add_One;
wire [logN-1:0] CNT_tmp;


// when the regs finish storage
reg a_ready, s_ready, e_ready, as_ready;

reg [2*logP-1:0] x;



// ----------------------------------- Wires ------------------------------------- //
//wire a_out_ready, s_out_ready, as_out_ready, e_out_ready;
//wire MUL_ready; // when a*s is finished
//wire [logP-1:0] e_out, as_out;
//wire [logP-1:0] sum_mod; // the sum of (a*s + e)%p

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
assign KeyGen_STATE = STATE;
assign KeyGen_CNT = CNT;

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
wire [logP-1:0] VAR_a, VAR_s, VAR_as; 


assign CNT_h = CNT ^ (1 << STAGE); // CNT_h = CNT +- h 

assign k_sft = (STAGE == 0) ? 0 : (CNT << (logN-STAGE)); 
assign k = k_sft[logN-1:1];

// VAR can be used for both NTT and iNTT, depending on inv
//assign VAR = (CNT[STAGE]==0) ? (reg_a[CNT_h]*w[k])%p : 0; 
assign VAR_a = (CNT[STAGE]==0) ? (reg_a[CNT_h]*w[k])%p : 0; //do nothing when CNT[STAGE]=0
assign VAR_s = (CNT[STAGE]==0) ? (reg_s[CNT_h]*w[k])%p : 0; //do nothing when CNT[STAGE]=0
assign VAR_as = (CNT[STAGE]==0) ? (reg_as[CNT_h]*iw[k])%p : 0; // using iw[k] for iNTT
//
//
// *************************************** end for NTT **************************************//


always @ (posedge clk)
begin
    if(reset)
    begin
        pub_key_a <= 0; 
        pub_key_b <= 0;
        sec_key_s <= 0;
        key_ready <= 0;
        CNT <= 0;
        STAGE <= 0;
        STATE <= 0;
        
        a_ready <= 0;
        s_ready <= 0;
        e_ready <= 0;
        as_ready <= 0;
        
        x <= 0;
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
                a_ready <= 0;
                s_ready <= 0;
                e_ready <= 0;
                as_ready <= 0;
                key_ready <= 0;
                
                temp <= 0;
                
                STATE <= RCV;                           
            end
            
            else // keep all the regs unchanged
                STATE <= IDLE;
        end // IDLE
        
        
        // to wait for incoming random numbers 
        RCV: // STATE 1
        begin
            if (a_ready && s_ready && e_ready) // all have been stored
            begin
                STAGE <= 0;
                CNT <= 0;
                STATE <= NTT_a;
            end
            else if (TRNG_ready && !a_ready)
                STATE <= STR_a;
            else if (Gaussian_ready && !s_ready)
                  STATE <= STR_s;
            else if (Gaussian_ready && !e_ready)
                STATE <= STR_e;
            else
                STATE <= RCV;
        end // RCV
        
        
        
        // To store the public key a from TRNG
        STR_a: // STATE 2
        begin
            if (CNT < N)
            begin
                // **** storage swap for NTT and NWC **** //
                //x <= (TRNG_in * phi[CNT]);
                reg_a[TNC] <= (TRNG_in * phi[CNT]) % p; 
                CNT <= CNT + 1;
                
                if (CNT == N-1)
                begin
                    a_ready <= 1;
                    CNT <= 0;
                    STATE <= RCV;
                end
            end // if CNT
        end // STR_a
        
        
        // To store the private key s from Gaussian noise sampler
        STR_s: // STATE 3
        begin
            if (CNT < N)
            begin
                // **** storage swap for NTT and NWC **** //
                reg_s[TNC] <= (Gaussian_in * phi[CNT]) % p; 
                CNT <= CNT + 1;
            
                if (CNT == N-1)
                begin
                    s_ready <= 1;
                    CNT <= 0;
                    STATE <= RCV;
                end
            end // if CNT       
        end // STR_s
        
        
        // To store the noise e from Gaussian noise sampler
        STR_e: // STATE 4
        begin
            if (CNT < N)
            begin 
                reg_e[CNT] <= Gaussian_in; 
                CNT <= CNT + 1;
        
                if (CNT == N-1)
                begin
                    e_ready <= 1;
                    CNT <= 0;
                    STATE <= RCV;
                end
            end // if CNT              
        end // STR_e
        
        
        // To do butterfly NTT for a
        NTT_a: // STATE 5
        begin
            if (STAGE < logN)
            begin
                if (CNT < N)
                begin
                    CNT <= CNT + 1;
                    if (CNT == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                        STAGE <= STAGE + 1;
                    
                    // ***** The general NTT equation ****** //
                    // We do one pair of butterfly (+ -) each time
                    if (CNT[STAGE] == 0)
                    
                        // compute add & sub of a pair at once
                        reg_a[CNT_h] <= (reg_a[CNT] >= VAR_a) ? (reg_a[CNT] - VAR_a) : (p - VAR_a + reg_a[CNT]); // so that no need of %p    
                        
                    else if (CNT[STAGE] == 1)
                        reg_a[CNT_h]   <= (reg_a[CNT_h]+VAR_a < p)? (reg_a[CNT_h] + VAR_a) : (reg_a[CNT_h] + VAR_a - p); // so that no need of %p  
                        
                        // Can also be done by:
                        //reg_a[CNT_h] <= (reg_a[CNT] - VAR_a) + ((reg_a[CNT] >= VAR_a) ? 0 : p);        
                        //reg_a[CNT]   <= (reg_a[CNT] + VAR_a) - ((reg_a[CNT]+VAR_a < p)? 0 : p);      
                                    
                end // if (CNT < N)         
            end // if (STAGE < logN)
            
            else if (STAGE == logN) // NTT_a done. This is why we set STAGE 1 bit bigger than [logN-1:0]
            begin
                CNT <= 0;
                STAGE <= 0;
                STATE <= NTT_s;
            end // else if 
        end // NTT_a
        
        
        // To do butterfly NTT for s
        NTT_s: // STATE 6
        begin
            if (STAGE < logN)
            begin
                if (CNT < N)
                begin
                    CNT <= CNT + 1;
                    if (CNT == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                        STAGE <= STAGE + 1;
                    
                    // ***** The general NTT equation ****** //
                    // We do one pair of butterfly (+ -) each time
                    if (CNT[STAGE] == 0)
                        // compute add & sub of a pair at once
                        reg_s[CNT_h] <= (reg_s[CNT] >= VAR_s) ? (reg_s[CNT] - VAR_s) : (p - VAR_s + reg_s[CNT]); // so that no need of %p
                    else  if (CNT[STAGE] == 1)  
                        reg_s[CNT_h]   <= (reg_s[CNT_h]+VAR_s < p)? (reg_s[CNT_h] + VAR_s) : (reg_s[CNT_h] + VAR_s - p); // so that no need of %p    
                   
                end // if (CNT < N)         
            end // if (STAGE < logN)
            
            else if (STAGE == logN) // NTT_s done. This is why we set STAGE 1 bit bigger than [logN-1:0]
            begin
                CNT <= 0;
                STAGE <= 0;
                STATE <= DOT_MUL_as;
            end // else if    
        end // NTT_s
        
        
        // After NTT, the convolution of two polynomials becomes the dot product of them being transformed 
        DOT_MUL_as: // STATE 7
        begin
            if (CNT < N)
            begin // swap the output for iNTT
                reg_as[TNC] <= (reg_a[CNT] * reg_s[CNT]) % p; 
                CNT <= CNT + 1;
    
                if (CNT == N-1)
                begin
                    as_ready <= 1;
                    CNT <= 0;
                    STATE <= iNTT_as;
                end
            end // if CNT  
        end // DOT_MUL_as
        
        
        // Then we inverse NTT the product
        iNTT_as: // STATE 8
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
                        reg_as[CNT_h] <= (reg_as[CNT] >= VAR_as) ? (reg_as[CNT] - VAR_as) : (p - VAR_as + reg_as[CNT]); // so that no need of %p    
                    else if (CNT[STAGE] == 1)                            
                        reg_as[CNT_h]   <= (reg_as[CNT_h]+VAR_as < p)? (reg_as[CNT_h] + VAR_as) : (reg_as[CNT_h] + VAR_as - p); // so that no need of %p    
                    //end
                end // if (CNT < N)         
            end // if (STAGE < logN)
            
            else if (STAGE == logN) // iNTT_as done
            begin
                CNT <= 0;
                STAGE <= 0;
                STATE <= iNWC_as;
            end // else if            
        end // iNTT_as
        
        
        // do * 1/N for iNTT, and then iNWC for product as
        iNWC_as: // STATE 9
        begin
            if (CNT < N)
            begin // can be done by shift reg
                reg_as[CNT] <= (reg_as[CNT] * N_inv * iphi[CNT]) % p;  
                CNT <= CNT + 1;
    
                if (CNT == N-1)
                begin
                    //CNT <= 0;
                    STATE <= ADD_ase;
                    //temp <= reg_e[0];
                end
            end // if CNT                          
        end // iNWC_as
        
        
        
        
        // final step to get b
        ADD_ase: // STATE 10
        begin
            if (CNT < N) // can be done by shift reg
            begin // so that we don't have to do % p
                //reg_b[CNT] <= (reg_as[CNT] + reg_e[CNT] < p) ? (reg_as[CNT] + reg_e[CNT]) : (reg_as[CNT] + reg_e[CNT] - p); //best 
                //reg_b[CNT] <= reg_as[CNT] + reg_e[CNT] - (((reg_as[CNT] + reg_e[CNT]) < p) ? 0 : p); //not so good
                //reg_b[CNT] <= (reg_as[CNT] + reg_e[CNT]) % p; //similarly best   
                //temp <= reg_e[CNT+1];
                reg_b[CNT] <= (reg_as[CNT] + temp < p) ? (reg_as[CNT] + temp) : (reg_as[CNT] + temp - p);
                CNT <= CNT + 1;

                if (CNT == N-1)
                begin
                    CNT <= 0;
                    key_ready <= 1;                    
                    STATE <= KEY_OUT;
                end
            end // if CNT          
        end // ADD_ce
        
        
        // to output all the keys
        KEY_OUT: // STATE 11
        begin
            //key_ready <= 1; // to sync with Enc module
            if (CNT < N)
            begin
                CNT <= CNT + 1;
                
                // Bob get a,b in N cycles from pub_key_a,b
                pub_key_a <= reg_a[CNT]; // a is NWCed and swapped, and NTTed
                pub_key_b <= reg_b[CNT]; // b is still in regular format
                
                sec_key_s <= reg_s[CNT]; // s is NWCed and swapped, and NTTed
                
                if (CNT == N-1)
                begin
                    CNT <= 0;
                    
                    STATE <= IDLE;
                end 
            end // if CNT
        end // KEY_OUT
    
    endcase
end // end always

//To infer reg_e as BRAM we need to have synchronous reads from reg_e 
always @ (posedge clk)
begin
    //CNT_tmp is used as the address so as to read correct value at CNT == 0. 
    //Without using CNT_tmp the value read from reg_e in first clock cycle in every state is x. 
    temp <= reg_e[CNT_tmp]; 
end

endmodule


