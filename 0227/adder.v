// Structural Modeling

// 4bit FA
`timescale 1ns / 1ps

module full_adder_4bit(

    input [3:0] a,b,
    input cin,
          
    output [3:0] s,
    output cout
);

    wire [3:1] c;
    
    full_adder u_FA1(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .c(c[1])
    );
    
    full_adder u_FA2(
        .a(a[1]),
        .b(b[1]),
        .cin(c[1]),
        .s(s[1]),
        .c(c[2])
    );
    
    full_adder u_FA3(
        .a(a[2]),
        .b(b[2]),
        .cin(c[2]),
        .s(s[2]),
        .c(c[3])
    );
    
    full_adder u_FA4(
        .a(a[3]),
        .b(b[3]),
        .cin(c[3]),
        .s(s[3]),
        .c(cout)
    );
    
endmodule 



module full_adder(
    input a, b, cin,
    output s, c
);
    
    wire w_s, w_c1, w_c2;
    
    assign c = w_c1 | w_c2;
      
    half_adder u_HA1 (
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_c1)
    );
    
    half_adder u_HA2 (
        .a(w_s),
        .b(cin),
        .s(s),
        .c(w_c2)
    );
    
endmodule

module half_adder(
    input a,b,
    output s,c
);
    
    assign s =  a ^ b;
    assign c =  a & b;
    
endmodule
