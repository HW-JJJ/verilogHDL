`timescale 1ns / 1ns

module fnd_controller (
    input clk,
    input reset,
    input [7:0] humidity,
    input [7:0] temperature,
    output [7:0] seg,
    output [3:0] seg_comm
);

    wire [3:0] w_bcd, w_digit_h_10, w_digit_h_1, w_digit_t_10, w_digit_t_1;
    wire [1:0] w_seg_sel;
    
    wire w_clk_100hz;
    clk_divider U_Clk_Divider (
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );
    counter_4 U_Counter_4 (
        .clk  (w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );


    decoder_2x4 U_decoder_2x4 (
        .seg_sel (w_seg_sel),
        .seg_comm(seg_comm)
    );

    digit_splitter U_Digit_Splitter_humid_10 (
        .bcd(humidity),
        .digit_1(w_digit_h_1),
        .digit_10(w_digit_h_10)
    );
    digit_splitter U_Digit_Splitter_temp_1 (
        .bcd(temperature),
        .digit_1(w_digit_t_1),
        .digit_10(w_digit_t_10)
    );


    mux_4x1 U_Mux_4x1 (
        .sel(w_seg_sel),
        .digit_1(w_digit_t_1),
        .digit_10(w_digit_t_10),
        .digit_100(w_digit_h_1),
        .digit_1000(w_digit_h_10),
        .bcd(w_bcd)
    );


    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),  
        .seg(seg)
    );

endmodule

module clk_divider (
    input  clk,
    input  reset,
    output o_clk
);
    parameter FCOUNT = 500_000 ;
    
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin  
            r_counter <= 0;  
            r_clk <= 1'b0;
        end else begin
            
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0; 
            end
        end
    end

endmodule

module counter_4 (
    input        clk,
    input        reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end


endmodule

module decoder_2x4 (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);

    // 2x4 decoder
    always @(seg_sel) begin
        case (seg_sel)
            2'b00:   seg_comm = 4'b1110;
            2'b01:   seg_comm = 4'b1101;
            2'b10:   seg_comm = 4'b1011;
            2'b11:   seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end

endmodule

module digit_splitter #(parameter BIT_WIDTH = 8) (
    input  [BIT_WIDTH -1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1 = bcd % 10; 
    assign digit_10 = bcd / 10 % 10; 
endmodule

module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    
    always @(sel, digit_1, digit_10, digit_100, digit_1000) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = 4'bx;
        endcase
    end

endmodule

module bcdtoseg (
    input [3:0] bcd,   
    output reg [7:0] seg
);
    
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hA: seg = 8'h88;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hc6;
            4'hD: seg = 8'ha1;
            4'hE: seg = 8'h86;
            4'hF: seg = 8'h8E;
            default: seg = 8'hff;
        endcase
    end
endmodule