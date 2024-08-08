/*`timescale 1ns / 1ps
module WRITE_FSM_TX (
    input wire clk,
    input wire rstn,
    input wire rvalid,           //Rvalid signal from DDRControllerDebug
   // input wire rready,
    input wire fifo_full,        //Signal to check whether the fifo is full or not
    input [255:0] data_in,       //This is the data read from the DdrDram
    output reg fifo_wen,         //Enables the write enable of fifo
    output reg [7:0] fifo_data   //Data that has to write into fifo
); 


   reg [2:0] state ; 
   reg [5:0] byte_count = 0;     //Counts the number of bytes has been written into the fifo
   reg [255:0] data_reg = 0;   
   
   // States Assignment
    parameter CHECK_RVALID = 3'b000;
    parameter CHECK_FIFO_FULL = 3'b001;
    parameter CHECK_WR_EN = 3'b010;
    parameter WRITE_DATA = 3'b011;
    parameter CHECK_BYTE_COUNT = 3'b100;

    // State transition
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            fifo_wen   <= 1'b0;
            fifo_data  <= 8'b0;
            byte_count <= 0;
            state <= CHECK_RVALID;
            end
        else  begin
           case (state)
             CHECK_RVALID: begin            //Whenever the Rvalid is high then only, 
                 fifo_wen   <= 1'b0;        //the read data is divided into each byte and write that data into fifo
                 byte_count <= 0;
                 if (rvalid ) begin
                     data_reg <= data_in ; 
                     state <= CHECK_FIFO_FULL;
                 end
                 else begin
                     state <= CHECK_RVALID;
                 end
             end
            
             CHECK_FIFO_FULL: begin
                 fifo_wen <= 1'b0;           
                 if (!fifo_full) begin         // The data should be write if the fifo is not full
                     state <= CHECK_WR_EN;
                 end 
                 else begin
                     state <= CHECK_FIFO_FULL;
                 end
             end
            
             CHECK_WR_EN: begin
                     fifo_wen <= 1'b1;                 //If the fifo is not full, then activate the write enable signal of fifo
                     fifo_data <= data_reg[255:248];   //Then write the data into fifo
                     state <= WRITE_DATA; 
             end

             WRITE_DATA: begin
                  if(fifo_wen) begin
                     byte_count <= byte_count + 1;     //After writing one data into fifo, increment the count by 1
                  end
                     fifo_wen <= 1'b0;
                     data_reg <= data_reg << 8 ;       //After writing the data of 1byte from the 256 bit data, shift left by 8 bits
                     state <= CHECK_BYTE_COUNT;
             end
             
             CHECK_BYTE_COUNT : begin
                  fifo_wen <= 1'b0 ;
                  if (byte_count == 32) begin           //CHecks whether the 256bits of data (32 bytes) is written into fifo or not
                      state <= CHECK_RVALID ;
                  end
                  else begin
                       state <= CHECK_FIFO_FULL ;
                  end
             end
         endcase
     end
     end
     
endmodule
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module WR_FSM_TX (
       input clk,
       input rst,
       input fifo_full,
       input rvalid,
       input [255:0] data_in,           // Data that is read from Dram
       output reg wr_en,                // Write enable signal to fifo
       output reg [255:0] fifo_data     // Data that has to be written into fifo
       );
        
      reg [1:0] state ;
      
      //States Declarations
      parameter CHECK_RVALID = 2'b00;
      parameter CHECK_FIFO_FULL = 2'b01;
     
       
       always@(posedge clk) begin
       if(~rst) begin
           wr_en <= 1'b0 ;
           fifo_data <= 0 ;
           state <= CHECK_RVALID;
       end
       else begin
           case (state) 
               CHECK_RVALID : begin          // When the data reads, then only it has to write into fifo
                    wr_en <= 1'b0 ;
                    fifo_data <= 0 ;
                    if(rvalid) begin
                       state <= CHECK_FIFO_FULL ;
                    end
                    else 
                       state <= CHECK_RVALID ;
              end
              
               CHECK_FIFO_FULL : begin
                     if(!fifo_full) begin
                         wr_en <= 1'b1 ;          // If the fifo is not full, then the wr_en is high and data should be write into it
                         fifo_data <= data_in ;
                         state <= CHECK_RVALID ;
                     end
                     else
                         state <= CHECK_FIFO_FULL ;
               end
               
                 default : begin
                       state <= CHECK_RVALID ;
                       wr_en <= 1'b0;
                       fifo_data <= 0;
                       end
           endcase
       end
       end
  endmodule
  
  
  //////////////////////////////////////////////////////////////////////////////////////////////////
  
  module RD_FSM_TX (
    input clk,
    input rst,
    input fifo_empty,
    input [255:0] in_data,              // Data that is read from fifo
    output reg rd_en,                   // Read enable signal to fifo
    output reg load,                    // When the data is read from, the load becomes high
    output reg [255:0] data_reg,        // register to store the read data from fifo
    output reg [255:0] out_data
);

    // State Definitions
    reg [1:0] state, next_state;
    parameter CHECK_FIFO_EMPTY = 2'b00;
    parameter READ_FIFO = 2'b01;
    parameter STORE_DATA = 2'b10;
    
    // State Register
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= CHECK_FIFO_EMPTY;
        end else begin
            state <= next_state;
        end
    end
    
    // State Machine and Output Logic
    always @(*) begin
        // Default values
        rd_en <= 1'b0;
        data_reg <= data_reg;
        out_data <= out_data;
        next_state <= state;
        
        case (state)
            CHECK_FIFO_EMPTY: begin
                if (!fifo_empty) begin
                    next_state <= READ_FIFO;
                end else begin
                    load <= 1'b0;
                    next_state <= CHECK_FIFO_EMPTY;
                end
            end
            
            READ_FIFO: begin
                rd_en <= 1'b1;  // Assert read enable to read from FIFO
                load <= 1'b0;
                next_state <= STORE_DATA;
            end
            
            STORE_DATA: begin
                rd_en <= 1'b0;  // Deassert read enable
                data_reg <= in_data;  // Store FIFO data
                out_data <= in_data;  // Update output data
                load <= 1'b1 ;
                next_state <= CHECK_FIFO_EMPTY;  // Go back to checking FIFO empty state
            end
            
            default: begin
                next_state <= CHECK_FIFO_EMPTY;
                rd_en <= 1'b0;
                data_reg <= 0;
                out_data <= 0;
                load <= 1'b0;
            end
        endcase
    end

endmodule

  
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
        
module data_shifter (
    input clk,
    input rstn,
    input read,                   // Signal that is getting from the uart transmitter fsm
    input load,                   // When the data is read from fifo, this signal becomes high
    input [255:0] data_in,        // Data that is read from fifo
    output reg [7:0] data_out,    // Data that has to be transmit
    output reg flag               // Signal that has to be start the uart transmitter fsm
);

    reg [255:0] shift_reg; // Shift register to hold the data
    reg [5:0] shift_count; // Counter to track the number of shifts
    reg [1:0]state ;
    
    parameter CHECK_READ = 2'b00;
    parameter CHECK_COUNT = 2'b01;
    parameter CHECK_LOAD = 2'b10;
    
    // Initialize shift register and counters on reset
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            shift_reg <= 0;      // Clear shift register on reset
            shift_count <= 0;    // Reset the shift counter
            data_out <= 0;       // Clear data output
            state <= 0; 
            flag <= 0;           // Clear flag
        end else begin
              case(state) 
               CHECK_LOAD : begin
                  if(load) begin
                     shift_reg <= data_in;
                     shift_count <= 0;
                     flag <= 1'b0;
                     state <= CHECK_READ ;
                   end
                   else begin
                     shift_reg <= 0;
                     shift_count <= 0;
                     data_out <= 0;
                     flag <= 1'b1;
                     state <= CHECK_LOAD ;
                    end 
                end   
                  CHECK_READ : begin
                      if (read) begin
                          data_out <= shift_reg [255:248] ;
                          shift_reg <= shift_reg << 8;
                          shift_count <= shift_count + 1 ;
                          state <= CHECK_COUNT;
                       end
                       else begin
                          state <= CHECK_READ ;
                          flag <= 0 ;
                          end
                  end  
                
                CHECK_COUNT : begin
                    if(shift_count == 33) begin
                       flag <= 1'b1;
                       state <= CHECK_LOAD ;
                    end
                    else begin
                       flag <= 1'b0;
                       state <= CHECK_READ ;
                    end
                end
                
                default : begin
                    flag <= 1'b1;
                    state <= CHECK_LOAD;
                end
                
               endcase 
             end 
           end
     endmodule      

