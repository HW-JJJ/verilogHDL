`timescale 1ns / 1ps

module fsm_mealy(
    input clk,
    input rst,
    input in_bit,
    output reg out_bit
    );

    reg [2:0] state, next;

    parameter [2:0] start = 3'b000,
                    rd0_once = 3'b001,
                    rd0_twice = 3'b010,
                    rd1_once = 3'b011,
                    rd1_twice = 3'b100;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin            
            state <= start;
            out_bit <= 1'b0;  
        end else begin            
            state <= next;
        end
    end

    always @ (*) begin
        next = state; 

        case (state)
            start : begin
                if (in_bit == 0) 
                    next = rd0_once;
                else if (in_bit == 1) 
                    next = rd1_once;
            end

            rd0_once : begin
                if (in_bit == 0) 
                    next = rd0_twice;
                else if (in_bit == 1) 
                    next = rd1_once;
            end

            rd0_twice : begin
                if (in_bit == 0) 
                    next = rd0_twice;
                else if (in_bit == 1) 
                    next = rd1_once;
            end
            
            rd1_once : begin
                if (in_bit == 0) 
                    next = rd0_once;
                else if (in_bit == 1) 
                    next = rd1_twice;
            end
            
            rd1_twice : begin
                if (in_bit == 0) 
                    next = rd0_once;
                else if (in_bit == 1) 
                    next = rd1_twice;
            end

            default : next = state;
        endcase    
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            out_bit <= 1'b0;
        end else begin
            case (next)
                rd0_twice, rd1_twice: out_bit <= 1'b1; 
                default: out_bit <= 1'b0;
            endcase
        end
    end  
endmodule
