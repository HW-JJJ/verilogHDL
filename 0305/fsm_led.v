`timescale 1ns / 1ps

module fsm_led(
    input clk, 
    input rst,
    input [2:0] sw,
    output [1:0] led
);
    reg [1:0] r_led;
    reg [1:0] state,next;

    assign led = r_led;

    parameter [1:0] idle = 2'b00, 
                    led01 = 2'b01,
                    led02 = 2'b10;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
        //    next  <= 0;
        end else begin
            // state manage : change next state
            state <= next;
        end
    end

    // state change logic 
    always @(*) begin
        
        next = state;

        case (state)
            idle : begin
                if (sw == 3'b001) begin 
                    next = led01; 
                end 
            end
            led01 : begin
                if (sw == 3'b011) begin 
                    next = led02;
                end
            end
            led02 : begin
                if (sw == 3'b110) begin 
                    next = led01;
                end 
                else if (sw == 3'b111) begin
                    next = idle;
                end 
                else begin
                    next = state;
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
                r_led = 2'b00;
            end
            led01 : begin
                r_led = 2'b10;
            end
            led02 : begin
                r_led = 2'b01;
            end
            default: begin
                r_led = 2'b00;
            end
        endcase        
    end
endmodule
