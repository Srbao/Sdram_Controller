`define SIM 
module uart_tx(
	input 			clk			,
	input			rst_n		,
	
	output	reg		rs232_tx	,
	
	input			tx_trig		,
	input  [ 7:0]	tx_data		
);
`ifndef SIM
parameter    BAUD_END  = 5208 - 1 ;
`else
parameter    BAUD_END = 56 ;
`endif
parameter	 BAUD_M    = BAUD_END/2 - 1   ;
parameter	 BIT_END   = 9 - 1;

reg 	[ 7:0]		tx_data_r	;
reg					tx_flag		;
reg		[12:0]		baud_cnt	;
reg					bit_flag	;
reg		[ 3:0]		bit_cnt		;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		tx_data_r <= 0;
	else if(tx_trig==1&&tx_flag==0)
		tx_data_r <= tx_data ;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		baud_cnt <= 0;
	else if(baud_cnt==BAUD_END)
		baud_cnt <= 0;
	else if(tx_flag==1)
		baud_cnt <= baud_cnt + 1;
	else
		baud_cnt <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		bit_flag <= 0;
	else if(baud_cnt==BAUD_END)
		bit_flag <= 1;
	else
		bit_flag <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		bit_cnt <= 0;
	else if(bit_cnt==BIT_END&&bit_flag==1)
		bit_cnt <= 0;
	else if(bit_flag==1)
		bit_cnt <= bit_cnt + 1;
end	

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		tx_flag <= 0;
	else if(tx_trig==1)
		tx_flag <= 1;
	else if(bit_cnt==BIT_END&&bit_flag==1)
		tx_flag <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		rs232_tx <= 0;
	else if(tx_flag==1)
		case(bit_cnt)
			0:		rs232_tx <= 0;
			1:		rs232_tx <= tx_data_r[0];
			2:		rs232_tx <= tx_data_r[1];
			3:		rs232_tx <= tx_data_r[2];
			4:		rs232_tx <= tx_data_r[3];
			5:		rs232_tx <= tx_data_r[4];
			6:		rs232_tx <= tx_data_r[5];
			7:		rs232_tx <= tx_data_r[6];
			8:		rs232_tx <= tx_data_r[7];
			default: rs232_tx <= 1;
		endcase	
end


endmodule