`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2023 07:07:43 PM
// Design Name: 
// Module Name: UART_RX_FSM
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


module UART_INTERNAL_FSM(
input i_clk , 
input i_rst_n ,
input i_fifo_full , 
input i_rx_valid , 
output o_enable  ,                      // enables the UART REGISTER 
output wr_en   
    );
    
  reg o_wren    =  0;
  reg en_reg =   0 ; 
  
  assign wr_en = o_wren  ;
  assign o_enable = en_reg ;
  
  
  parameter IDLE_RX =  3'b000 ;
  parameter ASSERT_W = 3'b001 ;  // ASSERT THE FIFO WRITE ENABLE 
  parameter DEASSERT_W = 3'b010 ;
  parameter WAIT_TX    = 3'b011 ;
  parameter DONE_RX  =  3'b100 ;
  
  
  reg [2:0] p_RX = 0;
  
  
  always @(posedge i_clk)
     begin
         if (~i_rst_n) begin
             p_RX <=  0;
             en_reg <= 0;
             o_wren <= 0 ;
          end    
    else
               begin
                          case (p_RX)
            
         IDLE_RX :  begin
                       if (i_rx_valid == 1'b1 )begin
                            en_reg <= 1'b1 ;           // enables the uart register to latch the data to further process to FIFO  
                            o_wren <= 1'b0 ;           // keep deasserted -- fifo write enable //
                            p_RX   <= ASSERT_W  ;
                       end 
                        else
                           begin
                             en_reg <= 0;
                             o_wren <= 1'b0 ;
                             p_RX   <= IDLE_RX ;
                         end 
                         
                        if (i_fifo_full == 1'b1)  begin
                            en_reg <= 1'b0;
                            o_wren <= 1'b0 ;
                            p_RX   <= DONE_RX ;
                         end 
                    
                      end 
                 
          ASSERT_W  : begin
                          en_reg <= 1'b0 ;
                          o_wren <= 1'b1 ;
                          p_RX   <= DEASSERT_W ;
                       end 
                
          DEASSERT_W :  begin
                              o_wren <= 1'b0 ;               /// disable the FIFO WRENABLE 
                              p_RX   <= DONE_RX ;
                              en_reg <= 1'b0 ;
                            end 
                             
         DONE_RX : begin
                       p_RX   <= IDLE_RX ;
                       o_wren  <= 1'b0 ;
                       en_reg  <= 1'b0 ; 
                   end                            
                                 
           default : p_RX <= IDLE_RX ;
           endcase
           end 
          end                                     
endmodule
