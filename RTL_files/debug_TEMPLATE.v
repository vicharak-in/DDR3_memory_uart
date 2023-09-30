edb_top edb_top_inst (
    .bscan_CAPTURE      ( jtag_inst1_CAPTURE ),
    .bscan_DRCK         ( jtag_inst1_DRCK ),
    .bscan_RESET        ( jtag_inst1_RESET ),
    .bscan_RUNTEST      ( jtag_inst1_RUNTEST ),
    .bscan_SEL          ( jtag_inst1_SEL ),
    .bscan_SHIFT        ( jtag_inst1_SHIFT ),
    .bscan_TCK          ( jtag_inst1_TCK ),
    .bscan_TDI          ( jtag_inst1_TDI ),
    .bscan_TMS          ( jtag_inst1_TMS ),
    .bscan_UPDATE       ( jtag_inst1_UPDATE ),
    .bscan_TDO          ( jtag_inst1_TDO ),
    .Axi_clk            ( $INSERT_YOUR_CLOCK_NAME ),
    .Axi_AVALID     ( Axi_AVALID ),
    .Axi_AREADY     ( Axi_AREADY ),
    .Axi_ATYPE      ( Axi_ATYPE ),
    .Axi_ALEN       ( Axi_ALEN ),
    .Axi_WVALID     ( Axi_WVALID ),
    .Axi_WREADY     ( Axi_WREADY ),
    .Axi_WLAST      ( Axi_WLAST ),
    .Axi_BREADY     ( Axi_BREADY ),
    .Axi_RVALID     ( Axi_RVALID ),
    .Axi_RREADY     ( Axi_RREADY ),
    .Axi_RLAST      ( Axi_RLAST ),
    .Axi_WrDataMode     ( Axi_WrDataMode ),
    .Axi_WrEn       ( Axi_WrEn ),
    .Axi_TestErr        ( Axi_TestErr ),
    .Axi_RdDataMode     ( Axi_RdDataMode ),
    .Axi_RdAva      ( Axi_RdAva ),
    .Axi_RDATA__95__64      ( Axi_RDATA__95__64 ),
    .Axi_RDATA_255_224      ( Axi_RDATA_255_224 ),
    .Axi_TimeOut        ( Axi_TimeOut ),
    .Axi_WrStartA       ( Axi_WrStartA ),
    .Axi_RdStartA       ( Axi_RdStartA ),
    .Axi_TestDdrRdEnd       ( Axi_TestDdrRdEnd ),
    .Axi_TesrWrTestEnd      ( Axi_TesrWrTestEnd ),
    .Axi_DdrReset       ( Axi_DdrReset ),
    .Axi_WrAddr     ( Axi_WrAddr ),
    .Axi_WDATA__31___0      ( Axi_WDATA__31___0 ),
    .Axi_WDATA__63__32      ( Axi_WDATA__63__32 ),
    .Axi_WDATA__95__64      ( Axi_WDATA__95__64 ),
    .Axi_WDATA_127__96      ( Axi_WDATA_127__96 ),
    .Axi_WDATA_159_128      ( Axi_WDATA_159_128 ),
    .Axi_WDATA_191_160      ( Axi_WDATA_191_160 ),
    .Axi_WDATA_223_192      ( Axi_WDATA_223_192 ),
    .Axi_WDATA_255_224      ( Axi_WDATA_255_224 ),
    .Axi_RdAddr     ( Axi_RdAddr ),
    .Axi_RDATA__31___0      ( Axi_RDATA__31___0 ),
    .Axi_RDATA__63__32      ( Axi_RDATA__63__32 ),
    .Axi_RDATA_127__96      ( Axi_RDATA_127__96 ),
    .Axi_RDATA_159_128      ( Axi_RDATA_159_128 ),
    .Axi_RDATA_191_160      ( Axi_RDATA_191_160 ),
    .Axi_RDATA_223_192      ( Axi_RDATA_223_192 ),
    .Axi_AADDR      ( Axi_AADDR ),
    .Axi_BVALID     ( Axi_BVALID ),
    .DdrTest_clk    ( $INSERT_YOUR_CLOCK_NAME ),
    .DdrTest_TestBusy( DdrTest_TestBusy ),
    .DdrTest_TestRight( DdrTest_TestRight ),
    .DdrTest_TestErrCnt( DdrTest_TestErrCnt ),
    .DdrTest_Operate_Total_Cycle( DdrTest_Operate_Total_Cycle ),
    .DdrTest_Operate_Actual_Cycle( DdrTest_Operate_Actual_Cycle ),
    .DdrTest_Operate_Efficiency_ppt( DdrTest_Operate_Efficiency_ppt ),
    .DdrTest_BandWidth_Mbps( DdrTest_BandWidth_Mbps ),
    .DdrTest_Test_Time_second( DdrTest_Test_Time_second ),
    .DdrTest_WrPeriod_minimun_Cycle( DdrTest_WrPeriod_minimun_Cycle ),
    .DdrTest_WrPeriod_Average_Cycle( DdrTest_WrPeriod_Average_Cycle ),
    .DdrTest_WrPeriod_Maximum_Cycle( DdrTest_WrPeriod_Maximum_Cycle ),
    .DdrTest_RdPeriod_minimun_Cycle( DdrTest_RdPeriod_minimun_Cycle ),
    .DdrTest_RdPeriod_Average_Cycle( DdrTest_RdPeriod_Average_Cycle ),
    .DdrTest_RdPeriod_Maximum_Cycle( DdrTest_RdPeriod_Maximum_Cycle ),
    .DdrTest_DdrReset( DdrTest_DdrReset ),
    .DdrTest_TestStart( DdrTest_TestStart ),
    .DdrTest_CfgDataMode( DdrTest_CfgDataMode ),
    .DdrTest_CfgTestMode( DdrTest_CfgTestMode ),
    .DdrTest_CfgBurstLen( DdrTest_CfgBurstLen ),
    .DdrTest_CfgTestLen( DdrTest_CfgTestLen ),
    .DdrTest_CfgStartAddr( DdrTest_CfgStartAddr ),
    .DdrTest_CfgEndAddr( DdrTest_CfgEndAddr ),
    .DdrTest_t_rst_in( DdrTest_t_rst_in )
);

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2021 Efinix Inc. All rights reserved.              
//
// This   document  contains  proprietary information  which   is        
// protected by  copyright. All rights  are reserved.  This notice       
// refers to original work by Efinix, Inc. which may be derivitive       
// of other work distributed under license of the authors.  In the       
// case of derivative work, nothing in this notice overrides the         
// original author's license agreement.  Where applicable, the           
// original license agreement is included in it's original               
// unmodified form immediately below this header.                        
//                                                                       
// WARRANTY DISCLAIMER.                                                  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
//                                                                       
// LIMITATION OF LIABILITY.                                              
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
//     APPLY TO LICENSEE.                                                
//
////////////////////////////////////////////////////////////////////////////////
