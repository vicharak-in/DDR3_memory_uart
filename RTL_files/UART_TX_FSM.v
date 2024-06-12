module UART_TX_FSM(
input i_clk , 
input i_rstn , 
input i_fifo_empty , 
input i_uart_tx_done ,                       // while streaming  1 byte on uart , another byte could be loaded which would be processed later when uart_tx_data_valid and ready signal handshake (both high at same time)
//input i_uart_tx_rdy ,                    // checks whether uart has ready to accept  the data 
output o_rd_en    ,                     /// read enable FIFO 
output o_ld_en  ,                     /// enable the data register 
output o_tx_data_valid   ,              /// valid data is loaded from FIFO .. 
input wire [7:0] wr_cnt
);
    
 reg rd_en  = 0;
 reg ld_en  = 0;
 reg tx_data_valid  =  0;
 
 assign o_rd_en  = rd_en  ;
 assign o_ld_en  = ld_en  ;
 assign o_tx_data_valid  = tx_data_valid  ;
 
 ///FSM STATES //
 parameter IDLE_TX = 3'b000 ;
 parameter ASSERT_RD = 3'b001 ;
 parameter ASSERT_LD_EN = 3'b010  ;
 parameter CHECK_TX_RDY  = 3'b011 ;
 parameter ASSERT_TX_DATA_VALID = 3'b100  ;
 parameter CHECK_UART_TX_DONE   = 3'b101 ;   
 /// NOTE =-: A NEW BYTE HAS TO BE READ FROM FIFO WHILE UART IS TRANSMITTING 
 /// THE PREVIOUS BYTE 
 /// THIS WOULD NOT AFFECT THE ONGOING TRANSFER 
 
 /// present state register 
 reg [2:0] p_state  = 0;
 /// next state register 
 reg [2:0] n_state  = 0;
 
 
 
 ///data register -- state 
 
 always @(posedge i_clk)
   begin
        if (!i_rstn)
             p_state <= IDLE_TX ;
        else
             p_state <= n_state ;
  end 
  
  
  /// next state combinatorial logic //
  
  always @(*)
    begin
          case (p_state)
     
     
     IDLE_TX :  begin
                  if (~i_fifo_empty && (wr_cnt > 1) )
                    n_state = ASSERT_RD ;
                  else
                   n_state  = p_state ;
               end 
       
      ASSERT_RD : begin
                     n_state = ASSERT_LD_EN ;
                   end 
                   
      ASSERT_LD_EN : begin
                        n_state = CHECK_TX_RDY ;  
                     end
      CHECK_TX_RDY : begin
                      //   if (i_uart_tx_rdy == 1'b1)
                            n_state = ASSERT_TX_DATA_VALID ;
                         //else
                       //     n_state = p_state ;
                    end 
                    
       ASSERT_TX_DATA_VALID :  begin
                            n_state = CHECK_UART_TX_DONE ;
                      end 
                      
       CHECK_UART_TX_DONE : begin
                                 if (i_uart_tx_done==1'b1)
                                  n_state = IDLE_TX ;
                                else
                                  n_state =  p_state ;
                                end   
                      
       default      :   n_state = IDLE_TX ;
        endcase 
      end 
      
      
      
      //// assign output ///
      
     always @(posedge i_clk)
        begin
                    case (p_state)
       IDLE_TX : begin
                       rd_en <= 1'b0 ;
                       ld_en <= 1'b0 ;
                       tx_data_valid  <= 1'b0;
                 end 
                 
      ASSERT_RD : begin  
                       rd_en <= 1'b1 ;
                       ld_en <= 1'b0 ;
                       tx_data_valid  <= 1'b0;
                   end 
       
       ASSERT_LD_EN : begin
                       rd_en <= 1'b0 ;
                       ld_en <= 1'b1 ;
                       tx_data_valid  <= 1'b0;
                     end 
                     
       CHECK_TX_RDY : begin
                       rd_en <= 1'b0 ;
                       ld_en <= 1'b0 ;
                       tx_data_valid  <= 1'b0;
                      end 
                      
       ASSERT_TX_DATA_VALID :  begin
                       rd_en <= 1'b0 ;
                       ld_en <= 1'b0 ;
                       tx_data_valid  <= 1'b1;
                      end 
                      
      CHECK_UART_TX_DONE : begin
                       rd_en <= 1'b0 ;
                       ld_en <= 1'b0 ;
                       tx_data_valid  <= 1'b0;
                      end     
     default : begin
                  rd_en  <= 1'b0 ;
                  ld_en  <= 1'b0  ;
                  tx_data_valid <= 1'b0 ;
               end 
            endcase
      end                    

endmodule