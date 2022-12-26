`timescale 1ns / 1ps

/** @module : keyGen
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

module keyGen(clk, reset, start, generator_ready, generator, S_ready, S, P_ready, P, pub_key, key_ready);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Key Generation Algorithm:
//q is the chosen prime number, defined in pars.vh
//t is number of bits that can be error corrected, defined in pars.vh
//N = 2 * t * q
//generated public key, G' is of order n x K where K is n + N
//Step-1: GP = G * P where G is of order n x K and P is of order K x K
//Step-2: G' = S * GP where S is of order n x n and GP is of order n x K
/////////////////////////////////////////////////////////////////////////////////////////////////////////


// ============================== PKC parameters ================================ //
`include "pars.vh"

parameter n = q * q;
parameter N = 2 * t * q;
parameter K = n + N;
parameter cnt_max_gen = n * K; //for generator matrix
parameter cnt_bw_gen = $clog2(cnt_max_gen); //for generator matrix
parameter cnt_max_perm = K * K; //for P matrix
parameter cnt_bw_perm = $clog2(cnt_max_perm); //for P matrix
parameter cnt_max_nons = n * n; //for S matrix
parameter cnt_bw_nons = $clog2(cnt_max_nons); //for S matrix
parameter logK = $clog2(K);
parameter logn = $clog2(n);

// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input generator_ready; // generator matrix is ready
input S_ready, P_ready; // 

//generator matrix n x K, need row-wise
input [K-1:0] generator;
//permutation matrix K x K, need col-wise
input [K-1:0] P;
//non-singular matrix n x n, need row-wise   
input [n-1:0] S;

//----------------------------------- Outputs ------------------------------------ //
output reg [n-1:0] pub_key; //public key column wise i.e. n bits from n x K
output reg key_ready;

//----------------------------------- Registers ----------------------------------- //
//public key G' of order n x K
reg [cnt_max_gen-1:0] reg_gdash;
//generator matrix of order n x K
reg [cnt_max_gen-1:0] reg_gen;
//P matrix of order K x K 
reg [cnt_max_perm-1:0] reg_p;
//S matrix of order n x n 
reg [cnt_max_nons-1:0] reg_s;

//intermediate results in matrix multiplication & addition
reg [K-1:0] reg_sum_gp;
reg [n-1:0] reg_sum_sgp;
reg [cnt_max_gen-1:0] reg_gp;
//reg [cnt_max_gen-1:0] reg_sgp;

// for FSM
reg [2:0] STATE;
reg [cnt_bw_gen-1:0] CNT_GEN;
reg [cnt_bw_perm-1:0] CNT_PERM;
reg [cnt_bw_nons-1:0] CNT_NONS;
reg [logK-1:0] CNT; //track the number of cols to store the matrix col wise
reg [cnt_bw_gen-1:0] j;

// =================================== for FSM ===================================== //
//starting state for the FSM
parameter IDLE = 0;
//get the generator matrix
parameter RCV_GEN = 1;
//get the permutation matrix
parameter RCV_S = 2;
//get the non-singular matrix
parameter RCV_P = 3;
//multiply G and P 
parameter MUL_GP = 4; 
//multiply S with GP
parameter MUL_SGP = 5;
//output the public key G'
parameter KEY_OUT = 6;

//assign reg_sum_gp = reg_gen[CNT_GEN+:K] & reg_p[CNT_PERM+:K];

