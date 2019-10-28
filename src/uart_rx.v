module uart_tx(
	input 			clk			,
	input			rst_n		,
	
	input			uart_rx	,
	output	[7:0]   uart_data	,
	output			uart_done

);

parameter 		CNT = 5000_0000;
parameter		BON = CNT / 9600;
parameter		BON_M = BON /2;
reg 	uart_rx_r0;
reg     uart_rx_r1;
wire    neg_flag ;
assign neg_flag = (uart_rx_r0==0&&uart_rx_r1==1)?1:0;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		uart_rx_r0 <= 0
		uart_rx_r1 <= 0;
	end
	else begin
		uart_rx_r0 <= uart_rx ;
		uart_rx_r1 <= uart_rx_r0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		flag <= 0;
	else if(neg_flag==1)
		flag <= 1;
	else if(CNT_END)
		flag <= 0;
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt <= 0;
	else if()
	
end
