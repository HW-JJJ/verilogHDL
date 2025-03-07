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
        in_bit = 0; rst = 1;

        #10; rst = 0; 
        
        #10; in_bit = 0;  
        #10; in_bit = 0;  
        #10; in_bit = 1;  
        #10; in_bit = 0;  
        #10; in_bit = 1;  
        #10; in_bit = 1;  
        
        #10; rst = 1; 
        #10; rst = 0; 
        
        #10; in_bit = 0; 
        #10; in_bit = 1;         
        #10; in_bit = 0;  
        #10; in_bit = 0;  
        
        #10; in_bit = 1;  
        #10; in_bit = 1;  
        #10; in_bit = 0;  
        #10; in_bit = 1;  
        #10; in_bit = 0;  
        
        #10; $stop;
    end
endmodule