always @ (posedge clk)
begin
    if(reset)
    begin
        pub_key <= 0; 
        key_ready <= 0;
        STATE <= 0;
        CNT_GEN <= 0;
        CNT_PERM <= 0;
        CNT_NONS <= 0;
        reg_sum_gp <= 0;
        reg_sum_sgp <= 0;
        reg_gp <= 0;
        reg_gdash <= 0;
        j <= 0;
    end
    else
        case (STATE)
            IDLE: //STATE 0
            begin
                if (start && generator_ready)
                begin
                    CNT_GEN <= 0;
                    CNT_PERM <= 0;
                    CNT_NONS <= 0;
                    j <= 0;
                    STATE <= RCV_GEN;
                end
                else
                    STATE <= IDLE;
            end //STATE 0
            
            RCV_GEN: //STATE 1, takes n cycles
            begin
                if (CNT_GEN <= cnt_max_gen)
                begin
                    //store the values row wise i.e. 0 to n-1
                    //helpful to perform multiplication operation in the MUL_GP state 
                    reg_gen[CNT_GEN+:K] <= generator;
                    CNT_GEN <= CNT_GEN + K; //increment by n which is equal to number of rows
                                
                    if (CNT_GEN == cnt_max_gen)
                    begin
                        CNT_GEN <= 0;
                        STATE <= RCV_S;
                    end
                end              
            end //STATE 1
            
            RCV_S: //STATE 2, takes n cycles
            begin
                if (CNT_NONS <= cnt_max_nons)
                begin
                    //store the values col wise i.e. 0 to n-1
                    //helpful to perform multiplication operation in state MUL_SGP
                    reg_s[CNT_NONS+:n] <= S;
                    CNT_NONS <= CNT_NONS + n; //increment by n which is equal to number of rows
                                                        
                    if (CNT_NONS == cnt_max_nons)
                    begin
                        CNT_NONS <= 0;
                        STATE <= RCV_P;
                    end
                end              
            
            end //STATE 2
            
            RCV_P: //STATE 3, takes K cycles
            begin
                if (CNT_PERM <= cnt_max_perm)
                begin
                    //store the values col wise i.e. 0 to K-1
                    //helpful to perform multiplication operation in next state 
                    reg_p[CNT_PERM+:K] <= P;
                    CNT_PERM <= CNT_PERM + K; //increment by K which is equal to number of rows
                                                                    
                    if (CNT_PERM == cnt_max_perm)
                    begin
                        CNT_PERM <= 0;
                        STATE <= MUL_GP;
                        CNT <= 2;
                        j <= cnt_max_gen + n - 1; //gp will need to store nK values in next state
                    end
                end 
            end //STATE 3
            
            MUL_GP: //STATE 4, takes n*K cycles
            begin
                if (CNT_GEN < cnt_max_gen)
                begin
                    //perform G and P multiplication
                    //G dimension is n x K
                    //P dimension is K x K
                    //since both matrices are binary
                    //and required result is in binary
                    //hence we perform AND operation instead of mul
                    //and XOR operation instead of add
                    reg_sum_gp <= reg_gen[CNT_GEN+:K] & reg_p[CNT_PERM+:K]; //moved to assign statement
                    reg_gp[j] <= ^reg_sum_gp; //gp is getting stored col wise
                    CNT_PERM <= CNT_PERM + K;
                    j <= j - n;
                    
                    if (CNT_PERM == cnt_max_perm)
                    begin
                        CNT_PERM <= 0;
                        j <= cnt_max_gen + n - CNT;
                        CNT_GEN <= CNT_GEN + K;
                        CNT <= CNT + 1; 
                    end
                end                
                else if (CNT_GEN == cnt_max_gen)
                begin
                    CNT_GEN <= cnt_max_gen - 1;
                    CNT <= 2;
                    CNT_PERM <= 0;
                    j <= cnt_max_gen + n - 1;
                    STATE <= MUL_SGP;
                end            
            end //STATE 4
            
            MUL_SGP: //STATE 5, takes n*K cycles
            begin
                if (CNT_NONS < cnt_max_nons)
                begin
                    //perform S and GP multiplication
                    //GP dimension is n x K, col-wise
                    //S dimension is n x n, row-wise
                    //since both matrices are binary
                    //and required result is in binary
                    //hence we perform AND operation instead of mul
                    //and XOR operation instead of add
                    reg_sum_sgp <= reg_gp[CNT_GEN-:n] & reg_s[CNT_NONS+:n];
                    reg_gdash[j] <= ^reg_sum_sgp; //sgp is getting stored col wise
                    CNT_GEN <= CNT_GEN - n;
                    j <= j - n; //ensure this is correct
                                
                    if (CNT_GEN == 255) //cnt_max_gen)
                    begin
                        CNT_GEN <= cnt_max_gen - 1; //0;
                        j <= cnt_max_gen + n - CNT;
                        CNT_NONS <= CNT_NONS + n;
                        CNT <= CNT + 1;
                    end
                end                            
                else if (CNT_NONS == cnt_max_nons)
                begin
                    CNT_NONS <= 0;
                    CNT_GEN <= cnt_max_gen - 1;
                    j <= 0;
                    key_ready <= 1;
                    STATE <= KEY_OUT;
                end
            end //STATE 5
            
            KEY_OUT: //STATE 6
            begin
                if (CNT_GEN <= 255)
                begin
                    pub_key <= reg_gdash[CNT_GEN-:n];
                    CNT_GEN <= CNT_GEN - n;
                    
                    if (CNT_GEN == 255)
                    begin
                        CNT_GEN <= 0;
                        STATE <= IDLE;
                    end    
                end
            end //STATE 6
        endcase
end

endmodule
