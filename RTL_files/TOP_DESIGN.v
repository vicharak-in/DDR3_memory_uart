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
//////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
// This module contains the top module of the receiver side.  This module takes the data 
// from uart receiver serially, and write into fifo, after that, the data is read from fifo 
// and then write the data into ddr dramto write into it.
////////////////////////////////////////////////////////////////////////////////////////////


module TOP_DESIGN(
    input i_clk,
    input axi_clk,
   // input i_rst,
    input data,
    input i_trig,
  //  output e_wr_flag ,
    output [255:0] s_out,
    output [31:0] mux_reg_data,
    input [7:0] alen_fifo ,
    //output ddr_trig,
    output wr_en_trig ,
    input wready_rx,
    output trig_en, 
    output trig_flag
);


wire r_valid ;
wire f_full, wr_en, e_wr_flag, read_en ;
wire tx_done, tx_rdy, tx_valid ;
wire [7:0] o_data1 , o_data2, o_data3;
wire [255:0] o_data4;
wire  cnt;
wire rst ; 
assign rst = 1'b0 ;
wire [9:0] occupant_count ;
wire trig_flag ;
//wire wr_en_trig ;
wire fifo_r_en ;
//wire [255:0] s_out ;
//reg [7:0] alen_fifo = 8'h00 ;

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

Asyn_fifo_1 
fifo_1(
    .full_o (f_full),
    .empty_o(e_wr_flag),
    .wr_clk_i(i_clk),
    .rd_clk_i(axi_clk),
    .wr_en_i(wr_en),
    .rd_en_i(read_en),
    .wdata(o_data2),
    .wr_datacount_o(),
    .rst_busy(),
    .rdata(o_data3),
    .rd_datacount_o(),
    .a_rst_i(rst)
);


Wr_FSM 
    fsm_shift(
        .axi_clk (axi_clk),
        .rst (1'b1),
        .i_trig(i_trig),
        .fifo_empty (e_wr_flag),
        .read_en (read_en),
        .i_data (o_data3),
        .dout1 (o_data4),
        .count (cnt),
        .register (s_out),
        .check_data (trig_flag)
);

wire [7:0] count_en  ;
wire wr_en_trig ;
/*
Wr_en_rx_ctrl
Wr_en_ctrl_inst(
    .clk(axi_clk),
    .rst(1'b1),
    .data_count(count_en),
    .alen (alen_fifo),
    .wr_en_rx (wr_en_trig)
);

sync_fifo_store 
sync_fifo_store_inst(
    .full_o(),
    .empty_o(),
    .clk_i (axi_clk),
    .wr_en_i (wr_en_trig),
    .rd_en_i (fifo_r_en),
    .wdata (s_out),
    .datacount_o (occupant_count),
    .rst_busy (),
    .rdata (rdata_fifo),
    .rvalid (trig_en),
    .a_rst_i (rst)
);
/*
rd_Rx_ctrl 
rd_Rx_ctrl_inst(
    .clk (axi_clk),
    .rst (1'b1),
    .wready_rx(wready_rx),
    .alen (alen_fifo),        // alen is now an 8-bit input
    .occupants (occupant_count),   // occupants remains a 10-bit input
    .storage_flag  (ddr_trig),
    .rd_en_rx  (fifo_r_en) 
);
*/
endmodule
