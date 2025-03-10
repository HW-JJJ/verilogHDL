`timescale 1ns / 1ps

module TOP_stopwatch(
    input clk,
    input reset,
    input btn_run,
    input btn_clear,
    output [3:0] fnd_comm,
    output [7:0] fnd_font 
    );

    wire w_run, w_clear;
    wire [6:0] msec, sec, min, hour;

    stopwatch_cu U_stopwatch_cu(
        .clk(clk),
        .reset(reset),
        .i_btn_run(btn_run),
        .i_btn_clear(btn_clear),
        .o_run(w_run),
        .o_clear(w_clear)
    );

    stopwatch_dp U_stopwatch_dp(
        .clk(clk),
        .reset(reset),
        .run(w_run),
        .clear(w_clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)                
    );

    fnd_controller U_fnd_controller(
       .clk(clk),
       .reset(reset),
       .msec(msec),
       .sec(sec),
       .min(min),
       .hour(hour),
       .fnd_font(fnd_font),
       .fnd_comm(fnd_comm)
    );    
endmodule
