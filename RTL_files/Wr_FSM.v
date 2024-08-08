`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2023 12:44:11
// Design Name: 
// Module Name: Wr_FSM
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

`define WIDTH 32
module Wr_FSM (
input axi_clk,
input rst,
input fifo_empty,
input i_trig,
output read_en,
input [7:0] i_data,              // Data read from fifo
output reg [255:0] dout1 = 0,    // Data that has to write into ddr dram.
output reg [255:0] register =0,
output reg check_data =0,
output count
);

reg [1:0] state = 0;
reg r_en = 0 ;
reg count_data = 0;
reg [6:0] rd_en_cnt = 0;        // Register that counts the number of times r_en is occurs

assign count = count_data;
assign read_en = r_en ;        // Read enable signal for the fifo 

//State assignments

parameter CHECK_FIFO_EMPTY = 2'b00;
parameter CHECK_READ_EN = 2'b01;
parameter SHIFT_DATA = 2'b10 ;
parameter WAIT = 2'b11;

always @(posedge axi_clk)
begin

    if(~rst) begin
        dout1 <= 0;
        r_en <= 0;
        count_data <= 0;
        state <= CHECK_FIFO_EMPTY ;
   end
    
    
    else begin
        case (state) 
            CHECK_FIFO_EMPTY : begin
                if(~fifo_empty) begin
                    r_en <= 1'b0;
                    count_data <= 0;
                    state <= CHECK_READ_EN ;

                end
                
                else 
                    state <= CHECK_FIFO_EMPTY ;
   
            end
            
            CHECK_READ_EN : begin
                r_en <= 1'b1 ;
                rd_en_cnt <= rd_en_cnt + 1 ;
                state <= SHIFT_DATA ;
                count_data <= 0;
             end
            
            SHIFT_DATA : begin   
                r_en <= 1'b0;
                dout1 <= (dout1 << 8) | i_data;  //Shifts the data into 256 bit register, byte by byte read from fifo
                count_data <= 1'b1;
                if (rd_en_cnt==33)
                    state <= WAIT ;
                else
                    state <= CHECK_FIFO_EMPTY ;
            end  
    
            WAIT : begin
            count_data <= 1'b0;
                 if(i_trig) begin
                    rd_en_cnt <= 0;
                    state <= CHECK_FIFO_EMPTY ;
                    check_data <= 1'b0 ;
                   end 
                  else begin
                    state <= WAIT ;
                    register <= dout1;
                    check_data <= 1'b1;
                    end
            end    
         endcase
    end
end

/// THIS LOGIC IS ONLY FOR DEBUGGING NOT FOR DESIGN. TO KNOW THE NUMBER OF READINGS OCCURED

      reg [9:0] READ_CNT = 0 ;
     always@(posedge axi_clk) begin
         if (~rst)
             READ_CNT <= 0;
          else if(r_en)
              READ_CNT <= READ_CNT + 1;
          else 
              READ_CNT <= READ_CNT;  
     end

endmodule