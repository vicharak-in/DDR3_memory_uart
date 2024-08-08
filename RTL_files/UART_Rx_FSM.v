`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2023 10:37:32 AM
// Design Name: 
// Module Name: UART_RX_FSM_2
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


module UART_Rx_FSM(
input  i_clk , 
input i_rstn ,
//input i_ack , 
input fifo_full , 
input rx_valid , 
input [7:0] rx_data , 
output o_wren_fifo  , 
output [7:0] o_rx_data   
//output wire  o_request 
);
    
   wire en_reg   ;
    
    UART_INTERNAL_FSM
    U2_RX_FSM(
          .i_clk(i_clk) , 
          .i_rst_n(i_rstn) ,
          //.i_APB_ack(i_ack) ,
          .i_fifo_full(fifo_full) , 
          .i_rx_valid(rx_valid) , 
          .o_enable(en_reg )  ,                      // enables the UART REGISTER 
          .wr_en(o_wren_fifo)  
         // .o_APB_REQUEST(o_request)   
    );
    
    UART_FSM_REG 
    REG_RX(
        .i_data(rx_data) , 
        .i_clk(i_clk) , 
        .i_rst(i_rstn) , 
        .i_enable(en_reg) , 
        .o_data(o_rx_data) 
    );
    
     reg [9:0] WRITE_CNT = 0 ;
     always@(posedge i_clk) begin
         if (~i_rstn)
             WRITE_CNT <= 0;
          else if(o_wren_fifo)
              WRITE_CNT <= WRITE_CNT + 1;
           else
              WRITE_CNT <= WRITE_CNT ;
     end
    
endmodule
