`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2022 12:50:34 PM
// Design Name: 
// Module Name: BRAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
/// design parameters 
//  DATA BUS = 48 bit//
/// address bus = 8
//  BRAM DEPTH =  2^8  = 256///
// clocks === write and read clock are same ///
// write_en == for controlling the writing into the bram ///
// read_en == for reading the contents (by axi ) from bram///

module BRAM_1
#(
  parameter WIDTH_DATA = 48 , 
            WIDTH_ADDR = 8 
)
(
 ///write block signals//
 input i_wclk , 
 input i_wr_en , 
 input [WIDTH_ADDR-1:0] i_WADDR , 
 input [WIDTH_DATA-1:0] i_WDATA , 
 
 ///read block signals //
 input i_rdclk , 
 input i_rd_en ,
 input [WIDTH_ADDR-1:0] i_RADDR , 
 output [WIDTH_DATA-1:0] o_RDATA  
);

//// 256 bit ////
localparam  FIFO_DEPTH = 2**WIDTH_ADDR ;

///memory declaration//
reg [WIDTH_DATA-1:0] mem[0:FIFO_DEPTH-1];

reg [WIDTH_DATA-1:0] rd_DATA = 0;

always @(posedge i_wclk)
  begin
    if(i_wr_en)
       mem[i_WADDR] <= i_WDATA ;
    end 

  
// read from memory ///  
always @(posedge i_rdclk)
  begin  
    if(i_rd_en)
        rd_DATA <= mem[i_RADDR];
    
  end

// assign the memory read data to output ///
assign o_RDATA = rd_DATA ;
   
        
endmodule 