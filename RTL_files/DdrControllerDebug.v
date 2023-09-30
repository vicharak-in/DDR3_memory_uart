`timescale 100ps/10ps

//`include  "ParamDefine.v"

///////////////////////////////////////////////////////////
/**********************************************************
  功能描述：

  重要输入信号要求：
  详细设计方案文件编号：
  仿真文件名：

  编制：朱仁昌
  创建日期： 2019-12-1
  版本：V1、0
  修改记录：
  
    2020.1.29 ---V1.0
    ==============================
    第一个版本
    功能说明：
    1、对DDR进行可配置的连续读写控制，并对数据进行检查；
    2、数据与地址相关，可配置正向数据、反向数据、正向/反向交替，确保数据检查客观性；
    3、可配置DDR控制器的Burst长度和Burst个数；
    4、可配置测试的DDR控制器的起始地址和结束地址，电路对设置的测试空间循环测试；
    5、测试数据错误个数（仅限于有读的操作）；
    6、测试操作的总周期、有效操作周期、操作效率、带宽；
    7、从测试起始进行计时；
    8、通过指示灯直观指示状态和误码状况；
    8、通过VIO进行测试配置、控制、统计结果和状态显示、波形抓取；
    
  /////////////////////   
    2020.1.30 ---V1.1
    ==============================
    修改了使用上的一些限制，和代码的整理

    修改了：
    1、AXI Burst 长度（ALEN）的设置，使配置的Burst长度为任意值;
    2、连续测试条件修改为TestLen = 0 或 32’hffffffff；
    3、修改了读写越界的BUG——原来测试区域的最后一个数据读写会越界；
    
  /////////////////////   
    2020.1.31 ---V1.2
    ==============================
    修改了参数化配置的需求

    修改了：
    1、Axi0和Axi1的时钟和复位分开
    2、与AXI-DATA-WIDTH有关的参数全部使用变量代替；
    3、增加了256和128位接口的测试选择；
    4、修改Debuger的信号名称，便于理解；
  
  /////////////////////   
    2020.2.2 ---V1.3
    ==============================
    修改了测试中发现的Bug

    修改了：
    1、CfgBurstLen在大于127时会直接采用255的Bug
    2、修改CfgBurstLen在修改后第一次会沿用上一次的值；
    3、修改了TestMode=3且TestLen小于3时，不启动Read的Bug；
    4、提高DDR的写效率，把写间隔缩小到最小（一个时钟周期）；
    5、添加读写Burst周期的测量——用于下一步效率改善测试；
    
**********************************************************/

`define   Test_AXI0
`define   Efinity_Debug

