module sdram_top(
	input			clk		   ,
	input			rst_n	   ,
	
	output	wire	       sdram_clk	,
	output	wire	       sdram_cke	,
	output	wire	       sdram_cs_n	,
	output	wire		   sdram_cas_n	,
	output	wire		   sdram_ras_n	,
	output 	wire			sdram_we_n	,
	output	wire  	[ 1:0]	sdram_bank	,
	output	wire	[11:0]	sdram_addr	,
	output	wire	[ 1:0]	sdram_dqm	,
	inout			[15:0]	sdram_dq	
);
		
localparam		IDLE	=	5'b0_0001		;
localparam		ARBIT	=	5'b0_0010		;
localparam		AREF	=	5'b0_0100		;
//init module
wire				flag_init_end			;
wire	[ 3:0]		init_cmd				;
wire	[11:0]		init_addr				;

reg		[ 4:0]		state					;
//refresh	module			
wire				ref_req					;
wire				flag_ref_end			;
reg 				ref_en					;
wire	[ 3:0]		ref_cmd					;
wire	[11:0]		ref_addr				;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state <= IDLE						;
	else case(state)
			IDLE:
					if(flag_init_end==1)
						state <= ARBIT 		;
					else	
						state <= IDLE  		;
			ARBIT:
					if(ref_en==1)
						state <= AREF		;
					else
						state <= ARBIT		;
			AREF:
					if(flag_ref_end==1)
						state <= ARBIT		;
					else	
						state <= AREF		;
			default:
						state <= IDLE	    ;
	
	endcase

end

// ref_en
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		ref_en <= 0;
	else if(state == ARBIT&&ref_req==1)
		ref_en <= 1;
	else
		ref_en <= 0;
end

assign sdram_addr = (state==IDLE)?init_addr:ref_addr;
assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n}= (state==IDLE)?init_cmd:ref_cmd;	
assign sdram_dqm = 2'b00;
assign sdram_cke = 1'b1; 
assign sdram_clk = ~clk;

sdram_init   sdram_init_inst(
	.clk		     (clk          ),
	.rst_n	         (rst_n        ),
								   
	.cmd_reg	     (init_cmd     ),
	.sdram_addr      (init_addr    ),
	.flag_init_end   (flag_init_end)

);

sdram_aref sdram_aref_inst(
	//system signals
	.clk					(clk	   			),
	.rst_n					(rst_n	   			),
	//communicate with ARBIT
	.ref_en					(ref_en				),
	.ref_req			    (ref_req			),
	.flag_ref_end			(flag_ref_end		),
	//others                ()
	.aref_cmd				(ref_cmd			),
	.sdram_addr				(ref_addr			),
    .flag_init_end          (flag_init_end		)
);
endmodule

