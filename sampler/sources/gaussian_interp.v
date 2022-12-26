
/** @module : gaussian_interp.v -Polynomial interpolation
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

`timescale 1 ns / 1 ps


module gaussian_interp (
    // System signals
    input clk,                    // system clock
    input rstn,                   // system synchronous reset, active low

    // Data interface
    input valid_in,               // input data valid
    input [63:0] data_in,         // input data
    output reg valid_out,         // output data valid
    output reg [15:0] data_out    // output data, s<16,11>
);

// Local variables
wire [5:0] num_lzd;
reg [5:0] num_lzd_r;
reg [14:0] mask;
reg [1:0] offset;
wire [7:0] addr;
wire [17:0] c0;    // u<18,14>
wire [17:0] c1;    // s<18,19>
wire [16:0] c2;    // u<17,23>
reg [14:0] x;      // u<15,15>
reg [14:0] x_r1, x_r2, x_r3, x_r4;   // u<15,15>
reg [17:0] c1_r1;    // s<18,19>
wire [37:0] sum1;    // s<38,38>
wire [17:0] sum1_new;    // s<18,18>
wire [33:0] mul1;    // s<34,33>
wire signed [13:0] mul1_new;    // s<14,14>
reg [17:0] c0_r1, c0_r2, c0_r3, c0_r4, c0_r5;   // u<18,14>
reg signed [18:0] sum2;    // s<19,14>
reg [14:0] sum2_rnd;    // u<15,11>
reg [8:0] sign_r;
reg [8:0] valid_in_r;


// Leading zero detector
gaussian_lzd u_gaussian_lzd (
    .data_in(data_in[63:3]),
    .data_out(num_lzd)
);

always @ (posedge clk) begin
    if (!rstn)
        num_lzd_r <= 6'd0;
    else
        num_lzd_r <= num_lzd;
end


// Get mask for value x
always @ (posedge clk) begin
    if (!rstn)
        mask <= 15'b111111111111111;
    else begin
        case (num_lzd_r)
            6'd61:   mask <= 15'b111111111111111;
            6'd60:   mask <= 15'b011111111111111;
            6'd59:   mask <= 15'b101111111111111;
            6'd58:   mask <= 15'b110111111111111;
            6'd57:   mask <= 15'b111011111111111;
            6'd56:   mask <= 15'b111101111111111;
            6'd55:   mask <= 15'b111110111111111;
            6'd54:   mask <= 15'b111111011111111;
            6'd53:   mask <= 15'b111111101111111;
            6'd52:   mask <= 15'b111111110111111;
            6'd51:   mask <= 15'b111111111011111;
            6'd50:   mask <= 15'b111111111101111;
            6'd49:   mask <= 15'b111111111110111;
            6'd48:   mask <= 15'b111111111111011;
            6'd47:   mask <= 15'b111111111111101;
            6'd46:   mask <= 15'b111111111111110;
            default: mask <= 15'b111111111111111;
        endcase
    end
end


// Generate table address and coefficients
always @ (posedge clk) begin
    if (!rstn)
        offset <= 2'd0;
    else
        offset <= {data_in[1], data_in[2]};
end

assign addr = {num_lzd_r, offset};

gaussian_coef u_gaussian_coef (
    .clk(clk),
    .addr(addr),
    .c0(c0),
    .c1(c1),
    .c2(c2)
);


// Data delay
always @ (posedge clk) begin
    if (!rstn)
        x <= 15'd0;
    else
        x <= {data_in[3], data_in[4], data_in[5], data_in[6], data_in[7],
              data_in[8], data_in[9], data_in[10], data_in[11], data_in[12],
              data_in[13], data_in[14], data_in[15], data_in[16], data_in[17]};
end

always @ (posedge clk) begin
    x_r1 <= x & mask;
    x_r2 <= x_r1;
    x_r3 <= x_r2;
    x_r4 <= x_r3;
end

always @ (posedge clk) begin
    c1_r1 <= c1;
end

always @ (posedge clk) begin
    c0_r1 <= c0;
    c0_r2 <= c0_r1;
    c0_r3 <= c0_r2;
    c0_r4 <= c0_r3;
    c0_r5 <= c0_r4;
end

always @ (posedge clk) begin
    sign_r <= {sign_r[7:0], data_in[0]};
end

always @ (posedge clk) begin
    if (!rstn)
        valid_in_r <= 9'd0;
    else
        valid_in_r <= {valid_in_r[7:0], valid_in};
end


// Polynomial interpolation of order 2
gaussian_smul_16_18_sadd_37 u_gaussian_smul_16_18_sadd_37 (
    .clk(clk),
    .a({1'b0, x_r1}),
    .b({1'b0, c2}),
    .c({c1_r1, 19'd0}),
    .p(sum1)
);

assign sum1_new = sum1[37:20];

gaussian_smul_16_18 u_gaussian_smul_16_18 (
    .clk(clk),
    .a({1'b0, x_r4}),
    .b(sum1_new),
    .p(mul1)
);

assign mul1_new = mul1[32:19];

always @ (posedge clk) begin
    sum2 <= $signed({1'b0, c0_r5}) + mul1_new;
end

always @ (posedge clk) begin
    sum2_rnd <= sum2[17:3] + sum2[2];
end


// Output data
always @ (posedge clk) begin
    if (!rstn)
        valid_out <= 1'b0;
    else
        valid_out <= valid_in_r[8];
end

always @ (posedge clk) begin
    if (!rstn)
        data_out <= 16'd0;
    else if (sign_r[8])
        data_out <= {1'b1, ~sum2_rnd} + 1'b1;
    else
        data_out <= {1'b0, sum2_rnd};
end


endmodule
