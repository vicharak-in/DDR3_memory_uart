`timescale 1ns / 1ps

module TX_INTERNAL_FSM(
input i_clk , 
input i_rstn ,
input i_flag ,                          // Whenever the data is loaded into register after reading from fifo it becomes high
input i_tx_done ,                       // Whenever one byte of data is transmitted successfully, it should be high 
output o_enable  ,                      // enables the UART REGISTER 
output rd_en ,                          // This signal enables the read of register data to transmit next byte
output tx_valid  
    );
    
  reg o_rden    =  0;
  reg en_reg =   0 ; 
  reg valid_en = 0;
  
  assign rd_en = o_rden  ;
  assign o_enable = en_reg ;
  assign tx_valid = valid_en;
  
  
  parameter CHECK_FIFO_EMPTY =  3'b000 ;
  parameter ASSERT_RD_EN = 3'b001 ;  // ASSERT THE FIFO READ ENABLE 
  parameter ASSERT_LD_EN = 3'b010 ;
  parameter ASSERT_TX_VALID = 3'b011 ;
  parameter CHECK_DONE_TX  =  3'b100 ;
  
  
  reg [2:0] state_TX = 0;
  
  
  always @(posedge i_clk)
     begin
         if (~i_rstn) begin
             state_TX <=  0;
             en_reg <= 0;
             o_rden <= 0 ;
             valid_en <= 0;
          end    
    else
               begin
                    case (state_TX)
            
         CHECK_FIFO_EMPTY :  begin
                       en_reg   <= 1'b0;
                       o_rden   <= 1'b0 ;
                       valid_en <= 1'b0; 
                       if (!i_flag )begin 
                            state_TX <= ASSERT_RD_EN  ;
                       end 
                        else begin
                             state_TX <= CHECK_FIFO_EMPTY ;
                         end 
                      end 
                 
          ASSERT_RD_EN  : begin
                          en_reg <= 1'b0 ;
                          o_rden <= 1'b1 ;
                          valid_en <= 1'b0; 
                          state_TX <= ASSERT_LD_EN ;
                       end 
                
          ASSERT_LD_EN :  begin
                              en_reg <= 1'b1 ;
                              o_rden <= 1'b0 ;               /// disable the FIFO RDENABLE 
                              valid_en <= 1'b0; 
                              state_TX <= ASSERT_TX_VALID ;   
                            end 
                             
         ASSERT_TX_VALID : begin
                          en_reg <= 1'b0 ;
                          o_rden <= 1'b0 ;
                          valid_en <= 1'b1; 
                          state_TX <= CHECK_DONE_TX ;
                   end                            
             
           CHECK_DONE_TX : begin
                          en_reg <= 1'b0 ;
                          o_rden <= 1'b0 ;
                          valid_en <= 1'b0; 
                       if (i_tx_done)
                          state_TX   <= CHECK_FIFO_EMPTY ;
                       else
                          state_TX   <= CHECK_DONE_TX ;
                          
                   end                   
           default : begin
                          en_reg <= 1'b0 ;
                          o_rden <= 1'b0 ;
                          valid_en <= 1'b0; 
                          state_TX <= CHECK_FIFO_EMPTY ;
                   end     
           endcase
           end 
          end                                     
endmodule
