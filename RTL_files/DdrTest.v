`timescale 100ps/10ps

module DdrTest
# (
  parameter   AXI_DATA_WIDTH    = 256             ,
	parameter   DDR_START_ADDRESS = 32'h00_00_21_00 ,  //DDR Memory Start Address
	parameter   DDR_END_ADDRESS   = 32'h0f_ff_ff_ff ,  //DDR Memory End Address
  parameter   DDR_WRITE_FIRST   = 1'h0            ,   //1:Write First ; 0: Read First
  parameter   RIGHT_CNT_WIDTH   = 27              ,      
	parameter   AXI_WR_ID         = 8'haa           ,
	parameter   AXI_RD_ID         = 8'h55           
  )
( 
  //System Signal
  input               SysClk      , //(O)System Clock
  input               Reset_N     , //(I)System Reset (Low Active)
  input   [  255 : 0] RamWrData   ,
  output  [  255 : 0] RamRdData   ,
//  output      reg     read_led    , 
//  input              R_trig,
  //Test Configuration & State
  input   [      1:0] CfgTestMode , //(I)Test Mode: 1:Read Only;2:Write Only;3:Write/Read alternate
  input   [      7:0] CfgBurstLen , //(I)Config Burst Length;
  input   [     31:0] CfgStartAddr, //(I)Config Start Address
  input   [     31:0] CfgEndAddr  , //(I)Config End Address
  input   [     31:0] CfgTestLen  , //(I)Config Test Length
  input   [      1:0] CfgDataMode , //Config Test Data Mode 0: Nomarl 1:Reverse
  input               TestStart   , //(I)Test Start Control
  //Test State  & Result      
  output              TestBusy    , //(O)Test Busy State  
  output              TestErr     , //(O)Test Data Error
  output              TestRight   , //(O)Test Data Right
  //AXI4 Operate 
 // output     reg    trig_rd ,
  output              AxiWrEn     , //Axi4 Write Enable
  output  [     31:0] AxiWrStartA , //Axi4 Write Start Address
  output  [     31:0] AxiWrAddr   , //Axi4 Write Address
  output  [ADW_C-1:0] AxiWrData   , //Axi4 Write Data
  output              AxiWrDMode  , //Axi4 Write DDR End
  output              AxiRdAva    , //Axi4 Read Available
  output  [     31:0] AxiRdStartA , //Axi4 Read Start Address
  output  [     31:0] AxiRdAddr   , //Axi4 Read Address
  output  [ADW_C-1:0] AxiRdData   , //Axi4 Read Data
  output              AxiRdDMode  , //Axi4 Read DDR End
  //DDR Controner AXI4 Signal
  output  [      7:0] aid         , //(O)[Addres] Address ID
  output  [     31:0] aaddr       , //(O)[Addres] Address
  output  [      7:0] alen        , //(O)[Addres] Address Brust Length
  output  [      2:0] asize       , //(O)[Addres] Address Burst size
  output  [      1:0] aburst      , //(O)[Addres] Address Burst type
  output  [      1:0] alock       , //(O)[Addres] Address Lock type
  output              avalid      , //(O)[Addres] Address Valid
  input               aready      , //(I)[Addres] Address Ready
  output              atype       , //(O)[Addres] Operate Type 0=Read, 1=Write
  /////////////               
  output  [      7:0] wid         , //(O)[Write]  ID
  output  [ADW_C-1:0] wdata       , //(O)[Write]  Data
  output  [ABN_C-1:0] wstrb       , //(O)[Write]  Data Strobes(Byte valid)
  output              wlast       , //(O)[Write]  Data Last
  output              wvalid      , //(O)[Write]  Data Valid
  input               wready      , //(I)[Write]  Data Ready
  /////////////               
  input   [      7:0] rid         , //(I)[Read]   ID
  input   [ADW_C-1:0] rdata       , //(I)[Read]   Data
  input               rlast       , //(I)[Read]   Data Last
  input               rvalid      , //(I)[Read]   Data Valid
  output              rready      , //(O)[Read]   Data Ready
  input   [      1:0] rresp       , //(I)[Read]   Response
  /////////////                   
  input   [      7:0] bid         , //(I)[Answer] Response Write ID
  input               bvalid      , //(I)[Answer] Response valid
  output              bready        //(O)[Answer] Response Ready
);

 	//Define  Parameter
/////////////////////////////////////////////////////////
  parameter		TCo_C   		= 1;    
		
  localparam  AXI_BYTE_NUMBER   = AXI_DATA_WIDTH/8        ;
  localparam  AXI_DATA_SIZE     = $clog2(AXI_BYTE_NUMBER) ;  
  
  localparam  ADW_C             = AXI_DATA_WIDTH          ;
  localparam  ABN_C             = AXI_BYTE_NUMBER         ;   
  localparam  ADS_C             = AXI_DATA_SIZE           ;
  
  localparam  [7:0] AXI_MAX_BURST     = (4096 / AXI_BYTE_NUMBER) - 1;
  
	/////////////////////////////////////////////////////////

  
//1111111111111111111111111111111111111111111111111111111
//	Process Configuration 
//	Input：
//	output：
//***************************************************/ 
  
  /////////////////////////////////////////////////////////
  reg   [1:0] TestStartReg  = 2'h0; 
  reg         TestConfInEn  = 1'h0;   //Test Config Input Enable
  reg         TestStartEn   = 1'h0;   //Test Start Enable
  reg         TestStopEn    = 1'h0;
  
  always @( posedge SysClk)  TestStartReg <= # TCo_C {TestStartReg[0] , TestStart};  
  always @( posedge SysClk)  TestConfInEn <= # TCo_C (TestStartReg == 2'h1) & (~TestBusy)
                                                    & (|CfgTestMode);     
  always @( posedge SysClk)  TestStartEn  <= # TCo_C TestConfInEn;  
  always @( posedge SysClk)  TestStopEn   <= # TCo_C (TestStartReg == 2'h2);     
                                                    
  /////////////////////////////////////////////////////////
  reg   [31:0]  CalcStartAddr ; //Calculate Start Address for DDR Test
  reg   [31:0]  CalcEndAddr   ; //Calculate End Address for DDR Test        
  reg   [ 7:0]  CalcBurstLen  ; //Calculate Burst Length for Axi4 Bus
  
  always @( posedge SysClk)  CalcStartAddr  <= # TCo_C (CfgStartAddr  > 32'h00_00_10_00 ) ?
                                                        CfgStartAddr  : 32'h00_00_10_00   ;
                                                        
  always @( posedge SysClk)  CalcEndAddr    <= # TCo_C (CfgEndAddr    < 32'h00_00_10_00   ) ?
                                                        CfgEndAddr    : 32'h00_00_10_00     ;
                                                        
  always @( posedge SysClk)  CalcBurstLen   <= # TCo_C (CfgBurstLen   < AXI_MAX_BURST     ) ?
                                                        CfgBurstLen   : AXI_MAX_BURST       ;
                                                        
  /////////////////////////////////////////////////////////
                                     
  reg   [ 1:0]  TestMode      =  2'h0             ;  //Test Mode: 1:Read Only;2:Write Only;2/3:Write/Read alternate
  reg   [ 7:0]  BurstLen      =  8'h0             ;  
  reg   [31:0]  StartAddr     = DDR_START_ADDRESS ; 
  reg   [31:0]  EndAddr       = DDR_END_ADDRESS   ; 
  reg   [31:0]  TestLen       = 32'h0             ;
                                                  
  reg   [12:0]  TestBurstLen  = 13'h0             ;
  
  always @( posedge SysClk)  begin 
  if (TestConfInEn)
  begin
    TestMode      <= # TCo_C    CfgTestMode   ;
    BurstLen      <= # TCo_C    CalcBurstLen  ;
    TestLen       <= # TCo_C    (|CfgTestLen) ? CfgTestLen :  {32{1'h1}};
    
    StartAddr     <= # TCo_C  { CalcStartAddr[31:8]  , 8'h 0  } ;
    EndAddr       <= # TCo_C  { CalcEndAddr  [31:8]  , 8'h 0} ;
    TestBurstLen  <= # TCo_C  (CalcBurstLen + 8'h1) << AXI_DATA_SIZE;
  end
  end
  
//1111111111111111111111111111111111111111111111111111111


//2222222222222222222222222222222222222222222222222222222
//	Write Address
//	Input：
//	output：
//***************************************************/ 
  
  /////////////////////////////////////////////////////////
  reg         WrBurstEn;
  reg [31:0]  WrBurstCnt  = 32'h0;
  
  always @( posedge SysClk or negedge Reset_N)  
  begin
    if (~Reset_N)           WrBurstCnt <= # TCo_C 32'h0   ;  
    else if (TestStopEn)    WrBurstCnt <= # TCo_C 32'h0   ;
    else if (TestStartEn)   WrBurstCnt <= # TCo_C TestLen ;
  //  else if (WrBurstEn )    WrBurstCnt <= # TCo_C WrBurstCnt - {31'h0,{|WrBurstCnt}};
    else if (WrBurstEn )    WrBurstCnt <= # TCo_C WrBurstCnt ;
  end
  
  /////////////////////////////////////////////////////////
  reg   TestWrBusy  = 1'h0;
  
  always @( posedge SysClk or negedge Reset_N) 
  begin
    if (~Reset_N)         TestWrBusy <= # TCo_C  1'h0;
    else if (TestWrBusy)
    begin
      if (TestStopEn)     TestWrBusy <= # TCo_C  1'h0;
      else if (~&TestLen) TestWrBusy <= # TCo_C  (|WrBurstCnt);
    end
    else if (TestStartEn) TestWrBusy <= # TCo_C  CfgTestMode[1];
  end
  
  /////////////////////////////////////////////////////////
  reg [31:0]  NextWrAddrCnt   = 32'h0;
  reg         TestDdrWrEnd    =  1'h0;
  reg         WrAxiCross4K    =  1'h0;

  always @( posedge SysClk)  
  begin
  //  if (TestStartEn)          NextWrAddrCnt   <= # TCo_C StartAddr      + {18'h0,TestBurstLen };
    if (TestStartEn)          NextWrAddrCnt   <= # TCo_C StartAddr ;
    else if (WrBurstEn)  
    begin
      if (TestDdrWrEnd)       NextWrAddrCnt   <= # TCo_C StartAddr   ;
       else if (WrAxiCross4K)  NextWrAddrCnt   <= # TCo_C {(NextWrAddrCnt[31:12])};
      else                    NextWrAddrCnt   <= # TCo_C NextWrAddrCnt ;
    end
  end

  /////////////////////////////////////////////////////////
 // wire  [32:0]  WrAddrEndDiff   = {1'h0,EndAddr} - {1'h0,NextWrAddrCnt};  
  wire  [32:0]  WrAddrEndDiff   = {1'h0,EndAddr} ;  
 // wire  [12:0]  WrAddr4KDiff    = 13'h1000 - {1'h0 , NextWrAddrCnt[11:0]} ; 
  wire  [12:0]  WrAddr4KDiff    = 13'h1000 ; 
  
  always @( posedge SysClk)  TestDdrWrEnd   <= # TCo_C ( WrAddrEndDiff < {1'h0,TestBurstLen} );
  always @( posedge SysClk)  WrAxiCross4K   <= # TCo_C ( WrAddr4KDiff  < {1'h0,TestBurstLen} ); 
  
  ///////////////////////////////////////////////////////// 
  reg   [7:0]  WrBurstLen       = 8'h0;
  
  wire  [7:0]  WrAddrRemainder  = (WrAddr4KDiff[11:0] - 12'h1) >> AXI_DATA_SIZE;
  
  always @( posedge SysClk)  
  begin    
    if (TestStartEn)          WrBurstLen <= # TCo_C BurstLen; 
    else if (WrBurstEn)
    begin
      if (TestDdrWrEnd)       WrBurstLen <= # TCo_C BurstLen;   
      else if (WrAxiCross4K)  WrBurstLen <= # TCo_C WrAddrRemainder;
      else                    WrBurstLen <= # TCo_C BurstLen;
    end
  end
  
  ///////////////////////////////////////////////////////// 
  reg [31:0]  TestWrStartAddr = 32'h0;   
  
  always @( posedge SysClk)  
  begin
    if (TestStartEn)      TestWrStartAddr <= # TCo_C StartAddr ;
    else if (WrBurstEn)   TestWrStartAddr <= # TCo_C TestDdrWrEnd ? StartAddr : NextWrAddrCnt;
  end
  
  ///////////////////////////////////////////////////////// 
  //Operate Control & State
  wire   RamWrStart  = WrBurstEn ; //(I)[DdrWrCtrl]Ram Operate Start
  
 /// wire  [ADW_C-1:0]  RamWrData   ; //(I)[DdrWrCtrl]Ram Write Data
  wire               RamWrEnd    ; //(O)[DdrWrCtrl]Ram Operate End
  wire  [     31:0]  RamWrAddr   ; //(O)[DdrWrCtrl]Ram Write Address
  wire               RamWrNext   ; //(O)[DdrWrCtrl]Ram Write Next
  wire               RamWrBusy   ; //(O)[DdrWrCtrl]Ram Write Busy
  wire               RamWrALoad  ; //(O)Ram Write Address Load

  //////////////////////////
  //Config DDR Operate Parameter
  wire  [31:0]    CfgWrAddr   = TestWrStartAddr ; //(I)[DdrWrCtrl]Config Write Start Address
  wire  [ 7:0]    CfgWrBLen   = WrBurstLen      ; //(I)[DdrWrCtrl]Config Write Burst Length

  ////////////////////////
  wire  [      7:0]   AWID    ; //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  wire  [     31:0]   AWADDR  ; //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  wire  [      7:0]   AWLEN   ; //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  wire  [      2:0]   AWSIZE  ; //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  wire  [      1:0]   AWBURST ; //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  wire  [      1:0]   AWLOCK  ; //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  wire                AWVALID ; //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  wire                AWREADY ; //(I)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////  
  wire  [      7:0]   WID     ; //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  wire  [ABN_C-1:0]   WSTRB   ; //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  wire                WLAST   ; //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  wire                WVALID  ; //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  wire                WREADY  ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  wire  [ADW_C-1:0]   WDATA   ; //(I)[WrData]Write data.
  /////////////
  wire  [       7:0]  BID     ; //(I)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  wire                BVALID  ; //(I)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  wire                BREADY  ; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

  DdrWrCtrl
  # (
      .AXI_WR_ID      ( AXI_WR_ID       ) ,
      .AXI_DATA_WIDTH ( AXI_DATA_WIDTH  )
    )
  U1_DdrWrCtrl
  (
    //System Signal
    .SysClk     ( SysClk      ), //System Clock
    .Reset_N    ( Reset_N     ), //System Reset
    //config AXI&DDR Operate Parameter
    .CfgWrAddr  ( CfgWrAddr   ), //(I)Config Write Start Address
    .CfgWrBLen  ( CfgWrBLen   ), //(I)Config Write Burst Length
    //Operate Control & State 
    .RamWrStart ( RamWrStart  ), //(I)Ram Operate Start
    .RamWrEnd   ( RamWrEnd    ), //(O)Ram Operate End
    .RamWrAddr  ( RamWrAddr   ), //(O)Ram Write Address
    .RamWrNext  ( RamWrNext   ), //(O)[DdrWrCtrl]Ram Write Next
    .RamWrData  ( RamWrData   ), //(I)[DdrWrCtrl]Ram Write Data
    .RamWrBusy  ( RamWrBusy   ), //(O)Ram Write Busy
    .RamWrALoad ( RamWrALoad  ), //(O)Ram Write Address Load
    //Axi Slave Interfac Signal
    .AWID       ( AWID        ), //(O)[WrAddr]Write address ID.
    .AWADDR     ( AWADDR      ), //(O)[WrAddr]Write address.
    .AWLEN      ( AWLEN       ), //(O)[WrAddr]Burst length.
    .AWSIZE     ( AWSIZE      ), //(O)[WrAddr]Burst size.
    .AWBURST    ( AWBURST     ), //(O)[WrAddr]Burst type.
    .AWLOCK     ( AWLOCK      ), //(O)[WrAddr]Lock type.
    .AWVALID    ( AWVALID     ), //(O)[WrAddr]Write address valid.
    .AWREADY    ( AWREADY     ), //(I)[WrAddr]Write address ready.
    /////////////             
    .WID        ( WID         ), //(O)[WrData]Write ID tag.
    .WDATA      ( WDATA       ), //(O)[WrData]Write data.
    .WSTRB      ( WSTRB       ), //(O)[WrData]Write strobes.
    .WLAST      ( WLAST       ), //(O)[WrData]Write last.
    .WVALID     ( WVALID      ), //(O)[WrData]Write valid.
    .WREADY     ( WREADY      ), //(I)[WrData]Write ready.
    /////////////             
    .BID        ( BID         ), //(I)[WrResp]Response ID tag.
    .BVALID     ( BVALID      ), //(I)[WrResp]Write response valid.
    .BREADY     ( BREADY      )  //(O)[WrResp]Response ready.
  );
  
  /////////////////////////////////////////////////////////  
  reg   [1:0] WrDdrReturn;
  reg         WrDataMode;
  
  always @( posedge SysClk)  if (RamWrALoad)  
  begin
    WrDdrReturn[1] <=  WrDdrReturn[0];
    WrDdrReturn[0] <= (TestDdrWrEnd & (&CfgTestMode) & CfgDataMode[1]);
  end
  
  wire  WrDdrReturnEn = WrDdrReturn[1] & RamWrALoad;
  
  always @( posedge SysClk)  
  begin
    if (TestConfInEn)         WrDataMode  <= # TCo_C CfgDataMode[0];
    else if (WrDdrReturnEn)   WrDataMode  <= # TCo_C (~WrDataMode) ;
  end
  
  ///////////////////////////////////////////////////////////// 
  wire [ADW_C-1:0]  RamWrDOut;
  
	DdrWrDataGen  #(.AXI_DATA_WIDTH ( AXI_DATA_WIDTH ))
	U1_DdrWrDataGen
  (   
  	.SysClk     ( SysClk      ),  //System Clock
  	.WrStartEn  ( RamWrALoad  ),  //(I)[DdrWrDataGen]Write Start Enale
  	.WrAddrIn   ( RamWrAddr   ),  //(I)[DdrWrDataGen]Write Address Input 
  	.WriteEn    ( RamWrNext   ) ,//(I)[DdrWrDataGen]Write Enable
  	.DdrWrData  ( RamWrDOut   )   //(O)[DdrWrDataGen]DDR Write Data
  );
  
 //  assign RamWrData = WrDataMode ? (~RamWrDOut) : RamWrDOut;
  
  /////////////////////////////////////////////////////////
  //AXI4 Operate 
  reg                 RamWrNextReg  ; //Axi4 Write Enable
  reg   [     31:0]   RamWrAddrReg  ; //Axi4 Write Address
  reg   [ADW_C-1:0]   RamWrDataReg  ; //Axi4 Write Data        
  reg   [     31:0]   WrStartAReg   ;                   
  
  always @( posedge SysClk)                 RamWrNextReg <= # TCo_C  RamWrNext       ; //Axi4 Write Enable   
  always @( posedge SysClk) if(RamWrNext)   RamWrAddrReg <= # TCo_C  RamWrAddr       ; //Axi4 Write Address
  always @( posedge SysClk) if(RamWrNext)   RamWrDataReg <= # TCo_C  RamWrData       ; //Axi4 Write Data
  always @( posedge SysClk) if(RamWrALoad)  WrStartAReg  <= # TCo_C  TestWrStartAddr ; //Axi4 Write Start Address
  
  /////////////////////////////////////////////////////////
  assign  AxiWrEn     = RamWrNextReg  ; //Axi4 Write Enable
  assign  AxiWrAddr   = RamWrAddrReg  ; //Axi4 Write Address
  assign  AxiWrData   = RamWrDataReg  ; //Axi4 Write Data
  assign  AxiWrStartA = WrStartAReg   ; //Axi4 Write Start Address
  
  assign  AxiWrDMode  = WrDataMode    ; //Axi4 Write DDR End
  
//2222222222222222222222222222222222222222222222222222222


//3333333333333333333333333333333333333333333333333333333
//	
//	Input：
//	output：
//***************************************************/ 
  
  /////////////////////////////////////////////////////////
  reg         RdBurstEn   =  1'h0;
  reg [31:0]  RdBurstCnt  = 32'h0;
  
  always @( posedge SysClk or negedge Reset_N) 
  begin
    if (~Reset_N)           RdBurstCnt <= # TCo_C 32'h0   ;
    else if (TestStopEn)    RdBurstCnt <= # TCo_C 32'h0   ;
    else if (TestStartEn)   RdBurstCnt <= # TCo_C TestLen ;
    else if (RdBurstEn )    RdBurstCnt <= # TCo_C RdBurstCnt - {31'h0,{|RdBurstCnt}};
  end
  
  /////////////////////////////////////////////////////////
  reg   TestRdBusy  = 1'h0;
  
  always @( posedge SysClk or negedge Reset_N) 
  begin
    if (~Reset_N)         TestRdBusy <= # TCo_C  1'h0;
    else if (TestRdBusy)
    begin
      if (TestStopEn)     TestRdBusy <= # TCo_C  1'h0;
      else if (~&TestLen) TestRdBusy <= # TCo_C  (|RdBurstCnt);
    end
    else if (TestStartEn) TestRdBusy <= # TCo_C  CfgTestMode[0];
  end
  
  /////////////////////////////////////////////////////////
  reg [31:0]  NextRdAddrCnt   = 32'h0;
  reg         TestDdrRdEnd    =  1'h0;
  reg         RdAxiCross4K    =  1'h0;

  always @( posedge SysClk)  
  begin
    if (TestStartEn)          NextRdAddrCnt   <= # TCo_C StartAddr      + {18'h0,TestBurstLen};
    else if (RdBurstEn)  
    begin
      if (TestDdrRdEnd)       NextRdAddrCnt   <= # TCo_C StartAddr      + {18'h0,TestBurstLen};
      else if (RdAxiCross4K)  NextRdAddrCnt   <= # TCo_C {(NextRdAddrCnt[31:12] + 20'h1),12'h0};
      else                    NextRdAddrCnt   <= # TCo_C NextRdAddrCnt  + {18'h0,TestBurstLen};
    end
  end

  /////////////////////////////////////////////////////////
  wire  [32:0]  RdAddrEndDiff   = {1'h0,EndAddr} - {1'h0,NextRdAddrCnt};  
  wire  [12:0]  RdAddr4KDiff    = 13'h1000 - {1'h0 , NextRdAddrCnt[11:0]} ; 
  
  always @( posedge SysClk)  TestDdrRdEnd   <= # TCo_C (RdAddrEndDiff < {1'h0,TestBurstLen} );
  always @( posedge SysClk)  RdAxiCross4K   <= # TCo_C (RdAddr4KDiff  < {1'h0,TestBurstLen} ); 
  
  ///////////////////////////////////////////////////////// 
  reg  [7:0]  RdBurstLen    = 8'h0;
  
  wire  [7:0] WrAddrRemainder = (RdAddr4KDiff[11:0] - 12'h1) >> AXI_DATA_SIZE;
  
  always @( posedge SysClk) 
  begin
    if (TestStartEn)          RdBurstLen <= # TCo_C BurstLen; 
    else  if (RdBurstEn)
    begin
      if (TestDdrRdEnd)       RdBurstLen <= # TCo_C BurstLen; 
      else if (RdAxiCross4K)  RdBurstLen <= # TCo_C WrAddrRemainder;
      else                    RdBurstLen <= # TCo_C BurstLen;
    end
  end
  
  ///////////////////////////////////////////////////////// 
  reg [31:0]  TestRdStartAddr = 32'h0;   
  
  always @( posedge SysClk)  
  begin
    if (TestStartEn)        TestRdStartAddr <= # TCo_C StartAddr    ;
    else if (RdBurstEn)     TestRdStartAddr <= # TCo_C TestDdrRdEnd ? StartAddr : NextRdAddrCnt;
  end
  
  /////////////////////////////////////////////////////////
  //Operate Control & State
  wire              RamRdStart  = RdBurstEn  ; //(I)[DdrRdCtrl]Ram Read Start
  
  wire              RamRdEnd    ; //(O)[DdrRdCtrl]Ram Read End
  wire  [     31:0] RamRdAddr   ; //(O)[DdrRdCtrl]Ram Read Addrdss
  wire              RamRdDAva   ; //(O)[DdrRdCtrl]Ram Read Available
 // wire  [ADW_C-1:0] RamRdData   ; //(O)[DdrRdCtrl]Ram Read Data
  wire              RamRdBusy   ; //(O)Ram Read Busy
  wire              RamRdALoad  ; //(O)Ram Read Address Load

  ////////////////////////////
  //Config DDR & AXI Operate Parameter
  wire  [     31:0] CfgRdAddr   = TestRdStartAddr ; //(I)[DdrRdCtrl]Config Read Start Address
  wire  [      7:0] CfgRdBLen   = RdBurstLen      ; //(I)[DdrRdCtrl]Config Read Burst Length

  ////////////////////////////
  //Axi4 Read Address & Data Bus
  wire  [      7:0] ARID        ; //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
  wire  [     31:0] ARADDR      ; //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
  wire  [      7:0] ARLEN       ; //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
  wire  [      2:0] ARSIZE      ; //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
  wire  [      1:0] ARBURST     ; //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
  wire  [      1:0] ARLOCK      ; //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
  wire              ARVALID     ; //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.
  wire              ARREADY     ; //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////            
  wire  [      7:0] RID         ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  wire  [      1:0] RRESP       ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  wire              RLAST       ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  wire              RVALID      ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  wire              RREADY      ; //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.
  wire [ADW_C-1:0]  RDATA       ; //(O)[RdData]Read data.

  DdrRdCtrl
  # (
      .AXI_RD_ID      (AXI_RD_ID      ) ,
      .AXI_DATA_WIDTH (AXI_DATA_WIDTH )
    )
  U2_DdrRdCtrl
  (
    //System Signal
    .SysClk     ( SysClk    ), //System Clock
    .Reset_N    ( Reset_N   ), //System Reset
    //.read_led   ( read_led  ),
    //.read_trig  ( read_trig ),
    //Config DDR & AXI Operate Parameter
    .CfgRdAddr  ( CfgRdAddr ), //(I)Config Read Start Address
    .CfgRdBLen  ( CfgRdBLen ), //(I)[DdrOpCtrl]Config Read Burst Length
    //Operate Control & State
    .RamRdStart ( RamRdStart), //(I)Ram Read Start
    .RamRdEnd   ( RamRdEnd  ), //(O)Ram Read End
    .RamRdAddr  ( RamRdAddr ), //(O)Ram Read Addrdss
    .RamRdData  ( RamRdData ), //(O)Ram Read Data
    .RamRdDAva  ( RamRdDAva ), //(O)Ram Read Available
    .RamRdBusy  ( RamRdBusy ), //(O)Ram Read Busy
    .RamRdALoad ( RamRdALoad), //(O)Ram Read Address Load
    //Axi4 Read Address & Data Bus
    .ARID       ( ARID      ), //(O)[RdAddr]Read address ID.
    .ARADDR     ( ARADDR    ), //(O)[RdAddr]Read address.
    .ARLEN      ( ARLEN     ), //(O)[RdAddr]Burst length.
    .ARSIZE     ( ARSIZE    ), //(O)[RdAddr]Burst size.
    .ARBURST    ( ARBURST   ), //(O)[RdAddr]Burst type.
    .ARLOCK     ( ARLOCK    ), //(O)[RdAddr]Lock type.
    .ARVALID    ( ARVALID   ), //(O)[RdAddr]Read address valid.
    .ARREADY    ( ARREADY   ), //(I)[RdAddr]Read address ready.
    /////////////
    .RID        ( RID       ), //(I)[RdData]Read ID tag.
    .RDATA      ( RDATA     ), //(I)[RdData]Read data.
    .RRESP      ( RRESP     ), //(I)[RdData]Read response.
    .RLAST      ( RLAST     ), //(I)[RdData]Read last.
    .RVALID     ( RVALID    ), //(I)[RdData]Read valid.
    .RREADY     ( RREADY    )  //(O)[RdData]Read ready.
  );

  /////////////////////////////////////////////////////////  
  reg   [1:0] RdDdrReturn;
  reg         RdDataMode;
  
  always @( posedge SysClk)  if (RamRdALoad)  
  begin
    RdDdrReturn[1] <= RdDdrReturn[0];
    RdDdrReturn[0] <= TestDdrRdEnd & (&CfgTestMode) & CfgDataMode[1];
  end
  
  wire  RdDdrReturnEn = RdDdrReturn[1] & RamRdALoad;
  
  always @( posedge SysClk)  
  begin
    if (TestConfInEn)         RdDataMode  <= # TCo_C CfgDataMode[0];
    else if (RdDdrReturnEn)   RdDataMode  <= # TCo_C (~RdDataMode) ;
  end
  
 // wire  [ADW_C-1:0] RamRdDIn    = RdDataMode ? (~RamRdData) : RamRdData;
  
  /////////////////////////////////////////////////////////  
   
 /* read_data_test 
  rd_test(
        .rd_clk (SysClk),
        .read_trig (R_trig),
        .read_led (read_led),
        .RamWrEnd (RamWrEnd)
);*/
  

  DdrRdDataChk 
  # (
      .RIGHT_CNT_WIDTH  ( RIGHT_CNT_WIDTH ),
      .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH  )
    )
  U2_DdrRdDataChk
  (   
    .SysClk     ( SysClk    ),  //(I)System Clock
    .RdAddrIn   ( RamRdAddr ),  //(I)[DdrRdDataChk]Read Address Input            
    .RdDataEn   ( RamRdDAva ),  //(I)[DdrRdDataChk]DDR Read Data Valid         
    .DdrRdData  ( RamRdDIn ),  //(I)[DdrRdDataChk]DDR Read DataOut  
  	.DdrRdError ( TestErr   ),  //(O)[DdrRdDataChk]DDR Prbs Error         
  	.DdrRdRight ( TestRight )   //(O)[DdrRdDataChk]DDR Read Right           
  );
  
  /////////////////////////////////////////////////////////
  //AXI4 Operate 
  reg               RamRdDAvaReg  ; //Axi4 Read Available
  reg   [     31:0] RamRdAddrReg  ; //Axi4 Read Address
  reg   [ADW_C-1:0] RamRdDataReg  ; //Axi4 Read Data
  reg   [     31:0] RdStartAReg   ; 
  
  always @( posedge SysClk) RamRdDAvaReg  <= # TCo_C RamRdDAva  ; //Axi4 Read Available
  always @( posedge SysClk) RamRdAddrReg  <= # TCo_C RamRdAddr  ; //Axi4 Read Address
  always @( posedge SysClk)  begin
            RamRdDataReg  <= # TCo_C RamRdData  ; //Axi4 Read Data
           // trig_rd <= 1'b1 ;
  end 
     
  always @( posedge SysClk) if(RamRdALoad)  RdStartAReg  <= # TCo_C TestRdStartAddr  ; 
  
  /////////////////////////////////////////////////////////
  assign  AxiRdAva    = RamRdDAvaReg  ; //Axi4 Read Available
  //assign  read_led    = RamRdDAvaReg  ;
  assign  AxiRdAddr   = RamRdAddrReg  ; //Axi4 Read Address
  assign  AxiRdData   = RamRdDataReg  ; //Axi4 Read Data
  assign  AxiRdStartA = RdStartAReg   ; //Axi4 Read Start Address
  
  assign  AxiRdDMode  = RdDataMode    ; //Axi4 Read DDR End
  
  
//3333333333333333333333333333333333333333333333333333333




//4444444444444444444444444444444444444444444444444444444
//	
//	Input：
//	output：
//***************************************************/ 
    
  /////////////////////////////////////////////////////////
  reg [1:0]   WrFirstDCnt = 2'h0;
  
  always @( posedge SysClk or negedge Reset_N )  
  begin
    if (~Reset_N)           WrFirstDCnt <= # TCo_C 2'h0;
    else if (TestStopEn)    WrFirstDCnt <= # TCo_C 2'h0;
    else if (TestStartEn)   WrFirstDCnt <= # TCo_C (|TestLen[31:2]) ? 2'h3 : TestLen[1:0];
    else if (WrBurstEn )    WrFirstDCnt <= # TCo_C WrFirstDCnt - {1'h0,{|WrFirstDCnt}};
  end
  
  /////////////////////////////////////////////////////////
  reg   TestWrBusyReg = 1'h0;
  reg   TesrWrTestEnd = 1'h0;
  
  always @( posedge SysClk)  TestWrBusyReg  <= # TCo_C TestWrBusy;
  always @( posedge SysClk)  TesrWrTestEnd  <= # TCo_C TestWrBusyReg & (~TestWrBusy)  ;
  
  /////////////////////////////////////////////////////////
  always @( posedge SysClk)  
  begin
    case (TestMode)
      2'b00:
      begin
        WrBurstEn <= # TCo_C 1'h0;
        RdBurstEn <= # TCo_C 1'h0;
      end
      2'b01:
      begin
        WrBurstEn <= # TCo_C 1'h0;
        RdBurstEn <= # TCo_C (RamRdEnd & TestRdBusy)  | TestStartEn;
      end
      2'b10:
      begin
        WrBurstEn <= # TCo_C (RamWrEnd & TestWrBusy)  | TestStartEn;
        RdBurstEn <= # TCo_C 1'h0;
      end
      2'b11:
      begin
        if (|WrFirstDCnt)     WrBurstEn <= # TCo_C (RamWrEnd & TestWrBusy)  | TestStartEn;
        else                  WrBurstEn <= # TCo_C (RamRdEnd & TestWrBusy)  | TestStartEn;
        
        if (|WrFirstDCnt)     RdBurstEn <= # TCo_C  1'h0;
        else if (TestWrBusy)  RdBurstEn <= # TCo_C  RamWrEnd;
        else                  begin
        RdBurstEn <= # TCo_C  (RamRdEnd & TestRdBusy) | TesrWrTestEnd;   
        //read_led  <= 1'b1 ;
        end 
      end
    endcase
  end
  
  
  
  /////////////////////////////////////////////////////////
  assign    TestBusy  =  TestWrBusy | TestRdBusy ; //(O)Test Busy State  
  
//4444444444444444444444444444444444444444444444444444444


//5555555555555555555555555555555555555555555555555555555
//	
//	Input：
//	output：
//***************************************************/ 
    
  /////////////////////////////////////////////////////////
	
//5555555555555555555555555555555555555555555555555555555


//6666666666666666666666666666666666666666666666666666666
//	
//	Input：
//	output：
//***************************************************/ 
    
  Axi4FullDeplex
  # (
      .DDR_WRITE_FIRST  ( DDR_WRITE_FIRST ),
      .AXI_DATA_WIDTH   ( AXI_DATA_WIDTH  )
    )
  U2_Axi4FullDeplex_0
  (
    //System Signal
    .SysClk   ( SysClk    ), //System Clock
    .Reset_N  ( Reset_N   ), //System Reset
    //Axi Slave Interfac Signal
    .AWID     ( AWID      ),  //(O)[WrAddr]Write address ID.
    .AWADDR   ( AWADDR    ),  //(O)[WrAddr]Write address.
    .AWLEN    ( AWLEN     ),  //(O)[WrAddr]Burst length.
    .AWSIZE   ( AWSIZE    ),  //(O)[WrAddr]Burst size.
    .AWBURST  ( AWBURST   ),  //(O)[WrAddr]Burst type.
    .AWLOCK   ( AWLOCK    ),  //(O)[WrAddr]Lock type.
    .AWVALID  ( AWVALID   ),  //(O)[WrAddr]Write address valid.
    .AWREADY  ( AWREADY   ),  //(I)[WrAddr]Write address ready.
    ///////////                 
    .WID      ( WID       ),  //(O)[WrData]Write ID tag.
    .WDATA    ( WDATA     ),  //(O)[WrData]Write data.
    .WSTRB    ( WSTRB     ),  //(O)[WrData]Write strobes.
    .WLAST    ( WLAST     ),  //(O)[WrData]Write last.
    .WVALID   ( WVALID    ),  //(O)[WrData]Write valid.
    .WREADY   ( WREADY    ),  //(I)[WrData]Write ready.
    ///////////                 
    .BID      ( BID       ),  //(I)[WrResp]Response ID tag.
    .BVALID   ( BVALID    ),  //(I)[WrResp]Write response valid.
    .BREADY   ( BREADY    ),   //(O)[WrResp]Response ready.
    ///////////                 
    .ARID     ( ARID      ),  //(O)[RdAddr]Read address ID.
    .ARADDR   ( ARADDR    ),  //(O)[RdAddr]Read address.
    .ARLEN    ( ARLEN     ),  //(O)[RdAddr]Burst length.
    .ARSIZE   ( ARSIZE    ),  //(O)[RdAddr]Burst size.
    .ARBURST  ( ARBURST   ),  //(O)[RdAddr]Burst type.
    .ARLOCK   ( ARLOCK    ),  //(O)[RdAddr]Lock type.
    .ARVALID  ( ARVALID   ),  //(O)[RdAddr]Read address valid.
    .ARREADY  ( ARREADY   ),  //(I)[RdAddr]Read address ready.
    ///////////                 
    .RID      ( RID       ),  //(I)[RdData]Read ID tag.
    .RDATA    ( RDATA     ),  //(I)[RdData]Read data.
    .RRESP    ( RRESP     ),  //(I)[RdData]Read response.
    .RLAST    ( RLAST     ),  //(I)[RdData]Read last.
    .RVALID   ( RVALID    ),  //(I)[RdData]Read valid.
    .RREADY   ( RREADY    ),  //(O)[RdData]Read ready.
    /////////////
    //DDR Controner AXI4 Signal
    .aid      ( aid       ),  //(O)[Addres] Address ID
    .aaddr    ( aaddr     ),  //(O)[Addres] Address
    .alen     ( alen      ),  //(O)[Addres] Address Brust Length
    .asize    ( asize     ),  //(O)[Addres] Address Burst size
    .aburst   ( aburst    ),  //(O)[Addres] Address Burst type
    .alock    ( alock     ),  //(O)[Addres] Address Lock type
    .avalid   ( avalid    ),  //(O)[Addres] Address Valid
    .aready   ( aready    ),  //(I)[Addres] Address Ready
    .atype    ( atype     ),  //(O)[Addres] Operate Type 0=Read, 1=Write
    /////////// /////////     
    .wid      ( wid       ),  //(O)[Write]  ID
    .wdata    ( wdata     ),  //(O)[Write]  Data
    .wstrb    ( wstrb     ),  //(O)[Write]  Data Strobes(Byte valid)
    .wlast    ( wlast     ),  //(O)[Write]  Data Last
    .wvalid   ( wvalid    ),  //(O)[Write]  Data Valid
    .wready   ( wready    ),  //(I)[Write]  Data Ready
    /////////// /////////     
    .rid      ( rid       ),  //(I)[Read]   ID
    .rdata    ( rdata     ),  //(I)[Read]   Data
    .rlast    ( rlast     ),  //(I)[Read]   Data Last
    .rvalid   ( rvalid    ),  //(I)[Read]   Data Valid
    .rready   ( rready    ),  //(O)[Read]   Data Ready
    .rresp    ( rresp     ),  //(I)[Read]   Response
    /////////// /////////     
    .bid      ( bid       ),  //(I)[Answer] Response Write ID
    .bvalid   ( bvalid    ),  //(I)[Answer] Response valid
    .bready   ( bready    )   //(O)[Answer] Response Ready
  );
  
//6666666666666666666666666666666666666666666666666666666


endmodule