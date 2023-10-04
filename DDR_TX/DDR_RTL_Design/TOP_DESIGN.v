`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2023 11:58:21
// Design Name: 
// Module Name: TOP_DESIGN
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP_DESIGN(
    input i_clk,
    input axi_clk,
   // input i_rst,
    input data,
    input i_trig,
    output [255:0] s_out,
    output [31:0] mux_reg_data,
    output blink_led
);


wire r_valid ;
wire f_full, wr_en, e_flag, read_en ;
wire tx_done, tx_rdy, tx_valid ;
wire [7:0] o_data1 , o_data2, o_data3;
wire [31:0] o_data4;
wire  cnt;


UART_Rx
 UART_rx(
     .i_clk(i_clk) ,     
     .i_Rx_serial(data) , 
     .o_RX_DV(r_valid) ,  
     .o_RX(o_data1)      
 );
 
UART_Rx_FSM
   FSM_1(
        .i_clk(i_clk) , 
        .i_rstn(1'b1) ,
       // .i_rstn(i_rst) ,
       // input i_ack , 
        .fifo_full(f_full) , 
        .rx_valid(r_valid) , 
        .rx_data(o_data1) , 
        .o_wren_fifo(wr_en)  ,
        .o_rx_data(o_data2)   
        //output wire  o_request 
);

ASYNCH_FIFO
    fifo_1(
         .i_WCLK(i_clk) , 
         .i_write_en(wr_en) , 
        // .i_wrstn(i_rst)  , 
         .i_wrstn(1'b1)  , 
         .i_WDATA(o_data2) , 
         .o_fifo_full() , 
         .o_fifo_almst_full(f_full) ,
        
         .i_RCLK(axi_clk) , 
         .i_read_en(read_en) ,
        // .i_rrstn(i_rst) ,
         .i_rrstn(1'b1) ,
         .o_RDATA(o_data3),
         .o_fifo_empty(e_flag) 
        // .o_FIFO_CNT_WR(w_cnt) 
        // .o_FIFO_CNT_RD(r_cnt)  
);

Wr_FSM 
    fsm_shift(
        .axi_clk (axi_clk),
        .rst (1'b1),
        .i_trig(i_trig),
        .fifo_empty (e_flag),
        .read_en (read_en),
        .i_data (o_data3),
        .dout1 (o_data4),
        .count (cnt)
);

Mux_8x1
    m_1(
        .clk(axi_clk),
        .rst(1'b1),
        .input_data(o_data4),
        .register (s_out),
        .i_count (cnt),
        .test_reg (mux_reg_data),
        .check_data (blink_led)
);

/*uart_tx_fsm_data
tx_fsm(
    .i_clk(axi_clk) , 
 //   .i_rstn(i_rst) , 
    .i_rstn(1'b1) , 
    //.i_fifo_empty(empty) , 
    .i_uart_tx_done(tx_done) ,                       // while streaming  1 byte on uart , another byte could be loaded which would be processed later when uart_tx_data_valid and ready signal handshake (both high at same time)
    .i_uart_tx_rdy(tx_rdy) ,                    // checks whether uart has ready to accept  the data 
  //  .o_rd_en(r_en1)    ,                     /// read enable FIFO 
    //.o_rd_en(re)    ,                     /// read enable FIFO 
    .o_ld_en()  ,                     /// enable the data register 
    .o_tx_data_valid(tx_valid)   ,              /// valid data is loaded from FIFO .. 
    .wr_cnt(cnt)
 );
 
uart_tx_data
UART_TX(
    .i_clk(axi_clk) , 
 //   .i_rst_n(i_rst) , 
    .i_rst_n(1'b1) , 
    .i_TX_valid(tx_valid) , 
    .i_TX_DATA(s_out) ,  ///data to be transmitted from FPGA TO PC ///
    .o_TX_uart(out) ,                    ////serial output data to be streamed (Parallel to Serial)to the PC ///
    .o_TX_active()   ,                 ///output showing data transmission is active //
    .o_TX(tx_done)     ,                    //output showing data is successfully transmitted ///, 
    .o_tx_rdy(tx_rdy)  
);*/

endmodule
