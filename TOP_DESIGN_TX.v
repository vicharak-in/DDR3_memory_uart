//////////////////////////////////////////////////////////////////////
// This module contains the top module of the transmiter side.  This module takes the data 
// that is read from dram and then write the data into fifo and the data is going to be read 
//from fifo and transmit through the UART transmitter.

`timescale 1ns / 1ps

module TOP_DESIGN_TX(
    input uart_clk,
    input AXI_clk,
    input i_rst,
    input rvalid_tx,           //The signal which activates the process of this top design
    input [255:0]data_in,      //The data that is read from the dram
  //  input rready_tx,
    output [7:0] tx_out,       //Data to be transmitted though the transmitter
    output done_tx ,           //Signal becomes high whenever the data of 1 byte is transmitted through the transmitter
    output tx_serial_en        //The data that is transmitting bit by bit through this signal
);

wire f_full, wr_en, read_en, emptyflag ;
wire [255:0] data1, data2, data3 ;
wire [7:0] tx_data, data4;
wire tx_valid, tx_active ;
wire [7:0]fifo_wr_cnt;
wire rd_en_tx;
wire flag_tx;
wire load;

 /*
fifo_asynchronous 
TX_FIFO_1(
    .almost_full_o (),
    .prog_full_o (),
    .full_o (f_full),
    .overflow_o(),
    .wr_ack_o(),
    .empty_o(emptyflag),
    .almost_empty_o(),
    .underflow_o(),
    .rd_valid_o(),
    .wr_clk_i(AXI_clk),
    .rd_clk_i(uart_clk),
    .wr_en_i(wr_en),
    .rd_en_i(read_en),
    .wdata(data1),
    .wr_datacount_o(),
    .rst_busy(),
    .rdata(data2),
    .rd_datacount_o(),
    .a_rst_i(i_rst)
);*/

WR_FSM_TX
 WR_FSM_TX1(
     .clk(AXI_clk) ,     
     .rst(i_rst) , 
     .rvalid(rvalid_tx) ,  
   //.rready(rready_tx) ,
     .fifo_full(f_full),
     .data_in(data_in),
     .wr_en(wr_en),
     .fifo_data(data1)         
 );

ASYNCH_FIFO_TX
fifo_tx(
     .i_WCLK (AXI_clk) , 
     .i_write_en (wr_en) , 
     .i_wrstn (i_rst)  , 
     .i_WDATA (data1) , 
     .o_fifo_full (f_full) , 
     .o_fifo_almst_full () ,

     .i_RCLK (uart_clk) , 
     .i_read_en (read_en),
     //input  i_mem_enable , 
     .i_rrstn (i_rst) ,
     .o_RDATA (data2),
    // .o_fifo_empty() , 
     .o_fifo_empty (emptyflag), 
     .o_FIFO_CNT_WR (fifo_wr_cnt) 
);

RD_FSM_TX
 RD_FSM_TX1(
     .clk(uart_clk) ,     
     .rst(i_rst) , 
     .fifo_empty(emptyflag),
     .in_data(data2),
     .rd_en(read_en),
     .load(load),
     .data_reg(),
     .out_data(data3)    
 );

   
data_shifter
 Reg_Rd_TX1(
     .clk(uart_clk) ,     
     .rstn(i_rst) , 
     //.rvalid(rvalid_tx),
     .load(load),
     .data_in(data3),
     .flag(flag_tx),
     .read(read_en_tx),
     .data_out(data4)  
  );

TRANSMITTER_FSM
 FSM_TX1(
     .clk(uart_clk) ,     
     .rstn(i_rst) , 
     .flag(flag_tx) ,  
     .tx_done(done_tx),
     .fifo_data(data4),
     .o_rden_fifo(read_en_tx),
     .o_tx_data(tx_data),
     .tx_valid(tx_valid)      
 );
 
 UART_TRANSMITTER
 UART_TX1(
     .i_Clock(uart_clk) ,     
     .i_Rst(i_rst) , 
     .i_TX_Valid(tx_valid) ,  
     .i_TX_Byte(tx_data),
     .o_TX_Active(tx_active),
     .o_TX_Serial(tx_serial_en),
     .o_TX_Done(done_tx)     
 );
 
 endmodule

