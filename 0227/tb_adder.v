`timescale 1ns / 1ps

module tb_full_adder_4bit;
    
    reg [3:0] a; 
    reg [3:0] b;
    reg cin;  // have to store value
    
    wire [3:0] s; 
    wire  cout; 
    
    full_adder_4bit u1 (.a(a), .b(b), .cin(cin), .s(s), .cout(cout));
    
    initial
    begin
        #10;    a[0] = 0; b[0] = 0; cin=0;  // #: delay 10 (ns) <- time declare in timescale
                a[1] = 0; b[1] = 0; cin=0;
                a[2] = 0; b[2] = 0; cin=0;
                a[3] = 0; b[3] = 0; cin=0;
                
        #10;    a[0] = 0; b[0] = 0; cin=1;  // #: delay 10 (ns) <- time declare in timescale
                a[1] = 0; b[1] = 0; cin=1;
                a[2] = 0; b[2] = 0; cin=1;
                a[3] = 0; b[3] = 0; cin=1;
                
        #10;    a[0] = 0; b[0] = 0; cin=0;  // #: delay 10 (ns) <- time declare in timescale
                a[1] = 1; b[1] = 0; cin=0;
                a[2] = 1; b[2] = 1; cin=0;
                a[3] = 0; b[3] = 1; cin=0;
        
        #10;    a[0] = 0; b[0] = 0; cin=1;  // #: delay 10 (ns) <- time declare in timescale
                a[1] = 1; b[1] = 0; cin=1;
                a[2] = 1; b[2] = 1; cin=1;
                a[3] = 0; b[3] = 1; cin=1;
                
        #10;    a[0] = 0; b[0] = 0; cin=0;  // #: delay 10 (ns) <- time declare in timescale
                a[1] = 0; b[1] = 1; cin=0;
                a[2] = 1; b[2] = 0; cin=1;
                a[3] = 0; b[3] = 0; cin=0;
        
        #10;    a[0] = 0; b[0] = 0; cin=1;  // #: delay 10 (ns) <- time declare in timescale
                a[1] = 1; b[1] = 1; cin=0;
                a[2] = 1; b[2] = 0; cin=1;
                a[3] = 1; b[3] = 1; cin=0;
        
        $stop;
    end
   
endmodule
