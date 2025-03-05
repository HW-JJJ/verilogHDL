`timescale 1ns / 1ps

module fnd_controller(
    input clk,rst,
    input [13:0] bcd,
    output [7:0] seg, 
    output[3:0] seg_com
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] mux_bcd;
    wire [1:0] w_sel;
    wire w_clk_1khz;

    clock_divider_1khz U_cd( 
        .clk(clk), 
        .rst(rst), 
        .clk_1khz(w_clk_1khz)
    );

    cnt_4 U_cnt( 
        .clk_1khz(w_clk_1khz), 
        .rst(rst), 
        .sel(w_sel)
    );

    decoder_2x4 U_decoder_2x4( 
        .d_in(w_sel), 
        .d_out(seg_com)
    );

    digit_splitter U_digit_splitter( 
        .bcd(bcd), 
        .digit_1(w_digit_1), 
        .digit_10(w_digit_10), 
        .digit_100(w_digit_100), 
        .digit_1000(w_digit_1000)
    );

    mux_4x1 U_mux_4x1(  
        .digit_1(w_digit_1), 
        .digit_10(w_digit_10), 
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .sel(w_sel), 
        .bcd(mux_bcd)
    );
    
    BCD_to_seg U_bcdtoseg( 
        .bcd(mux_bcd), 
        .seg(seg)
    );

endmodule

module clock_divider_1khz(
    input clk,rst,
    output reg clk_1khz
);

// $clog2 를 사용하면 비트수 계산 가능
// 예) $clog2(5) -> 3
// basys 는 기본 100Mhz
    reg [$clog2(100_000_000):0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin 
            cnt <= 0;
            clk_1khz <= 0; 
        end else begin
            if (cnt == 100_000-1) begin  
                cnt <= 0; 
                clk_1khz <= ~clk_1khz; 
            end else begin 
                cnt <= cnt + 1; 
            end
        end
    end
endmodule

module cnt_4(
    input clk_1khz, rst,
    output [1:0] sel
);

    reg [1:0] cnt_sel;

    assign sel = cnt_sel;

    always @(posedge clk_1khz or posedge rst) begin
        if (rst) 
            cnt_sel <= 0;
        else begin
            cnt_sel <= cnt_sel + 1;
        end
    end
endmodule

module decoder_2x4(
    input [1:0] d_in,
    output reg [3:0] d_out
    );

        always @(d_in) begin
            case(d_in)
                2'b00 : d_out = 4'b1110;
                2'b01 : d_out = 4'b1101;
                2'b10 : d_out = 4'b1011;
                2'b11 : d_out = 4'b0111;
                default : d_out = 4'b1111;
                endcase          
        end
endmodule

module digit_splitter (
    input [13:0] bcd,
    output [3:0] digit_1, digit_10, digit_100, digit_1000
);

    assign digit_1 = bcd % 10;
    assign digit_10 = bcd / 10 % 10;
    assign digit_100 = bcd / 100 % 10;
    assign digit_1000 = bcd / 1000 % 10;

endmodule

module mux_4x1(
    input [3:0] digit_1, digit_10, digit_100, digit_1000,
    input [1:0] sel,
    output reg [3:0] bcd
);
    
    always @(*) begin
        case (sel)
            2'b00: bcd = digit_1;
            2'b01: bcd = digit_10;
            2'b10: bcd = digit_100;
            2'b11: bcd = digit_1000;
            default: bcd = 4'bx;
        endcase
    end
endmodule

module BCD_to_seg(
    input [3:0] bcd,
    output reg [7:0] seg
);

    always @(bcd) begin
        case (bcd)
            4'h0 : seg = 8'hc0;
            4'h1 : seg = 8'hf9;
            4'h2 : seg = 8'ha4;
            4'h3 : seg = 8'hb0;
            4'h4 : seg = 8'h99;
            4'h5 : seg = 8'h92;
            4'h6 : seg = 8'h82;
            4'h7 : seg = 8'hf8;
            4'h8 : seg = 8'h80;
            4'h9 : seg = 8'h90;
            4'ha : seg = 8'h88;
            4'hb : seg = 8'h83;
            4'hc : seg = 8'hc6;
            4'hd : seg = 8'ha1;
            4'he : seg = 8'h86;
            4'hf : seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule
