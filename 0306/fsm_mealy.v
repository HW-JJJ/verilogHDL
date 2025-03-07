`timescale 1ns / 1ps

module fsm_mealy(
    input clk,
    input rst,
    input in_bit,
    output reg out_bit
    );

    reg [2:0] state, next;

    // 상태 정의
    parameter [2:0] start = 3'b000,
                    rd0_once = 3'b001,
                    rd1_once = 3'b010,
                    rd0_twice = 3'b011,
                    rd1_twice = 3'b100;

    // 1. 상태 레지스터 업데이트
    always @ (posedge clk or posedge rst) begin
        if (rst)
            state <= start;
        else
            state <= next;
    end

    // 2. 다음 상태 결정
    always @ (*) begin
        next = state;

        case (state)
            start: begin
                if (in_bit == 0) 
                    next = rd0_once;
                else if (in_bit == 1) 
                    next = rd1_once;
            end

            rd0_once: begin
                if (in_bit == 0)
                    next = rd0_twice;  // 0이 반복될 경우
                else if (in_bit == 1)
                    next = rd1_once;  // 1이 들어오면 rd1_once로 이동
            end

            rd0_twice: begin
                if (in_bit == 0)
                    next = rd0_twice;  // 0이 계속 들어오면 계속 rd0_twice
                else if (in_bit == 1)
                    next = rd1_once;  // 1이 들어오면 rd1_once로 이동
            end

            rd1_once: begin
                if (in_bit == 1)
                    next = rd1_twice;  // 1이 반복될 경우
                else if (in_bit == 0)
                    next = rd0_once;  // 0이 들어오면 rd0_once로 이동
            end

            rd1_twice: begin
                if (in_bit == 1)
                    next = rd1_twice;  // 1이 계속 들어오면 계속 rd1_twice
                else if (in_bit == 0)
                    next = rd0_once;  // 0이 들어오면 rd0_once로 이동
            end

            default: next = start;
        endcase
    end

    // 3. 출력 결정
    always @ (*) begin
        out_bit = 1'b0;  // 기본 출력은 0

        case (state)
            rd0_once, rd0_twice: begin
                if (in_bit == 0)
                    out_bit = 1'b1;  // 0이 반복되면 out_bit = 1
            end

            rd1_once, rd1_twice: begin
                if (in_bit == 1)
                    out_bit = 1'b1;  // 1이 반복되면 out_bit = 1
            end

            default: out_bit = 1'b0;  // 기본은 0
        endcase
    end

endmodule
