`timescale 1ns / 1ps

/** @module : Dec
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
*                                         Dec                                    *
*********************************************************************************/



module Dec(clk, reset, start, cipher_ready, c0_in, c1_in, sec_key_ready, sec_key_s, message_ready, message);

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



////////////////
//
// Notes:
// 
//  
//
//
////////////////



// ------------------------------- PKC parameters ------------------------------- //

// ------------- Small test case ---------------- //



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
parameter [41:0]  p = 1049089; 

// Polynomial length: # of coefficients in the polynomial
parameter N = 256;
parameter N_inv = 1044991; // 1/N mod p
*/

parameter t = (p-1) / 2; 		// t = (p-1)/2
parameter t_half = t/2;	    // t/2

//parameter t = 524544; 		// t = (p-1)/2
//parameter t_half = 262272;	// t/2


// Symbol (each element in a polynomial) bit width
parameter logP = $clog2(p); // ceiling of log_2 (p) = 21
// The counter size
parameter logN = $clog2(N); // log_2 (N) = 8


// ========= for FSM ============ //
parameter IDLE = 0;

// wait to see which is ready first: TRNG or Gaussian
parameter RCV = 1; 

// c = a $ b
parameter STR_s = 2;        // s is already swapped, NWCed, and NTTed
parameter STR_c0c1 = 3;   // we will do swap for NTT and c1'=c1*phi here 
parameter NTT_c1 = 4;       // A' = NTT(a')
parameter DOT_MUL_c1s = 5;  // C' = A' . S', and also Swap
parameter iNTT_c1s = 6;     // c' = iNTT(C')
parameter iNWC_c1s = 7;     // c = c'*phi_inv

parameter SUB_c0c1s = 8;    // c0 - c1*s
parameter DIV_t = 9;     	// [(c0-c1*s)/t]
parameter MSG_OUT = 10;     // to output the decrypted message

// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input cipher_ready, sec_key_ready; // random number and Gaussian noise ready



// The random numbers and Gaussian distribution sampling 
// It takes N cycles to get the whole a, s, e, r0, r1, r2
// ---- Once we have the TRNG & Gaussian modules, they will become internal signals 
input [logP-1:0] c0_in;
input [logP-1:0] c1_in;
input [logP-1:0] sec_key_s;


//----------------------------------- Outputs ------------------------------------ //
output reg [N-1:0] message; // plaintext is a N-bit binary vector
output reg message_ready;

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         


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
reg [logP-1:0] reg_c0 [0:N-1];
reg [logP-1:0] reg_c1 [0:N-1];
reg [logP-1:0] reg_s [0:N-1];

reg [logP-1:0] reg_c1s [0:N-1];		// to store c1*s
reg [logP-1:0] reg_c0c1s [0:N-1]; 	// to store c0 - c1*s

//hacks to infer reg_c0, reg_s and reg_c0c1s as BRAM
reg [logP-1:0] temps;
reg [logP-1:0] tempc;
reg [logP-1:0] tempcs;


// for FSM
reg [3:0] STATE;
reg [logN-1:0] CNT;

// some hacks for reg_s, reg_c0, reg_c0c1s to be inferred as BRAM 
//Without using CNT_tmp the value read from these registers in first clock cycle in every state is x.  
wire [logN:0] CNT_Add_One;
wire [logN-1:0] CNT_tmp;

// when the regs finish storage
reg c0c1_ready, s_ready, c1s_ready;


// ----------------------------------- Wires ------------------------------------- //




// ----------------------------------- Logic Starts-------------------------------- //


// *************************************** for NTT **************************************//
//
//
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


wire [logN-1:0] TNC;
// Reverse bits of CNT
assign TNC = BitReverse(CNT);


//CNT_tmp is used as the address so as to read correct value at CNT == 0.
//Let the CNT increment in previous state to N and that is why CNT_Add_one is N bits
//and then use N-1 bits out of the N bits and CNT_tmp is N-1 bits because of this.
assign CNT_Add_One = CNT + 1;
assign CNT_tmp = CNT_Add_One[logN-1:0];


// for NTT & NWC
reg [logP-1:0] phi [0:N-1];
reg [logP-1:0] iphi [0:N-1];    // inverse of phi
reg [logP-1:0] w [0:N-1];
reg [logP-1:0] iw [0:N-1];  	// inverse of w
reg [logN:0] STAGE;         	// it will be convenient to have STAGE one bit larger than LogN, so that we can do if STAGE == logN

wire [logN-1:0] k_sft; 
wire [logN-2:0] k; 				// k will go at most N/2
wire [logN-1:0] CNT_h;
wire [logP-1:0] VAR_c1, VAR_c1s; 


assign CNT_h = CNT ^ (1 << STAGE); // CNT_h = CNT +- h 

assign k_sft = (STAGE == 0) ? 0 : (CNT << (logN-STAGE)); 
assign k = k_sft[logN-1:1];

// VAR can be used for both NTT and iNTT, depending on inv
//assign VAR = (CNT[STAGE]==0) ? (reg_a[CNT_h]*w[k])%p : 0; 
assign VAR_c1 = (CNT[STAGE]==0) ? (reg_c1[CNT_h]*w[k])%p : 0; //do nothing when CNT[STAGE]=0
assign VAR_c1s = (CNT[STAGE]==0) ? (reg_c1s[CNT_h]*iw[k])%p : 0; // using iw[k] for iNTT
//
//
// *************************************** end for NTT **************************************//



always @ (posedge clk)
begin
    if(reset)
    begin
    	message <= 0;
        message_ready <= 0;
        CNT <= 0;
        STAGE <= 0;
        STATE <= 0;
        
        c0c1_ready <= 0; 
        s_ready <= 0;
        c1s_ready <= 0;
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
        		c0c1_ready <= 0; 
        		s_ready <= 0;
        		c1s_ready <= 0;
        		message <= 0;
                message_ready <= 0;
                
                STATE <= RCV;                           
            end
            
            else // keep all the regs unchanged
                STATE <= IDLE;
        end // IDLE
        
        
        // to wait for incoming random numbers 
        RCV: // STATE 1
        begin
            if (c0c1_ready && s_ready) // all have been stored
            begin
                STAGE <= 0;
                CNT <= 0;
                STATE <= NTT_c1;
            end
            else if (sec_key_ready && !s_ready)
                STATE <= STR_s;
            else if (cipher_ready && !c0c1_ready)
                STATE <= STR_c0c1;
            else
                STATE <= RCV;
        end // RCV
        
        
        
        // To store the secret key 
        STR_s: // STATE 2
        begin
            if (CNT < N)
            begin
                // **** s is already swapped, NWCed, and NTTed **** //
                reg_s[CNT] <= sec_key_s; 
                CNT <= CNT + 1;
                
                if (CNT == N-1)
                begin
                    s_ready <= 1;
                    CNT <= 0;
                    STATE <= RCV;
                end
            end // if CNT
        end // STR_s
        
        
        // To store the private key s from Gaussian noise sampler
        STR_c0c1: // STATE 3
        begin
            if (CNT < N)
            begin
            	reg_c0[CNT] = c0_in;

                // **** storage swap for NTT and NWC **** //
                reg_c1[TNC] <= (c1_in * phi[CNT]) % p; 
                
                CNT <= CNT + 1;
            
                if (CNT == N-1)
                begin
                    c0c1_ready <= 1;
                    CNT <= 0;
                    STATE <= RCV;
                end
            end // if CNT       
        end // STR_c0c1
               
        
        // To do butterfly NTT for c1
        NTT_c1: // STATE 4
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
                        reg_c1[CNT_h] <= (reg_c1[CNT] >= VAR_c1) ? (reg_c1[CNT] - VAR_c1) : (p - VAR_c1 + reg_c1[CNT]); // so that no need of %p    
                    else if (CNT[STAGE] == 1)
                        reg_c1[CNT_h]   <= (reg_c1[CNT_h]+VAR_c1 < p)? (reg_c1[CNT_h] + VAR_c1) : (reg_c1[CNT_h] + VAR_c1 - p); // so that no need of %p    
                end // if (CNT < N)         
            end // if (STAGE < logN)
            
            else if (STAGE == logN) // NTT_c1 done. This is why we set STAGE 1 bit bigger than [logN-1:0]
            begin
                CNT <= 0;
                STAGE <= 0;
                STATE <= DOT_MUL_c1s;
            end // else if 
        end // NTT_c1
        
                
        // After NTT, the convolution of two polynomials becomes the dot product of them being transformed 
        DOT_MUL_c1s: // STATE 5
        begin
            if (CNT < N)
            begin // swap the output for iNTT
                //reg_c1s[TNC] <= (reg_c1[CNT] * reg_s[CNT]) % p; 
                reg_c1s[TNC] <= (reg_c1[CNT] * temps) % p; //to infer reg_s as BRAM 
                CNT <= CNT + 1;
    
                if (CNT == N-1)
                begin
                    CNT <= 0;
                    STATE <= iNTT_c1s;
                end
            end // if CNT  
        end // DOT_MUL_c1s
        
        
        // Then we inverse NTT the product
        iNTT_c1s: // STATE 6
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
                        // the rest is the same as NTT, except using iw[k]
                        // need to mul N_inv at the last stage. We will do this in the next STATE with iNWC
                        reg_c1s[CNT_h] <= (reg_c1s[CNT] >= VAR_c1s) ? (reg_c1s[CNT] - VAR_c1s) : (p - VAR_c1s + reg_c1s[CNT]); // so that no need of %p    
                    else if (CNT[STAGE] == 1)                             
                        reg_c1s[CNT_h]   <= (reg_c1s[CNT_h]+VAR_c1s < p)? (reg_c1s[CNT_h] + VAR_c1s) : (reg_c1s[CNT_h] + VAR_c1s - p); // so that no need of %p    
                end // if (CNT < N)         
            end // if (STAGE < logN)
            
            else if (STAGE == logN) // iNTT_as done
            begin
                CNT <= 0;
                STAGE <= 0;
                STATE <= iNWC_c1s;
            end // else if            
        end // iNTT_c1s
        
        
        // do * 1/N for iNTT, and then iNWC for product as
        iNWC_c1s: // STATE 7
        begin
            if (CNT < N)
            begin // can be done by shift reg
                reg_c1s[CNT] <= (reg_c1s[CNT] * N_inv * iphi[CNT]) % p;  
                CNT <= CNT + 1;
    
                if (CNT == N-1)
                begin
                	c1s_ready <= 1;
                    CNT <= 0;
                    STATE <= SUB_c0c1s;
                end
            end // if CNT                          
        end // iNWC_c1s
        
        
        // final step to get b
        SUB_c0c1s: // STATE 8
        begin
            if (CNT < N) // can be done by shift reg
            begin // so that we don't have to do % p
                //reg_c0c1s[CNT] <= (reg_c0[CNT] >= reg_c1s[CNT]) ? (reg_c0[CNT] - reg_c1s[CNT]) : (p - reg_c1s[CNT] + reg_c0[CNT]);
                //reg_c0c1s[CNT] <= reg_c0[CNT] - reg_c1s[CNT] + ((reg_c0[CNT] >= reg_c1s[CNT]) ? 0 : p); //working line of code
                reg_c0c1s[CNT] <= tempc - reg_c1s[CNT] + ((tempc >= reg_c1s[CNT]) ? 0 : p); //to infer reg_c0 as BRAM
                CNT <= CNT + 1;

                if (CNT == N-1)
                begin
                    CNT <= 0;                 
                    STATE <= DIV_t;
                end
            end // if CNT          
        end // SUB_c0c1s
        
        
        // diving reg_c0c1s by t and taking the nearest integer
        // [] operator:
		// t = (q-1)/2   
		// [u/t] = (|u-t| < t/2) ? 1 : 0;
        DIV_t:
        begin
            if (CNT < N)  
            begin  
                CNT <= CNT + 1;
                //message[CNT] <= (((reg_c0c1s[CNT] >= t) ? (reg_c0c1s[CNT] - t) : (t - reg_c0c1s[CNT])) < t_half) ? 1 : 0;
                message[CNT] <= (((tempcs >= t) ? (tempcs - t) : (t - tempcs)) < t_half) ? 1 : 0;
    
                if (CNT == N-1)
                begin
                    CNT <= 0; 
                    message_ready <= 1;                
                    STATE <= IDLE;
                end
            end // if CNT         	
       	end // DIV_t


       	/*
        // to output the decrypted message
        MSG_OUT: // STATE 11
        begin
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
        end // MSG_OUT
        */
    
    endcase
end // end always

//To infer reg_s, reg_c0, reg_c0c1s as BRAM we need to have synchronous reads from these registers 
always @ (posedge clk)
begin
    //CNT_tmp is used as the address so as to read correct value at CNT == 0. 
    //Without using CNT_tmp the value read from these in first clock cycle in every state is x. 
    temps <= reg_s[CNT_tmp];
    tempc <= reg_c0[CNT_tmp];
    tempcs <= reg_c0c1s[CNT_tmp]; 
end


endmodule
