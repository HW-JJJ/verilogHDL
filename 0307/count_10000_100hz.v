`timescale 1ns / 1ps

module Top_Upcounter (
    input clk,
    input reset,
    input [2:0] sw,
    output [3:0] seg_comm,
    output [7:0] seg
);

    wire [13:0] w_count;
    wire w_tick_100hz, w_run_stop, w_clear;
/*
   counter_10000 U_Counter_10000 (
        .clk  (w_clk_10),
        .reset(reset),
        .clear(w_clear),   // clear
        .count(w_count)    // 14비트
    );
*/

    tick_100hz U_tick_100hz(
        .clk(clk),
        .reset(reset),
        .run_stop(sw[0]),
        .o_tick_100hz(w_tick_100hz)
    );

    fnd_controller U_fnd_cntl (
        .clk(clk),
        .reset(reset),
        .bcd(w_count),  // 14 biit
        .seg(seg),
        .seg_comm(seg_comm)
    );

    counter_tick U_counter_tick(
        .clk(clk),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(w_count)
    );

    control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(sw[0]),  // input 
        .i_clear(sw[1]),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );
endmodule

module tick_100hz(
    input clk,
    input reset,
    input run_stop,
    output o_tick_100hz
);
    
    reg [$clog2(1_000_000) - 1 : 0] r_cnt;
    
    reg r_tick_100hz;

    assign o_tick_100hz = r_tick_100hz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin 
            r_cnt <= 0;
        end else begin
            if (run_stop == 1'b1) begin
                if (r_cnt == 1_000_000-1) begin    // 마지막 cylce 에 tick에 해당하는 duty 생성 
                    r_cnt <= 0; // 초기화 
                    r_tick_100hz <= 1'b1;                                         
                end 
                else begin
                    r_cnt <= r_cnt + 1;
                    r_tick_100hz <= 1'b0;
                end
            end 
        end
    end
endmodule

/*
module counter_10000 (
    input clk,
    input reset,
    input clear,
    output [13:0] count  // 14비트
);

    reg [$clog2(10000)-1:0] r_counter;

    assign count = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (r_counter == 10000 - 1) begin
                r_counter <= 0;
            end 
            else if (clear == 1'b1) begin
                r_counter <= 0;
            end 
            else begin
                r_counter <= r_counter + 1;
            end
        end
    end
endmodule
*/

// 100Mhz clk를 이용해 100hz 신호의 HIGH를 COUNT
module counter_tick(
    input clk,
    input reset,
    input clear,
    input tick,
    output [$clog2(10_000) - 1 : 0]  counter
);

    reg [$clog2(10_000) - 1 : 0] counter_reg ,  counter_next;

    assign counter = counter_reg;

    // state
    always @(posedge clk, posedge reset) begin
        if (reset) 
            counter_reg <= 0;
        else 
            counter_reg <= counter_next;        
    end

    // next state
    always @(*) begin

        counter_next = counter_reg;  // initial value
        if (clear == 1'b1) begin
            counter_next = 0;
        end 
        else if (tick == 1'b1) begin                       // tick count
            if (counter_reg == 10_000 -1)
                counter_next = 0;
            else 
                counter_next = counter_reg + 1;
        end     
        
    end
endmodule

module control_unit (
    input clk,
    input reset,
    input i_run_stop,  // input 
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;
    // state 관리
    reg [2:0] state, next;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end


    // next combinational logic
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_run_stop == 1'b1) begin
                    next = RUN;
                end 
                else if (i_clear == 1'b1) begin
                    next = CLEAR;
                end 
                else begin
                    next = state;
                end
            end
            RUN: begin
                if (i_run_stop == 1'b0) begin
                    next = STOP;
                end 
                else begin
                    next = state;
                end
            end
            CLEAR: begin
                if (i_clear == 1'b0) begin
                    next = STOP;
                end
            end
            default: begin
                next = state;
            end
        endcase
    end

    // combinational output logic
    always @(*) begin
        case (state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR: begin
                o_clear    = 1'b1;
                o_run_stop = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
