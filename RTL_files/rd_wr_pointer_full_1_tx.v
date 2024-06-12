`timescale 1ns/1ps
module rd_wr_pointer_full_1_tx
#(parameter A_SIZE = 12)
 (                      
 input i_rd_clk,                           // read clock  //
 input i_rd_rstn,                      //active low reset  ,
 input i_rd_en  ,                      // input read enable  //
 input [A_SIZE:0] r_wrptr ,             //synchronized write gray pointer from write pointer full logic module //
 output [A_SIZE-1:0] o_rd_addr ,         // read address for the block memory  //
 output  [A_SIZE:0] o_rd_ptr,         // gray read  pointer to be synchronized into write clock domain // 
 output  o_empty,                      // read empty signal
 output  o_almst_empty,                // read almost empty //
 output  [A_SIZE-1:0] rd_counter         // read counter for counting how many words are left to be read  ///
 )  ;            //// read almost empty  //
 
 reg [A_SIZE:0] r_rd_ptr = 0;
 reg r_empty =0;
 reg r_almst_empty = 0;
 reg [A_SIZE-1:0] r_rd_counter = 0 ;
 
 assign o_rd_ptr = r_rd_ptr;
 assign o_empty = r_empty;
 assign o_almst_empty = r_almst_empty;
 assign rd_counter = r_rd_counter;
 
 reg  [A_SIZE:0]  rd_bin_ptr = 0 ;
 wire [A_SIZE:0] rd_GRAY_NXT ;
 wire [A_SIZE:0] rd_bin_next;
 
 
 ///reg [A_SIZE :0] rd_counter = 0 ;         

 wire r_enable  ;                          // wire for enabling the read operation //
 wire r_empty_log ;                         // wire for assigning the empty logic //
 wire r_empty_almst ;                        //wire for assingin the almost empty logic //


 localparam FIFO_DEPTH = 2**A_SIZE ;        ///number of data words to be read  ///


 
  /***************************************************************************************************************
                  read enable logic 
   ***********************************************************************************************************/
    assign r_enable  =  i_rd_en && (~r_empty) ;
   
 /***************************************************************************************************************
                   assigning memory addresss
   ***********************************************************************************************************/
               
     assign o_rd_addr = rd_bin_ptr[A_SIZE-1:0];
 
   /***************************************************************************************************************
                      binary next pointer logic 
   ***********************************************************************************************************/
 
     assign rd_bin_next = rd_bin_ptr +  r_enable ;

   /***************************************************************************************************************
                          binary to gray code logic 
   ***********************************************************************************************************/

       assign rd_GRAY_NXT = (rd_bin_next>>1)^rd_bin_next;

   /***************************************************************************************************************
                     read empty logic 
   ***********************************************************************************************************/
       assign r_empty_log = (rd_GRAY_NXT == r_wrptr);
 
 
   /***************************************************************************************************************
                    almost read empty logic 
   ***********************************************************************************************************/
       assign r_empty_almst  =   (rd_counter == 4) ;
 

/// register the read binary pointer  //
 always @(posedge i_rd_clk )begin
    if (~i_rd_rstn)  
        rd_bin_ptr <= 0;
    else 
        if(r_enable)
        rd_bin_ptr <= rd_bin_next;
    else
        rd_bin_ptr <= rd_bin_ptr ;   
 end 
 
 /**************************************************************************************************************************************
    register the rd_GRAY_NXT in o_rd_ptr to be assigned to write pointer logic through synchronizer chain of 2-DFF  ///
 *********************************************************************************************************/
 always @(posedge i_rd_clk) begin
    if (~i_rd_rstn) 
          r_rd_ptr <=  0;
     else
          r_rd_ptr <= rd_GRAY_NXT ;
   end 
  
   /***************************************************************************************************************
                  Register the read empty signal
   ***********************************************************************************************************/
 
   always @(posedge i_rd_clk ) begin
       if (~i_rd_rstn) //low reset 
            r_empty <= 1'b1;
     else 
            r_empty <= r_empty_log ;
   end 
 
 /***************************************************************************************************************
                  Register the read almost empty signal
   ***********************************************************************************************************/
    always @(posedge i_rd_clk ) begin
       if (~i_rd_rstn)
             r_almst_empty <= 0;
       else
             r_almst_empty <= r_empty_almst ;
      end                
 
   /***************************************************************************************************************
                  Counter for counting the number of words left to be read
   ***********************************************************************************************************/
     
     always @(posedge i_rd_clk ) begin
        if (~i_rd_rstn)
                r_rd_counter <= FIFO_DEPTH;
        else
             if (r_enable)
                r_rd_counter <= r_rd_counter  +  1'b1 ;        
         else
               r_rd_counter <= r_rd_counter;    
   end

endmodule

