`define SIM 
module uart_rx(
	input 			clk			,
	input			 rst_n		,
	
	input		            	 rx232_rx	,
	output	reg   [7:0]   rx_data	,
	output	reg		         po_flag

);
`ifndef SIM
parameter    BAUD_END  = 5208 - 1 		;
`else
parameter    BAUD_END = 56 				;
`endif
parameter	 BAUD_M    = BAUD_END/2 - 1 ;
parameter	 BIT_END   = 8				;
reg     rx_t							;
reg		rx_tt							;
reg 	rx_ttt							;
reg		rx_flag							;
reg  [12:0]   baud_cnt					;
reg   [3:0]   bit_cnt					;
reg 		  bit_flag					;
			
wire 	neg_flag						;
assign	neg_flag = ~rx_tt & rx_ttt		;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rx_t    <= 0			;
		rx_tt	<= 0			;
		rx_ttt  <= 0			;
	end
	else begin
		rx_t    <= rx232_rx  	;
		rx_tt	<= rx_t			;
		rx_ttt	<= rx_tt 		;
	end
		
end 


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		baud_cnt <=0			;
	end
	else if(baud_cnt==BAUD_END)begin
		baud_cnt <= 0			;
	end
	else if(rx_flag)begin
		baud_cnt <= baud_cnt + 1;
	end
	else
		baud_cnt <= 0			;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bit_flag <=0;
	end
	else if(baud_cnt==BAUD_M)begin
		bit_flag <= 1;
	end
	else begin
		bit_flag <= 0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bit_cnt <=0;
	end
	else if(bit_flag==1&&bit_cnt==BIT_END)begin
		bit_cnt <= 0;
	end
	else if(bit_flag==1)begin
		bit_cnt <= bit_cnt + 1;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		po_flag <=0;
	end
	else if(bit_cnt==BIT_END&&bit_flag==1)begin
		po_flag <= 1;
	end
	else begin
		po_flag <= 0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rx_flag <= 0;
	end
	else if(neg_flag==1)begin
		rx_flag <= 1;
	end
	else if(bit_cnt==0&&baud_cnt==BAUD_END)begin
	    rx_flag <= 0;
	end
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rx_data <=0;
	end
	else if(bit_cnt>=1&&bit_flag==1)begin
		rx_data <= {rx_tt,rx_data[7:1]};
	end
	else begin
		rx_data <= rx_data;
	end
end

endmodule