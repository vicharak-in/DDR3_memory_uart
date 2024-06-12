`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.05.2023 09:25:07
// Design Name: 
// Module Name: synch_rd_pointer_1
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


module synch_rd_pointer_1_tx
#(parameter PTR_W = 12)

(input  i_wr_clk ,
 input  i_wr_rstn , 
 input  [PTR_W:0] i_rd_ptr  , 
 output [PTR_W:0] w_rd_ptr
);

reg [PTR_W:0] d_ff1 , d_ff2 ;


always @(posedge i_wr_clk ) begin
     if (~i_wr_rstn)
            { d_ff2 , d_ff1} <= 0;
         else
            { d_ff2 , d_ff1} <= {d_ff1 , i_rd_ptr};
     end 
     
  assign w_rd_ptr  = d_ff2 ;
              

endmodule
