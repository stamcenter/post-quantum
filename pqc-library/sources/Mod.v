`timescale 1ns / 1ps

/** @module : Mod
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
*                                         Mod                                    *
*********************************************************************************/


module Mod(A, mod_A);


// ----------------------------- Module parameters ------------------------------- //
// The input size
parameter in_size = 21;


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





// ------------------------------------ Inputs ---------------------------------- //
// The number to be moded
// for mod after addtion, the input size is: [b:0]
// for mod after multiplication, the input size is: [2b-1:0]  (the actual size is [2b-2:0] calculated by p = 1049089)
input [in_size:0] A;



//----------------------------------- Outputs ------------------------------------ //
// mod_A = A % p
output [b-1:0] mod_A;



//------------------------------------- Regs ------------------------------------- //

// ----------------------------------- Wires ------------------------------------- //


// ================================= Logic Starts ================================= //
assign mod_A = A % p;

 


endmodule
