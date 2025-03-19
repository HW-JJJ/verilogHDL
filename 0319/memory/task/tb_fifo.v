`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 16:38:11
// Design Name: 
// Module Name: tb_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_fifo;

    reg clk;
    reg reset;
    reg wr;
    reg rd;
    wire full;
    wire empty;
    reg [7:0] w_data;
    wire [7:0] r_data;

    fifo DUT(
        .clk(clk),
        .reset(reset),
        .w_data(w_data),
        .wr(wr),
        .full(full),
        .rd(rd),
        .r_data(r_data),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; wr = 0; rd = 0; w_data = 0;

        #10; 
        reset = 0;
        
        #10; 
        wr = 1;
        w_data = 8'haa;
        
        #10;
        w_data = 8'h55;

        #10; 
        wr = 0;
        rd = 1;

        #20;
        $stop;
    end
endmodule
