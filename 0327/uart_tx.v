`timescale 1ns / 1ns

module uart_tx(
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx_done,
    output o_tx
);

    parameter IDLE  = 0,
              //SEND  = 1,
              START = 1,     
              DATA  = 2,
              STOP  = 3;

    reg tx_reg, tx_next, tx_done_reg, tx_done_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [3:0] state, next;
    reg [3:0] tick_count_reg, tick_count_next;
    
    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;

    // tx data in buffer
    reg [7:0] temp_data_reg, temp_data_next;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state           <= 0;
            tx_reg          <= 1'b1; // 
            tx_done_reg     <= 0;
            bit_count_reg   <= 0;
            tick_count_reg  <= 0;
            temp_data_reg   <= 0;
        end 
        else begin
            state           <= next;
            tx_reg          <= tx_next;
            tx_done_reg     <= tx_done_next;
            tick_count_reg  <= tick_count_next;
            bit_count_reg   <= bit_count_next; 
            temp_data_reg   <= temp_data_next;           
        end
    end

    always @(*) begin
        next            = state;
        tx_next         = tx_reg;
        tx_done_next    = tx_done_reg;
        tick_count_next = tick_count_reg;
        bit_count_next  = bit_count_reg;
        temp_data_next  = temp_data_reg;

        case (state)
            IDLE: begin
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tick_count_next = 4'h0;

                if (start_trigger) begin
                    next = START;
                    temp_data_next = data_in;
                end
            end
/*
            SEND: begin
                if(tick == 1'b1) begin
                    next = START;
                end
            end
*/
            START: begin
                tx_done_next = 1'b1;
                tx_next = 1'b0;

                if (tick == 1'b1) begin
                    if(tick_count_reg == 15) begin
                        next = DATA;
                        tick_count_next = 1'b0;
                        bit_count_next = 1'b0;
                    end
                    else begin 
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            DATA: begin
//                tx_next = data_in[bit_count_reg];
                tx_next = temp_data_reg[bit_count_reg];
                
                if (tick == 1'b1) begin
                    if(tick_count_reg == 15) begin
                        tick_count_next = 0;

                        if (bit_count_reg == 7) begin
                            next = STOP;
                        end
                        else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1;
                        end
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;

                if (tick == 1'b1) begin
                    if(tick_count_reg == 15) begin
                        next = IDLE;            
                    end
                    else begin 
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule