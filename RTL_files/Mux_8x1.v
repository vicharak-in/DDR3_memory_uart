module Mux_8x1(
  input clk,          // Clock signal
  input rst,              // Reset signal
  input [31:0] input_data,  // Input 32-bit data
  output [255:0] register ,  // Eight 32-bit registers
  input i_count ,
  output [31:0] test_reg,
  output reg check_data 
  );
 
  //reg [31:0] mem_data = 0; 
  
  //assign mem_data = mem_reg[0] ;
 
  assign  test_reg = mem_reg[0] ;
  reg [31:0] mem_reg [7:0] ;
  reg [7:0] input_data_count = 0;    // Counter to track input data index
  //reg [2:0] register_index = 0; // Counter to track register index
  reg [3:0] state = 0; 
  
  parameter f_data = 4'd0;
  parameter s_data = 4'd1;
  parameter t_data = 4'd2;
  parameter fo_data = 4'd3;
  parameter fi_data = 4'd4;
  parameter si_data = 4'd5;
  parameter se_data = 4'd6;
  parameter e_data = 4'd7;
  parameter stop_data = 4'd8;
  
  
  assign register = {mem_reg[0], mem_reg[1], mem_reg[2], mem_reg[3], mem_reg[4], mem_reg[5], mem_reg[6], mem_reg[7]} ;
  
always @(posedge i_count) begin
    if(~rst) begin
        input_data_count <= 0;
    end
    
    else
        input_data_count <= input_data_count + 1;
                 
end

always@(posedge clk)
begin

    if(~rst)
      state <= f_data;
      
    else begin
        case (state)
           f_data : begin 
             if(input_data_count == 6) begin
                mem_reg[0] <= input_data;
                state <= s_data;
                check_data <= 1'b0 ;
             end
             else
                state <= f_data;
           end
           
           s_data : begin
             if(input_data_count == 10) begin
                mem_reg[1] <= input_data;
                state <= t_data;
             end
             else
                state <= s_data;
           end
           
           t_data : begin
             if(input_data_count == 14) begin
                mem_reg[2] <= input_data;
                state <= fo_data;
             end
             else
                state <= t_data;
           end         
           
           fo_data : begin
             if(input_data_count == 18) begin
                mem_reg[3] <= input_data;
                state <= fi_data;
             end
             else
                state <= fo_data;
           end     
           
           fi_data : begin
             if(input_data_count == 22) begin
                mem_reg[4] <= input_data;
                state <= si_data;
             end
             else
                state <= fi_data;
           end
           
           si_data : begin
             if(input_data_count == 26) begin
                mem_reg[5] <= input_data;
                state <= se_data;
             end
             else
                state <= si_data;
           end
           
           se_data : begin
             if(input_data_count == 30) begin
                mem_reg[6] <= input_data;
                state <= e_data;
             end
             else
                state <= se_data;
           end
           
           e_data : begin
             if(input_data_count == 34) begin
                mem_reg[7] <= input_data;
                check_data <= 1'b1 ;
                state <= stop_data;
             end
             else
                state <= e_data;
           end
           
           stop_data : begin
            state <= stop_data;
          end
          
       endcase
  end
end  

endmodule