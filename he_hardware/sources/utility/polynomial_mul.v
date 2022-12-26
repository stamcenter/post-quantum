`timescale 1ns / 1ps

/** @module : polynomial_mul
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

module polynomial_mul(clk, reset, start, a, b, q, result);
    
    input clk;
    input reset;
    input start;
    input [29:0] a, b;
    input [29:0] q;
    output reg [59:0] result;
    
    reg [29:0] temp_a [0:1023];
    reg [29:0] temp_b [0:1023];
    reg [59:0] temp_result [0:1023];
    
    reg [2:0] STATE;
    
    parameter IDLE = 0;
    parameter STORE = 1;
    parameter NTT = 2;
    parameter MULT = 3;
    parameter iNTT = 4;
    parameter OUTPUT = 5;
    
    reg done;
    
    reg [9:0] count;
    
    // for NTT & NWC
    reg [29:0] phi [0:1023];
    reg [29:0] iphi [0:1023];    // inverse of phi
    reg [29:0] w [0:1023];
    reg [29:0] iw [0:1023];      // inverse of w
    reg [10:0] STAGE;             // it will be convenient to have STAGE one bit larger than LogN, so that we can do if STAGE == logN
    
    wire [9:0] k_sft; 
    wire [8:0] k;                 // k will go at most N/2
    wire [9:0] CNT_h;
    wire [29:0] VAR_a, VAR_b, VAR_result; 
    
    parameter N = 1024;
    parameter N_inv = 18415;
    
    assign CNT_h = count ^ (1 << STAGE); // CNT_h = CNT +- h 
    
    assign k_sft = (STAGE == 0) ? 0 : (count << (10-STAGE)); 
    assign k = k_sft[9:1];
    
    assign VAR_a = (count[STAGE]==0) ? (temp_a[CNT_h] * w[k]) % q : 0;
    assign VAR_b = (count[STAGE]==0) ? (temp_b[CNT_h] * w[k]) % q : 0;
    assign VAR_result = (count[STAGE]==0) ? (temp_result[CNT_h] * iw[k]) % q : 0; 
    
    always @(posedge clk) begin
        if (reset) begin
            STATE <= 0;
            count <= 0;
        end
        else begin
        case(STATE)
            IDLE:
            begin
                if (start && !done)
                begin
                    `include "phi.vh"
                    `include "w.vh"
                    STATE <= STORE;
                end
                else
                    STATE <= IDLE;
            end
        
            STORE:
            begin

                if (count < 1024) begin
                    temp_a[count] <= (a * phi[count]) % q;
                    temp_b[count] <= (b * phi[count]) % q;
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        STATE <= NTT;
                    end
                end
            end
            
            NTT:
            begin
                if (STAGE < 10)
                begin
                    if (count < N)
                    begin
                        count <= count + 1;
                        if (count == N-1) // CNT will return to 0, and so we don't need to do else if CNT == N
                            STAGE <= STAGE + 1;
                            
                            if (count[STAGE] == 0) begin
                                temp_a[CNT_h] <= (temp_a[count] >= VAR_a) ? (temp_a[count] - VAR_a) : (q - VAR_a + temp_a[count]); 
                                temp_b[CNT_h] <= (temp_b[count] >= VAR_b) ? (temp_b[count] - VAR_b) : (q - VAR_b + temp_b[count]);
                            end    
                            else if (count[STAGE] == 1) begin
                                temp_a[CNT_h]   <= (temp_a[CNT_h]+VAR_a < q)? (temp_a[CNT_h] + VAR_a) : (temp_a[CNT_h] + VAR_a - q); 
                                temp_b[CNT_h]   <= (temp_b[CNT_h]+VAR_b < q)? (temp_b[CNT_h] + VAR_b) : (temp_b[CNT_h] + VAR_b - q); 
                            end   
                    end // if (CNT < N)         
                end // if (STAGE < logN)
                       
                else if (STAGE == 10) // NTT_c1 done. This is why we set STAGE 1 bit bigger than [logN-1:0]
                begin
                    count <= 0;
                    STAGE <= 0;
                    STATE <= MULT;
                end // else if 
            end // NTT
            
            MULT:
            begin 
                if (count < 1024) begin
                    temp_result[count] <= temp_a[count] * temp_b[count] % q;
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        STATE <= iNTT;
                    end
                end
            end
            
            iNTT:
            begin
                if (STAGE < 10)
                begin
                    if (count < N)
                    begin
                        count <= count + 1;
                        if (count == N-1) 
                            STAGE <= STAGE + 1;

                        if (count[STAGE] == 0)
                            temp_result[CNT_h] <= (temp_result[count] >= VAR_result) ? (temp_result[count] - VAR_result) : (q - VAR_result + temp_result[count]); // so that no need of %p    
                        else if (count[STAGE] == 1)                             
                            temp_result[CNT_h]   <= (temp_result[CNT_h] + VAR_result < q)? (temp_result[CNT_h] + VAR_result) : (temp_result[CNT_h] + VAR_result - q); // so that no need of %p    
                            end // if (CNT < N)         
                        end // if (STAGE < logN)
                        
                        else if (STAGE == 10) // iNTT_as done
                        begin
                            count <= 0;
                            STAGE <= 0;
                            STATE <= OUTPUT;
                        end // else if   
            end
            
            OUTPUT: 
            begin
                if (count < 1024) begin
                    result <= (temp_result[count] * N_inv * iphi[count]) % q;
                    count <= count + 1;
                    if (count == 1023) begin
                        count <= 0;
                        done <= 1;
                        STATE <= IDLE;
                    end
                end
            end
        endcase
        end
    end

endmodule
