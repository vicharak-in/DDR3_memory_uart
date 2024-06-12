`timescale 100ps/10ps

////////////////// AxiStat /////////////////////////////

module DdrTestStatic
# (
  	parameter   DDR_CLK_PERIOD  = 32'd800_000_000 ,
  	parameter   AXI_CLK_PERIOD  = 32'd100_000_000 ,
  	parameter   DDR_DATA_WIDTH  = 32              ,
  	parameter   AXI_DATA_WIDTH  = 256             
  )
( 
  //System Signal
  input           SysClk    , //(O)System Clock
  input           Reset_N   , //(I)System Reset (Low Active)
  //DDR Controner Operate Statistics Control & Result
  input           TestBusy  , //(I)Test Busy State  
  input           TestErr   , //(I)Test Read Data Error
  input           StatiClr  , //(I)Staistics Couter Clear
  output  [23:0]  TestTime  , //(O)Test Time      
  output  [23:0]  ErrCnt    , //(O)Test Error Counter   
  output  [47:0]  OpTotCyc  , //(O)Total Operate Cycle Counter
  output  [47:0]  OpActCyc  , //(O)Actual Operate Cycle Counter
  output  [ 9:0]  OpEffic   , //(O)Operate Efficiency
  output  [15:0]  BandWidth , //(O)BandWidth
  output  [9:0]   WrPeriMin , //Write Minimum Period For One Burst
  output  [9:0]   WrPeriAvg , //Write Average Period For One Burst
  output  [9:0]   WrPeriMax , //Write maximum Period For One Burst
  output  [9:0]   RdPeriMin , //Read Minimum Period For One Burst
  output  [9:0]   RdPeriAvg , //Read Average Period For One Burst
  output  [9:0]   RdPeriMax , //Read maximum Period For One Burst
  output          TimeOut   , //(O)TimeOut
  //DDR Controner AXI4 Signal
  input           avalid    , //(I)[Addres] Address Valid
  input           aready    , //(I)[Addres] Address Ready
  input           atype     , //(I)[Addres] Operate Type 0=Read, 1=Write
  input           wlast     , //(I)[Write]  Data Last
  input           wvalid    , //(I)[Write]  Data Valid
  input           wready    , //(I)[Write]  Data Ready
  input           rlast     , //(I)[Read]   Data Last
  input           rvalid    , //(I)[Read]   Data Valid
  input           rready      //(I)[Read]   Data Ready
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
	
	localparam [80:0] CalcEfficCoaf_C = ( AXI_CLK_PERIOD  * AXI_DATA_WIDTH  * {64'h0,17'h1_f4_00}) 
	                                  / ( DDR_CLK_PERIOD  * DDR_DATA_WIDTH );
	
	localparam [16:0] EFFICIENCY_COAF = CalcEfficCoaf_C[18:2]; 
	
	localparam [16:0] BANDWIDTH_COAF  = (AXI_DATA_WIDTH == 256) ? 17'h1_0c_70 : 17'h0_86_38;
	                                                
	/////////////////////////////////////////////////////////

  
//1111111111111111111111111111111111111111111111111111111
//	 
//	Input��
//	output��
//***************************************************/ 
  
  /////////////////////////////////////////////////////////
  
  reg Reg_avalid  ; //(O)[Addres] Address Valid
  reg Reg_aready  ; //(I)[Addres] Address Ready
  reg Reg_atype   ; //(O)[Addres] Operate Type 0=Read, 1=Write
  reg Reg_wlast   ; //(O)[Write]  Data Last
  reg Reg_wvalid  ; //(O)[Write]  Data Valid
  reg Reg_wready  ; //(I)[Write]  Data Ready
  reg Reg_rlast   ; //(I)[Read]   Data Last
  reg Reg_rvalid  ; //(I)[Read]   Data Valid
  reg Reg_rready  ; //(O)[Read]   Data Ready
  
  always @( posedge SysClk)   Reg_avalid  <= # TCo_C  avalid; //(O)[Addres] Address Valid
  always @( posedge SysClk)   Reg_aready  <= # TCo_C  aready; //(I)[Addres] Address Ready
  always @( posedge SysClk)   Reg_atype   <= # TCo_C  atype ; //(O)[Addres] Operate Type 0=Read, 1=Write
  always @( posedge SysClk)   Reg_wlast   <= # TCo_C  wlast ; //(O)[Write]  Data Last
  always @( posedge SysClk)   Reg_wvalid  <= # TCo_C  wvalid; //(O)[Write]  Data Valid
  always @( posedge SysClk)   Reg_wready  <= # TCo_C  wready; //(I)[Write]  Data Ready
  always @( posedge SysClk)   Reg_rlast   <= # TCo_C  rlast ; //(I)[Read]   Data Last
  always @( posedge SysClk)   Reg_rvalid  <= # TCo_C  rvalid; //(I)[Read]   Data Valid
  always @( posedge SysClk)   Reg_rready  <= # TCo_C  rready; //(O)[Read]   Data Ready
  
  /////////////////////////////////////////////////////////
  reg   WrAddrAva;
  reg   WrDataAva;
  reg   WrDataEnd;
  
  always @( posedge SysClk)  WrAddrAva <= # TCo_C Reg_avalid & Reg_aready & Reg_atype ;
  always @( posedge SysClk)  WrDataAva <= # TCo_C Reg_wvalid & Reg_wready             ;
  always @( posedge SysClk)  WrDataEnd <= # TCo_C Reg_wvalid & Reg_wready & Reg_wlast ;
  
  
  /////////////////////////////////////////////////////////
  reg   RdAddrAva;
  reg   RdDataAva;
  reg   RdDataEnd;
  
  always @( posedge SysClk)  RdAddrAva <= # TCo_C Reg_avalid & Reg_aready & (~Reg_atype);
  always @( posedge SysClk)  RdDataAva <= # TCo_C Reg_rvalid & Reg_rready               ;
  always @( posedge SysClk)  RdDataEnd <= # TCo_C Reg_rvalid & Reg_rready &   Reg_rlast ;
  
  /////////////////////////////////////////////////////////   
  reg         Axi4Active = 1'h0 ; 
  reg   [7:0] TimeOutCnt = 8'hff;
  reg         TimeOutAva = 1'h0 ;
  
  always @( posedge SysClk)   Axi4Active  <= # TCo_C  WrAddrAva | WrDataAva | RdAddrAva | RdDataAva;
  always @( posedge SysClk)   TimeOutCnt  <= # TCo_C  Axi4Active ? 8'hff : (TimeOutCnt - {7'h0,(|TimeOutCnt)});
  always @( posedge SysClk)   TimeOutAva  <= # TCo_C  (TimeOutCnt == 8'h1);
  
  assign  TimeOut = TimeOutAva;
    
  /////////////////////////////////////////////////////////    
  reg [27:0]  SecendCnt   = 28'h0;
  reg         SecendEn    =  1'h0;
  reg [23:0]  TestSecCnt  = 24'h0;
  
  always @( posedge SysClk)  
  begin
    if (StatiClr)         SecendCnt <= # TCo_C AXI_CLK_PERIOD - 28'h1; 
    else if (|SecendCnt)  SecendCnt <= # TCo_C SecendCnt      - 28'h1;
    else                  SecendCnt <= # TCo_C AXI_CLK_PERIOD - 28'h1;
  end
  
  always @( posedge SysClk)  SecendEn <= # TCo_C (SecendCnt == 28'h0);  
  always @( posedge SysClk)  
  begin
    if (StatiClr)       TestSecCnt <= # TCo_C 24'h0;
    else if (SecendEn)  TestSecCnt <= # TCo_C TestSecCnt + 24'h1;
  end
    
  /////////////////////////////////////////////////////////
  reg [23:0]  OpErrCnt;
  
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)       OpErrCnt <= # TCo_C 24'h0;
    else if (StatiClr)  OpErrCnt <= # TCo_C 24'h0;
    else if (TestErr )  OpErrCnt <= # TCo_C OpErrCnt + {23'h0,(~&OpErrCnt)};
  end
       
  /////////////////////////////////////////////////////////  
  assign  TestTime  = TestSecCnt ; //(O)Test Time
  assign  ErrCnt    = OpErrCnt   ; //(O)Test Error Counter     
      
//1111111111111111111111111111111111111111111111111111111




//2222222222222222222222222222222222222222222222222222222
//	
//	Input��
//	output��
//***************************************************/ 

  /////////////////////////////////////////////////////////
  reg [7:0] WrBurstCnt  = 8'h0;
  reg [7:0] RdBurstCnt  = 8'h0;
  reg       OperateAva  = 1'h0;
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (~Reset_N)         WrBurstCnt <= # TCo_C 8'h0;
    else if (WrAddrAva ^ WrDataEnd)
    begin
      if (WrAddrAva)        WrBurstCnt <= # TCo_C WrBurstCnt + {7'h0,(~&WrBurstCnt)};
      else if (WrDataEnd)   WrBurstCnt <= # TCo_C WrBurstCnt - {7'h0,( |WrBurstCnt)};
    end
  end
    
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (~Reset_N)         RdBurstCnt <= # TCo_C 8'h0;
    else if (RdAddrAva ^ RdDataEnd)
    begin
      if (RdAddrAva)      RdBurstCnt <= # TCo_C RdBurstCnt + {7'h0,(~&RdBurstCnt)};
      else if (RdDataEnd) RdBurstCnt <= # TCo_C RdBurstCnt - {7'h0,( |RdBurstCnt)};
    end
  end
    
  always @( posedge SysClk)  OperateAva <= # TCo_C (|WrBurstCnt) | (|RdBurstCnt);
  
  /////////////////////////////////////////////////////////
  reg [23:0]  OpTotalCntL  = 24'h0;
  reg [23:0]  OpTotalCntH  = 24'h0;
  reg         OpTotalCryEn =  1'h0;
  
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)         OpTotalCntL <= # TCo_C 24'h0;
    else if (StatiClr)    OpTotalCntL <= # TCo_C 24'h0;
    else if (OperateAva)  OpTotalCntL <= # TCo_C OpTotalCntL + 24'h1;
  end
  
  always @( posedge SysClk)   OpTotalCryEn <= # TCo_C  (OpTotalCntL == 24'hff_ff_fe);  
  
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)         OpTotalCntH <= # TCo_C 24'h0;
    else if (StatiClr)    OpTotalCntH <= # TCo_C 24'h0;
    else if (OperateAva)  OpTotalCntH <= # TCo_C OpTotalCntH + {23'h0,OpTotalCryEn};
  end
  
  /////////////////////////////////////////////////////////  
  assign  OpTotCyc   = {OpTotalCntH , OpTotalCntL}; ////(O)Total Operate Cycle Counter
  
  /////////////////////////////////////////////////////////
  
//2222222222222222222222222222222222222222222222222222222 


//3333333333333333333333333333333333333333333333333333333
//	
//	Input��
//	output��
//***************************************************/ 
  /////////////////////////////////////////////////////////
  reg [1:0] OpAvaCycle;
  
  always @( posedge SysClk)  OpAvaCycle <= # TCo_C {1'h0,WrDataAva} + {1'h0,RdDataAva};
  
  /////////////////////////////////////////////////////////
  reg [23:0]  OpActualCntL    = 24'h0;
  reg [23:0]  OpActualCntH    = 24'h0;
  reg         OpActualCryEn   =  1'h0;
  
  wire  [24:0]  CalcOpActual = OpActualCntL + {23'h0,OpAvaCycle};
  
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)             OpActualCntL <= # TCo_C 24'h0;
    else if (StatiClr)        OpActualCntL <= # TCo_C 24'h0;
    else                      OpActualCntL <= # TCo_C CalcOpActual[23:0];
  end
  
  always @( posedge SysClk)   OpActualCryEn <= # TCo_C  CalcOpActual[24];  
  
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)             OpActualCntH <= # TCo_C 24'h0;
    else if (StatiClr)        OpActualCntH <= # TCo_C 24'h0;
    else if (OpActualCryEn)   OpActualCntH <= # TCo_C  OpActualCntH + 24'h1;
  end
  
  /////////////////////////////////////////////////////////  
  assign  OpActCyc    = {OpActualCntH , OpActualCntL}  ; //(O)Actual Operate Cycle Counter
  
  
//3333333333333333333333333333333333333333333333333333333



//4444444444444444444444444444444444444444444444444444444
//	
//	Input��
//	output��
//***************************************************/ 
  /////////////////////////////////////////////////////////     
  reg   [24:0]  OpEfficCnt;
  reg   [16:0]  OpEfficReg;    
    
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)           OpEfficCnt <= # TCo_C 25'h0;
    else if (StatiClr)      OpEfficCnt <= # TCo_C 25'h0;
    else if (OpTotalCryEn)  OpEfficCnt <= # TCo_C {23'h0,OpAvaCycle};
    else                    OpEfficCnt <= # TCo_C {23'h0,OpAvaCycle} + OpEfficCnt; 
  end
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (~Reset_N)           OpEfficReg <= # TCo_C 17'h0;
    else if (StatiClr)      OpEfficReg <= # TCo_C 17'h0;
    else if (OpTotalCryEn)  OpEfficReg <= # TCo_C OpEfficCnt[24:8];
  end
  
  /////////////////////////////////////////////////////////
  reg   [ 9:0]  EfficiencyReg ;
  wire  [33:0]  EfficiencyCalc  = OpEfficReg * EFFICIENCY_COAF;
  
  always @( posedge SysClk)  EfficiencyReg <= # TCo_C EfficiencyCalc[30:21];
                     
  /////////////////////////////////////////////////////////
  assign  OpEffic = EfficiencyReg ; //(O)Operate Efficiency
  
//4444444444444444444444444444444444444444444444444444444


//5555555555555555555555555555555555555555555555555555555
//	
//	Input��
//	output��
//***************************************************/ 
  /////////////////////////////////////////////////////////     
  reg   [26:0]  OpCycSecCnt;
  reg   [16:0]  OpCycSecReg;    
    
  always @( posedge SysClk or negedge Reset_N)    
  begin
    if (~Reset_N)       OpCycSecCnt <= # TCo_C 27'h0;
    else if (StatiClr)  OpCycSecCnt <= # TCo_C 27'h0;
    else if (SecendEn)  OpCycSecCnt <= # TCo_C {25'h0,OpAvaCycle};
    else                OpCycSecCnt <= # TCo_C {25'h0,OpAvaCycle} + OpCycSecCnt; 
  end
  
  wire  BWCalcEn = SecendEn & TestBusy;
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (~Reset_N)       OpCycSecReg <= # TCo_C 10'h0;
    else if (StatiClr)  OpCycSecReg <= # TCo_C 10'h0;
    else if (BWCalcEn)  OpCycSecReg <= # TCo_C OpCycSecCnt[26:10];
  end
  
  /////////////////////////////////////////////////////////
  reg   [33:0]  BandWidthReg  ;
  
  always @( posedge SysClk)  BandWidthReg <= # TCo_C OpCycSecReg * BANDWIDTH_COAF;
  
  /////////////////////////////////////////////////////////
  assign  BandWidth =  BandWidthReg[33:18];  //{1'h0,OpCycSecReg[26:11] ; //(O)BandWidth
  
//5555555555555555555555555555555555555555555555555555555


//6666666666666666666666666666666666666666666666666666666
//	
//	Input��
//	output��
//***************************************************/ 
                 
  /////////////////////////////////////////////////////////
  reg [19:0]  WrPeriodCnt     = 20'h0;
  reg         WrPeriodStaEn   =  1'h0;
  
  always @( posedge SysClk)  
  begin
    if (StatiClr )            WrPeriodCnt     <= # TCo_C  20'h0 ;
    else if (WrDataEnd)       WrPeriodCnt     <= # TCo_C  20'h1 + WrPeriodCnt;
  end
  
  always @( posedge SysClk)   WrPeriodStaEn   <= # TCo_C  &WrPeriodCnt & WrDataEnd;
  
  /////////////////////////////////////////////////////////
  reg [29:0]  WrPeriodStaCnt  = 30'h0 ;
  reg [ 9:0]  WrPeriodAvgReg  = 10'h0 ;
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             WrPeriodStaCnt  <= # TCo_C  30'h0 ;
    else if (StatiClr)        WrPeriodStaCnt  <= # TCo_C  30'h0 ;
    else if (WrPeriodStaEn)   WrPeriodStaCnt  <= # TCo_C  30'h0 ;
    else                      WrPeriodStaCnt  <= # TCo_C  30'h1 + WrPeriodStaCnt;
  end                                                     
                                                          
  always @( posedge SysClk or negedge Reset_N)            
  begin                                                   
    if (!Reset_N)             WrPeriodAvgReg  <= # TCo_C  10'h0;
    else if (StatiClr)        WrPeriodAvgReg  <= # TCo_C  10'h0;
    else if (WrPeriodStaEn)   WrPeriodAvgReg  <= # TCo_C  WrPeriodStaCnt[29:20];
  end  
  
  /////////////////////////////////////////////////////////
  reg [9:0] CalcWrPeriodCnt   = 10'h0 ;
  reg [9:0] CalcWrPeriodReg   = 10'h0 ;
                               
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             CalcWrPeriodCnt <= # TCo_C  10'h0 ;
    else if (StatiClr)        CalcWrPeriodCnt <= # TCo_C  10'h0 ;
    else if (WrDataEnd)       CalcWrPeriodCnt <= # TCo_C  10'h0 ;
    else                      CalcWrPeriodCnt <= # TCo_C  10'h1 + CalcWrPeriodCnt;
  end                                                     
                                                          
  always @( posedge SysClk or negedge Reset_N)            
  begin                                                   
    if (!Reset_N)             CalcWrPeriodReg <= # TCo_C  10'h0;
    else if (StatiClr)        CalcWrPeriodReg <= # TCo_C  10'h0;
    else if (WrDataEnd)       CalcWrPeriodReg <= # TCo_C  CalcWrPeriodCnt;
  end
  
  /////////////////////////////////////////////////////////
  reg       WrPeriGreatMax    =  1'h0 ;
  reg [9:0] CalcWrPeriodMax   = 10'h0 ;
  reg [9:0] WrPeriodMaxReg    = 10'h0 ;
  
  always @( posedge SysClk)   WrPeriGreatMax  <= # TCo_C  (CalcWrPeriodReg > CalcWrPeriodMax) & WrDataEnd;
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             CalcWrPeriodMax <= # TCo_C  10'h0;
    else if (StatiClr)        CalcWrPeriodMax <= # TCo_C  10'h0;
//    else if (WrPeriodStaEn)   CalcWrPeriodMax <= # TCo_C  10'h0;
    else if (WrPeriGreatMax)  CalcWrPeriodMax <= # TCo_C  CalcWrPeriodReg;
  end
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             WrPeriodMaxReg  <= # TCo_C  10'h0;
    else if (StatiClr)        WrPeriodMaxReg  <= # TCo_C  10'h0;
    else if (WrPeriodStaEn)   WrPeriodMaxReg  <= # TCo_C  CalcWrPeriodMax;
  end  
  
  /////////////////////////////////////////////////////////
  reg       WrPeriLessMin     =  1'h0   ;
  reg [9:0] CalcWrPeriodMin   = 10'h3ff ;
  reg [9:0] WrPeriodMinReg    = 10'h3ff ;
  
  always @( posedge SysClk)   WrPeriLessMin   <= # TCo_C  (CalcWrPeriodReg < CalcWrPeriodMin) & WrDataEnd;
  always @( posedge SysClk or negedge Reset_N)            
  begin                                                   
    if (!Reset_N)             CalcWrPeriodMin <= # TCo_C  10'h3ff;
    else if (StatiClr)        CalcWrPeriodMin <= # TCo_C  10'h3ff;
//    else if (WrPeriodStaEn)   CalcWrPeriodMin <= # TCo_C  10'h3ff;
    else if (WrPeriLessMin)   CalcWrPeriodMin <= # TCo_C  CalcWrPeriodReg;
  end
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             WrPeriodMinReg  <= # TCo_C  10'h3ff;
    else if (StatiClr)        WrPeriodMinReg  <= # TCo_C  10'h3ff;
    else if (WrPeriodStaEn)   WrPeriodMinReg  <= # TCo_C  CalcWrPeriodMin;
  end
  
  /////////////////////////////////////////////////////////
  assign WrPeriMin = WrPeriodMinReg ; //write Minimum Period For One Burst
  assign WrPeriAvg = WrPeriodAvgReg ; //write Average  Period For One Burst
  assign WrPeriMax = WrPeriodMaxReg ; //write maximum Period For One Burst
  
//6666666666666666666666666666666666666666666666666666666



//7777777777777777777777777777777777777777777777777777777
//	
//	Input��
//	output��
//***************************************************/ 
                 
  /////////////////////////////////////////////////////////
  reg [19:0]  RdPeriodCnt     = 20'h0;
  reg         RdPeriodStaEn   =  1'h0;
  
  always @( posedge SysClk)  
  begin
    if (StatiClr )            RdPeriodCnt     <= # TCo_C  20'h0 ;
    else if (RdDataEnd)       RdPeriodCnt     <= # TCo_C  20'h1 + RdPeriodCnt  ;
  end                                            
                                                 
  always @( posedge SysClk)   RdPeriodStaEn   <= # TCo_C  &RdPeriodCnt & RdDataEnd;
  
  /////////////////////////////////////////////////////////
  reg [29:0]  RdPeriodStaCnt    = 30'h0 ;
  reg [9:0]   RdPeriodAvgReg    = 10'h0 ;
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             RdPeriodStaCnt  <= # TCo_C  30'h0 ;
    else if (StatiClr)        RdPeriodStaCnt  <= # TCo_C  30'h0 ;
    else if (RdPeriodStaEn)   RdPeriodStaCnt  <= # TCo_C  30'h0 ;
    else                      RdPeriodStaCnt  <= # TCo_C  30'h1 + RdPeriodStaCnt;
  end                                                     
                                                          
  always @( posedge SysClk or negedge Reset_N)            
  begin                                                   
    if (!Reset_N)             RdPeriodAvgReg  <= # TCo_C  10'h0 ;
    else if (StatiClr)        RdPeriodAvgReg  <= # TCo_C  10'h0 ;
    else if (RdPeriodStaEn)   RdPeriodAvgReg  <= # TCo_C  RdPeriodStaCnt[29:20];
  end  
  
  /////////////////////////////////////////////////////////
  reg [9:0] CalcRdPeriodCnt   = 10'h0;
  reg [9:0] CalcRdPeriodReg   = 10'h0;
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             CalcRdPeriodCnt <= # TCo_C  10'h0 ;
    else if (StatiClr)        CalcRdPeriodCnt <= # TCo_C  10'h0 ;
    else if (RdDataEnd)       CalcRdPeriodCnt <= # TCo_C  10'h0 ;
    else                      CalcRdPeriodCnt <= # TCo_C  10'h1 + CalcRdPeriodCnt;
  end
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             CalcRdPeriodReg <= # TCo_C  10'h0 ;
    else if (StatiClr)        CalcRdPeriodReg <= # TCo_C  10'h0 ;
    else if (RdDataEnd)       CalcRdPeriodReg <= # TCo_C  CalcRdPeriodCnt;
  end
  
  /////////////////////////////////////////////////////////
  reg       RdPeriGreatMax    =  1'h0 ;
  reg [9:0] CalcRdPeriodMax   = 10'h0 ;
  reg [9:0] RdPeriodMaxReg    = 10'h0 ;
  
  always @( posedge SysClk)   RdPeriGreatMax  <= # TCo_C  (CalcRdPeriodReg > CalcRdPeriodMax) & RdDataEnd;
  always @( posedge SysClk or negedge Reset_N)            
  begin                                                   
    if (!Reset_N)             CalcRdPeriodMax <= # TCo_C  10'h0;
    else if (StatiClr)        CalcRdPeriodMax <= # TCo_C  10'h0;
//    else if (RdPeriodStaEn)   CalcRdPeriodMax <= # TCo_C  10'h0;
    else if (RdPeriGreatMax)  CalcRdPeriodMax <= # TCo_C  CalcRdPeriodReg;
  end
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (!Reset_N)             RdPeriodMaxReg  <= # TCo_C  10'h0;
    else if (StatiClr)        RdPeriodMaxReg  <= # TCo_C  10'h0;
    else if (RdPeriodStaEn)   RdPeriodMaxReg  <= # TCo_C  CalcRdPeriodMax;
  end  
  
  /////////////////////////////////////////////////////////
  reg       RdPeriLessMin     =  1'h0   ;
  reg [9:0] CalcRdPeriodMin   = 10'h3ff ;
  reg [9:0] RdPeriodMinReg    = 10'h3ff ;
  
  always @( posedge SysClk)   RdPeriLessMin   <= # TCo_C  (CalcRdPeriodReg < CalcRdPeriodMin) & RdDataEnd;
  always @( posedge SysClk or negedge Reset_N)    
  begin                                         
    if (!Reset_N)             CalcRdPeriodMin <= # TCo_C  10'h3ff;
    else if (StatiClr)        CalcRdPeriodMin <= # TCo_C  10'h3ff;
//    else if (RdPeriodStaEn)   CalcRdPeriodMin <= # TCo_C  10'h3ff;
    else if (RdPeriLessMin)   CalcRdPeriodMin <= # TCo_C  CalcRdPeriodReg;
  end                                                     
                                                          
  always @( posedge SysClk or negedge Reset_N)            
  begin                                                   
    if (!Reset_N)             RdPeriodMinReg  <= # TCo_C  10'h3ff;
    else if (StatiClr)        RdPeriodMinReg  <= # TCo_C  10'h3ff;
    else if (RdPeriodStaEn)   RdPeriodMinReg  <= # TCo_C  CalcRdPeriodMin;
  end
  
  /////////////////////////////////////////////////////////
  assign RdPeriMin = RdPeriodMinReg ; //Read Minimum Period For One Burst
  assign RdPeriAvg = RdPeriodAvgReg ; //Read Average  Period For One Burst
  assign RdPeriMax = RdPeriodMaxReg ; //Read maximum Period For One Burst
  
  /////////////////////////////////////////////////////////
  
//7777777777777777777777777777777777777777777777777777777



//8888888888888888888888888888888888888888888888888888888
//	
//	Input��
//	output��
//***************************************************/ 
                 
  /////////////////////////////////////////////////////////
  
//8888888888888888888888888888888888888888888888888888888

endmodule

////////////////// DdrTestStat /////////////////////////////