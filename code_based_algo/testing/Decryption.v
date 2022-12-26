`timescale 1ns / 1ps

/** @module : Decryption
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

module Decryption(clk, reset, start, cipher_ready, cipher, parity_ready, parity_check_row, parity_check_col, S_inv_ready, S_inv, P_inv_ready, P_inv, message, msg_ready);

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Decryption Algorithm:
//q is the chosen prime number, defined in pars.vh
//t is number of bits that can be error corrected, defined in pars.vh
//N = 2 * t * q
//decoded m is of order 1 x n where n is q * q
//Step-1: c' = cipher * P_inv where cipher is of order 1 x K and P_inv is of order K x K  
//Step-2: utemp = H * c' where H is of order N x K and c' is of order 1 x K
//Step-3: u = utemp * H where utemp is or order 1 x N
//Step-4: Error-correction, m'[i] = ~c'[i] if u[i] > q/2 else c'[i] where i ranges from 0 to n-1 
//Step-5: m = m' * S_inv where m' is of order 1 x n and S_inv is of order n x n 
/////////////////////////////////////////////////////////////////////////////////////////////////////////


// ============================== PKC parameters ================================ //
//`include "pars.vh"
parameter q = 41;
parameter t = 20;
parameter n = q * q;
parameter N = 2 * t * q;
parameter K = n + N;
parameter ec = (q-1)/2; //q-1 as q is odd
parameter cnt_max_parity = N * K; //for parity check matrix
parameter cnt_bw_parity = $clog2(cnt_max_parity); //for parity check matrix
parameter cnt_max_perm = K * K; //for P_inv matrix
parameter cnt_bw_perm = $clog2(cnt_max_perm); //for P_inv matrix
parameter cnt_max_nons = n * n; //for S_inv matrix
parameter cnt_bw_nons = $clog2(cnt_max_nons); //for S_inv matrix
parameter logK = $clog2(K);
parameter logn = $clog2(n);
parameter logN = $clog2(N);

// ------------------------------------ Inputs ---------------------------------- //
//Common system inputs
input clk, start, reset;
input cipher_ready; // cipher is ready
input parity_ready; // parity check matrix is ready to be received
input S_inv_ready; // S_inv matrix is ready to be received
input P_inv_ready; // P_inv matrix is ready to be received

//cipher 1 x K
input [K-1:0] cipher;
//P_inv column wise i.e. K bits from K x K   
input [K-1:0] P_inv;
//S_inv column wise i.e. n bits from n x n  
input [n-1:0] S_inv;
//parity_check matrix row wise i.e. K bits from N x K
input [K-1:0] parity_check_row;
//parity_check matrix col wise i.e. N bits from N x K
input [N-1:0] parity_check_col;  

//----------------------------------- Outputs ------------------------------------ //
//decoded message 1 x n
output reg [n-1:0] message; 
output reg msg_ready; // decoded message ready


//----------------------------------- Registers ----------------------------------- //
//cipher
//reg [K-1:0] reg_cipher;
//parity check matrix of order N x K
//reg [cnt_max_parity-1:0] reg_parity_check_row;
//reg [cnt_max_parity-1:0] reg_parity_check_col;
//P_inv matrix of order K x K 
//reg [cnt_max_perm-1:0] reg_p_inv;
//S_inv matrix of order n x n 
//reg [cnt_max_nons-1:0] reg_s_inv;

//intermediate results in matrix multiplication & addition
wire [N-1:0] reg_mul;
reg [logN-1:0] reg_sum; //check the number of bits required for this register
reg [K-1:0] reg_sum_cpinv;
reg [K-1:0] reg_sum_hcdash;
reg [K-1:0] reg_cdash;
reg [N-1:0] reg_utemp;
reg [(logN * K)-1:0] reg_u;
reg [n-1:0] reg_mdash;
reg [n-1:0] reg_msg;
reg [n-1:0] reg_sum_Sinvmdash;

// for FSM
reg [3:0] STATE;
reg [cnt_bw_parity-1:0] CNT_PARITY_ROW;
reg [cnt_bw_parity-1:0] CNT_PARITY_COL;
reg [cnt_bw_perm-1:0] CNT_PERM;
reg [cnt_bw_nons-1:0] CNT_NONS;
reg [logK-1:0] j;
reg [logn-1:0] CNT;
reg [(logN*logK):0] j_sum;

