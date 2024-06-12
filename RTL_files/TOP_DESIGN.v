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
   // input i_trig,
  //  output e_wr_flag ,
    output [255:0] s_out,
    output [31:0] mux_reg_data,
    output trig_flag
);


wire r_valid ;
wire f_full, wr_en, e_wr_flag, read_en ;
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
         .o_fifo_empty(e_wr_flag) 
        // .o_FIFO_CNT_WR(w_cnt) 
        // .o_FIFO_CNT_RD(r_cnt)  
);

Wr_FSM 
    fsm_shift(
        .axi_clk (axi_clk),
        .rst (1'b1),
       // .i_trig(i_trig),
        .fifo_empty (e_wr_flag),
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
        .check_data (trig_flag)
);



endmodule