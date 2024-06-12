module convert_data (
    input Axi0Clk ,
    input [255:0] input_data,
    output reg [7:0] R0,
    output reg [7:0] R1,
    output reg [7:0] R2,
    output reg [7:0] R3,
    output reg [7:0] R4,
    output reg [7:0] R5,
    output reg [7:0] R6,
    output reg [7:0] R7,
    output reg [7:0] R8,
    output reg [7:0] R9,
    output reg [7:0] R10,
    output reg [7:0] R11,
    output reg [7:0] R12,
    output reg [7:0] R13,
    output reg [7:0] R14,
    output reg [7:0] R15,
    output reg [7:0] R16,
    output reg [7:0] R17,
    output reg [7:0] R18,
    output reg [7:0] R19,
    output reg [7:0] R20,
    output reg [7:0] R21,
    output reg [7:0] R22,
    output reg [7:0] R23,
    output reg [7:0] R24,
    output reg [7:0] R25,
    output reg [7:0] R26,
    output reg [7:0] R27,
    output reg [7:0] R28,
    output reg [7:0] R29,
    output reg [7:0] R30,
    output reg [7:0] R31
);
 
   always @ (posedge Axi0Clk) R0  <= input_data [7:0];
   always @ (posedge Axi0Clk) R1  <= input_data [15:8];
   always @ (posedge Axi0Clk) R2  <= input_data [23:16];
   always @ (posedge Axi0Clk) R3  <= input_data [31:24];
   always @ (posedge Axi0Clk) R4  <= input_data [39:32];
   always @ (posedge Axi0Clk) R5  <= input_data [47:40];
   always @ (posedge Axi0Clk) R6  <= input_data [55:48];
   always @ (posedge Axi0Clk) R7  <= input_data [63:56];
   always @ (posedge Axi0Clk) R8  <= input_data [71:64];
   always @ (posedge Axi0Clk) R9  <= input_data [79:72];
   always @ (posedge Axi0Clk) R10 <= input_data [87:80];
   always @ (posedge Axi0Clk) R11 <= input_data [95:88];
   always @ (posedge Axi0Clk) R12 <= input_data [103:96];
   always @ (posedge Axi0Clk) R13 <= input_data [111:104];
   always @ (posedge Axi0Clk) R14 <= input_data [119:112];
   always @ (posedge Axi0Clk) R15 <= input_data [127:120];
   always @ (posedge Axi0Clk) R16 <= input_data [135:128];
   always @ (posedge Axi0Clk) R17 <= input_data [143:136];
   always @ (posedge Axi0Clk) R18 <= input_data [151:144];
   always @ (posedge Axi0Clk) R19 <= input_data [159:152];
   always @ (posedge Axi0Clk) R20 <= input_data [167:160];
   always @ (posedge Axi0Clk) R21 <= input_data [175:168];
   always @ (posedge Axi0Clk) R22 <= input_data [183:176];
   always @ (posedge Axi0Clk) R23 <= input_data [191:184];
   always @ (posedge Axi0Clk) R24 <= input_data [199:192];
   always @ (posedge Axi0Clk) R25 <= input_data [207:200];
   always @ (posedge Axi0Clk) R26 <= input_data [215:208];
   always @ (posedge Axi0Clk) R27 <= input_data [223:216];
   always @ (posedge Axi0Clk) R28 <= input_data [231:224];
   always @ (posedge Axi0Clk) R29 <= input_data [239:232];
   always @ (posedge Axi0Clk) R30 <= input_data [247:240];
   always @ (posedge Axi0Clk) R31 <= input_data [255:248];

endmodule


