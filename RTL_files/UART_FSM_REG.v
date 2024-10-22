`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2023 07:28:30 PM
// Design Name: 
// Module Name: Register_D
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

`define D_WIDTH 8

module UART_FSM_REG(
input [`D_WIDTH-1:0]  i_data , 
input i_clk , 
input i_rst , 
input i_enable , 
output [`D_WIDTH-1:0] o_data 
    );

reg [`D_WIDTH-1:0] o_reg = 0;
assign o_data = o_reg ;


always @(posedge i_clk) 
  begin
    if(~i_rst)
        o_reg <=  0;
     else
        if (i_enable == 1'b1)
            o_reg <= i_data ;
        else
            o_reg <= o_reg ;
 end                   


endmodule
