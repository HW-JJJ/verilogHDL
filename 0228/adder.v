`timescale 1ns / 1ps

module caculator (
    input [7:0] a,b,
    input [1:0] btn,
    // input cin,
    output [7:0] seg,
    output [3:0] seg_common,
    output c_led
);
    wire [7:0] s_b; 

    full_adder_8bit uc1 (.a(a), .b(b), .s(s_b), .cout(c_led));
    fnd_controller uc2 (.btn(btn), .bcd(s_b), .seg(seg), .seg_common(seg_common));
    
endmodule

module full_adder_8bit(
    input [7:0] a,b,
    // input cin
    output [7:0] s,
    output cout
);
    wire cout_wire;

    full_adder_4bit u1 (.a(a[3:0]), .b(b[3:0]), .s(s[3:0]), .cout(cout_wire) );
    full_adder_4bit u2 (.a(a[7:4]), .b(b[7:4]), .s(s[7:4]), .cout(cout));
endmodule

module full_adder_4bit(
    input [3:0] a, // bit -> vector expression [MSB:LSB]
    input [3:0] b,
   // input cin ,
    output [3:0] s,
    output cout 
);

    wire [3:1] c;

    full_adder_1bit u1 (.a(a[0]), .b(b[0]), .cin(1'b0), .s(s[0]), .c(c[1]));  // bit designate 
    full_adder_1bit u2 (.a(a[1]), .b(b[1]), .cin(c[1]), .s(s[1]), .c(c[2]));
    full_adder_1bit u3 (.a(a[2]), .b(b[2]), .cin(c[2]), .s(s[2]), .c(c[3]));
    full_adder_1bit u4 (.a(a[3]), .b(b[3]), .cin(c[3]), .s(s[3]), .c(cout));

endmodule

module full_adder_1bit(
    input a,b,cin,
    output s,c
);
    wire s1_wire,c1_wire,c2_wire; 

    or (c, c1_wire, c2_wire);

    half_adder u1 (.a(a), .b(b), .s(s1_wire), .c(c1_wire) ); 
    half_adder u2 (.a(s1_wire), .b(cin), .s(s), .c(c2_wire));

endmodule

module half_adder(
    input a,b,  // lbit wire
    output s,c
);

    //assign s = a ^ b;
    //assign c =  a & b;

    // Gate Primitive
    xor (s, a, b); // (출력, 입력1, 입력2, ....)
    and (c, a, b);

endmodule