module  DdrControllerDebug
(
  //Check Resultwire
`ifdef  Efinity_Debug  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  input  jtag_inst1_CAPTURE ,
  input  jtag_inst1_DRCK    ,
  input  jtag_inst1_RESET   ,
  input  jtag_inst1_RUNTEST ,
  input  jtag_inst1_SEL     ,
  input  jtag_inst1_SHIFT   ,
  input  jtag_inst1_TCK     ,
  input  jtag_inst1_TDI     ,
  input  jtag_inst1_TMS     ,
  input  jtag_inst1_UPDATE  ,
  output jtag_inst1_TDO     ,
`endif  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  //System Signal
  input           SysClk    , //System Clock
  input           Axi0Clk   , //Axi 0 Channel Clock
  input           Axi1Clk   , //Axi 1 Channel Clock
  input   [ 1:0]  PllLocked , //PLL Locked
 // input  [255:0]  Ram_Wr    ,
   input           TestStart ,
                                                 
  //DDR Controner Control Signal
  output      DdrCtrl_CFG_RST_N          , //(O)[Control]DDR Controner Reset(Low Active)     
  output      DdrCtrl_CFG_SEQ_RST   , //(O)[Control]DDR Controner Sequencer Reset 
  output      DdrCtrl_CFG_SEQ_START , //(O)[Control]DDR Controner Sequencer Start 
  //DDR Controner AXI4 0 Signal
  output  [ 7:0]  DdrCtrl_AID_0     , //(O)[Addres] Address ID
  output  [31:0]  DdrCtrl_AADDR_0   , //(O)[Addres] Address
  output  [ 7:0]  DdrCtrl_ALEN_0    , //(O)[Addres] Address Brust Length
  output  [ 2:0]  DdrCtrl_ASIZE_0   , //(O)[Addres] Address Burst size
  output  [ 1:0]  DdrCtrl_ABURST_0  , //(O)[Addres] Address Burst type
  output  [ 1:0]  DdrCtrl_ALOCK_0   , //(O)[Addres] Address Lock type
  output          DdrCtrl_AVALID_0  , //(O)[Addres] Address Valid
  input           DdrCtrl_AREADY_0  , //(I)[Addres] Address Ready
  output          DdrCtrl_ATYPE_0   , //(O)[Addres] Operate Type 0=Read, 1=Write

  output  [ 7:0]  DdrCtrl_WID_0     , //(O)[Write]  ID
  output [255:0]  DdrCtrl_WDATA_0   , //(O)[Write]  Data
  output  [31:0]  DdrCtrl_WSTRB_0   , //(O)[Write]  Data Strobes(Byte valid)
  output          DdrCtrl_WLAST_0   , //(O)[Write]  Data Last
  output          DdrCtrl_WVALID_0  , //(O)[Write]  Data Valid
  input           DdrCtrl_WREADY_0  , //(I)[Write]  Data Ready

  input   [ 7:0]  DdrCtrl_RID_0     , //(I)[Read]   ID
  input  [255:0]  DdrCtrl_RDATA_0   , //(I)[Read]   Data
  input           DdrCtrl_RLAST_0   , //(I)[Read]   Data Last
  input           DdrCtrl_RVALID_0  , //(I)[Read]   Data Valid
  output          DdrCtrl_RREADY_0  , //(O)[Read]   Data Ready
  input   [ 1:0]  DdrCtrl_RRESP_0   , //(I)[Read]   Response

  input   [ 7:0]  DdrCtrl_BID_0     , //(I)[Answer] Response Write ID
  input           DdrCtrl_BVALID_0  , //(I)[Answer] Response valid
  output          DdrCtrl_BREADY_0  , //(O)[Answer] Response Ready
  //DDR Controner AXI4 1 Signal
  output  [ 7:0]  DdrCtrl_AID_1     , //(O)[Addres] Address ID
  output  [31:0]  DdrCtrl_AADDR_1   , //(O)[Addres] Address
  output  [ 7:0]  DdrCtrl_ALEN_1    , //(O)[Addres] Address Brust Length
  output  [ 2:0]  DdrCtrl_ASIZE_1   , //(O)[Addres] Address Burst size
  output  [ 1:0]  DdrCtrl_ABURST_1  , //(O)[Addres] Address Burst type
  output  [ 1:0]  DdrCtrl_ALOCK_1   , //(O)[Addres] Address Lock type
  output          DdrCtrl_AVALID_1  , //(O)[Addres] Address Valid
  input           DdrCtrl_AREADY_1  , //(I)[Addres] Address Ready
  output          DdrCtrl_ATYPE_1   , //(O)[Addres] Operate Type 0=Read, 1=Write

  output  [ 7:0]  DdrCtrl_WID_1     , //(O)[Write]  Data ID
  output [127:0]  DdrCtrl_WDATA_1   , //(O)[Write]  Data Data
  output  [15:0]  DdrCtrl_WSTRB_1   , //(O)[Write]  Data Strobes(Byte valid)
  output          DdrCtrl_WLAST_1   , //(O)[Write]  Data Last
  output          DdrCtrl_WVALID_1  , //(O)[Write]  Data Valid
  input           DdrCtrl_WREADY_1  , //(I)[Write]  Data Ready

  input   [ 7:0]  DdrCtrl_RID_1     , //(I)[Read]   Data ID
  input   [127:0] DdrCtrl_RDATA_1   , //(I)[Read]   Data Data
  input           DdrCtrl_RLAST_1   , //(I)[Read]   Data Last
  input           DdrCtrl_RVALID_1  , //(I)[Read]   Data Valid
  output          DdrCtrl_RREADY_1  , //(O)[Read]   Data Ready
  input   [ 1:0]  DdrCtrl_RRESP_1   , //(I)[Read]   Response

  input   [ 7:0]  DdrCtrl_BID_1     , //(I)[Answer] Response Write ID
  input           DdrCtrl_BVALID_1  , //(I)[Answer] Response valid
  output          DdrCtrl_BREADY_1  , //(O)[Answer] Response Ready
  //Other Signal
  output  [7:0]   LED         //
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   TCo_C             = 100             ;
                                
	parameter   SYS_CLK_PERIOD    = 32'd100_000_000 ; //System Clock Period
	
	parameter   AXI0_CLK_PERIOD   = 32'd100_000_000 ; //AXI Clock Period(Hz)
	parameter   AXI0_DATA_WIDTH   = 256             ; //AXI Data Width(Bit)
	parameter   AXI0_WR_ID        = 8'haa           ; //AXI Write ID
	parameter   AXI0_RD_ID        = 8'h55           ; //AXI Read ID	
	
	parameter   AXI1_CLK_PERIOD   = 32'd100_000_000 ; //AXI Clock Period(Hz)
	parameter   AXI1_DATA_WIDTH   = 128             ; //AXI Data Width(Bit)
	parameter   AXI1_WR_ID        = 8'h5a           ; //AXI Write ID
	parameter   AXI1_RD_ID        = 8'ha5           ; //AXI Read ID
		
	parameter   DDR_CLK_PERIOD    = 32'd800_000_000 ; //DDR Clock Period(Hz)
	parameter   DDR_START_ADDRESS = 32'h00_00_10_00 ; //DDR Memory Start Address
	parameter   DDR_END_ADDRESS   = 32'h3f_ff_ff_ff ; //DDR Memory End Address
	parameter   DDR_DATA_WIDTH    = 32              ; //DDR Data Width(Bit)	                              	
  parameter   DDR_WRITE_FIRST   =  1'h1           ; //1:Write First ; 0: Read First
  parameter   RIGHT_CNT_WIDTH   = 27              ; //Data Checker Right Counter Width  
  
  /////////////////////////////////////////////////////////


/*0000000000000000000000000000000000000000000000000000000
//  Clock & Reset Process
//  Input：
//  output：
//***************************************************/
  
  /////////////////////////////////////////////////////////
   //Power On Reset Process
  reg [7:0] PowerOnResetCnt = 8'h0  ; //Power On Reset Counter
  reg [2:0] ResetShiftReg   = 3'h0  ; //Reset Shift Regist
  wire      DdrResetCtrl            ; //DDR Controller Reset Control
  
  always @( posedge SysClk) if (&PllLocked)    
  begin
    PowerOnResetCnt <= # TCo_C PowerOnResetCnt + {7'h0,(~&PowerOnResetCnt)};
  end
  
  always @( posedge SysClk)  
  begin
    ResetShiftReg[2] <= # TCo_C  ResetShiftReg[1] ;
    ResetShiftReg[1] <= # TCo_C  ResetShiftReg[0] ;
    ResetShiftReg[0] <= # TCo_C  (&PowerOnResetCnt) & (~DdrResetCtrl);
  end    
  
  /////////////////////////////////////////////////////////
  //DDR Reset  
  wire  DDrCtrlReset  ;  //DDR Controner Reset(Low Active)  
  wire  DdrSeqReset   ;  //DDR Controner Sequencer Reset    
  wire  DDrSeqStart   ;  //DDR Controner Sequencer Start    
  wire  DdrInitDone   ;  //DDR Initial Done status
  
  ddr_reset_sequencer 
  # (
      .FREQ (SYS_CLK_PERIOD / 1_000_000)
    )
  U0_DDR_Reset
  (
    .ddr_rstn_i         ( ResetShiftReg[2]      ), // main user DDR reset, active low
    .clk                ( SysClk                ), // user clock
    /* Connect these three signals to DDR reset interface */
    .ddr_rstn           ( DdrCtrl_CFG_RST_N          ), // Master Reset
    .ddr_cfg_seq_rst    ( DdrCtrl_CFG_SEQ_RST   ), // Sequencer Reset
    .ddr_cfg_seq_start  ( DdrCtrl_CFG_SEQ_START ), // Sequencer Start
    /* optional status monitor for user logic */
    .ddr_init_done		  ( DdrInitDone           )  // Done status
  );
  
  /////////////////////////////////////////////////////////
  reg   [2:0] SysClkResetReg = 3'h0;    //System Clock Reset Register
  
  always @( posedge SysClk)  
  begin
    SysClkResetReg[2] <= # TCo_C  SysClkResetReg[1] ;
    SysClkResetReg[1] <= # TCo_C  SysClkResetReg[0] ;
    SysClkResetReg[0] <= # TCo_C  (~DdrResetCtrl) & DdrInitDone;
  end
    
  wire    Reset_N  = SysClkResetReg[2]; //System Reset (Low Active)
  
   
  /////////////////////////////////////////////////////////
  reg   [2:0] Axi0ResetReg = 3'h0;    //System Clock Reset Register
  
  always @( posedge Axi0Clk)  
  begin
    Axi0ResetReg[2] <= # TCo_C  Axi0ResetReg[1] ;
    Axi0ResetReg[1] <= # TCo_C  Axi0ResetReg[0] ;
    Axi0ResetReg[0] <= # TCo_C  (~DdrResetCtrl) & DdrInitDone;
  end
    
  wire    Axi0Rst_N  = Axi0ResetReg[2]; //System Reset (Low Active)
    
  /////////////////////////////////////////////////////////
  reg   [2:0] Axi1ResetReg = 3'h0;    //System Clock Reset Register
  
  always @( posedge Axi1Clk)  
  begin
    Axi1ResetReg[2] <= # TCo_C  Axi1ResetReg[1] ;
    Axi1ResetReg[1] <= # TCo_C  Axi1ResetReg[0] ;
    Axi1ResetReg[0] <= # TCo_C  (~DdrResetCtrl) & DdrInitDone;
  end
    
  wire    Axi1Rst_N  = Axi1ResetReg[2]; //System Reset (Low Active)
  /////////////////////////////////////////////////////////
  
//0000000000000000000000000000000000000000000000000000000  



