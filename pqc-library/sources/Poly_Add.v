`timescale 1ns / 1ps

/** @module : Poly_Add
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
*                                    Poly_Add                                    *
*********************************************************************************/

module Poly_Add(clk, start, reset, A, B, A_ready, B_ready, sum_reg, sum_ready);


// ------------------------------- PKC parameters ------------------------------- //
// Ring element size
parameter p = 1049089; 

// t: floor of half of q
parameter t = 524544;
// t_half: floor of half of t
parameter t_half = 262272;

// Polynomial length: # of coefficients in the polynomial
parameter N = 256;

// Symbol (each element in a polynomial) bit width
parameter b = 21; // ceiling of log_2 (p)

// Total Polynomial length = N*b
parameter Nb = 5376;


// States
parameter IDLE = 0;
parameter ADD = 1;
parameter FIN = 2;


// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;

// If numbers to be added are ready
input A_ready, B_ready;

// The 2 numbers to be added and mod
input [b-1:0] A, B;




//----------------------------------- Outputs ------------------------------------ //
output reg [Nb-1:0] sum_reg;

// Flagged if the entire polynomial sum is done
output reg sum_ready;



//------------------------------------- Regs ------------------------------------- //
// for FSM
reg [2:0] state; 

// counter to iterate for N cycles
reg [8:0] counter;

// The reg for the entire sum
//reg [Nb-1:0] sum_reg;




// ----------------------------------- Wires ------------------------------------- //
wire [b:0] single_sum, mod_sum;






// ================================= Logic Starts ================================= //

// Adder is combinational, but the storage of the moded sum is sequential by DFF
assign single_sum = A[b-1:0] + B[b-1:0];

// Mod for addition, so input's size is parameterized to 22 - [21:0]
Mod #(21) mod_add (singe_sum, mod_sum);



// Add and mod one pair of symbols(total N) in each clock cycle
always @ (posedge clk)
begin
    if(reset)
begin
    sum_reg <= 0;
    sum_ready <= 0;
    
    state <= 0;
end

else
    case(state)
        // waiting for the "start" command to get ready for addition
        IDLE:
        begin
            if (start)
            begin
                sum_ready <= 0;
                sum_reg <= 0;
                
                state <= ADD;        
            end
            
            else
                state <= IDLE;
        end
        
        
        // To add the two N-digit ploynomials in N clock cycles
        ADD:
        begin
            

        end
        
        
        // To tell everyone the sum is ready
        FIN:
        begin
            sum_ready <= 1;
            
            state <= IDLE;
        end
    
    endcase


end




endmodule
