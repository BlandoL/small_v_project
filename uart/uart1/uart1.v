module uart_top(
    input rxd,
    input clk,
    output txd
);

    wire clk_9600;
    wire receive_ack;
    wire [7:0] data;

    uart_tx uart_tx(
        data, clk_9600, receive_ack, txd
    );

    uart_rx uart_rx(
        rxd, clk_9600, receive_ack, data
    );

    clk_div clk_div(
        clk,
        clk_9600
    );

endmodule

module uart_rx(
    input rxd,
    input clk,
    output receive_ack,
    output reg [7:0] data_i
);

    localparam [1:0] idle=0, receive=1, receive_end=2;
    reg [1:0] cs, ns;
    reg [4:0] cnt;
    reg data_out_temp;

    always@(posedge clk)begin
        cs<=ns;
    end

    always@(*)begin
        ns=cs;
        case(cs)
            idle: ns=rxd ? idle:receive;
            receive: ns=(cnt==7) ? receive_end:receive;
            receive_end: ns=idle;
            default: ns=idle;
        endcase
    end

    always@(posedge clk)begin
        if(cs==receive) cnt<=cnt+1'b1;
        else if(cs==idle|cs==receive_end) cnt<=0;
    end

    always@(posedge clk)begin
        if(cs==receive)begin
            data_i[6:0]<=data_i[7:1];
            data_i[7]<=rxd;
        end
    end

    assign receive_ack=(cs==receive_end)?1'b1:1'b0;
endmodule

module uart_tx(
    input [7:0] data_out,
    input clk,
    /*input rst,*/
    input receive_ack,
    output reg txd
);
    localparam [1:0] idle = 0, send_start=1,send_data=2,send_end=3;
    reg [1:0] cs,ns;
    reg [4:0] cnt;
    reg [7:0] data_out_temp;

    always@(posedge clk)begin
        cs<=ns;
    end

    always@(*)begin
        ns=cs;
        case(cs)
            idle: ns=receive_ack? send_start: idle;
            send_start: ns= send_data;
            send_data: ns=(cnt==7)? send_end: send_data;
            send_end: ns=receive_ack? send_start: idle;
            default: ns=idle;
        endcase
    end

    always@(posedge clk)begin
        if(cs==send_data) cnt<=cnt+1'b1;
        else if(cs==idle|cs==send_end) cnt<=0;
    end

    always@(posedge clk)begin
        if(cs==send_start) data_out_temp<=data_out;
        else if(cs==send_data) data_out_temp[6:0]<=data_out_temp[7:1];
    end

    always@(posedge clk)begin
        if(cs==send_start) txd<=0;
        else if(cs==send_data) txd<=data_out_temp[0];
        else if(cs==send_end) txd<=1'b1;
    end

endmodule

module clk_div(
    input clk,
    output reg clk_out
);
    localparam Baud_rate=9600;
    localparam div_num=2;

    reg [15:0] num;

    always@(posedge clk)begin
        if(num==div_num)begin
            num<=0;
            clk_out<=1'b1;
        end
        else begin
            num<=num+1'b1;
            clk_out<=0;
        end
    end

endmodule