`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2023 03:49:50 PM
// Design Name: 
// Module Name: UART_TX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// De
//////////////////////////////////////////////////////////////////////////////////
// Company: 

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2023 11:42:28 AM
// Design Name: 
// Module Name: UART_TX
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

//////////////////////////////////////////////////////////////////////////////////
// Company: 

//////////////////////////////////////////////////////////////////////////////////
///Design name : UART_TX 
 ///UART TRANSMITTER (sending data from FPGA to PC )
 ///Buad rate = 9600 bps //
 ///UART TX clk = 60MHZ 


///CLK_PER_BIT_TX = Fpga_clk (60_000_000)/Baud_rate115200/// = 520
/// MASTER receiver --- 115200 BAUD RATE 
`define CLK_PER_BIT_TX 607
`define CNT_BYTE_TX 3
`define STATE_WIDTH_TX 3
`define DATA_WIDTH_TX 8
`define WIDTH_CLK_CNT_TX 14
module UART_TX(
input i_clk , 
input i_rst_n , 
input i_TX_valid , 
input [`DATA_WIDTH_TX-1:0] i_TX_DATA ,  ///data to be transmitted from FPGA TO PC ///
output  o_TX_uart ,                    ////serial output data to be streamed (Parallel to Serial)to the PC ///
output o_TX_active   ,                 ///output showing data transmission is active //
output o_TX     ,                    //output showing data is successfully transmitted ///, 
output o_tx_rdy  
  );
  
reg o_TX_Serial ;
assign o_TX_uart = o_TX_Serial ;



parameter IDLE           =    3'b000;
parameter TX_START_BIT   =    3'b001;
parameter TX_DATA_BITS   =    3'b010;
parameter TX_STOP_BIT    =    3'b011;
parameter CLEAN_BITS_TX  =    3'b100;


reg[`WIDTH_CLK_CNT_TX-1:0] clk_count_TX = 0 ; ///counter counting the CLK_PER_BIT (2^10 =1024, COUNTING TILL 868 ( 0 to 867)////
reg[`CNT_BYTE_TX-1:0] tx_cnt = 0; // transmitter couter counting the data received bits(8 bits) ///
reg[7:0] tx_BYTE   ; ///data sent from FPGA to PC ///
reg o_TX_byte = 0; ///output showing data is successfully transmitted ////     
reg TX_Active = 0;  ///output showing data is initialized for transmitting from FPGA to PC //
reg [2:0] n_STATE = 0;
reg [2:0] p_STATE = 0;

 assign o_tx_rdy = (p_STATE == IDLE) ? 1'b1 : 1'b0;

//assign o_tx_en = (tx_cnt == 3'b111 ) ? 1'b1 : 1'b0;
//wire o_tx_enable ;
//assign o_tx_enable = (tx_cnt == 0)? 1'b1 : 1'b0 ;
assign o_TX = o_TX_byte ;     ////output showing data is successfully transmitted ////
assign o_TX_active = TX_Active ;
//assign {wr_en , enable } = o_tx_enable? 2'b11 : 2'b00;

/*
///data state reg //
always @(posedge i_clk )
  begin
    if (~i_rst_n)
         p_STATE <= IDLE ;
         else
        p_STATE <= n_STATE ;
     end 
  */       

always @(posedge i_clk)
    begin
 if (~i_rst_n)
   begin
     p_STATE <= IDLE ;
   end
  else
    begin    
       case (p_STATE)  
       
IDLE :     
                 begin            
                         
                           tx_cnt <= 0;        ///none of the bits have been transmitted //
                           clk_count_TX <= 0;
                           o_TX_Serial <=1;   ///start bit of transmitter goes high (no transmission)// 
                           o_TX_byte <= 0;    ///data hasn't been transmitted yet /// 
         if (i_TX_valid  == 1'b1)
                   begin 
                           p_STATE <= TX_START_BIT ;     ////p_STATE
                           TX_Active <= 1'b1 ;   ///data is initialised for transmission //
                           o_TX_Serial <= 0;     ///start bit goes active low for serial transmission ///
                           tx_BYTE  <=  i_TX_DATA ;    ///data is loaded in register "tx_BYTE" // 
                           
                               
                   end
        else
                            p_STATE <= IDLE ;   
 
          end    
          
////make start bit 0 so as to active the transmission of data///                    
TX_START_BIT :
           begin
                   o_TX_Serial <= 1'b0;
                  if ( clk_count_TX < `CLK_PER_BIT_TX-1)
                           begin
                              clk_count_TX <= clk_count_TX + 1'b1 ;
                              p_STATE <= TX_START_BIT ;
                            end  
                     else
                            begin
                              p_STATE <= TX_DATA_BITS ;
                              clk_count_TX <= 0;
                            end
               end
               
TX_DATA_BITS : begin
                 o_TX_Serial <= tx_BYTE[tx_cnt];  ///load the parallel data from FPGA Serially /              
                    if (clk_count_TX < `CLK_PER_BIT_TX-1)
                           begin
                           clk_count_TX <= clk_count_TX + 1'b1 ;
                           p_STATE <= TX_DATA_BITS ;
                          end
                    else
                           begin
                        //  o_TX_Serial <= tx_BYTE[tx_cnt];  ///load the parallel data from FPGA Serially /                                       
                          clk_count_TX <= 0;
               ///checking if the data transmitted is 8 bit or not ///    
                   if (tx_cnt <7)
                            begin
                                      tx_cnt <= tx_cnt + 1'b1 ;
                                      p_STATE <= TX_DATA_BITS ;
                            end
                            else
                               begin
                                      tx_cnt <= 0;
                                      p_STATE <= TX_STOP_BIT ;
                               end         
                    end  
               end 
                        
 TX_STOP_BIT :    begin
                      o_TX_Serial <= 1'b1;   ///stop bit =1
                        if (clk_count_TX < `CLK_PER_BIT_TX-1)
                              begin
                                      clk_count_TX <= clk_count_TX + 1'b1 ;
                                      p_STATE <= TX_STOP_BIT ;
                               end
                            else
                                begin
                                        clk_count_TX <= 0;   
                                        o_TX_byte <= 1'b1;         //data is succesfully transmitted///
                                     //   o_TX_Serial <= 1'b1;   ///stop bit =1///
                                        TX_Active <= 1'b0 ;       ///no  data transmission///
                                        p_STATE <= CLEAN_BITS_TX ;
                              end
                          end    
                          
CLEAN_BITS_TX     :    begin
                          o_TX_byte <= 1'b0;
                          p_STATE <= IDLE ;
                       end 
   
 default     :     begin
                          p_STATE <= IDLE ;
                    end
          endcase  
   end  
 end     
endmodule


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: UART Transmitter
// Module Name: uart_tx
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////
// The clock frequency --> 100MHz 
// Baud rate           --> 115200
// clk frequency / baud rate --> 100*10^6 / 115200 --> 868 clks/bit 

module UART_TX #(parameter CLKS_PER_BITS = 868)( 
  input [7:0] i_data_byte, //The input to the tx is a byte 
  output      o_data_bit,  //The output from the tx is a bit sent out 8 times serially
  input       clk,
  output      o_done,      //Done is raised when it is done sending all the 8 bits
  input       i_valid     //It starts converting a byte to bit when it gets a valid
 // output      tx_busy      //Busy is high until it transmits one byte
);
  //reg         r_tx_busy = 0;
  reg         r_o_data_bit = 1; 
  reg [13:0]  r_counter = 0;// Keeps track of no. of counts tx has to wait to send each bit based on baud rate
  reg [3:0]   r_index = 0;  // Keeps track of bit count (0 to 7) to transmit 8 bits
  reg [2:0]   p_state = 0;
  reg         r_o_done = 0;
  reg [7:0]   r_i_data = 0;
  parameter   IDLE = 2'd0;
  parameter   START_BIT = 2'd1;
  parameter   DATA_BITS = 2'd2;
  parameter   STOP_BIT = 2'd3;
  parameter   STOP_BIT_2 = 2'd4;
  
  assign o_done = r_o_done;
  assign o_data_bit = r_o_data_bit;
  
  always @(posedge clk) begin
    case (p_state)
      IDLE : begin
        r_o_done <= 0;
        r_index <= 0;
        r_counter <= 0;
        r_o_data_bit <= 1;
        if (i_valid == 1) begin
          p_state <= 5;
         // r_tx_busy <= 1'b1;
          r_i_data <= i_data_byte;
        end
      end
      
      5: begin
        if(r_counter == CLKS_PER_BITS - 1) begin
          r_counter <= 0;
          p_state <= START_BIT;            
        end else begin
          r_counter <= r_counter + 1;
          r_o_data_bit <= 1'b1;
        end
      end
      
      START_BIT : begin
        if(r_counter == CLKS_PER_BITS - 1) begin
          r_counter <= 0;
          p_state <= DATA_BITS;            
        end else begin
          r_counter <= r_counter + 1;
          r_o_data_bit <= 1'b0;
        end
      end
      
      DATA_BITS : begin
        if (r_index < 8) begin
            if (r_counter == CLKS_PER_BITS - 1) begin
              r_counter <= 0;
              r_index <= r_index + 1;
            end
            else begin
              r_o_data_bit <= r_i_data [r_index];
              r_counter <= r_counter + 1;
            end 
        end else begin
            r_index <= 0;
            p_state <= STOP_BIT;
        end
      end
      STOP_BIT : begin
        if (r_counter == CLKS_PER_BITS - 1) begin
          r_counter <= 0;
          r_o_done <= 1;
          p_state <= IDLE;
          //r_tx_busy <= 1'b0;
        end
        else begin
          r_o_data_bit <= 1'b1;
          r_counter <= r_counter + 1;      
        end
      end     
    endcase
  end 
 // assign tx_busy = r_tx_busy;
     
endmodule*/