//////////////////////////aa design chale che //////////////////////////////////////////
module t_mux (
    input clk,
    input rst,
    input [4:0] i_sel,
    input [7:0] i_R0,
    input [7:0] i_R1,
    input [7:0] i_R2,
    input [7:0] i_R3,
    input [7:0] i_R4,
    input [7:0] i_R5,
    input [7:0] i_R6,
    input [7:0] i_R7,
    input [7:0] i_R8,
    input [7:0] i_R9,
    input [7:0] i_R10,
    input [7:0] i_R11,
    input [7:0] i_R12,
    input [7:0] i_R13,
    input [7:0] i_R14,
    input [7:0] i_R15,
    input [7:0] i_R16,
    input [7:0] i_R17,
    input [7:0] i_R18,
    input [7:0] i_R19,
    input [7:0] i_R20,
    input [7:0] i_R21,
    input [7:0] i_R22,
    input [7:0] i_R23,
    input [7:0] i_R24,
    input [7:0] i_R25,
    input [7:0] i_R26,
    input [7:0] i_R27,
    input [7:0] i_R28,
    input [7:0] i_R29,
    input [7:0] i_R30,
    input [7:0] i_R31,
    output [7:0] mout_data
);

 assign mout_data = m_out ;
 
 reg [5:0] state = 0;
 reg [7:0] m_out = 0; 
  // reg [4:0] count_sel = 0; 
    parameter data0  = 6'd0  ;
    parameter data1  = 6'd1  ;
    parameter data2  = 6'd2  ;
    parameter data3  = 6'd3  ;
    parameter data4  = 6'd4  ;
    parameter data5  = 6'd5  ;
    parameter data6  = 6'd6  ;
    parameter data7  = 6'd7  ;
    parameter data8  = 6'd8  ;
    parameter data9  = 6'd9  ;
    parameter data10 = 6'd10 ;
    parameter data11 = 6'd11 ;
    parameter data12 = 6'd12 ;
    parameter data13 = 6'd13 ;
    parameter data14 = 6'd14 ;
    parameter data15 = 6'd15 ;
    parameter data16 = 6'd16 ;
    parameter data17 = 6'd17 ;
    parameter data18 = 6'd18 ;
    parameter data19 = 6'd19 ;
    parameter data20 = 6'd20 ;
    parameter data21 = 6'd21 ;
    parameter data22 = 6'd22 ;
    parameter data23 = 6'd23 ;
    parameter data24 = 6'd24 ;
    parameter data25 = 6'd25 ;
    parameter data26 = 6'd26 ;
    parameter data27 = 6'd27 ;
    parameter data28 = 6'd28 ;
    parameter data29 = 6'd29 ;
    parameter data30 = 6'd30 ;
    parameter data31 = 6'd31 ;
    parameter stop_data = 6'd32 ;

    
