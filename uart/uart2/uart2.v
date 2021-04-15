module uart2(
	input clk,
	input rst,
	input rxd,
	output data_error,
	output txd
);

wire [7:0] data;
wire receive_ack;

uart_tx uart_tx(
	clk, rst, receive_ack, data, txd
);

uart_rx uart_rx(
	rxd, clk, rst, data, receive_ack, data_error
);

endmodule
