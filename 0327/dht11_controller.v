`timescale 1ns/1ns

module dht11_controller(
    input clk,          // 100mhz on fpga oscillator
    input reset,        // reset btn
    input btn_start,    // start trigger
    input tick,         // 1us tick
    inout dht_io,       // 1-wire data path

    output [7:0] humidity, 
    output [7:0] temperature,
    output [3:0] led, // state 변화 확인을 위한 led
    output led_checksum
);
    parameter   SEND            = 1800, // FPGA to DHT11 trigger send
                WAIT_RESPONSE   = 3 ,   // wait for responce from dht11
                SYNC            = 8,    // wait for transieve
                DATA_COMMON     = 5,  // common low with s  
                DATA_STANDARD   = 4,  // 40us 기준  -> 짧으면 0, 길면 1
                STOP            = 5,  // 데이터 다 받고 다시 high 상태 가기전 대기시간
                BIT_DHT11       = 40, // 40비트 데이터비트
                TIME_OUT        = 2000;

    // 1. state definition
    localparam  IDLE            = 0, // 초기상태
                START           = 1, // 입력 trigger
                WAIT            = 2, // 응답 대기
            //  READ    = 3;
                SYNC_LOW        = 3, // dht11로 부터 응답 받음
                SYNC_HIGH       = 4, // 데이터 송수신전 대기
                DATA_SYNC       = 5, // 온습도 데이터(40bit) 송수신
                DATA_DECISION   = 6, // 통신 종료후 다시 high로로
                DONE            = 7; // 데이터 송수신 종료 후 다시 PULL UP HIGH 상태로로

    // register for CU
    reg [2:0] state, next;
    reg [$clog2(TIME_OUT)-1:0] count_reg, count_next;
    
    reg io_out_reg, io_out_next;    // 
    reg io_oe_reg, io_oe_next;      // for 3-state buffer enable 
    reg led_ind_reg, led_ind_next;  // led indicator for check appropriate

    reg [5:0] bit_count_reg, bit_count_next;  // for count 40 bit 
    reg [39:0] data_reg, data_next; // store data register

    reg led_check_reg, led_check_next;
    assign led_checksum = led_check_reg;

    // out 3 state on/off
    assign dht_io = (io_oe_reg) ? io_out_reg :1'bz;

    // led for configure state
    assign led  = {led_ind_reg,state};

    // assign humidity , temperature
    assign humidity = data_reg [39:32]; // data 중 습도 정수부분
    assign temperature = data_reg [23:16]; // data 중 온도 정수 부분

    wire [7:0] checksum;
    assign checksum = data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8];

    // 2. for continue next state
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state               <= IDLE;
            count_reg           <= 0;
            bit_count_reg       <= 0;  
            data_reg            <= 0;  
            io_out_reg          <= 1'b1;
            io_oe_reg           <= 0;
            led_ind_reg         <= 0;
            led_check_reg       <= 1'b0;
        end
        else begin
            state               <= next;
            count_reg           <= count_next;
            bit_count_reg       <= bit_count_next;  
            data_reg            <= data_next; 
            io_out_reg          <= io_out_next;
            io_oe_reg           <= io_oe_next;
            led_ind_reg         <= led_ind_next;
            led_check_reg       <= led_check_next;
        end
    end
    
    // 3. output combinational logic
    always @(*) begin
        next                 = state;
        count_next           = count_reg;
        io_out_next          = io_out_reg;
        io_oe_next           = io_oe_reg;
        bit_count_next       = bit_count_reg;
        data_next            = data_reg;
        led_ind_next         = 0;
        led_check_next       = 1'b0;

        case (state)
            IDLE : begin // 0
                io_out_next = 1'b1;
                io_oe_next  = 1'b1;

                if (btn_start == 1'b1) begin
                    next       = START;
                    count_next = 0;
                end
            end

            START : begin // 1
                io_out_next = 1'b0;

                if(tick == 1'b1)begin
                    if(count_reg == SEND -1) begin                        
                        next       = WAIT;
                        count_next = 0;
                    end
                    else begin                     
                        count_next = count_reg + 1;
                    end
                end
            end

            WAIT : begin // 2
                io_out_next = 1'b1;

                if(tick == 1'b1) begin
                    if(count_reg == WAIT_RESPONSE - 1) begin
                        next       = SYNC_LOW;
                        io_oe_next = 1'b0;
                        count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end
/* for middle testbench
            READ : begin
                // io oe change
                // output open - high z
                io_oe_next = 1'b0;

                if(tick == 1'b1) begin
                    if(count_reg == TIME_OUT) begin
                        next       = IDLE;
                        count_next = 0;
                    end
                    else begin
                        count_next = count_reg +1;
                    end
                end

                if (dht_io == 1'b0) begin
                    led_ind_next = 1'b1;
                end
                else begin
                    led_ind_next = 1'b0;
                end
                
            end
*/
            SYNC_LOW : begin // 3
                if(tick == 1'b1) begin
                    if(count_reg == 1) begin
                        if(dht_io == 1'b1) begin
                            next = SYNC_HIGH;
                        end
                    count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end

            SYNC_HIGH : begin // 4
                if(tick == 1'b1) begin
                    if(count_reg == 1) begin
                        if(dht_io == 1'b0) begin
                            next = DATA_SYNC;
                        end
                    count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end
            
            DATA_SYNC : begin // 5
                if(tick == 1'b1) begin
                    if(count_reg == 1) begin
                        if(dht_io == 1'b1) begin
                            next = DATA_DECISION;
                        end
                    count_next = 0;
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end

           DATA_DECISION: begin // 6
                if (tick == 1'b1) begin 
                    if (dht_io == 1'b1) begin
                        count_next = count_reg + 1;  // HIGH 지속 시간 측정\
                        led_ind_next = 1'b1;
                    end
                    else begin
                        led_ind_next = 1'b0;
                        if (count_reg <= DATA_STANDARD - 1) begin
                            data_next = {data_reg[38:0], 1'b0};  // 40µs보다 짧으면 0
                        end
                        else begin
                            data_next = {data_reg[38:0], 1'b1};  // 40µs보다 길면 1
                        end

                        bit_count_next = bit_count_reg + 1;
                        count_next = 0;  // 다음 비트를 위해 카운터 초기화

                        if (bit_count_reg == BIT_DHT11 - 1) begin
                            next = DONE;  // 40비트 수집 완료 후 DONE 상태로 이동
                            bit_count_next = 0;
                        end
                        else begin
                            next = DATA_SYNC;  // 다음 비트 수집을 위해 DATA_SYNC로 다시 이동
                        end
                    end
                end
            end

            DONE : begin // 7
                if (tick == 1'b1) begin
                    if(count_reg == STOP - 1) begin

                        if ((data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]) & 8'hFF == data_reg[7:0]) begin
                            next = IDLE;
                            io_out_next = 1'b1;
                            io_oe_next = 1'b1;  // pull-up 유지
                            count_next = 0;
                            led_check_next = 1'b0;
                        end 
                        else begin
                            next = IDLE;
                            io_out_next = 1'b1;
                            io_oe_next = 1'b1;  // pull-up 유지
                            count_next = 0;
                            led_check_next = 1'b1;
                        end
                    end
                    else begin
                        count_next = count_reg + 1;
                    end
                end
            end
        endcase        
    end
endmodule