//1111111111111111111111111111111111111111111111111111111
//  DDR Test Control & State 
//  Input：
//  output：
//***************************************************/


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI0
//&&&&&&&&&&&&&&&&&&&&&&&&&&



  /////////////////////////////////////////////////////////
  wire  [ 1:0]  CfgDataMode   ; //(I)Config Test Data Mode 0: Normal 1:Reverse 2,3:Normal&Revers Alternate 
  wire  [ 1:0]  CfgTestMode   ; //(I)Test Mode: 1:Read Only;2:Write Only;3:Write/Read alternate
  wire  [ 7:0]  CfgBurstLen   ; //(I)Config Burst Length;
  wire  [31:0]  CfgStartAddr  ; //(I)Config Start Address
  wire  [31:0]  CfgEndAddr    ; //(I)Config End Address
  wire  [31:0]  CfgTestLen    ; //(I)Cinfig Test Length
  wire          TestStart     ; //(I)Test Start Control
    //Test State              
  wire          TestBusy      ; //(O)Test Busy State
  wire          TestErr       ; //(O)Test Data Error
  wire          TestRight     ; //(O)Test Data Right
  //AXI4 Operate              
  wire  [31:0]  AxiWrStartA   ; //Axi4 Write Start Address
  wire          AxiWrEn       ; //Axi4 Write Enable
  wire  [31:0]  AxiWrAddr     ; //Axi4 Write Address
  wire  [255:0] AxiWrData     ; //Axi4 Write Data
  wire  [31:0]  AxiRdStartA   ; //Axi4 Read Start Address
  wire          AxiRdAva      ; //Axi4 Read Available
  wire  [31:0]  AxiRdAddr     ; //Axi4 Read Address
  wire  [255:0] AxiRdData     ; //Axi4 Read Data
  wire          AxiWrDMode    ; //Axi4 Write DDR End
  wire          AxiRdDMode    ; //Axi4 Read DDR End

  DdrTest  
  # (
      .AXI_DATA_WIDTH     ( AXI0_DATA_WIDTH   ),
      .DDR_WRITE_FIRST    ( DDR_WRITE_FIRST   ), //1:Write First ; 0: Read First
      .RIGHT_CNT_WIDTH    ( RIGHT_CNT_WIDTH   ),
	    .DDR_START_ADDRESS  ( DDR_START_ADDRESS ), //DDR Memory Start Address
	    .DDR_END_ADDRESS    ( DDR_END_ADDRESS   ), //DDR Memory End Address
	    .AXI_WR_ID          ( AXI0_WR_ID         ),
	    .AXI_RD_ID          ( AXI0_RD_ID         )
    )
  U1_DdrTest
  (
    //System Signal
    .SysClk       ( Axi0Clk           ), //(O)System Clock
    .Reset_N      ( Axi0Rst_N         ), //(I)System Reset (Low Active)
   
   // .RamWrData    ( Ram_Wr            ),
    //Test Configuration & State      
    .CfgTestMode  ( CfgTestMode       ), //(I)Test Mode: 1:Read Only;2:Write Only;3:Write/Read alternate
    .CfgBurstLen  ( CfgBurstLen       ), //(I)Config Burst Length;
    .CfgStartAddr ( CfgStartAddr      ), //(I)Config Start Address
    .CfgEndAddr   ( CfgEndAddr        ), //(I)Config End Address
    .CfgTestLen   ( CfgTestLen        ), //(I)Cinfig Test Length
    .CfgDataMode  ( CfgDataMode       ), //Config Test Data Mode 0: Nomarl 1:Reverse
    .TestStart    ( TestStart         ), //(I)Test Start Control
    //Test State  & Result            
    .TestBusy     ( TestBusy          ), //(O)Test Busy State
    .TestErr      ( TestErr           ), //(O)Test Data Error
    .TestRight    ( TestRight         ), //(O)Test Data Right
    //AXI4 Operate                    
    .AxiWrStartA  ( AxiWrStartA       ), //Axi4 Write Start Address
    .AxiWrEn      ( AxiWrEn           ), //Axi4 Write Enable
    .AxiWrAddr    ( AxiWrAddr         ), //Axi4 Write Address
    .AxiWrData    ( AxiWrData         ), //Axi4 Write Data
    .AxiRdStartA  ( AxiRdStartA       ), //Axi4 Read Start Address
    .AxiRdAva     ( AxiRdAva          ), //Axi4 Read Available
    .AxiRdAddr    ( AxiRdAddr         ), //Axi4 Read Address
    .AxiRdData    ( AxiRdData         ), //Axi4 Read Data
    .AxiWrDMode   ( AxiWrDMode        ), //Axi4 Write DDR End
    .AxiRdDMode   ( AxiRdDMode        ), //Axi4 Read DDR End
    //DDR Controner AXI4 Signal
    .aid          ( DdrCtrl_AID_0     ),  //(O)[Addres] Address ID
    .aaddr        ( DdrCtrl_AADDR_0   ),  //(O)[Addres] Address
    .alen         ( DdrCtrl_ALEN_0    ),  //(O)[Addres] Address Brust Length
    .asize        ( DdrCtrl_ASIZE_0   ),  //(O)[Addres] Address Burst size
    .aburst       ( DdrCtrl_ABURST_0  ),  //(O)[Addres] Address Burst type
    .alock        ( DdrCtrl_ALOCK_0   ),  //(O)[Addres] Address Lock type
    .avalid       ( DdrCtrl_AVALID_0  ),  //(O)[Addres] Address Valid
    .aready       ( DdrCtrl_AREADY_0  ),  //(I)[Addres] Address Ready
    .atype        ( DdrCtrl_ATYPE_0   ),  //(O)[Addres] Operate Type 0=Read, 1=Write
    ///////////
    .wid          ( DdrCtrl_WID_0     ),  //(O)[Write]  ID
    .wdata        ( DdrCtrl_WDATA_0   ),  //(O)[Write]  Data
    .wstrb        ( DdrCtrl_WSTRB_0   ),  //(O)[Write]  Data Strobes(Byte valid)
    .wlast        ( DdrCtrl_WLAST_0   ),  //(O)[Write]  Data Last
    .wvalid       ( DdrCtrl_WVALID_0  ),  //(O)[Write]  Data Valid
    .wready       ( DdrCtrl_WREADY_0  ),  //(I)[Write]  Data Ready
    ///////////
    .rid          ( DdrCtrl_RID_0     ),  //(I)[Read]   ID
    .rdata        ( DdrCtrl_RDATA_0   ),  //(I)[Read]   Data
    .rlast        ( DdrCtrl_RLAST_0   ),  //(I)[Read]   Data Last
    .rvalid       ( DdrCtrl_RVALID_0  ),  //(I)[Read]   Data Valid
    .rready       ( DdrCtrl_RREADY_0  ),  //(O)[Read]   Data Ready
    .rresp        ( DdrCtrl_RRESP_0   ),  //(I)[Read]   Response
    ///////////
    .bid          ( DdrCtrl_BID_0     ),  //(I)[Answer] Response Write ID
    .bvalid       ( DdrCtrl_BVALID_0  ),  //(I)[Answer] Response valid
    .bready       ( DdrCtrl_BREADY_0  )   //(O)[Answer] Response Ready
  );




