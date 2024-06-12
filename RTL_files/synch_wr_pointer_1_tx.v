`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.05.2023 09:27:31
// Design Name: 
// Module Name: synch_wr_pointer_1
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


module synch_wr_pointer_1_tx
#(parameter PTR_R = 12
)
(input  i_rd_clk , 
 input  i_rd_rstn ,
 input  [PTR_R:0] i_wr_ptr ,
 output [PTR_R:0] r_wr_ptr
);

reg [PTR_R:0] d_f1 , d_f2 ;


always @(posedge i_rd_clk ) begin
     if (~i_rd_rstn)
            { d_f2 , d_f1} <= 0;
         else
            { d_f2 , d_f1} <= {d_f1 , i_wr_ptr};
     end 
     
  assign r_wr_ptr  = d_f2 ;
              

endmodule 
