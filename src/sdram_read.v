module  sdram_read(
    // system   signals
    input                clk         ,
    input                rst_n       ,
    //Communication with    TOP
    input                rd_en       ,
    output   wire        rd_req      ,
    output   reg         flag_rd_end ,
    //Others
    input                ref_req     ,
    input                rd_trig     ,
    //write interfaces
    output  reg [ 3:0]   rd_cmd      ,
    output  reg [11:0]   rd_addr     ,
    output  wire [ 1:0]  bank_addr   

    //output	reg  [15:0]	  wr_data
);

//Define    state
localparam      S_IDLE      =   5'b0_0001   ;
localparam      S_REQ       =   5'b0_0010   ;
localparam      S_ACT       =   5'b0_0100   ;
localparam      S_RD        =   5'b0_1000   ;
localparam		S_PRE		=	5'b1_0000	;
//SDRAM	command
localparam		CMD_NOP  = 4'b0111;
localparam		CMD_PRE	 = 4'b0010;
localparam		CMD_AREF = 4'b0001;
localparam		CMD_ACT  = 4'b0011;	
localparam		CMD_RD   = 4'b0101;	

reg  [ 4:0]         state                   ;
reg                 flag_rd                 ;
//================================================
reg                 flag_act_end            ;
reg                 flag_pre_end            ;
reg                 sd_row_end              ;
reg  [ 1:0]         burst_cnt               ;
reg  [ 1:0]         burst_cnt_t             ;
reg                 rd_data_end             ;
//--------------------------------------------------
reg     [ 3:0]      act_cnt                 ;
reg     [ 3:0]      break_cnt               ;
reg     [ 6:0]      col_cnt                 ;
//---------------------------------------------------
reg     [11:0]      row_addr                ;
wire    [ 8:0]      col_addr                ;

//=================================================
//******************Main  Code*********************
//==================================================
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_rd <= 0;
    end
    else if(rd_trig==1'b1 && flag_rd == 1'b0)begin
        flag_rd <= 1'b1;
    end
    else if(rd_data_end==1'b1)begin
        flag_rd <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		burst_cnt	<=	1'd0	;
	else if(state == S_RD)
		burst_cnt	<=	burst_cnt	+	1;
	else
		burst_cnt	<=	1'd0	;
end

always @(posedge clk)begin
		burst_cnt_t	<=	burst_cnt	;	
end



//----------------STATE---------------------------------
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state   <=  S_IDLE  ;
    end
    else begin
        case(state)
                S_IDLE:
                        if(rd_trig == 1'b1)
                                state   <=  S_REQ   ;
                        else
                                state   <=  S_IDLE  ;
                S_REQ:
                        if(rd_en == 1'b1)
                                state   <=  S_ACT   ;
                        else    
                                state   <=  S_REQ   ;
                S_ACT:
                        if(flag_act_end ==1'b1)
                                state   <=  S_RD    ;
                        else    
                                state   <=  S_ACT   ;
                S_RD:
                        if(rd_data_end==1'b1)
                                state   <=  S_PRE   ;
                        else if(ref_req==1'b1&&burst_cnt_t=='d2&&flag_rd==1'b1)
                                state   <=  S_PRE   ;
                        else if(sd_row_end==1'd1&&flag_rd==1'b1)
                                state   <=  S_PRE   ;
                S_PRE:
                        if(ref_req==1'b1&&flag_rd==1'b1)
                                state   <=  S_REQ   ;
                        else if(flag_pre_end==1'b1&&flag_rd==1'b1)
                                state   <=  S_ACT   ;
                        else if(rd_data_end == 1'b1)
                                state   <=  S_IDLE  ;
                default:
                                state   <=  S_IDLE  ;
                    
        endcase
    end
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		rd_cmd	<=	CMD_NOP	;
	else case(state)
			S_ACT:
					if(act_cnt == 'd0)
						rd_cmd <= CMD_ACT	;
					else
						rd_cmd <= CMD_NOP	;
			S_RD:	
					if(burst_cnt == 'd0)
						rd_cmd <= CMD_RD	;
					else
						rd_cmd <= CMD_NOP	;
			S_PRE:
					if(break_cnt =='d0)
						rd_cmd	<=	CMD_PRE	;
					else
						rd_cmd	<=	CMD_NOP	;
			default:
						rd_cmd  <=  CMD_NOP  ;
	endcase
end

always @(*)begin
    case(state)
		S_ACT:
				if(act_cnt=='d0)
					rd_addr <= row_addr	;
		S_RD:	
				rd_addr <= {3'b000,col_addr}	;
		S_PRE:
				if(break_cnt == 'd0)
					rd_addr	<=	{12'b0100_0000_0000};
	endcase
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		flag_act_end	<=	1'b0;
	else if(act_cnt=='d3)
		flag_act_end	<=	1'b1;  
	else
		flag_act_end	<=	1'b0;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		act_cnt	<=	'd0				;
	else if(state==S_ACT)
		act_cnt <=	act_cnt	+	1	;                                         
	else
		act_cnt	<=	1'b0			;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		flag_rd_end	<=	1'b0	;
	else if(state==S_PRE && ref_req == 1'b1||state==S_PRE&&rd_data_end==1)
		flag_rd_end	<=	1'b1	;
	else
		flag_rd_end	<=	1'b0	;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		flag_pre_end	<=	1'b0	;
	else if(break_cnt=='d3)
		flag_pre_end	<=	1'b1	;
	else
		flag_pre_end	<=	1'b0	;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		break_cnt	<=	1'd0	;
	else if(state==S_PRE)
		break_cnt	<=	break_cnt	+	1;
	else
		break_cnt	<=	1'd0	;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
		rd_data_end	<=	1'b0	;
	else if(row_addr == 'd2 && col_addr == 'd511)    //
		rd_data_end <=	1'b1	;
	else
		rd_data_end	<=	1'b0	;
end



always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
			col_cnt	<=	'd0	;
	else if(col_addr=='d511)
			col_cnt <=	 'd0;
	else if(burst_cnt_t=='d3)
			col_cnt <= col_cnt + 1;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
			sd_row_end	<=	'b0	;
	else if(col_addr=='d509)
			sd_row_end <=	 'b1;
	else 
			sd_row_end <= 'b0;
end
//==========================
/* always @(*)begin
	case(burst_cnt_t)
			0:		wr_data	<=	'd3		;
			1:		wr_data	<=	'd5		;
			2:		wr_data	<=	'd7		;
			3:		wr_data	<=	'd9		;
	endcase
end */
//=========================


always @(posedge clk or negedge rst_n)begin
	if(rst_n==1'b0)
			row_addr	<=	'd0	;
	else if(sd_row_end==1'b1)
			row_addr	<=	row_addr	+	1;
end

assign	col_addr	=	{col_cnt,burst_cnt_t}	;
assign	bank_addr	=	2'b00;
assign  rd_req      =   state[1]	;


endmodule
