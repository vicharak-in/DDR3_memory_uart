`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2022 04:46:35 PM
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2022 04:46:35 PM
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
/////////////////////////////////////////////////////////////////////////////////////

`define W_DATA 256
`define ADDR_W 10
 
 module ASYNCH_FIFO_TX(
 input i_WCLK , 
 input i_write_en , 
 input i_wrstn  , 
 input [`W_DATA-1:0] i_WDATA , 
 output o_fifo_full , 
 output o_fifo_almst_full ,

 input  i_RCLK , 
 input  i_read_en ,
 //input  i_mem_enable , 
 input  i_rrstn ,
 output [`W_DATA-1:0]o_RDATA,
 //output o_fifo_empty , 
 output o_fifo_empty , 
 output [`ADDR_W-1:0] o_FIFO_CNT_WR ,
 output [`ADDR_W-1:0] o_FIFO_CNT_RD  
);

 //assign o_mipi_en = (~o_fifo_empty) ;

 //wire i_rd_en_BRAM ;
 //wire i_wr_en_BRAM ;

 wire [`ADDR_W-1:0] wr_addr  ;
 wire [`ADDR_W-1:0] rd_addr  ;
    
 //assign i_rd_en_BRAM = i_read_en  ;
 //assign i_wr_en_BRAM = i_write_en && (~o_fifo_full) ; 



///instantition of block RAM //
//  data width = 48 bits //
//  address width = 8 bits 
BRAM_1_tx
#(.WIDTH_DATA(`W_DATA) , 
  .WIDTH_ADDR(`ADDR_W) 
)
BRAM(
 ///write block signals//
  .i_wclk(i_WCLK) , 
  .i_wr_en(i_write_en) , 
  .i_WADDR(wr_addr) , 
  .i_WDATA(i_WDATA) , 
 
 ///read block signals //
  .i_rdclk(i_RCLK) , 
  .i_rd_en(i_read_en) ,
  .i_RADDR(rd_addr) , 
  .o_RDATA(o_RDATA)  
);

  // wire [`ADDR_W:0] i_rd_pointer ;
   //wire [`ADDR_W:0] i_wr_pointer ;
 
   wire [`ADDR_W:0] wr_rd_ptr ;     ///synchronised rd_pointer  //
   wire [`ADDR_W:0] rd_wr_ptr ;    ///synchronised wr_pointer // 
   
   wire [`ADDR_W:0] rd_ptr ;  //read pointer
   wire [`ADDR_W:0] wr_ptr ;   //write pointer
   
  
 //instantiation of  sync_rd_pointer //
  
synch_rd_pointer_1_tx
 #(.PTR_W(`ADDR_W))

SYNCH_RD_POINTER(
         .i_wr_clk(i_WCLK) ,
         .i_wr_rstn(i_wrstn) , 
         .i_rd_ptr (rd_ptr) , 
         .w_rd_ptr (wr_rd_ptr)
);


// instantiation of sycn_wr_pointer ///

synch_wr_pointer_1_tx
#(.PTR_R(`ADDR_W))

SYNCH_WR_POINTER(
  .i_rd_clk(i_RCLK) , 
  .i_rd_rstn(i_rrstn) ,
  .i_wr_ptr(wr_ptr),
  .r_wr_ptr(rd_wr_ptr)
);
 
 
 //instantiation of write_pointer_empty logic module//
   
wr_pointer_full_1_tx
WRITE_POINTER( 
   .i_wr_clk(i_WCLK) , 
  .i_wr_en(i_write_en) , 
  .i_wr_rstn(i_wrstn) , 
  .o_wr_addr(wr_addr) , 
  .w_rdptr(wr_rd_ptr) ,        // output from sync_read_pointer ---output 
  .r_wrptr(wr_ptr),          // --- to sync_write_pointer --input // 
  .w_full(o_fifo_full), 
  .w_allmost_full(o_fifo_almst_full) ,
  .w_cnt(o_FIFO_CNT_WR) 
  );

rd_wr_pointer_full_1_tx
#(.A_SIZE(`ADDR_W))
READ_POINTER( 
   .i_rd_clk(i_RCLK),                           // read clock  //
   .i_rd_rstn(i_rrstn),                      //active low reset  ,
   .i_rd_en (i_read_en) ,                      // input read enable  //
   .r_wrptr (rd_wr_ptr),             //synchronized write gray pointer from write pointer full logic module //
   .o_rd_addr(rd_addr) ,             // read address for the block memory  //
   .o_rd_ptr (rd_ptr),              // gray read  pointer to be synchronized into write clock domain // 
   .o_empty  (o_fifo_empty),                      // read empty signal
   .o_almst_empty(), 
   .rd_counter(o_FIFO_CNT_RD)
 );            //// read almost empty  //
 
endmodule