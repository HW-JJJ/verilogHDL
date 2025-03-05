`timescale 1ns / 1ps

module Top_Upcounter(
    input clk,rst,
    input [1:0] sw, // sw[0] = run_stop , sw[1] = clear 
    output [7:0] seg,
	output [3:0] seg_com
);

    wire [13:0] w_cnt;
    wire w_clk_10hz, w_run_stop, w_clear;

    assign w_run_stop = clk & sw[0];
    assign w_clear = rst | sw[1];

    clock_divider_10hz U_clk_10( 
        .clk(w_run_stop), 
        .rst(w_clear), 
        .clk_10hz(w_clk_10hz));

    counter_10000 U_counter( 
        .clk(w_clk_10hz), 
        .rst(w_clear), 
        .cnt(w_cnt));

    fnd_controller U_fnd_ctrl(
        .clk(clk),  
        .rst(rst), 
        .bcd(w_cnt), 
        .seg(seg), 
        .seg_com(seg_com));

endmodule
// $clog2 를 사용하면 비트수 계산 가능
// 예) $clog2(5) -> 3
// basys 는 기본 100Mhz
// 10000000 -> 10hz
module clock_divider_10hz(
    input clk,rst,
    output reg clk_10hz
);
    reg [$clog2(100_000_000):0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin 
            cnt <= 0;
            clk_10hz <= 0; 
        end else begin
            if (cnt == 10_000_000-1) begin  
                cnt <= 0; 
                clk_10hz <= ~clk_10hz; 
            end else begin 
                cnt <= cnt + 1; 
            end
        end
    end
endmodule

module counter_10000(
    input clk,rst,
    output reg [13:0] cnt
);
    always@( posedge clk, posedge rst) begin
        if (rst) 
            cnt <= 0;
        else if(cnt == 10000-1) 
            cnt <= 0;
        else 
            cnt <= cnt+1;
    end
endmodule