//&&&&&&&&&&&&&&&&&&&&&&&&&&
`else
//&&&&&&&&&&&&&&&&&&&&&&&&&&




  /////////////////////////////////////////////////////////
  //DDR Controner AXI4_0 Signal
  assign  DdrCtrl_AID_0     =   8'h0; //(O)[Addres] Address ID
  assign  DdrCtrl_AADDR_0   =  32'h0; //(O)[Addres] Address
  assign  DdrCtrl_ALEN_0    =   8'h0; //(O)[Addres] Address Brust Length
  assign  DdrCtrl_ASIZE_0   =   3'h0; //(O)[Addres] Address Burst size
  assign  DdrCtrl_ABURST_0  =   2'h0; //(O)[Addres] Address Burst type
  assign  DdrCtrl_ALOCK_0   =   2'h0; //(O)[Addres] Address Lock type
  assign  DdrCtrl_AVALID_0  =   1'h0; //(O)[Addres] Address Valid
  assign  DdrCtrl_ATYPE_0   =   1'h0; //(O)[Addres] Operate Type 0=Read, 1=Write

  assign  DdrCtrl_WID_0     =   8'h0; //(O)[Write]  Data ID
  assign  DdrCtrl_WDATA_0   = 128'h0; //(O)[Write]  Data Data
  assign  DdrCtrl_WSTRB_0   =   8'h0; //(O)[Write]  Data Strobes(Byte valid)
  assign  DdrCtrl_WLAST_0   =   8'h0; //(O)[Write]  Data Last
  assign  DdrCtrl_WVALID_0  =   8'h0; //(O)[Write]  Data Valid

  assign  DdrCtrl_RREADY_0  =   1'h0; //(O)[Read]   Data Ready
                                
  assign  DdrCtrl_BREADY_0  =   1'h0; //(O)[Answer] Response Ready
  
  /////////////////////////////////////////////////////////


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&


//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//  DDR Test Staitics
//  Input：
//  output：
//***************************************************/


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI0
//&&&&&&&&&&&&&&&&&&&&&&&&&&
       

  /////////////////////////////////////////////////////////
  reg [1:0]   TestStartReg  ;
  reg         TestStartEn   ;
  
  always @( posedge Axi0Clk)  TestStartReg <= # TCo_C {TestStartReg[0],TestStart};
  always @( posedge Axi0Clk)  TestStartEn  <= # TCo_C (TestStartReg == 2'h1);
  
  wire          StatiClr  = TestStartEn; //(I)Staistics Couter Clear
    
  /////////////////////////////////////////////////////////
  wire  [23:0]  TestTime  ; //(O)Test Time      
  wire  [23:0]  ErrCnt    ; //(O)Test Error Counter   
  wire  [47:0]  OpTotCyc  ; //(O)Total Operate Cycle Counter
  wire  [47:0]  OpActCyc  ; //(O)Actual Operate Cycle Counter
  wire  [ 9:0]  OpEffic   ; //(O)Operate Efficiency
  wire  [15:0]  BandWidth ; //(O)BandWidth  
  wire  [9:0]   WrPeriMin ; //Write Minimum Period For One Burst
  wire  [9:0]   WrPeriAvg ; //Write Average Period For One Burst
  wire  [9:0]   WrPeriMax ; //Write maximum Period For One Burst
  wire  [9:0]   RdPeriMin ; //Read Minimum Period For One Burst
  wire  [9:0]   RdPeriAvg ; //Read Average Period For One Burst
  wire  [9:0]   RdPeriMax ; //Read maximum Period For One Burst
  wire          TimeOut   ; //(O)TimeOut
  
  DdrTestStatic
  # (
  	  .DDR_CLK_PERIOD ( DDR_CLK_PERIOD  ),
  	  .DDR_DATA_WIDTH ( DDR_DATA_WIDTH  ),
  	  .AXI_CLK_PERIOD ( AXI0_CLK_PERIOD ),
  	  .AXI_DATA_WIDTH ( AXI0_DATA_WIDTH )
    )
  U2_DdrTestStatis
  ( 
    //System Signal
    .SysClk     ( Axi0Clk           ), //(O)System Clock
    .Reset_N    ( Axi0Rst_N           ), //(I)System Reset (Low Active)
    //DDR Controner Operate Statistics Control & Result
    .TestBusy   ( TestBusy          ), //(I)Test Busy State
    .TestErr    ( TestErr           ), //(I)Test Read Data Error
    .StatiClr   ( StatiClr          ), //(I)Staistics Couter Clear
    .TestTime   ( TestTime          ), //(O)Test Time      
    .ErrCnt     ( ErrCnt            ), //(O)Test Error Counter   
    .OpTotCyc   ( OpTotCyc          ), //(O)Total Operate Cycle Counter
    .OpActCyc   ( OpActCyc          ), //(O)Actual Operate Cycle Counter
    .OpEffic    ( OpEffic           ), //(O)Operate Efficiency
    .BandWidth  ( BandWidth         ), //(O)BandWidth
    .WrPeriMin  ( WrPeriMin         ), //Write Minimum Period For One Burst
    .WrPeriAvg  ( WrPeriAvg         ), //Write Average Period For One Burst
    .WrPeriMax  ( WrPeriMax         ), //Write maximum Period For One Burst
    .RdPeriMin  ( RdPeriMin         ), //Read Minimum Period For One Burst
    .RdPeriAvg  ( RdPeriAvg         ), //Read Average Period For One Burst
    .RdPeriMax  ( RdPeriMax         ), //Read maximum Period For One Burst
    .TimeOut    ( TimeOut           ), //(O)TimeOut
    //DDR Controner AXI4 Signal
    .avalid     ( DdrCtrl_AVALID_0  ),  //(O)[Addres] Address Valid
    .aready     ( DdrCtrl_AREADY_0  ),  //(I)[Addres] Address Ready
    .atype      ( DdrCtrl_ATYPE_0   ),  //(O)[Addres] Operate Type 0=Read, 1=Write
    .wlast      ( DdrCtrl_WLAST_0   ),  //(O)[Write]  Data Last
    .wvalid     ( DdrCtrl_WVALID_0  ),  //(O)[Write]  Data Valid
    .wready     ( DdrCtrl_WREADY_0  ),  //(I)[Write]  Data Ready
    .rlast      ( DdrCtrl_RLAST_0   ),  //(I)[Read]   Data Last
    .rvalid     ( DdrCtrl_RVALID_0  ),  //(I)[Read]   Data Valid
    .rready     ( DdrCtrl_RREADY_0  )   //(O)[Read]   Data Ready
  );



//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&


//22222222222222222222222222222222222222222222222222222



//3333333333333333333333333333333333333333333333333333333
//
//  Input：
//  output：
//***************************************************/


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI1
//&&&&&&&&&&&&&&&&&&&&&&&&&&


  /////////////////////////////////////////////////////////
  wire  [ 1:0]  CfgDataMode   ; //(I)Config Test Data Mode 0: Normal 1:Reverse 2,3:Normal&Revers Alternate 
  wire  [ 1:0]  CfgTestMode   ; //(I)Test Mode: 1:Read Only;2:Write Only;3:Write/Read alternate
  wire  [ 7:0]  CfgBurstLen   ; //(I)Config Burst Length;
  wire  [31:0]  CfgStartAddr  ; //(I)Config Start Address
  wire  [31:0]  CfgEndAddr    ; //(I)Config End Address
  wire  [31:0]  CfgTestLen    ; //(I)Cinfig Test Length
  wire          TestStart     ; //(I)Test Start Control
    //Test State              
  wire          TestBusy      ; //(O)Test Busy State
  wire          TestErr       ; //(O)Test Data Error
  wire          TestRight     ; //(O)Test Data Right
  //AXI4 Operate              
  wire  [31:0]  AxiWrStartA   ; //Axi4 Write Start Address
  wire          AxiWrEn       ; //Axi4 Write Enable
  wire  [31:0]  AxiWrAddr     ; //Axi4 Write Address
  wire  [255:0] AxiWrData     ; //Axi4 Write Data
  wire  [31:0]  AxiRdStartA   ; //Axi4 Read Start Address
  wire          AxiRdAva      ; //Axi4 Read Available
  wire  [31:0]  AxiRdAddr     ; //Axi4 Read Address
  wire  [255:0] AxiRdData     ; //Axi4 Read Data
  wire          AxiWrDMode    ; //Axi4 Write DDR End
  wire          AxiRdDMode    ; //Axi4 Read DDR End

  DdrTest  
  # (
      .AXI_DATA_WIDTH     ( AXI1_DATA_WIDTH   ),
      .DDR_WRITE_FIRST    ( DDR_WRITE_FIRST   ), //1:Write First ; 0: Read First
      .RIGHT_CNT_WIDTH    ( RIGHT_CNT_WIDTH   ),
	    .DDR_START_ADDRESS  ( DDR_START_ADDRESS ), //DDR Memory Start Address
	    .DDR_END_ADDRESS    ( DDR_END_ADDRESS   ), //DDR Memory End Address
	    .AXI_WR_ID          ( AXI1_WR_ID         ),
	    .AXI_RD_ID          ( AXI1_RD_ID         )
    )
  U1_DdrTest
  (
    //System Signal
    .SysClk       ( Axi1Clk           ), //(O)System Clock
    .Reset_N      ( Axi1Rst_N         ), //(I)System Reset (Low Active)
    //Test Configuration & State      
    .CfgTestMode  ( CfgTestMode       ), //(I)Test Mode: 1:Read Only;2:Write Only;3:Write/Read alternate
    .CfgBurstLen  ( CfgBurstLen       ), //(I)Config Burst Length;
    .CfgStartAddr ( CfgStartAddr      ), //(I)Config Start Address
    .CfgEndAddr   ( CfgEndAddr        ), //(I)Config End Address
    .CfgTestLen   ( CfgTestLen        ), //(I)Cinfig Test Length
    .CfgDataMode  ( CfgDataMode       ), //Config Test Data Mode 0: Nomarl 1:Reverse
    .TestStart    ( TestStart         ), //(I)Test Start Control
    //Test State  & Result            
    .TestBusy     ( TestBusy          ), //(O)Test Busy State
    .TestErr      ( TestErr           ), //(O)Test Data Error
    .TestRight    ( TestRight         ), //(O)Test Data Right
    //AXI4 Operate                    
    .AxiWrStartA  ( AxiWrStartA       ), //Axi4 Write Start Address
    .AxiWrEn      ( AxiWrEn           ), //Axi4 Write Enable
    .AxiWrAddr    ( AxiWrAddr         ), //Axi4 Write Address
    .AxiWrData    ( AxiWrData         ), //Axi4 Write Data
    .AxiRdStartA  ( AxiRdStartA       ), //Axi4 Read Start Address
    .AxiRdAva     ( AxiRdAva          ), //Axi4 Read Available
    .AxiRdAddr    ( AxiRdAddr         ), //Axi4 Read Address
    .AxiRdData    ( AxiRdData         ), //Axi4 Read Data
    .AxiWrDMode   ( AxiWrDMode        ), //Axi4 Write DDR End
    .AxiRdDMode   ( AxiRdDMode        ), //Axi4 Read DDR End
    //DDR Controner AXI4 Signal
    .aid          ( DdrCtrl_AID_1     ),  //(O)[Addres] Address ID
    .aaddr        ( DdrCtrl_AADDR_1   ),  //(O)[Addres] Address
    .alen         ( DdrCtrl_ALEN_1    ),  //(O)[Addres] Address Brust Length
    .asize        ( DdrCtrl_ASIZE_1   ),  //(O)[Addres] Address Burst size
    .aburst       ( DdrCtrl_ABURST_1  ),  //(O)[Addres] Address Burst type
    .alock        ( DdrCtrl_ALOCK_1   ),  //(O)[Addres] Address Lock type
    .avalid       ( DdrCtrl_AVALID_1  ),  //(O)[Addres] Address Valid
    .aready       ( DdrCtrl_AREADY_1  ),  //(I)[Addres] Address Ready
    .atype        ( DdrCtrl_ATYPE_1   ),  //(O)[Addres] Operate Type 0=Read, 1=Write
    ///////////
    .wid          ( DdrCtrl_WID_1     ),  //(O)[Write]  ID
    .wdata        ( DdrCtrl_WDATA_1   ),  //(O)[Write]  Data
    .wstrb        ( DdrCtrl_WSTRB_1   ),  //(O)[Write]  Data Strobes(Byte valid)
    .wlast        ( DdrCtrl_WLAST_1   ),  //(O)[Write]  Data Last
    .wvalid       ( DdrCtrl_WVALID_1  ),  //(O)[Write]  Data Valid
    .wready       ( DdrCtrl_WREADY_1  ),  //(I)[Write]  Data Ready
    ///////////
    .rid          ( DdrCtrl_RID_1     ),  //(I)[Read]   ID
    .rdata        ( DdrCtrl_RDATA_1   ),  //(I)[Read]   Data
    .rlast        ( DdrCtrl_RLAST_1   ),  //(I)[Read]   Data Last
    .rvalid       ( DdrCtrl_RVALID_1  ),  //(I)[Read]   Data Valid
    .rready       ( DdrCtrl_RREADY_1  ),  //(O)[Read]   Data Ready
    .rresp        ( DdrCtrl_RRESP_1   ),  //(I)[Read]   Response
    ///////////
    .bid          ( DdrCtrl_BID_1     ),  //(I)[Answer] Response Write ID
    .bvalid       ( DdrCtrl_BVALID_1  ),  //(I)[Answer] Response valid
    .bready       ( DdrCtrl_BREADY_1  )   //(O)[Answer] Response Ready
  );


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`else
//&&&&&&&&&&&&&&&&&&&&&&&&&&


  /////////////////////////////////////////////////////////
  //DDR Controner AXI4 1 Signal
  assign  DdrCtrl_AID_1     =   8'h0; //(O)[Addres] Address ID
  assign  DdrCtrl_AADDR_1   =  32'h0; //(O)[Addres] Address
  assign  DdrCtrl_ALEN_1    =   8'h0; //(O)[Addres] Address Brust Length
  assign  DdrCtrl_ASIZE_1   =   3'h0; //(O)[Addres] Address Burst size
  assign  DdrCtrl_ABURST_1  =   2'h0; //(O)[Addres] Address Burst type
  assign  DdrCtrl_ALOCK_1   =   2'h0; //(O)[Addres] Address Lock type
  assign  DdrCtrl_AVALID_1  =   1'h0; //(O)[Addres] Address Valid
  assign  DdrCtrl_ATYPE_1   =   1'h0; //(O)[Addres] Operate Type 0=Read, 1=Write

  assign  DdrCtrl_WID_1     =   8'h0; //(O)[Write]  Data ID
  assign  DdrCtrl_WDATA_1   = 128'h0; //(O)[Write]  Data Data
  assign  DdrCtrl_WSTRB_1   =   8'h0; //(O)[Write]  Data Strobes(Byte valid)
  assign  DdrCtrl_WLAST_1   =   8'h0; //(O)[Write]  Data Last
  assign  DdrCtrl_WVALID_1  =   8'h0; //(O)[Write]  Data Valid

  assign  DdrCtrl_RREADY_1  =   1'h0; //(O)[Read]   Data Ready
                                
  assign  DdrCtrl_BREADY_1  =   1'h0; //(O)[Answer] Response Ready


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&


