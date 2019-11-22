module 	sdram_aref(
	//system signals
	input			clk			,
	input			rst_n		,
	//communicate with ARBIT
	input			ref_en		,
	output	reg		ref_req		,
	output			flag_ref_end,
	//others
	output	reg [ 3:0]	aref_cmd,
	output	wire[11:0]	sdram_addr,
    input               flag_init_end
);

//=========================================================\
//***********Define Parameter and Internal Signals******
//=========================================================/
localparam	 DELAY_15US		=		750 - 1		;
localparam   CMD_AREF       =       4'b0001     ;
localparam   CMD_NOP        =       4'b0111     ;
localparam   CMD_PRE        =       4'b0010     ;


reg		[ 3:0]			cmd_cnt					;
reg		[ 9:0]			ref_cnt					;
reg                     flag_ref                ;
//=========================================================\
//*******************Main	Code***************************
//=========================================================/
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ref_cnt <= 0;
    end
    else if(ref_cnt>=DELAY_15US)begin
        ref_cnt <= 'd0;
    end
    else if(flag_init_end=='d1)begin
        ref_cnt <= ref_cnt + 1  ;
    end
end



always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        flag_ref <= 0;
    end
    else if(flag_ref_end)begin
        flag_ref <= 0;
    end
    else if(ref_en)begin
        flag_ref <= 1;
    end
end


always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        cmd_cnt <=  'd0     ;
    end
    else if(flag_ref==1'b1)begin
        cmd_cnt <=  cmd_cnt + 1'b1;
    end
    else begin
        cmd_cnt <= 'd0      ;
    end
end

always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        ref_req <=  'd0     ;
    end
    else if(ref_en==1'b1)begin
        ref_req <=  1'b0;
    end
    else if(ref_cnt >= DELAY_15US)begin
        ref_req <= 'b1      ;
    end
end



always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        aref_cmd       <=       CMD_NOP     ;
    end
    else if(cmd_cnt=='d2)begin
		aref_cmd		<=	CMD_AREF		;
    end
	  else begin
		aref_cmd		<=	CMD_NOP;
	  end
end

assign  sdram_addr  =   12'b0100_0000_0000                  ;
//assign  ref_req     =   (ref_cnt >= DELAY_15US)?1'b1:1'b0  ;
assign  flag_ref_end =	(cmd_cnt >= 'd3)?1:0           ;
	
endmodule











