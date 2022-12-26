`timescale 1ns / 1ps

/** @module : Poly_Store
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
*                                  Poly_Store                                    *
*********************************************************************************/


module Poly_Store(clk, reset, WRITE, data_in_ready, data_in, READ, data_out_ready, data_out, poly_reg);



// ------------------------------- PKC parameters ------------------------------- //
// Ring element size
//parameter p = 1049089; 


// Polynomial length: # of coefficients in the polynomial
//parameter N = 256;
//parameter logN = 8; // log_2 N


// Symbol (each element in a polynomial) bit width
//parameter b = 21; // ceiling of log_2 (p)

// Total Polynomial length = N*b
//parameter Nb = 5376;


// States
parameter IDLE = 0;
parameter SND = 1;
parameter STR = 2;



// ------------- Small test case ---------------- //
parameter p = 17; 
parameter N = 8;
parameter logN = 3;
parameter b = 5;
parameter Nb = N*b;


// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, reset;

// Flagged when all data are stored into the regs
input WRITE, data_in_ready, READ;

// The input data, each clock cycle comes in one b-bit symbol
input [b-1:0] data_in;




//----------------------------------- Outputs ------------------------------------ //
// The entire poly_reg has finished storage
output reg data_out_ready;

// Outputting one component at each clock cycle    
output [b-1:0] data_out;

// The reg to store the entire polynomial   
output reg [Nb-1:0] poly_reg;





//------------------------------------- Regs ------------------------------------- //

// for FSM
reg [1:0] state; 

// counter to iterate for N cycles
reg [logN:0] CNT;


// ----------------------------------- Wires ------------------------------------- //
assign data_out = poly_reg[b-1:0];





// ================================= Logic Starts ================================= //
always @ (posedge clk)
begin
    if(reset)
    begin
        poly_reg <= 0;
        data_out_ready <= 0;
        CNT <= 0;
        state <= 0;
    end
    
    else
        case(state)
            // waiting for the "start" command to receive the data
            IDLE:
            begin
                if (READ && data_out_ready) // if a READ request, then we send out 1 component per cycle
                begin
                    CNT <= 0;
                    
                    state <= SND; // go to Send state 
                end
                
                else if (WRITE && data_in_ready) // if a WRITE request, then we write in 1 component per cycle
                begin
                    poly_reg <= 0;
                    data_out_ready <= 0;
                    CNT <= 0;
                
                    state <= STR;   
                end
                
                else
                begin
                    // All the registers' values are kept unchanged when there is no request
                    state <= IDLE;
                end
            end // end IDLE
            
            
            SND:
            begin
                if (CNT < N)
                begin
                    poly_reg <= (CNT == 0) ? poly_reg : {poly_reg[b-1:0], poly_reg[Nb-1:b]};
                    CNT <= CNT + 1;
                end
                
                else if (CNT == N) // the outsider has finished reading all the N components
                begin
                    CNT <= 0;
                    state <= IDLE;
                end
            end
            
            
            // To store the N-digit data in N clock cycles
            STR:
            begin
                if (CNT < N)
                begin
                    poly_reg <= {data_in, poly_reg[Nb-1:b]};
                    CNT <= CNT + 1;
                end
            
                else if (CNT == N) // the outsider has finished reading all the N components
                begin
                    CNT <= 0;
                    data_out_ready <= 1; // now people can read from the reg
                    state <= IDLE;
                end
            end
            
            2'b11:
                state <= IDLE;
         
        endcase
end // end always




endmodule
