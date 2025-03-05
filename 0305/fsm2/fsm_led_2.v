`timescale 1ns / 1ps

module fsm_led(
    input clk,
    input rst,
    input [2:0] sw,
    output [2:0] led
    );

    reg [2:0] r_led;
    reg [2:0] state, next;

    assign led = r_led;

    parameter [2:0] idle = 3'b000,
                    st1 = 3'b001,
                    st2 = 3'b010,
                    st3 = 3'b100,
                    st4 = 3'b111;

    always @(posedge clk, posedge rst) begin
        if (rst) begin            
            state <= 0;
        end else begin            
            state <= next;
        end
    end
        
    always @(*) begin
        next = state;

        case (state)
            
            idle : begin                
                if (sw == 3'b001) begin
                    next = st1;
                end
                
                else if (sw == 3'b010) begin
                    next = st2;
                end 
            end

            st1 : begin
                if (sw == 3'b010) begin
                    next = st2;
                end
            end

            st2 : begin
                if (sw == 3'b100) begin
                    next = st3;
                end
            end

            st3 : begin
                if (sw == 3'b000) begin
                    next = idle;
                end 
                else if (sw == 3'b001) begin
                    next = st1;
                end
                else if (sw == 3'b111) begin
                    next = st4;
                end
            end

            st4 : begin
                if (sw == 3'b100) begin
                    next = st3;
                end
            end

            default: begin
                next = state;
            end
        endcase
    end

    always @(*) begin
        case (state)
            idle : begin
                r_led = 3'b000;
            end
            st1 : begin
                r_led = 3'b001;
            end
            st2 : begin
                r_led = 3'b010;
            end
            st3 : begin
                r_led = 3'b100;
            end
            st4 : begin
                r_led = 3'b111;
            end
            default : begin
                r_led = 3'b000;
            end
        endcase
    end
endmodule