// =================================== for FSM ===================================== //
//starting state for the FSM //need 8 states
parameter IDLE = 0;
//get the cipher
parameter CIPHER_IN = 1;
//get the parity check matrix row-wise H
parameter RCV_PC_ROW = 2;
//get the parity check matrix col-wise H
parameter RCV_PC_COL = 3;
//get the permutation matrix inverse P_inv
parameter RCV_Sinv = 4;
//get the non-singular matrix inverse S_inv
parameter RCV_Pinv = 5;
//multiply P_inv(matrix) and cipher(vector) 
parameter MUL_cPinv = 6;
//multiply H(matrix) and cdash(vector)
//cdash is result from previous state 
parameter MUL_Hcdash = 7;
//multiply H(matrix) and utemp(vector)
//utemp is result from previous state
//only state with non-binary operation 
parameter MUL_Hutemp = 8;
//perform error-correction
parameter ERROR_CORRECTION = 9;
//multiply S_inv(matrix) and mdash(vector)
//mdash is result from previous state 
parameter MUL_Sinvmdash = 10;
//output the decoded message
parameter MSG_OUT = 11;

integer i=0;

//had to use this so that the for loop doesnot get the value after a cycle
assign reg_mul = parity_check_col & reg_utemp;

always @ (posedge clk)
begin
    if(reset)
    begin
        message <= 0; 
        msg_ready <= 0;
        STATE <= 0;
        CNT_PARITY_ROW <= 0;
        CNT_PARITY_COL <= 0;
        CNT_PERM <= 0;
        CNT_NONS <= 0;
        reg_sum <= 0;
        reg_sum_Sinvmdash <= 0;
        CNT <= 0;
        //reg_parity_check_row <= 0;
        //reg_parity_check_col <= 0;
        //reg_p_inv <= 0;
        //reg_s_inv <= 0;
        reg_cdash <= 0;
        reg_utemp <= 0;
        reg_u <= 0;
        reg_mdash <= 0;
        reg_msg <= 0;
        j <= 0;
        j_sum <= 0;
    end
    else
        case (STATE)
            IDLE: //STATE 0
            begin
                if (start && cipher_ready)
                begin
                    message <= 0; 
                    msg_ready <= 0;
                    CNT_PARITY_ROW <= 0;
                    CNT_PARITY_COL <= 0;
                    CNT_PERM <= 0;
                    CNT_NONS <= 0;
                    STATE <= MUL_cPinv;
                end
                else
                    STATE <= IDLE;
            end //STATE 0
            /*
            CIPHER_IN: //STATE 1, takes 1 clock cycle
            begin
                reg_cipher <= cipher;
                if (parity_ready)
                    STATE <= RCV_PC_ROW;
            end //STATE 1
                 
            RCV_PC_ROW: //STATE 2, takes N clock cycles  
            begin
                if (CNT_PARITY_ROW <= cnt_max_parity)
                begin
                    //store the values row wise i.e. 0 to N-1
                    //helpful to perform multiplication operation in state MUL_Hcdash
                    reg_parity_check_row[CNT_PARITY_ROW+:K] <= parity_check_row;
                    CNT_PARITY_ROW <= CNT_PARITY_ROW + K; //increment by K which is equal to number of cols
                                
                    if (CNT_PARITY_ROW == cnt_max_parity)
                    begin
                        CNT_PARITY_ROW <= 0;
                        STATE <= RCV_PC_COL;
                    end
                end              
            end //STATE 2
            
            RCV_PC_COL: //STATE 3, takes K clock cycles
            begin
                if (CNT_PARITY_COL <= cnt_max_parity)
                begin
                    //store the values col wise i.e. 0 to K-1
                    //helpful to perform multiplication operation in state MUL_Hutemp
                    reg_parity_check_col[CNT_PARITY_COL+:N] <= parity_check_col;
                    CNT_PARITY_COL <= CNT_PARITY_COL + N; //increment by N which is equal to number of rows
                                            
                    if (CNT_PARITY_COL == cnt_max_parity)
                    begin
                        CNT_PARITY_COL <= 0;
                        if (S_inv_ready)
                            STATE <= RCV_Sinv;
                    end
                end              
            end //STATE 3
            
            RCV_Sinv: //STATE 4, takes n clock cycles
            begin
                if (CNT_NONS <= cnt_max_nons)
                begin
                    //store the values col wise i.e. 0 to n-1
                    //helpful to perform multiplication operation in state MUL_Sinvmdash
                    reg_s_inv[CNT_NONS+:n] <= S_inv;
                    CNT_NONS <= CNT_NONS + n; //increment by n which is equal to number of rows
                                            
                    if (CNT_NONS == cnt_max_nons)
                    begin
                        CNT_NONS <= 0;
                        if (P_inv_ready)
                            STATE <= RCV_Pinv;
                    end
                end              
            end //STATE 4
            
            RCV_Pinv: //STATE 5, takes K clock cycles
            begin
                if (CNT_PERM <= cnt_max_perm)
                begin
                    //store the values col wise i.e. 0 to K-1
                    //helpful to perform multiplication operation in next state 
                    reg_p_inv[CNT_PERM+:K] <= P_inv;
                    CNT_PERM <= CNT_PERM + K; //increment by K which is equal to number of rows
                                                        
                    if (CNT_PERM == cnt_max_perm)
                    begin
                        CNT_PERM <= 0;
                        STATE <= MUL_cPinv;
                        j <= K; //cdash will need to store K values in next state
                    end
                end              
            end //STATE 5
            */
            MUL_cPinv: //STATE 6, takes K clock cycles
            begin
                if (CNT_PERM <= cnt_max_perm)
                begin
                    //perform P_inv(matrix) and cipher(vector) multiplication
                    //P_inv dimension is K x K
                    //cipher dimension is 1 x K
                    //since both matrix and vector is binary
                    //and required result is in binary
                    //hence we perform AND operation instead of mul
                    //and XOR operation instead of add
                    reg_sum_cpinv <= P_inv & cipher;
                    reg_cdash[j] <= ^reg_sum_cpinv;
                    CNT_PERM <= CNT_PERM + K;
                    j <= j - 1;
                                
                    if (CNT_PERM == cnt_max_perm)
                    begin
                        CNT_PERM <= 0;
                        STATE <= MUL_Hcdash;
                        j <= N; //utemp will need to store N values in next state
                    end
                end
            end //STATE 6
            
            MUL_Hcdash: //STATE 7, takes N clock cycles
            begin
                if (CNT_PARITY_ROW <= cnt_max_parity)
                begin
                    //perform H(matrix) and cdash(vector) multiplication
                    //H dimension is N x K and use row-wise storage
                    //cdash dimension is 1 x K
                    //since both matrix and vector is binary
                    //and required result is in binary
                    //hence we perform AND operation instead of mul
                    //and XOR operation instead of add
                    reg_sum_hcdash <= parity_check_row & reg_cdash;
                    reg_utemp[j] <= ^reg_sum_hcdash;
                    CNT_PARITY_ROW <= CNT_PARITY_ROW + K;
                    j <= j - 1;
                                            
                    if (CNT_PARITY_ROW == cnt_max_parity)
                    begin
                        CNT_PARITY_ROW <= 0;
                        STATE <= MUL_Hutemp;
                        j_sum <= (logN * K) - 1; //u will need to store K values in next state
                    end
                end
            end //STATE 7
            
            MUL_Hutemp: //STATE 8, takes K clock cycles
            begin
                if (CNT_PARITY_COL <= cnt_max_parity)
                begin
                    //perform H(matrix) and utemp(vector) multiplication
                    //H dimension is N x K and use col-wise storage
                    //utemp dimension is 1 x N
                    //binary multiplication will still be performed using AND operation
                    //then perform normal add to get non-binary values
                    //reg_mul = reg_parity_check_col[CNT_PARITY_COL+:N] & reg_utemp; //moved to assign statement
                    reg_sum = 0;
                    for (i = 0; i < N; i = i + 1)
                    begin
                          reg_sum = reg_sum + reg_mul[i];
                    end
                    reg_u[j_sum-:logN] <= reg_sum;
                    CNT_PARITY_COL <= CNT_PARITY_COL + N;
                    j_sum <= j_sum - logN;
                                                        
                    if (CNT_PARITY_COL == cnt_max_parity)
                    begin
                        CNT_PARITY_COL <= 0;
                        STATE <= ERROR_CORRECTION;
                        j_sum <= (logN * K) - 1; 
                        CNT <= n - 1;
                        j <= K - 1; //need to check only n values for error-correction 
                    end
                end
            end //STATE 8
            
            ERROR_CORRECTION: //STATE 9, takes n cycles
            begin
                if (CNT >= 0)
                begin
                    reg_mdash[CNT] <= (reg_u[j_sum-:logN] > ec) ? ~reg_cdash[j] : reg_cdash[j];
                    CNT <= CNT - 1;
                    j_sum <= j_sum - logN;
                    j <= j - 1; 
                end     
                if (CNT == 0)
                begin
                    reg_sum <= 0;
                    STATE <= MUL_Sinvmdash;
                    j <= n;
                end
            end //STATE 9
            
            MUL_Sinvmdash: //STATE 10, takes n cycles
            begin
                if (CNT_NONS <= cnt_max_nons)
                begin
                    //perform S_inv(matrix) and mdash(vector) multiplication
                    //S_inv dimension is n x n
                    //message dimension is 1 x n
                    //since both matrix and vector is binary
                    //and required result is in binary
                    //hence we perform AND operation instead of mul
                    //and XOR operation instead of add
                    reg_sum_Sinvmdash <= S_inv & reg_mdash;
                    reg_msg[j] <= ^reg_sum_Sinvmdash;
                    CNT_NONS <= CNT_NONS + n;
                    j <= j - 1;
                                
                    if (CNT_NONS == cnt_max_nons)
                    begin
                        CNT_NONS <= 0;
                        msg_ready <= 1;
                        j <= 0;
                        STATE <= MSG_OUT; //output msg in next clock cycle 
                    end
                end
            end //STATE 10
            
            MSG_OUT: //STATE 11, takes 1 cycle
            begin
                message <= reg_msg;
            end  //STATE 11
        endcase
end

endmodule

