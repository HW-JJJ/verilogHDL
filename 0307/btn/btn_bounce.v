`timescale 1ns / 1ps

module btn_debounce (
    input clk,
    input reset,
    input i_btn,
    output o_btn
);

    reg state, next;
    reg [7:0] q_reg , q_next;
    reg edge_detect;

    wire btn_deb;

    // 1Khz clk generate
    reg [$clog2(100_000) - 1 : 0] counter;
    reg r_1khz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_1khz <= 1'b0;
        end
        else if (counter == 100_000 - 1) begin
            counter <= 0;
            r_1khz <= 1'b1;
        end
        else begin // 1khz tick
            counter <= counter + 1;
            r_1khz <= 1'b0;
        end                   
    end

    // SR state logic
    always @(posedge r_1khz, posedge reset) begin
        if (reset)  begin
            q_reg <= 0;
        end
        else begin
            q_reg <= q_next;  
        end      
    end
    
    // next logic
    always @(r_1khz, i_btn) begin
        q_next = {i_btn, q_reg[7:1]};  // 8SR 마지막 비트 밀어내기       
    end

    // 8-input and gate
    assign btn_deb = &q_reg; 

    // edge detector
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 1'b0 ;
        end else begin
            edge_detect <= btn_deb;
        end
    end

    // final output
    assign o_btn = btn_deb & (~ edge_detect);

endmodule 
