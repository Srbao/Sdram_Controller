module sdram_init(
	input						clk		,
	input						rst_n	,
	
	output	reg	   [ 3:0]		cmd_reg		,
	output	wire   [11:0]		sdram_addr	,
	output	wire				flag_init_end

);

localparam		NOP  = 4'b0111;
localparam		PRE	 = 4'b0010;
localparam		AREF = 4'b0001;
localparam		MSET = 4'b0000;	

parameter 	        CNT_200US = 10_000;
reg 	[ 13:0]		cnt_200us  ;
wire				flag_200us ;
reg     [ 3:0]		cnt_cmd	   ;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_200us <= 0;
	else if(flag_200us==0)
		cnt_200us <= cnt_200us + 1;
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_cmd <=0;
	else if(flag_200us==1&&flag_init_end==0)
		cnt_cmd <= cnt_cmd + 1;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cmd_reg <= NOP;
	else if(flag_200us==1)
		case(cnt_cmd)
			0:			cmd_reg <= PRE;
			1:			cmd_reg <= AREF;
			5:			cmd_reg <= AREF;
			9:			cmd_reg <= MSET;
			default:	cmd_reg <= NOP ;
		endcase
end

assign 	sdram_addr	= 	(cmd_reg==MSET)?12'b0000_0011_0010:12'b0100_0000_0000;
assign  flag_init_end = (cnt_cmd >= 10)?1:0;
assign 	flag_200us = (cnt_200us==CNT_200US)?1:0;

endmodule