//3333333333333333333333333333333333333333333333333333333



//4444444444444444444444444444444444444444444444444444444
//
//  Input：
//  output：
//***************************************************/



//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI1
//&&&&&&&&&&&&&&&&&&&&&&&&&&




  /////////////////////////////////////////////////////////
  reg [1:0]   TestStartReg  ;
  reg         TestStartEn   ;
  
  always @( posedge Axi0Clk)  TestStartReg <= # TCo_C {TestStartReg[0],TestStart};
  always @( posedge Axi0Clk)  TestStartEn  <= # TCo_C (TestStartReg == 2'h1);
  
  wire          StatiClr  = TestStartEn; //(I)Staistics Couter Clear
    
  /////////////////////////////////////////////////////////
  wire  [23:0]  TestTime  ; //(O)Test Time      
  wire  [23:0]  ErrCnt    ; //(O)Test Error Counter   
  wire  [47:0]  OpTotCyc  ; //(O)Total Operate Cycle Counter
  wire  [47:0]  OpActCyc  ; //(O)Actual Operate Cycle Counter
  wire  [ 9:0]  OpEffic   ; //(O)Operate Efficiency
  wire  [15:0]  BandWidth ; //(O)BandWidth  
  wire          TimeOut   ; //(O)TimeOut
  
  DdrTestStatic
  # (
  	  .DDR_CLK_PERIOD ( DDR_CLK_PERIOD  ),
  	  .DDR_DATA_WIDTH ( DDR_DATA_WIDTH  ),
  	  .AXI_CLK_PERIOD ( AXI1_CLK_PERIOD ),
  	  .AXI_DATA_WIDTH ( AXI1_DATA_WIDTH )
    )
  U2_DdrTestStatis
  ( 
    //System Signal
    .SysClk     ( Axi1Clk           ), //(O)System Clock
    .Reset_N    ( Axi1Rst_N           ), //(I)System Reset (Low Active)
    //DDR Controner Operate Statistics Control & Result
    .TestBusy   ( TestBusy          ), //(I)Test Busy State
    .TestErr    ( TestErr           ), //(I)Test Read Data Error
    .StatiClr   ( StatiClr          ), //(I)Staistics Couter Clear
    .TestTime   ( TestTime          ), //(O)Test Time      
    .ErrCnt     ( ErrCnt            ), //(O)Test Error Counter   
    .OpTotCyc   ( OpTotCyc          ), //(O)Total Operate Cycle Counter
    .OpActCyc   ( OpActCyc          ), //(O)Actual Operate Cycle Counter
    .OpEffic    ( OpEffic           ), //(O)Operate Efficiency
    .BandWidth  ( BandWidth         ), //(O)BandWidth
    .TimeOut    ( TimeOut           ), //(O)TimeOut
    //DDR Controner AXI4 Signal
    .avalid     ( DdrCtrl_AVALID_1  ),  //(O)[Addres] Address Valid
    .aready     ( DdrCtrl_AREADY_1  ),  //(I)[Addres] Address Ready
    .atype      ( DdrCtrl_ATYPE_1   ),  //(O)[Addres] Operate Type 0=Read, 1=Write
    .wlast      ( DdrCtrl_WLAST_1   ),  //(O)[Write]  Data Last
    .wvalid     ( DdrCtrl_WVALID_1  ),  //(O)[Write]  Data Valid
    .wready     ( DdrCtrl_WREADY_1  ),  //(I)[Write]  Data Ready
    .rlast      ( DdrCtrl_RLAST_1   ),  //(I)[Read]   Data Last
    .rvalid     ( DdrCtrl_RVALID_1  ),  //(I)[Read]   Data Valid
    .rready     ( DdrCtrl_RREADY_1  )   //(O)[Read]   Data Ready
  );


