`timescale 1ns / 1ps

/** @module : sim_PKC_TOP
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

module sim_PKC_TOP;

// ------------------------------- PKC parameters ------------------------------- //

`include "pars.vh"
//parameter q = 3;
//parameter t = 1;
parameter n = q * q;
parameter N = 2 * t * q;
parameter K = n + N;

//inputs
reg clk, start, reset;
reg generator_ready, S_ready, P_ready; 
reg [K-1:0] generator;
reg [n-1:0] S;
reg [K-1:0] P;
reg [n-1:0] message;
reg [K-1:0] error;
reg parity_ready, S_inv_ready, P_inv_ready;
reg [K-1:0] parity_check_row; 
reg [N-1:0] parity_check_col;
reg [n-1:0] S_inv; 
reg [K-1:0] P_inv;


//outputs
wire [n-1:0] dec_message; 
wire dec_msg_ready;

// Instantiate the Module Under Test
PKC_TOP PKC_TOP_DUT(
    .clk(clk), 
    .reset(reset), 
    .start(start), 
    .generator_ready(generator_ready), 
    .S_ready(S_ready), 
    .P_ready(P_ready), 
    .generator(generator), 
    .S(S), 
    .P(P), 
    .message(message), 
    .error(error),
    .parity_ready(parity_ready), 
    .parity_check_row(parity_check_row), 
    .parity_check_col(parity_check_col), 
    .S_inv_ready(S_inv_ready), 
    .S_inv(S_inv), 
    .P_inv_ready(P_inv_ready), 
    .P_inv(P_inv), 
    .dec_message(dec_message), 
    .dec_msg_ready(dec_msg_ready)
);

wire Success;

assign Success = (message == dec_message) ? 1 : 0;

always #5 clk = ~clk;

initial begin
    // Initialize Inputs  
    clk = 0;
    reset = 1;
    start = 0;
    generator_ready = 0;
    //message = 0;

    #100;
    reset = 0;

    #100;
    // Add stimulus here
    start = 1;    

    //generator matrix row-wise
    generator_ready = 1;
    
    #10; generator = 15'b100000000100100;
    #10; generator = 15'b010000000100010;
    #10; generator = 15'b001000000100001;
    #10; generator = 15'b000100000010100;
    #10; generator = 15'b000010000010010;
    #10; generator = 15'b000001000010001;
    #10; generator = 15'b000000100001100;
    #10; generator = 15'b000000010001010;
    #10; generator = 15'b000000001001001;
    
    //non-singular matrix row-wise
    S_ready = 1;
    #20; S = 9'b101011000;
    #10; S = 9'b000111000;
    #10; S = 9'b101101010;
    #10; S = 9'b011100010;
    #10; S = 9'b110001010;
    #10; S = 9'b111011000;
    #10; S = 9'b000000110;
    #10; S = 9'b001110110;
    #10; S = 9'b000000001;
    
    //permutation matrix col-wise
    P_ready = 1;
    #20; P = 15'b100000000000000;
    #10; P = 15'b000000000000001;
    #10; P = 15'b010000000000000;
    #10; P = 15'b001000000000000;
    #10; P = 15'b000100000000000;
    #10; P = 15'b000010000000000;
    #10; P = 15'b000001000000000;
    #10; P = 15'b000000100000000;
    #10; P = 15'b000000010000000;
    #10; P = 15'b000000001000000;
    #10; P = 15'b000000000100000;
    #10; P = 15'b000000000010000;
    #10; P = 15'b000000000001000;
    #10; P = 15'b000000000000100;
    #10; P = 15'b000000000000010;
    
    #3000; //wait for key generation
    
    // msg to encrypt
    message = {1'b0,1'b0,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b1};  
    error = {1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
    
    #800; //wait for encryption
    
    #20; parity_ready = 1;
    S_inv_ready = 1;
    P_inv_ready = 1;
        
    #10; parity_check_row = 15'b111000000100000;
    #10; parity_check_row = 15'b000111000010000;
    #10; parity_check_row = 15'b000000111001000;
    #10; parity_check_row = 15'b100100100000100;
    #10; parity_check_row = 15'b010010010000010;
    #10; parity_check_row = 15'b001001001000001;
       
    #20; parity_check_col = 6'b100100;
    #10; parity_check_col = 6'b100010;
    #10; parity_check_col = 6'b100001;
    #10; parity_check_col = 6'b010100;
    #10; parity_check_col = 6'b010010;
    #10; parity_check_col = 6'b010001;
    #10; parity_check_col = 6'b001100;
    #10; parity_check_col = 6'b001010;
    #10; parity_check_col = 6'b001001;
    #10; parity_check_col = 6'b100000;
    #10; parity_check_col = 6'b010000;
    #10; parity_check_col = 6'b001000;
    #10; parity_check_col = 6'b000100;
    #10; parity_check_col = 6'b000010;
    #10; parity_check_col = 6'b000001;
      
    #20; S_inv = 9'b011011000;
    #10; S_inv = 9'b100001000;
    #10; S_inv = 9'b100110110;
    #10; S_inv = 9'b001101110;
    #10; S_inv = 9'b101011110;
    #10; S_inv = 9'b110110000;
    #10; S_inv = 9'b001110100;
    #10; S_inv = 9'b001110000;
    #10; S_inv = 9'b000000001;
      
    #20; P_inv = 15'b100000000000000;
    #10; P_inv = 15'b001000000000000;
    #10; P_inv = 15'b000100000000000;
    #10; P_inv = 15'b000010000000000;
    #10; P_inv = 15'b000001000000000;
    #10; P_inv = 15'b000000100000000;
    #10; P_inv = 15'b000000010000000;
    #10; P_inv = 15'b000000001000000;
    #10; P_inv = 15'b000000000100000;
    #10; P_inv = 15'b000000000010000;
    #10; P_inv = 15'b000000000001000;
    #10; P_inv = 15'b000000000000100;
    #10; P_inv = 15'b000000000000010;
    #10; P_inv = 15'b000000000000001;
    #10; P_inv = 15'b010000000000000;
        
    #10000;
    $finish;
    
end


endmodule
