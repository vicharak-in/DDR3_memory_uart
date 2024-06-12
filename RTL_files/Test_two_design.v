`define   Test_AXI0
`define   Efinity_Debug

module Test_two_design (
    input i_clk,
    input axi_clk,
    input uart_clk,
    input s_data,
   // output R_trig,
    output RD_led ,
    output last_s_out, 
   // input rst,
    output [7:0] test_t_data,
    output [7:0] test_rd_data,
    output wr_en,
    output e_en,
    output rd_enable,
    output done,
  // output ready,
    output valid,
   // output [7:0] o_t_data,
    output [255:0] rd_data,
   // output [255:0] RD_out ,
    
   // output t_data ,
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
 // input           TestStart ,
   
    
  //DDR Controner Control Signal
  output          DdrCtrl_CFG_RST_N          , //(O)[Control]DDR Controner Reset(Low Active)     
  output          DdrCtrl_CFG_SEQ_RST   , //(O)[Control]DDR Controner Sequencer Reset 
  output          DdrCtrl_CFG_SEQ_START , //(O)[Control]DDR Controner Sequencer Start 
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
  output          DdrCtrl_BREADY_0   //(O)[Answer] Response Ready
 // output  [7:0]   LED
);

wire [255:0] wr_data ;
//wire [7:0] o_t_data ;
wire trig_en , c_data;

TOP_DESIGN
    u_1(
        .i_clk (i_clk),
        .axi_clk (axi_clk),
        .data (s_data),
      //  .i_trig (trig),
       // .e_wr_flag (wr_empty),
        .s_out (wr_data),
        .trig_flag (trig_en)
);


DdrControllerDebug
c_1(
  //Check Resultwire
   `ifdef  Efinity_Debug  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
      .jtag_inst1_CAPTURE (jtag_inst1_CAPTURE) ,
      .jtag_inst1_DRCK  (jtag_inst1_DRCK)  ,
      .jtag_inst1_RESET (jtag_inst1_RESET)  ,
      .jtag_inst1_RUNTEST (jtag_inst1_RUNTEST) ,
      .jtag_inst1_SEL  (jtag_inst1_SEL)   ,
      .jtag_inst1_SHIFT  (jtag_inst1_SHIFT) ,
      .jtag_inst1_TCK  (jtag_inst1_TCK)   ,
      .jtag_inst1_TDI  (jtag_inst1_TDI)   ,
      .jtag_inst1_TMS  (jtag_inst1_TMS)   ,
      .jtag_inst1_UPDATE (jtag_inst1_UPDATE) ,
      .jtag_inst1_TDO  (jtag_inst1_TDO)   ,
    `endif  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
      //System Signal
      .SysClk  (SysClk)  , //System Clock
      .Axi0Clk  (Axi0Clk) , //Axi 0 Channel Clock
      .Axi1Clk  (Axi1Clk) , //Axi 1 Channel Clock
      .uart_clk (uart_clk),
      .PllLocked (PllLocked), //PLL Locked
      .TestStart (trig_en) ,

      .Ram_Wr (wr_data),
      .Ram_Rd (rd_data),
     // .read_trig (re_trig) ,
      
      //.rst(rst),
      .w_enable (wr_en) ,
      .rd_en (rd_enable),
     // .e_flag (e_en),
    //  .tx_trig (tx_trig) ,
      .tx_data (test_t_data) ,
      .rd_test (test_rd_data),
      .f_out (last_s_out),
      .led_1 (RD_led),
      .t_done (done),
      .t_valid (valid),

     
     //DDR Controner Control Signal
        .DdrCtrl_CFG_RST_N   (DdrCtrl_CFG_RST_N)       , //(O)[Control]DDR Controner Reset(Low Active)     
        .DdrCtrl_CFG_SEQ_RST (DdrCtrl_CFG_SEQ_RST)  , //(O)[Control]DDR Controner Sequencer Reset 
        .DdrCtrl_CFG_SEQ_START (DdrCtrl_CFG_SEQ_START) , //(O)[Control]DDR Controner Sequencer Start 
      //DDR Controner AXI4 0 Signal
        .DdrCtrl_AID_0    (DdrCtrl_AID_0) , //(O)[Addres] Address ID
        .DdrCtrl_AADDR_0  (DdrCtrl_AADDR_0) , //(O)[Addres] Address
        .DdrCtrl_ALEN_0   (DdrCtrl_ALEN_0) , //(O)[Addres] Address Brust Length
        .DdrCtrl_ASIZE_0  (DdrCtrl_ASIZE_0) , //(O)[Addres] Address Burst size
        .DdrCtrl_ABURST_0 (DdrCtrl_ABURST_0) , //(O)[Addres] Address Burst type
        .DdrCtrl_ALOCK_0  (DdrCtrl_ALOCK_0) , //(O)[Addres] Address Lock type
        .DdrCtrl_AVALID_0 (DdrCtrl_AVALID_0) , //(O)[Addres] Address Valid
        .DdrCtrl_AREADY_0 (DdrCtrl_AREADY_0) , //(I)[Addres] Address Ready
        .DdrCtrl_ATYPE_0  (DdrCtrl_ATYPE_0) , //(O)[Addres] Operate Type 0=Read, 1=Write
                        
        .DdrCtrl_WID_0    (DdrCtrl_WID_0) , //(O)[Write]  ID
        .DdrCtrl_WDATA_0  (DdrCtrl_WDATA_0) , //(O)[Write]  Data
        .DdrCtrl_WSTRB_0  (DdrCtrl_WSTRB_0) , //(O)[Write]  Data Strobes(Byte valid)
        .DdrCtrl_WLAST_0  (DdrCtrl_WLAST_0) , //(O)[Write]  Data Last
        .DdrCtrl_WVALID_0 (DdrCtrl_WVALID_0) , //(O)[Write]  Data Valid
        .DdrCtrl_WREADY_0 (DdrCtrl_WREADY_0) , //(I)[Write]  Data Ready
        
        .DdrCtrl_RID_0    (DdrCtrl_RID_0) , //(I)[Read]   ID
        .DdrCtrl_RDATA_0  (DdrCtrl_RDATA_0) , //(I)[Read]   Data
        .DdrCtrl_RLAST_0  (DdrCtrl_RLAST_0) , //(I)[Read]   Data Last
        .DdrCtrl_RVALID_0 (DdrCtrl_RVALID_0) , //(I)[Read]   Data Valid
        .DdrCtrl_RREADY_0 (DdrCtrl_RREADY_0) , //(O)[Read]   Data Ready
        .DdrCtrl_RRESP_0  (DdrCtrl_RRESP_0) , //(I)[Read]   Response
                       
        .DdrCtrl_BID_0    (DdrCtrl_BID_0) , //(I)[Answer] Response Write ID
        .DdrCtrl_BVALID_0 (DdrCtrl_BVALID_0) , //(I)[Answer] Response valid
        .DdrCtrl_BREADY_0 (DdrCtrl_BREADY_0)  //(O)[Answer] Response Ready

);



endmodule