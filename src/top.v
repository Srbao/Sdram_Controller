module top(
	input	    	clk 	    ,
	input		    rst_n	    ,
	
	input		    rs232_rx    ,
	output	 wire	rs232_tx	
);

wire 	[ 7:0]   	rx_data		;
wire 			   	tx_trig     ;

 uart_rx uart_rx_inst(
	   .clk			    (clk		),
	   .rst_n		    (rst_n	),
	   .rx232_rx	    (rx232_rx),
	   .rx_data	       (rx_data	 ),
	   .po_flag        (tx_trig  )

);
 uart_tx  uart_tx_inst(
	.clk		   (clk	),
	.rst_n		(rst_n	),
				 		
	.rs232_tx	(rs232_tx),
				 		
	.tx_trig	   (tx_trig),
	.tx_data	   (rx_data)
);



endmodule