//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&


//4444444444444444444444444444444444444444444444444444444



//5555555555555555555555555555555555555555555555555555555
//  LED output
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  reg [25:0]  LedFlashCnt = 0;

  always @( posedge SysClk) LedFlashCnt <= # TCo_C LedFlashCnt + 26'h1;

  /////////////////////////////////////////////////////////
  assign  LED[   7] =   LedFlashCnt[25] ;
  assign  LED[   6] = (~LedFlashCnt[25]) & TestBusy;

  assign  LED[   5] =   TestErr         ;
  assign  LED[   4] =   TestRight       ;

  assign  LED[3 :0] =   (|ErrCnt[23:4]) ? 4'hf : ErrCnt[3:0];

//5555555555555555555555555555555555555555555555555555555


`ifdef  Efinity_Debug  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  /////////////////////////////////////////////////////////
  
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI0
//&&&&&&&&&&&&&&&&&&&&&&&&&&


    wire  Axi_clk  = Axi0Clk;
    
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&
                                          
                                          
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI1
//&&&&&&&&&&&&&&&&&&&&&&&&&&


    wire  Axi_clk  = Axi1Clk;
    
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&

                                          
    reg             Axi_AVALID          =  1'h0 ;
    reg             Axi_AREADY          =  1'h0 ;
    reg             Axi_ATYPE           =  1'h0 ;
    reg   [ 7:0]    Axi_ALEN            =  8'h0 ;
    reg             Axi_WVALID          =  1'h0 ;
    reg             Axi_WREADY          =  1'h0 ;
    reg             Axi_BVALID          =  1'h0 ;
    reg             Axi_BREADY          =  1'h0 ;
    reg             Axi_RVALID          =  1'h0 ;
    reg             Axi_RREADY          =  1'h0 ;
    reg             Axi_WLAST           =  1'h0 ;
    reg             Axi_RLAST           =  1'h0 ;
    reg   [31:0]    Axi_AADDR           = 32'h0 ;
                                     
    reg             Axi_WrEn            =  1'h0 ;
    reg   [31:0]    Axi_WrAddr          = 32'h0 ;
    reg   [31:0]    Axi_WDATA__31___0   = 32'h0 ;
    reg   [31:0]    Axi_WDATA__63__32   = 32'h0 ;
    reg   [31:0]    Axi_WDATA__95__64   = 32'h0 ;
    reg   [31:0]    Axi_WDATA_127__96   = 32'h0 ;
    reg   [31:0]    Axi_WDATA_159_128   = 32'h0 ;
    reg   [31:0]    Axi_WDATA_191_160   = 32'h0 ;
    reg   [31:0]    Axi_WDATA_223_192   = 32'h0 ;
    reg   [31:0]    Axi_WDATA_255_224   = 32'h0 ;
                                        
    reg             Axi_RdAva           =  1'h0 ;
    reg   [31:0]    Axi_RdAddr          = 32'h0 ;
    reg   [31:0]    Axi_RDATA__31___0   = 32'h0 ;
    reg   [31:0]    Axi_RDATA__63__32   = 32'h0 ;
    reg   [31:0]    Axi_RDATA__95__64   = 32'h0 ;
    reg   [31:0]    Axi_RDATA_127__96   = 32'h0 ;
    reg   [31:0]    Axi_RDATA_159_128   = 32'h0 ;
    reg   [31:0]    Axi_RDATA_191_160   = 32'h0 ;
    reg   [31:0]    Axi_RDATA_223_192   = 32'h0 ;
    reg   [31:0]    Axi_RDATA_255_224   = 32'h0 ;
    
    reg             Axi_TestErr         =  1'h0 ;
    reg             Axi_WrDataMode      =  1'h0 ;
    reg             Axi_RdDataMode      =  1'h0 ;
    reg             Axi_TimeOut         =  1'h0 ;
    reg   [31:0]    Axi_WrStartA        = 32'h0 ;
    reg   [31:0]    Axi_RdStartA        = 32'h0 ;
    
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI0
//&&&&&&&&&&&&&&&&&&&&&&&&&&


    always @( posedge Axi_clk)    Axi_AVALID        <= # TCo_C DdrCtrl_AVALID_0    ;
    always @( posedge Axi_clk)    Axi_AREADY        <= # TCo_C DdrCtrl_AREADY_0    ;
    always @( posedge Axi_clk)    Axi_ATYPE         <= # TCo_C DdrCtrl_ATYPE_0     ;
    always @( posedge Axi_clk)    Axi_ALEN          <= # TCo_C DdrCtrl_ALEN_0      ;
    always @( posedge Axi_clk)    Axi_WVALID        <= # TCo_C DdrCtrl_WVALID_0    ;
    always @( posedge Axi_clk)    Axi_WREADY        <= # TCo_C DdrCtrl_WREADY_0    ;
    always @( posedge Axi_clk)    Axi_BVALID        <= # TCo_C DdrCtrl_BVALID_0    ;
    always @( posedge Axi_clk)    Axi_BREADY        <= # TCo_C DdrCtrl_BREADY_0    ;
    always @( posedge Axi_clk)    Axi_RVALID        <= # TCo_C DdrCtrl_RVALID_0    ;
    always @( posedge Axi_clk)    Axi_RREADY        <= # TCo_C DdrCtrl_RREADY_0    ;
    always @( posedge Axi_clk)    Axi_WLAST         <= # TCo_C DdrCtrl_WLAST_0     ;
    always @( posedge Axi_clk)    Axi_RLAST         <= # TCo_C DdrCtrl_RLAST_0     ;
    always @( posedge Axi_clk)    Axi_AADDR         <= # TCo_C DdrCtrl_AADDR_0     ;       
                                                                                     
                                                                                     
//&&&&&&&&&&&&&&&&&&&&&&&&&&                                                         
`endif                                                                               
//&&&&&&&&&&&&&&&&&&&&&&&&&&                                                         
                                                                                     
                                                                                     
//&&&&&&&&&&&&&&&&&&&&&&&&&&                                                         
`ifdef  Test_AXI1                                                                    
//&&&&&&&&&&&&&&&&&&&&&&&&&&                                                         
                                                                                     
                                                                                     
    always @( posedge Axi_clk)    Axi_AVALID        <= # TCo_C DdrCtrl_AVALID_1    ;
    always @( posedge Axi_clk)    Axi_AREADY        <= # TCo_C DdrCtrl_AREADY_1    ;
    always @( posedge Axi_clk)    Axi_ATYPE         <= # TCo_C DdrCtrl_ATYPE_1     ;
    always @( posedge Axi_clk)    Axi_ALEN          <= # TCo_C DdrCtrl_ALEN_1      ;
    always @( posedge Axi_clk)    Axi_WVALID        <= # TCo_C DdrCtrl_WVALID_1    ;
    always @( posedge Axi_clk)    Axi_WREADY        <= # TCo_C DdrCtrl_WREADY_1    ;
    always @( posedge Axi_clk)    Axi_BVALID        <= # TCo_C DdrCtrl_BVALID_1    ;
    always @( posedge Axi_clk)    Axi_BREADY        <= # TCo_C DdrCtrl_BREADY_1    ;
    always @( posedge Axi_clk)    Axi_RVALID        <= # TCo_C DdrCtrl_RVALID_1    ;
    always @( posedge Axi_clk)    Axi_RREADY        <= # TCo_C DdrCtrl_RREADY_1    ;
    always @( posedge Axi_clk)    Axi_WLAST         <= # TCo_C DdrCtrl_WLAST_1     ;
    always @( posedge Axi_clk)    Axi_RLAST         <= # TCo_C DdrCtrl_RLAST_1     ;
    always @( posedge Axi_clk)    Axi_AADDR         <= # TCo_C DdrCtrl_AADDR_1     ;       
                                                    
                                                    
//&&&&&&&&&&&&&&&&&&&&&&&&&&                        
`endif                                              
//&&&&&&&&&&&&&&&&&&&&&&&&&&                        
                                                    
                                                    
    always @( posedge Axi_clk)    Axi_WrEn          <= # TCo_C AxiWrEn             ;
    always @( posedge Axi_clk)    Axi_WrAddr        <= # TCo_C AxiWrAddr           ;       
    always @( posedge Axi_clk)    Axi_WDATA__31___0 <= # TCo_C AxiWrData[ 31:  0]  ;
    always @( posedge Axi_clk)    Axi_WDATA__63__32 <= # TCo_C AxiWrData[ 63: 32]  ;
    always @( posedge Axi_clk)    Axi_WDATA__95__64 <= # TCo_C AxiWrData[ 95: 64]  ;
    always @( posedge Axi_clk)    Axi_WDATA_127__96 <= # TCo_C AxiWrData[127: 96]  ;
    always @( posedge Axi_clk)    Axi_WDATA_159_128 <= # TCo_C AxiWrData[159:128]  ;
    always @( posedge Axi_clk)    Axi_WDATA_191_160 <= # TCo_C AxiWrData[191:160]  ;
    always @( posedge Axi_clk)    Axi_WDATA_223_192 <= # TCo_C AxiWrData[223:192]  ;
    always @( posedge Axi_clk)    Axi_WDATA_255_224 <= # TCo_C AxiWrData[255:224]  ;
                                                                                  
    always @( posedge Axi_clk)    Axi_RdAva         <= # TCo_C AxiRdAva            ;
    always @( posedge Axi_clk)    Axi_RdAddr        <= # TCo_C AxiRdAddr           ;    
    always @( posedge Axi_clk)    Axi_RDATA__31___0 <= # TCo_C AxiRdData[ 31:  0]  ;
    always @( posedge Axi_clk)    Axi_RDATA__63__32 <= # TCo_C AxiRdData[ 63: 32]  ;
    always @( posedge Axi_clk)    Axi_RDATA__95__64 <= # TCo_C AxiRdData[ 95: 64]  ;
    always @( posedge Axi_clk)    Axi_RDATA_127__96 <= # TCo_C AxiRdData[127: 96]  ;
    always @( posedge Axi_clk)    Axi_RDATA_159_128 <= # TCo_C AxiRdData[159:128]  ;
    always @( posedge Axi_clk)    Axi_RDATA_191_160 <= # TCo_C AxiRdData[191:160]  ;
    always @( posedge Axi_clk)    Axi_RDATA_223_192 <= # TCo_C AxiRdData[223:192]  ;
    always @( posedge Axi_clk)    Axi_RDATA_255_224 <= # TCo_C AxiRdData[255:224]  ;
                                                  
    always @( * )                 Axi_TestErr       <= # TCo_C TestErr             ; 
    always @( posedge Axi_clk)    Axi_WrDataMode    <= # TCo_C AxiWrDMode          ; 
    always @( posedge Axi_clk)    Axi_RdDataMode    <= # TCo_C AxiRdDMode          ; 
    always @( posedge Axi_clk)    Axi_TimeOut       <= # TCo_C TimeOut             ; 
                                                                                  
    always @( posedge Axi_clk)    Axi_WrStartA      <= # TCo_C AxiWrStartA         ;
    always @( posedge Axi_clk)    Axi_RdStartA      <= # TCo_C AxiRdStartA         ;
    
  /////////////////////////////////////////////////////////
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI0
//&&&&&&&&&&&&&&&&&&&&&&&&&&


    wire  DdrTest_clk = Axi0Clk    ;
    
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&
                                          
                                          
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`ifdef  Test_AXI1
//&&&&&&&&&&&&&&&&&&&&&&&&&&


    wire  DdrTest_clk = Axi1Clk    ;
    
    
//&&&&&&&&&&&&&&&&&&&&&&&&&&
`endif
//&&&&&&&&&&&&&&&&&&&&&&&&&&
                                          
                                                                
    wire              DdrTest_TestBusy                = TestBusy  ;
    wire  [23:0]      DdrTest_TestErrCnt              = ErrCnt    ;
    wire              DdrTest_TestRight               = TestRight ;
    wire  [47:0]      DdrTest_Operate_Total_Cycle     = OpTotCyc  ;
    wire  [47:0]      DdrTest_Operate_Actual_Cycle    = OpActCyc  ;
    wire  [ 9:0]      DdrTest_Operate_Efficiency_ppt  = OpEffic   ;
    wire  [15:0]      DdrTest_BandWidth_Mbps          = BandWidth ;
    wire  [ 9:0]      DdrTest_WrPeriod_minimun_Cycle  = WrPeriMin ;
    wire  [ 9:0]      DdrTest_WrPeriod_Average_Cycle  = WrPeriAvg ;
    wire  [ 9:0]      DdrTest_WrPeriod_Maximum_Cycle  = WrPeriMax ;
    wire  [ 9:0]      DdrTest_RdPeriod_minimun_Cycle  = RdPeriMin ;
    wire  [ 9:0]      DdrTest_RdPeriod_Average_Cycle  = RdPeriAvg ;
    wire  [ 9:0]      DdrTest_RdPeriod_Maximum_Cycle  = RdPeriMax ;
    wire  [23:0]      DdrTest_Test_Time_second        = TestTime  ;
                                                      
    wire              DdrTest_DdrReset                ;
    wire  [ 1:0]      DdrTest_CfgDataMode             ;
    wire  [ 1:0]      DdrTest_CfgTestMode             ;
    wire  [ 7:0]      DdrTest_CfgBurstLen             ;
    wire  [31:0]      DdrTest_CfgStartAddr            ;
    wire  [31:0]      DdrTest_CfgEndAddr              ;
    wire  [31:0]      DdrTest_CfgTestLen              ;
    wire              DdrTest_TestStart               ;
    
  edb_top edb_top_inst (
  ////////////////
    .bscan_CAPTURE        ( jtag_inst1_CAPTURE  ),
    .bscan_DRCK           ( jtag_inst1_DRCK     ),
    .bscan_RESET          ( jtag_inst1_RESET    ),
    .bscan_RUNTEST        ( jtag_inst1_RUNTEST  ),
    .bscan_SEL            ( jtag_inst1_SEL      ),
    .bscan_SHIFT          ( jtag_inst1_SHIFT    ),
    .bscan_TCK            ( jtag_inst1_TCK      ),
    .bscan_TDI            ( jtag_inst1_TDI      ),
    .bscan_TMS            ( jtag_inst1_TMS      ),
    .bscan_UPDATE         ( jtag_inst1_UPDATE   ),
    .bscan_TDO            ( jtag_inst1_TDO      ),
  ////////////////        
    .Axi_clk              ( Axi_clk             ),
    
    .Axi_AVALID           ( Axi_AVALID          ),
    .Axi_AREADY           ( Axi_AREADY          ),
    .Axi_ATYPE            ( Axi_ATYPE           ),
    .Axi_ALEN             ( Axi_ALEN            ),
    .Axi_WVALID           ( Axi_WVALID          ),
    .Axi_WREADY           ( Axi_WREADY          ),
    .Axi_BVALID           ( Axi_BVALID          ),
    .Axi_BREADY           ( Axi_BREADY          ),
    .Axi_RVALID           ( Axi_RVALID          ),
    .Axi_RREADY           ( Axi_RREADY          ),
    .Axi_WLAST            ( Axi_WLAST           ),
    .Axi_RLAST            ( Axi_RLAST           ),
    .Axi_AADDR            ( Axi_AADDR           ),
                                                
    .Axi_WrEn             ( Axi_WrEn            ),
    .Axi_WrAddr           ( Axi_WrAddr          ),
                                                
    .Axi_RdAva            ( Axi_RdAva           ),
    .Axi_RdAddr           ( Axi_RdAddr          ),
                                                
    .Axi_TestErr          ( Axi_TestErr         ),
    .Axi_WrDataMode       ( Axi_WrDataMode      ),
    .Axi_RdDataMode       ( Axi_RdDataMode      ),
    .Axi_TimeOut          ( Axi_TimeOut         ),
    .Axi_WrStartA         ( Axi_WrStartA        ),
    .Axi_RdStartA         ( Axi_RdStartA        ),
                                                
    .Axi_WDATA__31___0    ( Axi_WDATA__31___0   ),
    .Axi_WDATA__63__32    ( Axi_WDATA__63__32   ),
    .Axi_WDATA__95__64    ( Axi_WDATA__95__64   ),
    .Axi_WDATA_127__96    ( Axi_WDATA_127__96   ),
    .Axi_WDATA_159_128    ( Axi_WDATA_159_128   ),
    .Axi_WDATA_191_160    ( Axi_WDATA_191_160   ),
    .Axi_WDATA_223_192    ( Axi_WDATA_223_192   ),
    .Axi_WDATA_255_224    ( Axi_WDATA_255_224   ),
                                                
    .Axi_RDATA__31___0    ( Axi_RDATA__31___0   ),
    .Axi_RDATA__63__32    ( Axi_RDATA__63__32   ),
    .Axi_RDATA__95__64    ( Axi_RDATA__95__64   ),
    .Axi_RDATA_127__96    ( Axi_RDATA_127__96   ),
    .Axi_RDATA_159_128    ( Axi_RDATA_159_128   ),
    .Axi_RDATA_191_160    ( Axi_RDATA_191_160   ),
    .Axi_RDATA_223_192    ( Axi_RDATA_223_192   ),
    .Axi_RDATA_255_224    ( Axi_RDATA_255_224   ),
    
  ////////////////
    .DdrTest_clk                    ( DdrTest_clk                     ),
    
    .DdrTest_TestBusy               ( DdrTest_TestBusy                ),
    .DdrTest_TestErrCnt             ( DdrTest_TestErrCnt              ),
    .DdrTest_TestRight              ( DdrTest_TestRight               ),
    .DdrTest_Operate_Total_Cycle    ( DdrTest_Operate_Total_Cycle     ),
    .DdrTest_Operate_Actual_Cycle   ( DdrTest_Operate_Actual_Cycle    ),
    .DdrTest_Operate_Efficiency_ppt ( DdrTest_Operate_Efficiency_ppt  ),
    .DdrTest_BandWidth_Mbps         ( DdrTest_BandWidth_Mbps          ),
    .DdrTest_WrPeriod_minimun_Cycle ( DdrTest_WrPeriod_minimun_Cycle  ),
    .DdrTest_WrPeriod_Average_Cycle ( DdrTest_WrPeriod_Average_Cycle  ),
    .DdrTest_WrPeriod_Maximum_Cycle ( DdrTest_WrPeriod_Maximum_Cycle  ),
    .DdrTest_RdPeriod_minimun_Cycle ( DdrTest_RdPeriod_minimun_Cycle  ),
    .DdrTest_RdPeriod_Average_Cycle ( DdrTest_RdPeriod_Average_Cycle  ),
    .DdrTest_RdPeriod_Maximum_Cycle ( DdrTest_RdPeriod_Maximum_Cycle  ),
    .DdrTest_Test_Time_second       ( DdrTest_Test_Time_second        ),
    
    .DdrTest_DdrReset               ( DdrTest_DdrReset                ),
    .DdrTest_CfgDataMode            ( DdrTest_CfgDataMode             ),
    .DdrTest_CfgTestMode            ( DdrTest_CfgTestMode             ),
    .DdrTest_CfgBurstLen            ( DdrTest_CfgBurstLen             ),
    .DdrTest_CfgStartAddr           ( DdrTest_CfgStartAddr            ),
    .DdrTest_CfgEndAddr             ( DdrTest_CfgEndAddr              ),
    .DdrTest_CfgTestLen             ( DdrTest_CfgTestLen              ),
    .DdrTest_TestStart              ( DdrTest_TestStart               )
 );

                                              
  /////////////////////////////////////////////////////////
  
 // assign  TestStart     = DdrTest_TestStart     ;
  assign  DdrResetCtrl  = DdrTest_DdrReset      ;
  assign  CfgDataMode   = DdrTest_CfgDataMode   ;
  assign  CfgTestMode   = DdrTest_CfgTestMode   ;
  assign  CfgBurstLen   = DdrTest_CfgBurstLen   ;
  assign  CfgStartAddr  = DdrTest_CfgStartAddr  ;
  assign  CfgEndAddr    = DdrTest_CfgEndAddr    ;
  assign  CfgTestLen    = DdrTest_CfgTestLen    ;
                                                     
