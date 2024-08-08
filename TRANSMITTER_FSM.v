`timescale 1ns / 1ps

module TRANSMITTER_FSM(
input  clk , 
input  rstn ,
//input i_ack , 
input flag , 
input tx_done , 
input [7:0] fifo_data ,  //Data reads from fifo to transmit
output o_rden_fifo  ,    //Enables the read enable signal of fifo
output [7:0] o_tx_data,  //Data to be transmitted that is read from fifo
output tx_valid          //Signal that activates the UART transmitter to transmit the data
//output wire  o_request 
);
    
   wire en_reg   ;
    
    TX_INTERNAL_FSM
    U2_TX_FSM(                         
          .i_clk(clk) , 
          .i_rstn(rstn) ,
          .i_flag(flag) , 
          .i_tx_done(tx_done) , 
          .o_enable(en_reg )  ,        // enables the UART REGISTER 
          .rd_en(o_rden_fifo)  ,
          .tx_valid(tx_valid)   
    );
    
    TX_FSM_REG 
    REG_TX(
        .i_data(fifo_data) , 
        .i_clk(clk) , 
        .i_rst(rstn) , 
        .i_enable(en_reg) , 
        .o_data(o_tx_data) 
    );
    
    
endmodule
