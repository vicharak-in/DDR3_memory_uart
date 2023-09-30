`define DAT_W  8 
module wr_pointer_full_1
( input i_wr_clk , 
  input i_wr_en , 
  input i_wr_rstn , 
  output [`DAT_W-1:0] o_wr_addr , 
  input  [`DAT_W:0]  w_rdptr ,  
  output wire [`DAT_W:0] r_wrptr,  
  output wire w_full , 
  output wire w_allmost_full,
  output wire [`DAT_W-1:0] w_cnt 
  ); 
 
  reg [`DAT_W:0] bin_wptr= 0  ;  ///write pointer  ///
  wire[`DAT_W:0] bin_nxt ;
  wire [`DAT_W:0] gray_w ;
  
  //fifo full , almost full flags //
  
  wire o_full ;
  wire o_full_allmost ;
  
  reg [8:0] WRPTR = 0;
  reg FULL_FLAG = 0;
  reg ALLMOST_FULL_FLAG = 0;
  reg [7:0] COUNTER = 0;
     wire w_enable; 
     
     assign w_enable = i_wr_en && (~FULL_FLAG)  ;
    assign r_wrptr = WRPTR;
    assign w_full = FULL_FLAG;
    assign w_allmost_full = ALLMOST_FULL_FLAG;
    assign w_cnt = COUNTER;
    
  //counter for counting how many words of data is written //  
        always @(posedge i_wr_clk ) begin
          if (~i_wr_rstn)
               COUNTER <= 0;
            else
              if (w_enable==1'b1)
              // w_cnt <= (w_bin_ptr>= gray_nxt) ? (w_bin_ptr-gray_nxt): (FIFO_W-(w_bin_ptr+gray_nxt));
               COUNTER <=  COUNTER + 1'b1 ;
             else
               if (bin_wptr == 255)
               COUNTER <= 0;
           end 
   
   assign bin_nxt = bin_wptr + w_enable ;
   
   //binary to gray code converter//
   assign gray_w =  ((bin_nxt)>>1)^ (bin_nxt)  ;
   

  //synchronise the binary nxt pointer into binary reg//
  always @(posedge i_wr_clk )
     begin
         if (~i_wr_rstn)
            bin_wptr <= 0;
         else
            bin_wptr <= bin_nxt;    ///write pointer  ///  
     end

    // assigning the write address //
      assign o_wr_addr = bin_wptr[`DAT_W-1:0] ;

     // assigning the r_wrptr (write pointer to gray next , aka: gray code output to later compare it with read_pointer for logic empty comparison )
       always @(posedge i_wr_clk  )
         begin 
              if (~i_wr_rstn)
                  WRPTR <=  0;
              else
                  WRPTR <= gray_w ;    
        end          


         wire [`DAT_W:0] binary_wrptr ;
         
         //convert the gray to binary ///
         assign binary_wrptr = ^(w_rdptr>>1'b1);
 
      // assign o_full  = (bin_wptr == {~binary_wrptr[`DAT_W:`DAT_W-1] ,  binary_wrptr[`DAT_W-2:0]} ); 
       
       assign o_full = ( COUNTER == 254 );
       assign o_full_allmost =  (COUNTER == 252);
        
              
       
 
        always @(posedge i_wr_clk )
            begin
              if (~i_wr_rstn)
                  ALLMOST_FULL_FLAG <= 0 ;
                   else
                   ALLMOST_FULL_FLAG <= o_full_allmost ;
             end       


       always @(posedge i_wr_clk )
           begin
              if (~i_wr_rstn)
                   FULL_FLAG <= 0;
               else
                   FULL_FLAG <= o_full  ; 
            end              

endmodule
