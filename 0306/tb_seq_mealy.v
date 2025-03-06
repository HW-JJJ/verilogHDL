`timescale 1ns / 1ps

module tb_mealy;

    reg clk;
    reg rst;
    reg in_bit;
    wire out_bit;

    fsm_mealy U_fsm_mealy (
        .clk(clk),
        .rst(rst),
        .in_bit(in_bit),
        .out_bit(out_bit)
    );

    // 100Mhz clk
    always begin
        clk = 0; #5; clk = 1; #5;
    end

    initial begin

        clk = 0;
        rst = 1;
        in_bit = 0;

        rst = 1; #10;  
        rst = 0; #10;  
        
        in_bit = 0; #10;  // start -> rd0_once
        in_bit = 0; #10;  // rd0_once -> rd0_twice
        in_bit = 1; #10;  // rd0_twice -> rd1_once
        in_bit = 0; #10;  // rd1_once -> rd0_once
        in_bit = 1; #10;  // rd0_once -> rd1_twice
        in_bit = 1; #10;  // rd1_twice -> rd1_twice
        
        in_bit = 1; #10;  // start -> rd1_once
        in_bit = 1; #10;  // rd1_once -> rd1_twice
        in_bit = 0; #10;  // rd1_twice -> rd0_once
        in_bit = 1; #10;  // rd0_once -> rd1_once
        in_bit = 0; #10;  // rd1_once -> rd0_once
        
        in_bit = 0; #10;  // start -> rd0_once
        in_bit = 1; #10;  // rd0_once -> rd1_once
        in_bit = 0; #10;  // rd1_once -> rd0_once
        in_bit = 0; #10;  // rd0_once -> rd0_twice
        
        $stop;
    end
endmodule
