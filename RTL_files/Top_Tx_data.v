module Top_Tx_data (
    input Axi0Clk,
    input uart_clk ,
    input rst ,
    input [7:0] fifo_data_in,
    output [7:0] tx_out_data,
    output [7:0] rd_tx_out,
    output wr_tx,
    output e_tx,
    output rd_tx ,
    output tx_done,
    output tx_valid,
    output f_tx_out
);

wire full_tx ,wr_tx, e_tx, rd_tx, tx_ready, rd_tx;
wire tx_done, tx_valid ;
wire [7:0]  w_count;
wire [7:0] tx_out_data ;
wire [7:0] rd_tx_out ;


fsm_tx 
f_t_1(
    .clk (Axi0Clk),
    .rst (1'b1),
    .full_flag (full_tx),
    .w_en (wr_tx) 
);

ASYNCH_FIFO_TX
fifo_tx(
     .i_WCLK (Axi0Clk) , 
     .i_write_en (wr_tx) , 
     .i_wrstn (rst)  , 
     .i_WDATA (fifo_data_in) , 
     .o_fifo_full () , 
     .o_fifo_almst_full (full_tx) ,

     .i_RCLK (uart_clk) , 
     .i_read_en (rd_tx),
     //input  i_mem_enable , 
     .i_rrstn (rst) ,
     .o_RDATA (tx_out_data),
    // .o_fifo_empty() , 
     .o_fifo_empty (e_tx), 
     .o_FIFO_CNT_WR (w_count) 
);


connector_tx_reg
tx_reg_inst(
    .i_clk (uart_clk) , 
    .i_rstn (rst),  
    .empty (e_tx),
    .i_fifo_data (tx_out_data), 
    .uart_tx_done (tx_done) ,
    .o_rd_tx (rd_tx),
    .uart_tx_valid (tx_valid) ,  
    .o_TX_DATA_IN (rd_tx_out),
    .w_count  (w_count)
);


UART_TX(
    .i_clk (uart_clk) , 
    .i_rst_n (rst) , 
    .i_TX_valid (tx_valid), 
    .i_TX_DATA (rd_tx_out) ,  ///data to be transmitted from FPGA TO PC ///
    .o_TX_uart (f_tx_out) ,                    ////serial output data to be streamed (Parallel to Serial)to the PC ///
    .o_TX_active () ,                 ///output showing data transmission is active //
     .o_TX (tx_done)                   //output showing data is successfully transmitted ///, 
);
   

endmodule

