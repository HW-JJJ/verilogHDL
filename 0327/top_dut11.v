`timescale 1ns / 1ns

module top_dht11(
    
    input clk,
    input reset,
    input btn_start,      
    inout dht_io,

    input rx,
    output tx,

    //output [7:0] humidity,
    //output [7:0] temparature,
    output [3:0] led,
    output [7:0] fnd_font,
    output [3:0] fnd_comm,
    output led_checksum
);

    wire w_tick;
    wire [7:0] w_humidity;
    wire [7:0] w_temperature;

    wire w_tx, w_baud_tick;
    wire w_uart_start, w_btn_start;

    assign w_start = w_uart_start | w_btn_start;

    uart U_uart(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    ); 

    uart_cu U_uart_cu(
        .clk(clk),
        .reset(reset),
        .tick(w_baud_tick),
        .rx(tx),
        .run(w_uart_start)
    );

    baud_tick_gen U_baud_tick_gen(
        .clk(clk),
        .rst(reset),
        .baud_tick(w_baud_tick)
    );

    btn_debounce U_btn_debounce(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_start),
        .o_btn(w_btn_start)
    );

    tick_gen U_tick_gen(
        .clk(clk),
        .reset(reset),
        .tick(w_tick) 
    );

    dht11_controller U_dht11_controller(
        .clk(clk),
        .reset(reset),
        .btn_start(w_start),
        .tick(w_tick),         // 1us tick
        .dht_io(dht_io),
        .humidity(w_humidity),
        .temperature(w_temperature),
        .led_checksum(led_checksum),
        .led(led)
    );

    fnd_controller U_fnd_controller(
        .clk(clk),
        .reset(reset),
        .humidity(w_humidity),
        .temperature(w_temperature),
        .seg(fnd_font),
        .seg_comm(fnd_comm)
    );
    
endmodule