`timescale 1ns / 1ps

module fnd_controller(
    input [1:0] btn,
    input [3:0] bcd,
    output [7:0] seg,
    output [3:0] seg_common    // segment type : annode
);
    
    decoder u1(.btn(btn), .dec_seg(seg_common));
    bcd_to_seg u2 (.bcd(bcd), .seg(seg));

endmodule

module bcd_to_seg(
    input [3:0] bcd,
    output reg [7:0] seg
);
    // output values in always construction must be reg type
    always @(bcd) begin // if sensitivity lists change, sentense in begin end activate    
        case (bcd)
            4'h0 : seg = 8'hc0; // 0
            4'h1 : seg = 8'hf9; // 1
            4'h2 : seg = 8'hA4; // 2
            4'h3 : seg = 8'hB0; // 3
            4'h4 : seg = 8'h99; // 4
            4'h5 : seg = 8'h92; // 5
            4'h6 : seg = 8'h82; // 6
            4'h7 : seg = 8'hF8; // 7
            4'h8 : seg = 8'h80; // 8
            4'h9 : seg = 8'h90; // 9
            4'hA : seg = 8'h88; // 10
            4'hB : seg = 8'h83; // 11
            4'hC : seg = 8'hC6; // 12
            4'hD : seg = 8'hA1; // 13
            4'hE : seg = 8'h86; // 14
            4'hF : seg = 8'h8E; // 15    
            default: seg = 8'hff; // default
        endcase    
    end
endmodule

module decoder(
    input [1:0] btn,
    output reg [3:0] dec_seg
);

    always @(btn) begin
        case (btn)
            2'b00 :  dec_seg = 4'b1110;
            2'b01 :  dec_seg = 4'b1101;
            2'b10 :  dec_seg = 4'b1011;
            2'b11 :  dec_seg = 4'b0111;
            default : dec_seg = 4'b1110;
        endcase
    end     
endmodule
