`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2023 12:44:11
// Design Name: 
// Module Name: Wr_FSM
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

`define WIDTH 32
module Wr_FSM (
input axi_clk,
input rst,
input fifo_empty,
input i_trig,
output read_en,
input [7:0] i_data,
output reg [31:0] dout1 = 0,
output count
);

reg [1:0] state = 0;
reg r_en = 0 ;
reg count_data = 0;

assign count = count_data;
assign read_en = r_en ;

parameter CHECK_FIFO_EMPTY = 2'b00;
parameter CHECK_READ_EN = 2'b01;
parameter SHIFT_DATA = 2'b10 ;

always @(posedge axi_clk)
begin

    if(~rst) begin
        dout1 <= 0;
        r_en <= 0;
        count_data <= 0;
        state <= CHECK_FIFO_EMPTY ;
   end
    
    
    else begin
        case (state) 
            CHECK_FIFO_EMPTY : begin
                if(~fifo_empty && i_trig) begin
                    r_en <= 1'b0;
                    count_data <= 0;
                    state <= CHECK_READ_EN ;

                end
                
                else 
                    state <= CHECK_FIFO_EMPTY ;
   
            end
            
            CHECK_READ_EN : begin
                r_en <= 1'b1 ;
                state <= SHIFT_DATA ;
                count_data <= 0;
             end
            
            SHIFT_DATA : begin   
                r_en <= 1'b0;
                dout1 <= (dout1 << 8) | i_data;
                count_data <= 1'b1;
                state <= CHECK_FIFO_EMPTY ;
            end          
         endcase
    end
end


endmodule