`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 15:11:10
// Design Name: 
// Module Name: fifo
// Project Name: memory
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo(
    input clk,
    input reset,
    // write
    input  [7:0] w_data,
    input  wr,
    output full,
    // read 
    input  rd,
    output [7:0] r_data,
    output empty
    );

    // module instance
    wire [3:0] w_addr, r_addr;

    fifo_control_unit U_fifo_control_unit(
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .full(full),
        .w_addr(w_addr),
        .rd(rd),
        .empty(empty),
        .r_addr(r_addr)
    );

    register_file U_register_file(
        .clk(clk),
        .wr({~full&wr}), 
        .w_addr(w_addr),  
        .w_data(w_data),  
        .r_addr(r_addr),
        .r_data(r_data)
    );
endmodule

module register_file (
    input clk,
    // write
    input  wr, 
    input  [3:0] w_addr,  // 4bit
    input  [7:0] w_data,  // 8bit
    // read
    input  [3:0] r_addr,
    output [7:0] r_data
);
    reg [7:0] mem [0:15]; // 4bit addr

    // write 
    always @(posedge clk) begin
        if (wr) begin
            mem[w_addr] <= w_data;
        end        
    end
    
    // read
    assign r_data = mem[r_addr];
endmodule

module fifo_control_unit (
    input  clk,
    input  reset,
    // write
    input  wr,
    output full,
    output [3:0] w_addr,
    // read
    input  rd,
    output empty,
    output [3:0] r_addr
);
    // output FSM
    // 1bit output state
    reg full_reg, full_next;
    reg empty_reg, empty_next;
    // W,R address manage
    reg [3:0] w_ptr_reg, w_ptr_next;
    reg [3:0] r_ptr_reg, r_ptr_next;
    
    assign w_addr   = w_ptr_reg;
    assign r_addr   = r_ptr_reg;
    assign full     = full_reg;
    assign empty    = empty_reg;    
    // state
    always @(posedge clk, posedge reset) begin
        if(reset) begin
           full_reg  <= 0;
           empty_reg <= 1;
           w_ptr_reg <= 0;
           r_ptr_reg <= 0; 
        end else begin
            full_reg  <= full_next;
            empty_reg <= empty_next;
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
        end
    end

    // next state
    always @(*) begin
        full_next  = full_reg;            
        empty_next = empty_reg;
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;

        case ({wr, rd}) // vector by 
            2'b01 : begin // rd == 1 : 
                if(empty_reg == 1'b0) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next = 1'b0;

                    if (w_ptr_reg == r_ptr_next) begin// 같은 경우 empty로 가야하니 미리 예측해서 바뀌도록
                        empty_next = 1'b1;
                    end
                end
            end
    
            2'b10 : begin  // wr == 1;
                if (full_reg == 1'b0) begin
                    w_ptr_next = w_ptr_reg + 1;
                    empty_next = 1'b0;

                    if(w_ptr_next == r_ptr_reg) begin
                        full_next = 1'b1;                            
                    end
                end                   
            end

            2'b11 : begin
                if (empty_reg == 1'b1) begin      // empty의 이전상태가 1인 상태에서 0이 되면
                    w_ptr_next = w_ptr_reg + 1;   // pop 없이 push만
                    empty_next = 1'b0;
                end
                else if (full_reg == 1'b1) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next = 1'b0;    
                end 
                else begin
                    r_ptr_next = r_ptr_reg + 1;
                    w_ptr_next = w_ptr_reg + 1;
                end
            end   
        endcase
    end
endmodule
