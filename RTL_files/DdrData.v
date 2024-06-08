
`timescale 100ps/10ps

module DdrWrDataGen   
#(
  parameter   AXI_DATA_WIDTH = 256
  )
(   
  input               SysClk    , //System Clock
  input   [31:0]      WrAddrIn  , //(I)[DdrWrDataGen]Write Address Input 
  input               WrStartEn , //(I)[DdrWrDataGen]Write Start Enale
  input               WriteEn   , //(I)[DdrWrDataGen]Write Enable
  output  [ADW_C-1:0]  DdrWrData   //(O)[DdrWrDataGen]DDR Write Data
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  localparam   TCo_C  = 1;    
    
  localparam  [15:0]  AXI_BYTE_NUM  =   AXI_DATA_WIDTH/8  ;
  localparam          ADW_C         =   AXI_DATA_WIDTH    ;
  
  /////////////////////////////////////////////////////////             
    
//1111111111111111111111111111111111111111111111111111111
//  
//  Input��
//  output��
//***************************************************/ 
  reg   [ADW_C-1:0]  AddrData  = {ADW_C{1'h0}};    
        
  tri0  [15:0]      Adder     [7:0];
  wire  [15:0]      AddValue  [7:0];
  
  genvar  j;
  generate  
    for (j=0;j<ADW_C/32;j=j+1)
    begin : DdrWrDataGen_AddrData_Output
      
      assign Adder[j]             = {11'h0,j,2'h0};
      assign AddValue[j][15:0]    = WrAddrIn[31:16] + WrAddrIn[15:0] + Adder[j] ;
      
      always @( posedge SysClk)  
      begin
        if (WriteEn)
        begin
          AddrData[j*32+15:j*32   ]  <= # TCo_C   AddValue[j][15:0] + AXI_BYTE_NUM;
          AddrData[j*32+31:j*32+16]  <= # TCo_C   AddValue[j][2] ? 16'haaaa : 16'h5555;
        end
        else if (WrStartEn)
        begin         
          AddrData[j*32+15:j*32   ]  <= # TCo_C   AddValue[j][15:0];
          AddrData[j*32+31:j*32+16]  <= # TCo_C   AddValue[j][2] ? 16'haaaa : 16'h5555;
        end
      end 
      
    end
  endgenerate                       
                              
  assign  DdrWrData   = AddrData; //(O)[DdrWrDataGen]DDR Write Data     
  
endmodule 
  
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//DDR Read Data and Address check module 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module DdrRdDataChk 
# (
    parameter RIGHT_CNT_WIDTH = 12  ,
    parameter AXI_DATA_WIDTH  = 256 
  )
(   
  input               SysClk    , //(I)System Clock
  input   [     31:0] RdAddrIn  , //(I)[DdrRdDataChk]Read Address Input  
  input               RdDataEn  , //(I)[DdrRdDataChk]DDR Read Data Valid         
  input   [ADW_C-1:0] DdrRdData , //(I)[DdrRdDataChk]DDR Read DataOut      
  output              DdrRdError, //(O)[DdrRdDataChk]DDR Prbs Error         
  output              DdrRdRight    //(O)[DdrRdDataChk]DDR Read Right           
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  localparam   TCo_C     = 1;    
    
  localparam  AXI_LONGWORD_NUM = AXI_DATA_WIDTH/32;
  
  localparam  ADW_C = AXI_DATA_WIDTH  ;  
  localparam  LWN_C = AXI_LONGWORD_NUM;
  
  /////////////////////////////////////////////////////////
  
//1111111111111111111111111111111111111111111111111111111
//  
//  Input��
//  output��
//***************************************************/ 
  
  /////////////////////////////////////////////////////////
  wire [15:0] CalcAddrValue    = RdAddrIn[31:16] + RdAddrIn[15:0];  
  
  reg [LWN_C-1:0]  ChkValue  = {LWN_C{1'h0}};
  reg [LWN_C-1:0]  ChkFlag   = {LWN_C{1'h0}};
    
  always @( posedge SysClk)  
  begin
    ChkValue[0]   <= # TCo_C DdrRdData[15: 0] ==  CalcAddrValue    ;
    ChkFlag [0]   <= # TCo_C DdrRdData[31:16] == (CalcAddrValue[2] ? 16'haaaa : 16'h5555);
  end
  
  /////////////////////////////////////////////////////////
  reg [15:0]  AddrValueReg = 16'h0;
  
  always @( posedge SysClk)  AddrValueReg <= # TCo_C CalcAddrValue;
  
  /////////////////////////////////////////////////////////
  genvar  j;
  generate  
    for (j=1;j<LWN_C;j=j+1)
    begin : DdrRdDataChk_Check
      always @( posedge SysClk)  
      begin
        ChkValue[j]   <= # TCo_C DdrRdData[j*32+15 : j*32   ] ==  ( DdrRdData[(j-1)*32+15 : (j-1)*32   ]  + 16'h4)  ;
        ChkFlag [j]   <= # TCo_C DdrRdData[j*32+31 : j*32+16] ==  (~DdrRdData[(j-1)*32+31 : (j-1)*32+16]  )         ;
      end
    end
  endgenerate
  
  /////////////////////////////////////////////////////////
  reg  [2:0]  RdDataEnReg = 3'h0;
  
  always @( posedge SysClk)  RdDataEnReg <= # TCo_C {RdDataEnReg[1:0],RdDataEn};
  
  /////////////////////////////////////////////////////////
  reg  CheckDataErr = 1'h0;
  
  always @( posedge SysClk)  if (RdDataEnReg[0])  CheckDataErr <= # TCo_C ~((&ChkValue) & (&ChkFlag));
  
  /////////////////////////////////////////////////////////
  reg   RdDataErr = 1'h0;
  
  always @( posedge SysClk)  RdDataErr <= # TCo_C (~((&ChkValue) & (&ChkFlag))) & RdDataEnReg[0];
//  always @( posedge SysClk)  RdDataErr <= # TCo_C CheckDataErr & RdDataEnReg[1];
  
  /////////////////////////////////////////////////////////
  reg [RIGHT_CNT_WIDTH-1:0] TimeOutCnt = {RIGHT_CNT_WIDTH{1'h0}};
  
  always @( posedge SysClk)  
  begin
    if (RdDataEnReg[0])   TimeOutCnt <= # TCo_C {RIGHT_CNT_WIDTH{1'h0}};
   // else                  TimeOutCnt <= # TCo_C TimeOutCnt + (~&TimeOutCnt);
    else                  TimeOutCnt <= # TCo_C TimeOutCnt + {{(RIGHT_CNT_WIDTH-1){1'h0}},(~&TimeOutCnt)};
  end
  
  wire  RightClr = TimeOutCnt[RIGHT_CNT_WIDTH-1];
  
  /////////////////////////////////////////////////////////
  reg [RIGHT_CNT_WIDTH-1:0] AddrRightCnt = {RIGHT_CNT_WIDTH{1'h0}};
  
  always @( posedge SysClk)  if (RdDataEnReg[1])
  begin
    if (RdDataErr)      AddrRightCnt <= # TCo_C {RIGHT_CNT_WIDTH{1'h0}};
    else if (RightClr)  AddrRightCnt <= # TCo_C {RIGHT_CNT_WIDTH{1'h0}};
    else                AddrRightCnt <= # TCo_C AddrRightCnt + {{(RIGHT_CNT_WIDTH-1){1'h0}},(~&AddrRightCnt)};
  end
  
  wire  AddrRight = &AddrRightCnt ;
  
/////////////////////////////////////////////////////////
  assign  DdrRdError  =   RdDataErr ; //(O)[DdrRdDataChk]DDR Prbs Error        
  assign  DdrRdRight  =   AddrRight ; //(O)[DdrRdDataChk]DDR Read Right  
  
/////////////////////////////////////////////////////////
    
//1111111111111111111111111111111111111111111111111111111

endmodule 
  
    
    
    