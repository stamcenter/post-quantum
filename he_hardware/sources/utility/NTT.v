`timescale 1ns / 1ps

/** @module : NTT
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

module NTT(clk, 
    reset, 
    data_in_ready,
    poly,
    a_0
    );
   
        parameter p = 1073741824;
        parameter N = 1024;
        parameter logN = $clog2(N);
        parameter logP = $clog2(p);
        parameter Nb = N * logP;
            
        input wire clk;
        input wire reset;
        input wire data_in_ready;
        input wire [Nb-1:0] poly;
         
        output [logP-1:0] a_0; //polynomial a
           
        reg [logN-1:0] STAGE; //stages in Butterfly
        wire [logP-1:0] VAR;
        reg [logN-1:0] CNT; //counter
        wire [logN-1:0] CNT_h;
        wire [logN-1:0] k; //index to various omega powers
        wire [logN-1:0] k_sft; //index to various omega powers
        reg NTT_done; //indicates NTT result is ready
        reg [1:0] STATE; //STATE = 00(IDLE), STATE = 01(Copy data), STATE = 10(Computations)
        
        parameter IDLE = 0;
        parameter DATAREADY = 1;
        parameter COMPUTATIONS = 2;
        parameter UNUSED = 3;
        
        reg [logP-1:0] w [0:N-1];
        reg [logP-1:0] iw [0:N-1];
        reg [logP-1:0] a [0:N-1];
        
        //assign TNC_h = TNC ^ (1 << logN-1-STAGE);
        assign CNT_h = CNT ^ (1 << STAGE);
        
        assign VAR = (CNT[STAGE] == 0) ? (a[CNT_h] * w[k]) % p : 0;
        
        assign a_0 = a[0];
        
        // Alan told us this 
        assign k_sft = (STAGE == 0) ? 0 : (CNT << (logN - STAGE)); 
        assign k = {1'b0, k_sft[logN-1:1]};
        
          
        always @(posedge clk)
        begin
            if(reset)
                begin
                    STAGE <= 0;
                    CNT <= 0;
                    STATE <= 0;
                    NTT_done <= 0;               
                    `include "w.vh" 
                     
                end 
            else 
                case(STATE)
                IDLE:
                begin
                    if(data_in_ready)
                        begin                                    
                        STATE <= DATAREADY;
                        end
                    else
                        STATE <= IDLE;
                end // end IDLE
                
                DATAREADY:
                begin
                    a[0] = poly[logP-1:0];
                    a[1] = poly[logP*2-1:logP];
                    a[2] = poly[logP*3-1:logP*2];
                    a[3] = poly[logP*4-1:logP*3];
                    a[4] = poly[logP*5-1:logP*4];
                    a[5] = poly[logP*6-1:logP*5];
                    a[6] = poly[logP*7-1:logP*6];
                    a[7] = poly[logP*8-1:logP*7];
                    //data_in_ready = 0;
                    STATE <= COMPUTATIONS;
                end // end DATAREADY
                
                COMPUTATIONS:
                if(STAGE < logN)
                begin
                    if(CNT < N)
                    begin
                        CNT <= CNT + 1;
                        if (CNT == N-1)
                            STAGE <= STAGE + 1;         
                        
                        if(CNT[STAGE] == 0)
                        begin
                            a[CNT_h] <= (a[CNT] >= VAR) ? (a[CNT] - VAR) : (p - VAR + a[CNT]);
                            a[CNT] <= (a[CNT] + VAR < p) ? (a[CNT] + VAR) : (a[CNT] + VAR - p);
                        end                    
                    end
                end
                else
                begin
                    NTT_done = 1;
                    STATE <= IDLE;
                end
                
                UNUSED:
                begin
                    STATE <= IDLE;
                end
                endcase
        end 
    
    
endmodule