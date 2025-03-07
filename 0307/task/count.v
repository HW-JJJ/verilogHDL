`timescale 1ns / 1ps

module Top_Upcounter (
    input clk,
    input reset,
    //  input [2:0] sw,
    input btn_run_stop,         
    input btn_clear,              
    output [3:0] seg_comm,
    output [7:0] seg
);

    wire [$clog2(100)-1:0] msec_count;
    wire [$clog2(60)-1:0] sec_count;
    wire w_tick_100hz, w_run_stop, w_clear;
    wire o_btn_run_stop, o_btn_clear;

    btn_debounce U_btn_debounce_run_stop (
        .clk(clk),
        .reset(reset),
        .i_btn(btn_run_stop),
        .o_btn(o_btn_run_stop)
    );  

    btn_debounce U_btn_debounce_clear (
        .clk(clk),
        .reset(reset),
        .i_btn(btn_clear),
        .o_btn(o_btn_clear)
    );

    tick_100hz U_tick_100hz(
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .o_tick_100hz(w_tick_100hz)
    );

    counter_tick_msec U_counter_tick_msec(
        .clk(clk),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(msec_count)
    );
    
    counter_tick_sec U_counter_tick_sec(
        .clk(clk),
        .reset(reset),
        .clear(w_clear),
        .tick(w_tick_100hz),
        .counter(sec_count)
    );

    control_unit U_Control_unit (
        .clk(clk),
        .reset(reset),
        .i_run_stop(o_btn_run_stop),  // input 
        .i_clear(o_btn_clear),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );
    
    fnd_controller U_fnd_cntl (
        .clk(clk),
        .reset(reset),
        .bcd_msec(msec_count),
        .bcd_sec(sec_count),  // 14 biit
        .seg(seg),
        .seg_comm(seg_comm)
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

module counter_tick_msec(
    input clk,
    input reset,
    input clear,
    input tick,
    output [$clog2(100) - 1 : 0]  counter
);

    reg [$clog2(100) - 1 : 0] counter_reg ,  counter_next;

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
            if (counter_reg == 100 -1)
                counter_next = 0;
            else 
                counter_next = counter_reg + 1;
        end     
        
    end
endmodule

module counter_tick_sec(
    input clk,
    input reset,
    input clear,
    input tick,
    output [$clog2(60) - 1 : 0]  counter
);

    reg [$clog2(60) - 1 : 0] counter_reg ,  counter_next;

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
            if (counter_reg == 60 -1)
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
                if (i_run_stop == 1'b1) begin
                    next = STOP;
                end 
                else begin
                    next = state;
                end
            end

            CLEAR: begin
                if (i_clear == 1'b1) begin
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

        o_run_stop = 1'b0;
        o_clear = 1'b0;

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
                // o_run_stop = 1'b1;
            end

            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
        endcase
    end
endmodule