//   assign mout_data = {i_R0 , i_R1 , i_R2 , i_R3 , i_R4 , i_R5 , i_R6 , i_R7 , i_R8 , i_R9 , i_R10 , i_R11 , i_R12 , i_R13 , i_R14 , i_R15 , i_R16 , i_R17 , i_R18 , i_R19 , i_R20 , i_R21 , i_R22 , i_R23 , i_R24 , i_R25 , i_R26 , i_R27 , i_R28 , i_R29 , i_R30 , i_R31}
  //  always @ ( i_R0 or i_R1 or i_R2 or i_R3 or i_R4 or i_R5 or i_R6 or i_R7 or i_R8 or i_R9 or i_R10 or i_R11 or i_R12 or i_R13 or i_R14 or i_R15 or i_R16 or i_R17 or i_R18 or i_R19 or i_R20 or i_R21 or i_R22 or i_R23 or i_R24 or i_R25 or i_R26 or i_R27 or i_R28 or i_R29 or i_R30 or i_R31 or i_sel) begin
   always @(posedge clk) begin
        if(~rst) begin
                m_out <= 8'b0 ;
                state <= data0;
        end
        
        else begin
            case (state)
               data0 : begin 
                    if (i_sel == 0) begin
                        m_out <= i_R0 ;
                        state <= data1 ;
                    end
               end
               
               data1 : begin
                    if (i_sel == 1) begin
                        m_out <= i_R1 ;
                        state <= data2 ;
                    end
               end 
               
                data2 : begin 
                    if (i_sel == 2) begin
                        m_out <= i_R2 ;
                        state <= data3 ;
                    end
               end
               
               data3 : begin
                    if (i_sel == 3) begin
                        m_out <= i_R3 ;
                        state <= data4 ;
                    end
               end 
               
               data4 : begin 
                    if (i_sel == 4) begin
                        m_out <= i_R4 ;
                        state <= data5 ;
                    end
               end
               
               data5 : begin
                    if (i_sel == 5) begin
                        m_out <= i_R5 ;
                        state <= data6 ;
                    end
               end 
               
                data6 : begin 
                    if (i_sel == 6) begin
                        m_out <= i_R6 ;
                        state <= data7 ;
                    end
               end
               
               data7 : begin
                    if (i_sel == 7) begin
                        m_out <= i_R7 ;
                        state <= data8 ;
                    end
               end 
               
               data8 : begin 
                    if (i_sel == 8) begin
                        m_out <= i_R8 ;
                        state <= data9 ;
                    end
               end
               
               data9 : begin
                    if (i_sel == 9) begin
                        m_out <= i_R9 ;
                        state <= data10 ;
                    end
               end 
               
                data10 : begin 
                    if (i_sel == 10) begin
                        m_out <= i_R10 ;
                        state <= data11 ;
                    end
               end
               
               data11 : begin
                    if (i_sel == 11) begin
                        m_out <= i_R11 ;
                        state <= data12 ;
                    end
               end 
               
               data12 : begin 
                    if (i_sel == 12) begin
                        m_out <= i_R12 ;
                        state <= data13 ;
                    end
               end
               
               data13 : begin
                    if (i_sel == 13) begin
                        m_out <= i_R13 ;
                        state <= data14 ;
                    end
               end 
               
                data14 : begin 
                    if (i_sel == 14) begin
                        m_out <= i_R14 ;
                        state <= data15 ;
                    end
               end
               
               data15 : begin
                    if (i_sel == 15) begin
                        m_out <= i_R15 ;
                        state <= data16 ;
                    end
               end 
               
               data16 : begin 
                    if (i_sel == 16) begin
                        m_out <= i_R16 ;
                        state <= data17 ;
                    end
               end
               
               data17 : begin
                    if (i_sel == 17) begin
                        m_out <= i_R17 ;
                        state <= data18 ;
                    end
               end 
               
                data18 : begin 
                    if (i_sel == 18) begin
                        m_out <= i_R18 ;
                        state <= data19 ;
                    end
               end
               
               data19 : begin
                    if (i_sel == 19) begin
                        m_out <= i_R19 ;
                        state <= data20 ;
                    end
               end 
               
               data20 : begin 
                    if (i_sel == 20) begin
                        m_out <= i_R20 ;
                        state <= data21 ;
                    end
               end
               
               data21 : begin
                    if (i_sel == 21) begin
                        m_out <= i_R21 ;
                        state <= data22 ;
                    end
               end 
               
                data22 : begin 
                    if (i_sel == 22) begin
                        m_out <= i_R22 ;
                        state <= data23 ;
                    end
               end
               
               data23 : begin
                    if (i_sel == 23) begin
                        m_out <= i_R23 ;
                        state <= data24 ;
                    end
               end 
               
               data24 : begin 
                    if (i_sel == 24) begin
                        m_out <= i_R24 ;
                        state <= data25 ;
                    end
               end
               
               data25 : begin
                    if (i_sel == 25) begin
                        m_out <= i_R25 ;
                        state <= data26 ;
                    end
               end 
               
                data26 : begin 
                    if (i_sel == 26) begin
                        m_out <= i_R26 ;
                        state <= data27 ;
                    end
               end
               
               data27 : begin
                    if (i_sel == 27) begin
                        m_out <= i_R27 ;
                        state <= data28 ;
                    end
               end 
               
               data28 : begin 
                    if (i_sel == 28) begin
                        m_out <= i_R28 ;
                        state <= data29 ;
                    end
               end
               
               data29 : begin
                    if (i_sel == 29) begin
                        m_out <= i_R29 ;
                        state <= data30 ;
                    end
               end 
               
                data30 : begin 
                    if (i_sel == 30) begin
                        m_out <= i_R30 ;
                        state <= data31 ;
                    end
               end
               
               data31 : begin
                    if (i_sel == 31) begin
                        m_out <= i_R31 ;
                        state <= stop_data ;
                    end
               end
               
               stop_data : begin
                    m_out <= 0;
               end


               default : m_out <= i_R31 ;
          endcase
         end
    end
    
endmodule
