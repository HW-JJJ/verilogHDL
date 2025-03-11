`timescale 1ns / 1ps

module stopwatch_cu(
    input clk,
    input reset,
    input i_btn_run,
    input i_btn_clear,
    output reg o_run,
    output reg o_clear
    );

    // fsm structure
    parameter STOP = 2'b00 ,
              RUN = 2'b01 ,
              CLEAR = 2'b10 ;

    reg [1:0] p_state, n_state;

    // state register
    always @(posedge clk, posedge reset) begin
        if(reset)
            p_state <= STOP;  //초기상태로 초기화
        else 
            p_state <= n_state;         
    end

    // next state
    always @(*) begin

        n_state = p_state;

        case(p_state)
            STOP :begin
                if (i_btn_run == 1)
                    n_state = RUN;
                else if (i_btn_clear == 1)
                    n_state =  CLEAR;   
            end
            RUN : begin
                if (i_btn_run == 1)
                    n_state = STOP;
            end
            CLEAR : begin
                if (i_btn_clear == 1)
                    n_state =  STOP;
            end
        endcase
    end

        // output 
    always @(*) begin

            o_run = 1'b0;
            o_clear = 1'b0;

            case (p_state)
                STOP : begin
                    o_run = 1'b0;
                    o_clear = 1'b0;
                end
                RUN : begin
                    o_run = 1'b1;
                    o_clear = 1'b0;
                end
                CLEAR : begin
                    o_clear = 1'b1;
                end
            endcase
    end
endmodule