`else //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  //Use Simulation
  /////////////////////////////////////////////////////////
  reg   TestBusyReg = 1'h0;
  reg   TestEndFlag = 1'h0;
  
  always @( posedge Axi0Clk)  TestBusyReg  <= # TCo_C TestBusy;
  always @( posedge Axi0Clk)  TestEndFlag  <= # TCo_C (~TestBusy)  & TestBusyReg;
  
  /////////////////////////////////////////////////////////
  reg  [3:0]  TestDlyCnt    = 4'h0;
  reg         TestStartFlag = 1'h0;
  
  always @( posedge Axi0Clk or negedge Axi0Rst_N)  
  begin
    if (~Axi0Rst_N)           TestDlyCnt <= # TCo_C 4'h0;
    else if (TestEndFlag)   TestDlyCnt <= # TCo_C 4'h0;
    else                    TestDlyCnt <= # TCo_C TestDlyCnt + {3'h0,(~&TestDlyCnt)};
  end
  always @( posedge Axi0Clk) TestStartFlag <= # TCo_C (TestDlyCnt == 4'he);
  
  /////////////////////////////////////////////////////////
  reg [1:0] ModeSelCnt = 2'h3;
  
  always @( posedge Axi0Clk)  if (TestEndFlag)
  begin
    if (ModeSelCnt == 2'h1) ModeSelCnt <= 2'h3;
    else                    ModeSelCnt <= ModeSelCnt - 2'h1;
  end
  
  /////////////////////////////////////////////////////////
  assign  TestStart     = TestStartFlag ;
  assign  DdrResetCtrl  =  1'h0         ;
  assign  CfgDataMode   =  2'h3         ;
  assign  CfgTestMode   = ModeSelCnt    ;
  assign  CfgBurstLen   =  8'h3         ;
  assign  CfgStartAddr  = 32'h0         ;
  assign  CfgEndAddr    = 32'hff_ff     ;
  assign  CfgTestLen    = 32'h100       ;

`endif  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

endmodule