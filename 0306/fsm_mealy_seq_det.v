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

     //1.

    always @ (posedge clk, posedge rst) begin
        if (rst) begin            
            state <= start;
        end else begin            
            state <= next;
        end
    end

    // 2. for continue next state
        
    always @ (*) begin
        
        next = state; 

        case (state)
            start : begin
                if (in_bit == 0) begin
                    next = rd0_once;
                end else if (in_bit == 1) begin
                    next = rd1_once;
                end 
            end

            rd0_once : begin
                if (in_bit == 0) begin
                    next = rd0_twice;
                end else if (in_bit == 1) begin
                    next = rd1_once;
                end
            end

            rd0_twice : begin
                if (in_bit == 0) begin
                    next = rd0_twice;
                end else if (in_bit == 1) begin
                    next = rd1_once;
                end
            end
            
            rd1_once : begin
                if (in_bit == 0) begin
                    next = rd0_once;
                end else if (in_bit == 1) begin
                    next = rd1_twice;
                end
            end
            
            rd1_twice : begin
                if (in_bit == 0) begin
                    next = rd0_once;
                end else if (in_bit == 1) begin
                    next = rd1_twice;
                end
            end

            default : next = state;
        endcase    
    end
        

    // 3. output combinational logic

    always @ (*) begin
        case (state)
            start : begin
                if (in_bit == 0) begin
                    out_bit = 1'b0;
                end else if (in_bit == 1) begin
                    out_bit = 1'b1;
                end 
            end

            rd0_once : begin
                if (in_bit == 0) begin
                    out_bit = 1'b1;
                end else if (in_bit == 1) begin
                    out_bit = 1'b0;
                end
            end

            rd0_twice : begin
                if (in_bit == 0) begin
                    out_bit = 1'b1;
                end else if (in_bit == 1) begin
                    out_bit = 1'b0;
                end
            end
            
            rd1_once : begin
                if (in_bit == 0) begin
                    out_bit = 1'b0;
                end else if (in_bit == 1) begin
                    out_bit = 1'b1;
                end
            end
            
            rd1_twice : begin
                if (in_bit == 0) begin
                    out_bit = 1'b0;
                end else if (in_bit == 1) begin
                    out_bit = 1'b1;
                end
            end

            default : out_bit = 1'b0;

        endcase
    end     
endmodule
