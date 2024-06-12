module connector_tx_reg(
    input i_clk , 
    input i_rstn, 
    input empty ,
    input [7:0] i_fifo_data, 
   // input  uart_tx_rdy , 
    input  uart_tx_done ,
    output o_rd_tx,
    output uart_tx_valid  ,  
    output [7:0] o_TX_DATA_IN ,
    input [7:0] w_count 
);
      
wire ld_en  ;

UART_TX_FSM
fsm_inst(
    .i_clk (i_clk) , 
    .i_rstn (i_rstn) , 
    .i_fifo_empty (empty) , 
    .i_uart_tx_done (uart_tx_done) ,                       // while streaming  1 byte on uart , another byte could be loaded which would be processed later when uart_tx_data_valid and ready signal handshake (both high at same time)
    //input i_uart_tx_rdy ,                    // checks whether uart has ready to accept  the data 
    .o_rd_en  (o_rd_tx)  ,                     /// read enable FIFO 
    .o_ld_en (ld_en) ,                     /// enable the data register 
    .o_tx_data_valid (uart_tx_valid) ,              /// valid data is loaded from FIFO .. 
    .wr_cnt (w_count)
);

REGISTER
reg_inst(
    .i_data (i_fifo_data) , 
    .i_clk (i_clk) , 
    .i_rst (i_rstn) , 
    .i_enable (ld_en) , 
    .o_data (o_TX_DATA_IN) 
);   
endmodule

///////TestStart_enable //////////////////////////
module en_pass (
    input clk,
    input reset,
    input wire [255:0] d_pass_out,
    output reg [4:0] count_data
);

reg [1:0] state ;
//reg [255:0] d_out = 0 ;

//assign d_pass_out = d_out ;

parameter FIRST_S = 2'b00 ;
parameter SECOND_S = 2'b01 ;

always @ (posedge clk) begin

    if (!reset) begin 
        count_data <= 1'b0 ;
        state <= FIRST_S;
    end 
    
    else begin 
    
        case (state) 
        FIRST_S : begin 
            if (d_pass_out != 256'b0) begin
                state <= SECOND_S ;
            end
        end
        SECOND_S : begin 
            if (d_pass_out == 256'b0)
                state <= FIRST_S ;
            else 
                count_data <= count_data + 1 ;
   
         end
       endcase
  end
end
             
endmodule             
   
////////////////////////////////////////////////////////////

module en_test (
    input clk ,
    input [4:0] counter,
    output reg trig_read
);

always @ (posedge clk) begin   
   if (counter == 5'b11111) 
        trig_read <= 1'b1 ;

end
endmodule 

//////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
