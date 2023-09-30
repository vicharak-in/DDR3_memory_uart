`timescale 100ps/10ps

////////////////// DdrWrCtrl /////////////////////////////
/**********************************************************
  Function Description:

  Establishment : Richard Zhu
  Create date   : 2020-01-09
  Versions      : V0.1
  Revision of records:
  Ver0.1

**********************************************************/

module  DdrWrCtrl
(
  //System Signal
  SysClk      , //System Clock
  Reset_N     , //System Reset
  //config AXI&DDR Operate Parameter
  CfgWrAddr   , //(I)Config Write Start Address
  CfgWrBLen   , //(I)Config Write Burst Length
  //Operate Control & State
  RamWrStart  , //(I)Ram Operate Start
  RamWrEnd    , //(O)Ram Operate End
  RamWrAddr   , //(O)Ram Write Address
  RamWrNext   , //(O)Ram Write Next
  RamWrData   , //(I)Ram Write Data
  RamWrBusy   , //(O)Ram Write Busy
  RamWrALoad  , //(O)Ram Write Address Load
  //Axi Slave Interfac Signal
  AWID        , //(O)[WrAddr]Write address ID.
  AWADDR      , //(O)[WrAddr]Write address.
  AWLEN       , //(O)[WrAddr]Burst length.
  AWSIZE      , //(O)[WrAddr]Burst size.
  AWBURST     , //(O)[WrAddr]Burst type.
  AWLOCK      , //(O)[WrAddr]Lock type.
  AWVALID     , //(O)[WrAddr]Write address valid.
  AWREADY     , //(I)[WrAddr]Write address ready.
  /////////////
  WID         , //(O)[WrData]Write ID tag.
  WDATA       , //(O)[WrData]Write data.
  WSTRB       , //(O)[WrData]Write strobes.
  WLAST       , //(O)[WrData]Write last.
  WVALID      , //(O)[WrData]Write valid.
  WREADY      , //(I)[WrData]Write ready.
  /////////////
  BID         , //(I)[WrResp]Response ID tag.
  BVALID      , //(I)[WrResp]Write response valid.
  BREADY        //(O)[WrResp]Response ready.
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   TCo_C           = 1                 ;
                                                  
  parameter   AXI_WR_ID       = 8'ha5             ;
  parameter   AXI_DATA_WIDTH  = 256               ;
                                                  
  localparam  AXI_BYTE_NUMBER = AXI_DATA_WIDTH/8  ;
  localparam  AXI_DATA_SIZE   = $clog2(AXI_BYTE_NUMBER) ;  
                                                  
  localparam  ADW_C           = AXI_DATA_WIDTH    ;
  localparam  ABN_C           = AXI_BYTE_NUMBER   ;

  /////////////////////////////////////////////////////////

  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  input         SysClk    ;     //System Clock
  input         Reset_N   ;     //System Reset

  /////////////////////////////////////////////////////////
  //Operate Control & State
  input             RamWrStart  ; //(I)[DdrWrCtrl]Ram Operate Start
  output            RamWrEnd    ; //(O)[DdrWrCtrl]Ram Operate End
  output  [31:0]    RamWrAddr   ; //(O)[DdrWrCtrl]Ram Write Address
  output            RamWrNext   ; //(O)[DdrWrCtrl]Ram Write Next
  output            RamWrBusy   ; //(O)[DdrWrCtrl]Ram Write Busy
  input [ADW_C-1:0] RamWrData   ; //(I)[DdrWrCtrl]Ram Write Data
  output            RamWrALoad  ; //(O)Ram Write Address Load

  /////////////////////////////////////////////////////////
  //Config DDR Operate Parameter
  input   [31:0]    CfgWrAddr   ; //(I)[DdrWrCtrl]Config Write Start Address
  input   [ 7:0]    CfgWrBLen   ; //(I)[DdrWrCtrl]Config Write Burst Length

  /////////////////////////////////////////////////////////
  output  [ 7:0]    AWID        ; //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  output  [31:0]    AWADDR      ; //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  output  [ 7:0]    AWLEN       ; //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  output  [ 2:0]    AWSIZE      ; //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  output  [ 1:0]    AWBURST     ; //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  output  [ 1:0]    AWLOCK      ; //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  output            AWVALID     ; //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  input             AWREADY     ; //(I)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////                 
  output  [ 7:0]    WID         ; //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  output[ABN_C-1:0] WSTRB       ; //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  output            WLAST       ; //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  output            WVALID      ; //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  input             WREADY      ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  output[ADW_C-1:0] WDATA       ; //(I)[WrData]Write data.
  /////////////                 
  input   [ 7:0]    BID         ; //(I)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  input             BVALID      ; //(I)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  output            BREADY      ; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

//1111111111111111111111111111111111111111111111111111111
//  Process Address Channel
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  AddrReady = AWREADY;

  /////////////////////////////////////////////////////////
  reg   [ 7:0]  WrBurstLen  =  8'h0;
  reg   [31:0]  WrStartAddr = 32'h0;

  always @( posedge SysClk)   if(RamWrStart)  WrBurstLen  <= # TCo_C  CfgWrBLen;
  always @( posedge SysClk)   if(RamWrStart)  WrStartAddr <= # TCo_C  CfgWrAddr;

  /////////////////////////////////////////////////////////
  reg     AddrValid = 1'h0;

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)         AddrValid <= # TCo_C 1'h0;
    else if (RamWrStart)  AddrValid <= # TCo_C 1'h1;
    else if (AddrReady)   AddrValid <= # TCo_C 1'h0;
  end

  wire AddrWrEn = (AddrValid & AddrReady);

  /////////////////////////////////////////////////////////
  wire  [ 7:0]  AWID    = AXI_WR_ID     ; //(O)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  wire  [31:0]  AWADDR  = WrStartAddr   ; //(O)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  wire  [ 7:0]  AWLEN   = WrBurstLen    ; //(O)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
                                        
  wire  [ 2:0]  AWSIZE  = AXI_DATA_SIZE ; //(O)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  wire  [ 1:0]  AWBURST = 2'b01         ; //(O)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  wire  [ 1:0]  AWLOCK  = 2'b00         ; //(O)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  wire          AWVALID = AddrValid     ; //(O)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.

  /////////////////////////////////////////////////////////

//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//  Process DDR Operate
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  DataWrReady     = WREADY  ;

  /////////////////////////////////////////////////////////
  reg   DataWrValid     = 1'h0    ;
  reg   DataWrLast      = 1'h0    ;
                        
  wire  DataWrEn        = DataWrValid & DataWrReady              ;
  wire  DataWrEnd       = DataWrValid & DataWrReady & DataWrLast ;

  /////////////////////////////////////////////////////////
  reg   DataWrAddrAva   = 1'h0 ;
  reg   DataWrStart     = 1'h0 ;

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (~Reset_N)       DataWrAddrAva <= # TCo_C 1'h0;
    else if (DataWrEnd) DataWrAddrAva <= # TCo_C 1'h0;
    else if (AddrWrEn)  DataWrAddrAva <= # TCo_C DataWrValid;
  end
    
 // wire	DataWrNextBrst  = (AddrWrEn | DataWrAddrAva ) & DataWrEnd;
  wire	DataWrNextBrst  = 0;
  
  always @( posedge SysClk)  DataWrStart    <= # TCo_C (AddrWrEn & (~DataWrValid)) | DataWrNextBrst;
  
  /////////////////////////////////////////////////////////
  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)           DataWrValid  <= # TCo_C 1'h0;
    else if (DataWrStart)   DataWrValid  <= # TCo_C 1'h1;
    else if (DataWrEnd)     DataWrValid  <= # TCo_C 1'h0;
  end

  /////////////////////////////////////////////////////////
  reg   [7:0]   WrBurstCnt = 8'h0;

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)           WrBurstCnt  <= # TCo_C 8'h0;
    else if (DataWrStart)   WrBurstCnt  <= # TCo_C WrBurstLen;
    //else if (DataWrEn)      WrBurstCnt  <= # TCo_C WrBurstCnt - {7'h0,(|WrBurstCnt)};
    else if (DataWrEn)      WrBurstCnt  <= # TCo_C WrBurstCnt;
  end

  always @( posedge SysClk)
  begin
    if (DataWrStart)      DataWrLast <= # TCo_C  (~|WrBurstLen);
    else if (DataWrEn)    DataWrLast <= # TCo_C  (WrBurstCnt == 8'h1);
    else if (DataWrEnd)   DataWrLast <= # TCo_C  1'h0;
  end

  /////////////////////////////////////////////////////////
  wire  [      7:0]   WID     = AXI_WR_ID     ; //(O)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  wire  [ABN_C-1:0]   WSTRB   = {ABN_C{1'h1}} ; //(O)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  wire                WVALID  = DataWrValid   ; //(O)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  wire                WLAST   = DataWrLast    ; //(O)[WrData]Write last. This signal indicates the last transfer in a write burst.
  wire  [ADW_C-1:0]   WDATA   = RamWrData     ; //(I)[WrData]Write data.

  /////////////////////////////////////////////////////////
  wire  RamWrALoad  = DataWrStart; //(O)Ram Write Address Load

//22222222222222222222222222222222222222222222222222222


//3333333333333333333333333333333333333333333333333333333
//  Write Address
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  [ 7:0]  WrByteNum = AXI_BYTE_NUMBER ;
  reg   [31:0]  WrAddrCnt = 32'h0           ;  //(O)Ram Write Address

  always @( posedge SysClk)
  begin
    if (~DataWrValid)         WrAddrCnt <= # TCo_C WrStartAddr;
    else if (DataWrNextBrst)  WrAddrCnt <= # TCo_C WrStartAddr;
   // else if (DataWrEn)        WrAddrCnt <= # TCo_C WrAddrCnt  + {24'h0,WrByteNum};
    else if (DataWrEn)        WrAddrCnt <= # TCo_C WrAddrCnt  ;
  end

  /////////////////////////////////////////////////////////
  reg   RamWrBusy = 1'h0; //(O)[DdrWrCtrl]Ram Write Busy

  always @( posedge SysClk) RamWrBusy <= # TCo_C DataWrAddrAva & DataWrValid;

  /////////////////////////////////////////////////////////
  reg   DataWrBusy  = 1'h0  ;
  reg   RamWrEnd    = 1'h0  ;   //(O)[DdrWrCtrl]Ram Operate End

  always @( posedge SysClk)
  begin
    if (DataWrEnd)       DataWrBusy <= # TCo_C 1'h0;
    else if (DataWrEn)   DataWrBusy <= # TCo_C 1'h1;
  end
  
  always @( posedge SysClk)   RamWrEnd  <= # TCo_C (~DataWrBusy) & DataWrEn;   
  
  /////////////////////////////////////////////////////////  
  wire          RamWrNext = DataWrEn    ;               //(O)[DdrWrCtrl]Ram Write Next
  wire  [31:0]  RamWrAddr = WrAddrCnt   ;               //(O)[DdrWrCtrl]Ram Write Address
  
  /////////////////////////////////////////////////////////

//3333333333333333333333333333333333333333333333333333333

//4444444444444444444444444444444444444444444444444444444
//  Write Address
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire    BackValid = BVALID;

  /////////////////////////////////////////////////////////
  reg     BackReady = 1'h0; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)           BackReady  <= # TCo_C 1'h0;
    else if (DataWrLast)    BackReady  <= # TCo_C 1'h1;
    else if (BackValid)     BackReady  <= # TCo_C 1'h0;
  end

  wire    BackRespond = BackReady & BackValid;

  /////////////////////////////////////////////////////////
  wire    BREADY = BackReady; //(O)[WrResp]Response ready. This signal indicates that the master can accept a write response.

  /////////////////////////////////////////////////////////

//4444444444444444444444444444444444444444444444444444444


//5555555555555555555555555555555555555555555555555555555
//  Write Address
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
//5555555555555555555555555555555555555555555555555555555



endmodule

/////////////////// DdrWrCtrl ///////////////////////////////////








/////////////////// DdrRdCtrl ///////////////////////////////////
/**********************************************************
  Function Description:

  Establishment : Richard Zhu
  Create date   : 2020-01-09
  Versions      : V0.1
  Revision of records:
  Ver0.1

**********************************************************/
module  DdrRdCtrl
(
  //System Signal
  SysClk      , //System Clock
  Reset_N     , //System Reset
  //Operate Control & State
  RamRdStart  , //(I)Ram Read Start
  RamRdEnd    , //(O)Ram Read End
  RamRdAddr   , //(O)Ram Read Addrdss
  RamRdData   , //(O)Ram Read Data
  RamRdDAva   , //(O)Ram Read Available
  RamRdBusy   , //(O)Ram Read Busy
  RamRdALoad  , //(O)Ram Read Address Load
  //Config DDR & AXI Operate Parameter
  CfgRdAddr   , //(I)Config Read Start Address
  CfgRdBLen   , //(I)[DdrOpCtrl]Config Read Burst Length
  //Axi4 Read Address & Data Bus
  ARID        , //(O)[RdAddr]Read address ID.
  ARADDR      , //(O)[RdAddr]Read address.
  ARLEN       , //(O)[RdAddr]Burst length.
  ARSIZE      , //(O)[RdAddr]Burst size.
  ARBURST     , //(O)[RdAddr]Burst type.
  ARLOCK      , //(O)[RdAddr]Lock type.
  ARVALID     , //(O)[RdAddr]Read address valid.
  ARREADY     , //(I)[RdAddr]Read address ready.
  /////////////
  RID         , //(I)[RdData]Read ID tag.
  RDATA       , //(I)[RdData]Read data.
  RRESP       , //(I)[RdData]Read response.
  RLAST       , //(I)[RdData]Read last.
  RVALID      , //(I)[RdData]Read valid.
  RREADY        //(O)[RdData]Read ready.
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   TCo_C           = 1;

  parameter   AXI_RD_ID       = 8'ha5             ;
  parameter   AXI_DATA_WIDTH  = 256               ;

  localparam  AXI_BYTE_NUMBER = AXI_DATA_WIDTH/8  ;
  localparam  AXI_DATA_SIZE   = $clog2(AXI_BYTE_NUMBER) ;  
  
  localparam  ADW_C           = AXI_DATA_WIDTH    ;
  localparam  ABN_C           = AXI_BYTE_NUMBER   ;

  /////////////////////////////////////////////////////////

  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  input         SysClk    ;     //System Clock
  input         Reset_N   ;     //System Reset

  /////////////////////////////////////////////////////////
  //Operate Control & State
  input               RamRdStart  ; //(I)[DdrRdCtrl]Ram Read Start
  output              RamRdEnd    ; //(O)[DdrRdCtrl]Ram Read End
  output  [     31:0] RamRdAddr   ; //(O)[DdrRdCtrl]Ram Read Addrdss
  output              RamRdDAva   ; //(O)[DdrRdCtrl]Ram Read Available
  output              RamRdBusy   ; //(O)Ram Read Busy
  output              RamRdALoad  ; //(O)Ram Read Address Load
  output  [ADW_C-1:0] RamRdData   ; //(O)[DdrRdCtrl]Ram Read Data

  /////////////////////////////////////////////////////////
  //Config DDR & AXI Operate Parameter
  input   [     31:0] CfgRdAddr   ; //(I)[DdrRdCtrl]Config Read Start Address
  input   [      7:0] CfgRdBLen   ; //(I)[DdrRdCtrl]Config Read Burst Length

  /////////////////////////////////////////////////////////
  //Axi4 Read Address & Data Bus
  output  [      7:0] ARID        ; //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
  output  [     31:0] ARADDR      ; //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
  output  [      7:0] ARLEN       ; //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
  output  [      2:0] ARSIZE      ; //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
  output  [      1:0] ARBURST     ; //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
  output  [      1:0] ARLOCK      ; //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
  output              ARVALID     ; //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.
  input               ARREADY     ; //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////              
  input   [      7:0] RID         ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  input   [      1:0] RRESP       ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  input               RLAST       ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  input               RVALID      ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  output              RREADY      ; //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.
  input   [ADW_C-1:0] RDATA       ; //(O)[RdData]Read data.


  /////////////////////////////////////////////////////////

//1111111111111111111111111111111111111111111111111111111
//  Process AXI Operate Parameter
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  AddrReady = ARREADY;

  /////////////////////////////////////////////////////////
  reg   [7 :0]  RdBurstLen  = 8'h0;
  reg   [31:0]  RdStartAddr = 32'h0;

  always @( posedge SysClk)   if(RamRdStart)  RdBurstLen    <= # TCo_C  CfgRdBLen;
  always @( posedge SysClk)   if(RamRdStart)  RdStartAddr   <= # TCo_C  CfgRdAddr;

  /////////////////////////////////////////////////////////
  reg     AddrValid = 1'h0; //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)         AddrValid <= # TCo_C 1'h0;
    else if (RamRdStart)  AddrValid <= # TCo_C 1'h1;
    else if (AddrReady)   AddrValid <= # TCo_C 1'h0;
  end

  wire AddrRdEn = (AddrValid & AddrReady);

  /////////////////////////////////////////////////////////
  wire  [ 7:0]  ARID    = AXI_RD_ID     ; //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
  wire  [31:0]  ARADDR  = RdStartAddr   ; //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
  wire  [ 7:0]  ARLEN   = RdBurstLen    ; //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
  wire  [ 2:0]  ARSIZE  = AXI_DATA_SIZE ; //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
  wire  [ 1:0]  ARBURST = 2'b01         ; //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
  wire  [ 1:0]  ARLOCK  = 2'h00         ; //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
  wire          ARVALID = AddrValid     ; //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.

//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//  Process DDR Operate
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  [     7:0]   DataRdId    = RID     ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  wire  [     1:0]   DataRdResp  = RRESP   ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  wire               DataRdLast  = RLAST   ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  wire               DataRdValid = RVALID  ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  wire  [ADW_C-1:0]  DataRdData  = RDATA   ; //(O)[RdData]Read data.

  /////////////////////////////////////////////////////////
  reg   DataRdReady = 1'h0;

  wire  DataRdEn    = DataRdReady & DataRdValid;
  wire  DataRdEnd   = DataRdReady & DataRdValid & DataRdLast;

  /////////////////////////////////////////////////////////
  reg   DataRdAddrAva     = 1'h0;
  reg   DataRdNextBrst    = 1'h0;
  reg   DataRdStart       = 1'h0;

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (~Reset_N)       DataRdAddrAva <= # TCo_C 1'h0;
    else if (DataRdEnd) DataRdAddrAva <= # TCo_C 1'h0;
    else if (AddrRdEn)  DataRdAddrAva <= # TCo_C DataRdReady;
  end

  always @( posedge SysClk)  DataRdNextBrst <= # TCo_C (AddrRdEn | DataRdAddrAva ) & DataRdEnd;
  always @( posedge SysClk)  DataRdStart    <= # TCo_C (AddrRdEn & (~DataRdReady)) | DataRdNextBrst;

  wire  RamRdALoad =  DataRdStart; //(O)Ram Read Address Load;

  /////////////////////////////////////////////////////////
  reg [7:0] DataRdTimeOut   = 8'hff ;
  reg       DataRdReadyClr  = 1'h0  ;

  always @( posedge SysClk)
  begin
    if (DataRdValid)  DataRdTimeOut <= # TCo_C 8'h01;
    //else              DataRdTimeOut <= # TCo_C DataRdTimeOut - {7'h0, (|DataRdTimeOut)};
    else              DataRdTimeOut <= # TCo_C DataRdTimeOut ;
  end

  always @( posedge SysClk)  DataRdReadyClr <= # TCo_C (DataRdTimeOut == 5'h1);

  /////////////////////////////////////////////////////////
  reg [7:0] RdBurstCnt      = 8'h0;
  reg       DataRdLastFlag  = 1'h0;

  always @( posedge SysClk or negedge Reset_N)
  begin
    if (! Reset_N)          RdBurstCnt <= # TCo_C 8'h0;
    else if (DataRdStart)   RdBurstCnt <= # TCo_C RdBurstLen;
    else if (DataRdEn)      RdBurstCnt <= # TCo_C RdBurstCnt - {7'h0,(|RdBurstCnt)};
  end

  always @( posedge SysClk)
  begin
    if (DataRdStart)    DataRdLastFlag <= # TCo_C (RdBurstLen == 8'h0);
    else if (DataRdEn)  DataRdLastFlag <= # TCo_C (RdBurstCnt == 8'h1);
    else if (DataRdEnd) DataRdLastFlag <= # TCo_C (RdBurstCnt == 8'h0);
  end

  wire  DataRdEndFlag = DataRdLastFlag & DataRdEn;

  /////////////////////////////////////////////////////////
  reg   DataRdEndReg;
  
  always @( posedge SysClk)  DataRdEndReg <= # TCo_C DataRdEnd;
  
  
  /////////////////////////////////////////////////////////
  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)             DataRdReady  <= # TCo_C 1'h0;
    else if (DataRdReadyClr)  DataRdReady  <= # TCo_C 1'h0;
    else if (DataRdEndReg)    DataRdReady  <= # TCo_C 1'h0;
    else if (DataRdEnd  )     DataRdReady  <= # TCo_C 1'h0;
    else if (DataRdEndFlag)   DataRdReady  <= # TCo_C 1'h0;
    else if (DataRdStart)     DataRdReady  <= # TCo_C 1'h1;
    else if (DataRdValid)     DataRdReady  <= # TCo_C 1'h1;
  end

  /////////////////////////////////////////////////////////
  wire  RREADY  = DataRdReady ; //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.

//22222222222222222222222222222222222222222222222222222




//3333333333333333333333333333333333333333333333333333333
//
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire [7:0]   RdByteNum =  AXI_BYTE_NUMBER ;
  reg  [31:0]  RdAddrCnt = 32'h0  ; //(O)[DdrRdCtrl]Ram Read Addrdss

  always @( posedge SysClk)
  begin
    if (DataRdStart)    RdAddrCnt <= # TCo_C RdStartAddr;
    else  if (DataRdEn) RdAddrCnt <= # TCo_C RdAddrCnt + {24'h0,RdByteNum};
  end

  /////////////////////////////////////////////////////////
  reg   RamRdBusy   = 1'h0; //(O)Ram Read Busy

  always @( posedge SysClk)   RamRdBusy <= DataRdReady | DataRdAddrAva;

  /////////////////////////////////////////////////////////
  reg   DataRdBusy = 1'h0;

  always @( posedge SysClk)
  begin
    if (DataRdEnd)      DataRdBusy <= # TCo_C 1'h0;
    else if (DataRdEn)  DataRdBusy <= # TCo_C 1'h1;
  end

  /////////////////////////////////////////////////////////
  reg   RamRdEnd = 1'h0;   //(O)[DdrRdCtrl]Ram Read End
  
  always @( posedge SysClk)  RamRdEnd  <= # TCo_C DataRdEn & (~DataRdBusy) ;   //(O)[DdrRdCtrl]Ram Read End

  /////////////////////////////////////////////////////////
  reg                 RamRdDAva ; //(O)[DdrRdCtrl]Ram Read Available
  reg   [ADW_C-1:0]   RamRdData ; //(O)[DdrRdCtrl]Ram Read Data
  reg   [     31:0]   RamRdAddr ; //(O)[DdrRdCtrl]Ram Read Addrdss

  always @( posedge SysClk)                 RamRdDAva <= # TCo_C DataRdEn   ; //(O)[DdrRdCtrl]Ram Read Available
  always @( posedge SysClk)  if (DataRdEn)  RamRdData <= # TCo_C DataRdData ; //(O)[DdrRdCtrl]Ram Read Data
  always @( posedge SysClk)  if (DataRdEn)  RamRdAddr <= # TCo_C RdAddrCnt  ; //(O)[DdrRdCtrl]Ram Read Addrdss


  /////////////////////////////////////////////////////////

//3333333333333333333333333333333333333333333333333333333

endmodule



/////////////////// DdrRdCtrl ///////////////////////////







/////////////////// Axi4FullDeplex ///////////////////////////
module Axi4FullDeplex
(
  //System Signal
  SysClk    , //System Clock
  Reset_N   , //System Reset
  //Axi Slave Interfac Signal
  AWID      , //(I)[WrAddr]Write address ID.
  AWADDR    , //(I)[WrAddr]Write address.
  AWLEN     , //(I)[WrAddr]Burst length.
  AWSIZE    , //(I)[WrAddr]Burst size.
  AWBURST   , //(I)[WrAddr]Burst type.
  AWLOCK    , //(I)[WrAddr]Lock type.
  AWVALID   , //(I)[WrAddr]Write address valid.
  AWREADY   , //(O)[WrAddr]Write address ready.
  ///////////
  WID       , //(I)[WrData]Write ID tag.
  WDATA     , //(I)[WrData]Write data.
  WSTRB     , //(I)[WrData]Write strobes.
  WLAST     , //(I)[WrData]Write last.
  WVALID    , //(I)[WrData]Write valid.
  WREADY    , //(O)[WrData]Write ready.
  ///////////
  BID       , //(O)[WrResp]Response ID tag.
  BVALID    , //(O)[WrResp]Write response valid.
  BREADY    , //(I)[WrResp]Response ready.
  ///////////
  ARID      , //(I)[RdAddr]Read address ID.
  ARADDR    , //(I)[RdAddr]Read address.
  ARLEN     , //(I)[RdAddr]Burst length.
  ARSIZE    , //(I)[RdAddr]Burst size.
  ARBURST   , //(I)[RdAddr]Burst type.
  ARLOCK    , //(I)[RdAddr]Lock type.
  ARVALID   , //(I)[RdAddr]Read address valid.
  ARREADY   , //(O)[RdAddr]Read address ready.
  ///////////
  RID       , //(O)[RdData]Read ID tag.
  RDATA     , //(O)[RdData]Read data.
  RRESP     , //(O)[RdData]Read response.
  RLAST     , //(O)[RdData]Read last.
  RVALID    , //(O)[RdData]Read valid.
  RREADY    , //(I)[RdData]Read ready.
  /////////////
  //DDR Controner AXI4 Signal
  aid       , //(O)[Addres] Address ID
  aaddr     , //(O)[Addres] Address
  alen      , //(O)[Addres] Address Brust Length
  asize     , //(O)[Addres] Address Burst size
  aburst    , //(O)[Addres] Address Burst type
  alock     , //(O)[Addres] Address Lock type
  avalid    , //(O)[Addres] Address Valid
  aready    , //(I)[Addres] Address Ready
  atype     , //(O)[Addres] Operate Type 0=Read, 1=Write
  /////////////
  wid       , //(O)[Write]  ID
  wdata     , //(O)[Write]  Data
  wstrb     , //(O)[Write]  Data Strobes(Byte valid)
  wlast     , //(O)[Write]  Data Last
  wvalid    , //(O)[Write]  Data Valid
  wready    , //(I)[Write]  Data Ready
  /////////////
  rid       , //(I)[Read]   ID
  rdata     , //(I)[Read]   Data
  rlast     , //(I)[Read]   Data Last
  rvalid    , //(I)[Read]   Data Valid
  rready    , //(O)[Read]   Data Ready
  rresp     , //(I)[Read]   Response
  /////////////
  bid       , //(I)[Answer] Response Write ID
  bvalid    , //(I)[Answer] Response valid
  bready      //(O)[Answer] Response Ready
);

  //Define  Parameter
  /////////////////////////////////////////////////////////
  parameter   TCo_C  = 1;

  parameter   DDR_WRITE_FIRST     = 1'h1;
  parameter   AXI_DATA_WIDTH      = 256 ;

  localparam  AXI_BYTE_NUMBER     = AXI_DATA_WIDTH/8  ;
                                                      
  localparam  ADW_C               = AXI_DATA_WIDTH    ;
  localparam  ABN_C               = AXI_BYTE_NUMBER   ;

  /////////////////////////////////////////////////////////

  //Define Port
  /////////////////////////////////////////////////////////
  //System Signal
  input               SysClk  ; //System Clock
  input               Reset_N ; //System Reset

  /////////////////////////////////////////////////////////
  //AXI4 Full Deplex
  input   [      7:0] AWID    ; //(I)[WrAddr]Write address ID. This signal is the identification tag for the write address group of signals.
  input   [     31:0] AWADDR  ; //(I)[WrAddr]Write address. The write address gives the address of the first transfer in a write burst transaction.
  input   [      7:0] AWLEN   ; //(I)[WrAddr]Burst length. The burst length gives the exact number of transfers in a burst. This information determines the number of data transfers associated with the address.
  input   [      2:0] AWSIZE  ; //(I)[WrAddr]Burst size. This signal indicates the size of each transfer in the burst.
  input   [      1:0] AWBURST ; //(I)[WrAddr]Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
  input   [      1:0] AWLOCK  ; //(I)[WrAddr]Lock type. Provides additional information about the atomic characteristics of the transfer.
  input               AWVALID ; //(I)[WrAddr]Write address valid. This signal indicates that the channel is signaling valid write address and control information.
  output              AWREADY ; //(O)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////  
  input   [      7:0] WID     ; //(I)[WrData]Write ID tag. This signal is the ID tag of the write data transfer.
  input   [ABN_C-1:0] WSTRB   ; //(I)[WrData]Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
  input               WLAST   ; //(I)[WrData]Write last. This signal indicates the last transfer in a write burst.
  input               WVALID  ; //(I)[WrData]Write valid. This signal indicates that valid write data and strobes are available.
  output              WREADY  ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.
  input   [ADW_C-1:0] WDATA   ; //(I)[WrData]Write data.
  /////////////  
  output  [      7:0] BID     ; //(O)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  output              BVALID  ; //(O)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.
  input               BREADY  ; //(I)[WrResp]Response ready. This signal indicates that the master can accept a write response.
  /////////////  
  input   [      7:0] ARID    ; //(I)[RdAddr]Read address ID. This signal is the identification tag for the read address group of signals.
  input   [     31:0] ARADDR  ; //(I)[RdAddr]Read address. The read address gives the address of the first transfer in a read burst transaction.
  input   [      7:0] ARLEN   ; //(I)[RdAddr]Burst length. This signal indicates the exact number of transfers in a burst.
  input   [      2:0] ARSIZE  ; //(I)[RdAddr]Burst size. This signal indicates the size of each transfer in the burst.
  input   [      1:0] ARBURST ; //(I)[RdAddr]Burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
  input   [      1:0] ARLOCK  ; //(I)[RdAddr]Lock type. This signal provides additional information about the atomic characteristics of the transfer.
  input               ARVALID ; //(I)[RdAddr]Read address valid. This signal indicates that the channel is signaling valid read address and control information.
  output              ARREADY ; //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  /////////////  
  output  [      7:0] RID     ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  output  [      1:0] RRESP   ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  output              RLAST   ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  output              RVALID  ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  input               RREADY  ; //(I)[RdData]Read ready. This signal indicates that the master can accept the read data and response information.
  output  [ADW_C-1:0] RDATA   ; //(O)[RdData]Read data.

  /////////////////////////////////////////////////////////
  //DDR Controner AXI4 Signal Define
  output  [      7:0] aid     ; //(O)[Addres]Address ID
  output  [     31:0] aaddr   ; //(O)[Addres]Address
  output  [      7:0] alen    ; //(O)[Addres]Address Brust Length
  output  [      2:0] asize   ; //(O)[Addres]Address Burst size
  output  [      1:0] aburst  ; //(O)[Addres]Address Burst type
  output  [      1:0] alock   ; //(O)[Addres]Address Lock type
  output              avalid  ; //(O)[Addres]Address Valid
  input               aready  ; //(I)[Addres]Address Ready
  output              atype   ; //(O)[Addres]Operate Type 0=Read, 1=Write
  output  [      7:0] wid     ; //(O)[Write]Data ID
  output  [ABN_C-1:0] wstrb   ; //(O)[Write]Data Strobes(Byte valid)
  output              wlast   ; //(O)[Write]Data Last
  output              wvalid  ; //(O)[Write]Data Valid
  input               wready  ; //(I)[Write]Data Ready
  output  [ADW_C-1:0] wdata   ; //(O)[Write]Data Data
  input   [      7:0] rid     ; //(I)[Read]Data ID
  input               rlast   ; //(I)[Read]Data Last
  input               rvalid  ; //(I)[Read]Data Valid
  output              rready  ; //(O)[Read]Data Ready
  input   [      1:0] rresp   ; //(I)[Read]Response
  input   [ADW_C-1:0] rdata   ; //(I)[Read]Data Data
  input   [      7:0] bid     ; //(I)[Answer]Response Write ID
  input               bvalid  ; //(I)[Answer]Response valid
  output              bready  ; //(O)[Answer]Response Ready

//1111111111111111111111111111111111111111111111111111111
//
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  reg           OpType = 1'h0;

  wire          AWREADY =  OpType & aready  ; //(O)[WrAddr]Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
  wire          ARREADY = ~OpType & aready  ; //(O)[RdAddr]Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.

  /////////////////////////////////////////////////////////
  reg   OperateSel = 1'h0;

  always @( posedge SysClk) if (aready)
  begin
    if      (AWVALID ^ ARVALID)   OperateSel <= # TCo_C ~DDR_WRITE_FIRST  ;
    else if (AWVALID & ARVALID)   OperateSel <= # TCo_C ~OperateSel       ;
  end

  /////////////////////////////////////////////////////////
  reg   [1:0] OprateAva = 2'h3;

  always @( posedge SysClk or negedge Reset_N )
  begin
    if ( ! Reset_N )      OprateAva <= # TCo_C  2'h3;
    else
    begin
      case (OprateAva)
        2'h0:               OprateAva <= # TCo_C  2'h3;
        2'h1: if (ARREADY)  OprateAva <= # TCo_C  {AWVALID  , 1'h0   };
        2'h2: if (AWREADY)  OprateAva <= # TCo_C  {1'h0     , ARVALID};
        2'h3:
        begin
          case ({AWVALID , ARVALID})
            2'h0:   OprateAva  <= # TCo_C 2'h3;
            2'h1:   OprateAva  <= # TCo_C 2'h1;
            2'h2:   OprateAva  <= # TCo_C 2'h2;
            2'h3:   OprateAva  <= # TCo_C OperateSel ? 2'h2 : 2'h1;
          endcase
        end
      endcase
    end
  end

  /////////////////////////////////////////////////////////
  wire  [1:0]  AddrVal = {AWVALID , ARVALID} & OprateAva;

  always @( * )
  begin
    case (AddrVal)
      2'h0:   OpType  <= # TCo_C OperateSel;
      2'h1:   OpType  <= # TCo_C 1'h0;
      2'h2:   OpType  <= # TCo_C 1'h1;
      2'h3:   OpType  <= # TCo_C OperateSel;
    endcase
  end

//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//
//  Input：
//  output：
//***************************************************/

  /////////////////////////////////////////////////////////
  wire  [      7:0] aid     = OpType ? AWID     : (~ARID) ; //(O)[Addres]Address ID
  wire  [     31:0] aaddr   = OpType ? AWADDR   : ARADDR  ; //(O)[Addres]Address
  wire  [      7:0] alen    = OpType ? AWLEN    : ARLEN   ; //(O)[Addres]Address Brust Length
  wire  [      2:0] asize   = OpType ? AWSIZE   : ARSIZE  ; //(O)[Addres]Address Burst size
  wire  [      1:0] aburst  = OpType ? AWBURST  : ARBURST ; //(O)[Addres]Address Burst type
  wire  [      1:0] alock   = OpType ? AWLOCK   : ARLOCK  ; //(O)[Addres]Address Lock type
  wire              avalid  = OpType ? AWVALID  : ARVALID ; //(O)[Addres]Address Valid
  wire              atype   = OpType                      ; //(O)[Addres]Operate Type 0=Read, 1=Write

  /////////////////////////////////////////////////////////
  wire  [      7:0] wid     = WID     ; //(O)[Write]Data ID
  wire  [ABN_C-1:0] wstrb   = WSTRB   ; //(O)[Write]Data Strobes(Byte valid)
  wire              wlast   = WLAST   ; //(O)[Write]Data Last
  wire              wvalid  = WVALID  ; //(O)[Write]Data Valid
  wire  [ADW_C-1:0] wdata   = WDATA   ; //(O)[Write]Data Data
                                      
  wire              WREADY  = wready  ; //(O)[WrData]Write ready. This signal indicates that the slave can accept the write data.

  /////////////////////////////////////////////////////////
  wire              bready  = BREADY  ; //(O)[Answer]Response Ready
                                      
  wire  [     7:0]  BID     = bid     ; //(O)[WrResp]Response ID tag. This signal is the ID tag of the write response.
  wire              BVALID  = bvalid  ; //(O)[WrResp]Write response valid. This signal indicates that the channel is signaling a valid write response.

  /////////////////////////////////////////////////////////
  wire              rready  = RREADY  ; //(O)[Read]Data Ready
                                      
  wire  [     7:0]  RID     = (~rid)  ; //(O)[RdData]Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
  wire  [     1:0]  RRESP   = rresp   ; //(O)[RdData]Read response. This signal indicates the status of the read transfer.
  wire              RLAST   = rlast   ; //(O)[RdData]Read last. This signal indicates the last transfer in a read burst.
  wire              RVALID  = rvalid  ; //(O)[RdData]Read valid. This signal indicates that the channel is signaling the required read data.
  wire [ADW_C-1:0]  RDATA   = rdata   ; //(O)[RdData]Read data.

//22222222222222222222222222222222222222222222222222222




endmodule

/////////////////// Axi4FullDeplex ///////////////////////////