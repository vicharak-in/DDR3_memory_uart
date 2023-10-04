------------- Begin Cut here for COMPONENT Declaration ------
component edb_top
  port (
         bscan_CAPTURE : in  std_logic;
         bscan_DRCK    : in  std_logic;
         bscan_RESET   : in  std_logic;
         bscan_RUNTEST : in  std_logic;
         bscan_SEL     : in  std_logic;
         bscan_SHIFT   : in  std_logic;
         bscan_TCK     : in  std_logic;
         bscan_TDI     : in  std_logic;
         bscan_TMS     : in  std_logic;
         bscan_UPDATE  : in  std_logic;
         bscan_TDO     : out std_logic;
         Axi_clk       : in  std_logic;
         Axi_AADDR     : in  std_logic_vector(31 downto 0);
         Axi_ALEN      : in  std_logic_vector(7 downto 0);
         Axi_AREADY    : in  std_logic;
         Axi_ATYPE     : in  std_logic;
         Axi_AVALID    : in  std_logic;
         Axi_BREADY    : in  std_logic;
         Axi_BVALID    : in  std_logic;
         Axi_DdrReset  : in  std_logic;
         Axi_mux_reg_data : in  std_logic_vector(31 downto 0);
         Axi_RdAddr    : in  std_logic_vector(31 downto 0);
         Axi_RDATA__31___0 : in  std_logic_vector(31 downto 0);
         Axi_RDATA__63__32 : in  std_logic_vector(31 downto 0);
         Axi_RDATA__95__64 : in  std_logic_vector(31 downto 0);
         Axi_RDATA_127__96 : in  std_logic_vector(31 downto 0);
         Axi_RDATA_159_128 : in  std_logic_vector(31 downto 0);
         Axi_RDATA_191_160 : in  std_logic_vector(31 downto 0);
         Axi_RDATA_223_192 : in  std_logic_vector(31 downto 0);
         Axi_RDATA_255_224 : in  std_logic_vector(31 downto 0);
         Axi_RdAva     : in  std_logic;
         Axi_RdDataMode : in  std_logic;
         Axi_RdStartA  : in  std_logic_vector(31 downto 0);
         Axi_RLAST     : in  std_logic;
         Axi_RREADY    : in  std_logic;
         Axi_RVALID    : in  std_logic;
         Axi_TesrWrTestEnd : in  std_logic;
         Axi_TestDdrRdEnd : in  std_logic;
         Axi_TestErr   : in  std_logic;
         Axi_TimeOut   : in  std_logic;
         Axi_WDATA__31___0 : in  std_logic_vector(31 downto 0);
         Axi_WDATA__63__32 : in  std_logic_vector(31 downto 0);
         Axi_WDATA__95__64 : in  std_logic_vector(31 downto 0);
         Axi_WDATA_127__96 : in  std_logic_vector(31 downto 0);
         Axi_WDATA_159_128 : in  std_logic_vector(31 downto 0);
         Axi_WDATA_191_160 : in  std_logic_vector(31 downto 0);
         Axi_WDATA_223_192 : in  std_logic_vector(31 downto 0);
         Axi_WDATA_255_224 : in  std_logic_vector(31 downto 0);
         Axi_WLAST     : in  std_logic;
         Axi_WrAddr    : in  std_logic_vector(31 downto 0);
         Axi_WrDataMode : in  std_logic;
         Axi_WREADY    : in  std_logic;
         Axi_WrEn      : in  std_logic;
         Axi_WrStartA  : in  std_logic_vector(31 downto 0);
         Axi_WVALID    : in  std_logic;
         DdrTest_clk   : in  std_logic;
         DdrTest_TestBusy : in  std_logic;
         DdrTest_TestRight : in  std_logic;
         DdrTest_TestErrCnt : in  std_logic_vector(23 downto 0);
         DdrTest_Operate_Total_Cycle : in  std_logic_vector(47 downto 0);
         DdrTest_Operate_Actual_Cycle : in  std_logic_vector(47 downto 0);
         DdrTest_Operate_Efficiency_ppt : in  std_logic_vector(9 downto 0);
         DdrTest_BandWidth_Mbps : in  std_logic_vector(15 downto 0);
         DdrTest_Test_Time_second : in  std_logic_vector(23 downto 0);
         DdrTest_WrPeriod_minimun_Cycle : in  std_logic;
         DdrTest_WrPeriod_Average_Cycle : in  std_logic_vector(9 downto 0);
         DdrTest_WrPeriod_Maximum_Cycle : in  std_logic_vector(9 downto 0);
         DdrTest_RdPeriod_minimun_Cycle : in  std_logic_vector(9 downto 0);
         DdrTest_RdPeriod_Average_Cycle : in  std_logic_vector(9 downto 0);
         DdrTest_RdPeriod_Maximum_Cycle : in  std_logic_vector(9 downto 0);
         DdrTest_mux_reg_data : in  std_logic_vector(31 downto 0);
         DdrTest_data_load : in  std_logic;
         DdrTest_DdrReset : out std_logic;
         DdrTest_TestStart : out std_logic;
         DdrTest_CfgDataMode : out std_logic_vector(1 downto 0);
         DdrTest_CfgTestMode : out std_logic_vector(1 downto 0);
         DdrTest_CfgBurstLen : out std_logic_vector(7 downto 0);
         DdrTest_CfgTestLen : out std_logic_vector(31 downto 0);
         DdrTest_CfgStartAddr : out std_logic_vector(31 downto 0);
         DdrTest_CfgEndAddr : out std_logic_vector(31 downto 0);
         DdrTest_t_rst_in : out std_logic
       );
end component ;
---------------------- End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template -----
edb_top_inst : edb_top
port map (
           bscan_CAPTURE => jtag_inst1_CAPTURE,
           bscan_DRCK    => jtag_inst1_DRCK,
           bscan_RESET   => jtag_inst1_RESET,
           bscan_RUNTEST => jtag_inst1_RUNTEST,
           bscan_SEL     => jtag_inst1_SEL,
           bscan_SHIFT   => jtag_inst1_SHIFT,
           bscan_TCK     => jtag_inst1_TCK,
           bscan_TDI     => jtag_inst1_TDI,
           bscan_TMS     => jtag_inst1_TMS,
           bscan_UPDATE  => jtag_inst1_UPDATE,
           bscan_TDO     => jtag_inst1_TDO,
           Axi_clk      => #INSERT_YOUR_CLOCK_NAME,
           Axi_AADDR    => Axi_AADDR,
           Axi_ALEN => Axi_ALEN,
           Axi_AREADY   => Axi_AREADY,
           Axi_ATYPE    => Axi_ATYPE,
           Axi_AVALID   => Axi_AVALID,
           Axi_BREADY   => Axi_BREADY,
           Axi_BVALID   => Axi_BVALID,
           Axi_DdrReset => Axi_DdrReset,
           Axi_mux_reg_data => Axi_mux_reg_data,
           Axi_RdAddr   => Axi_RdAddr,
           Axi_RDATA__31___0    => Axi_RDATA__31___0,
           Axi_RDATA__63__32    => Axi_RDATA__63__32,
           Axi_RDATA__95__64    => Axi_RDATA__95__64,
           Axi_RDATA_127__96    => Axi_RDATA_127__96,
           Axi_RDATA_159_128    => Axi_RDATA_159_128,
           Axi_RDATA_191_160    => Axi_RDATA_191_160,
           Axi_RDATA_223_192    => Axi_RDATA_223_192,
           Axi_RDATA_255_224    => Axi_RDATA_255_224,
           Axi_RdAva    => Axi_RdAva,
           Axi_RdDataMode   => Axi_RdDataMode,
           Axi_RdStartA => Axi_RdStartA,
           Axi_RLAST    => Axi_RLAST,
           Axi_RREADY   => Axi_RREADY,
           Axi_RVALID   => Axi_RVALID,
           Axi_TesrWrTestEnd    => Axi_TesrWrTestEnd,
           Axi_TestDdrRdEnd => Axi_TestDdrRdEnd,
           Axi_TestErr  => Axi_TestErr,
           Axi_TimeOut  => Axi_TimeOut,
           Axi_WDATA__31___0    => Axi_WDATA__31___0,
           Axi_WDATA__63__32    => Axi_WDATA__63__32,
           Axi_WDATA__95__64    => Axi_WDATA__95__64,
           Axi_WDATA_127__96    => Axi_WDATA_127__96,
           Axi_WDATA_159_128    => Axi_WDATA_159_128,
           Axi_WDATA_191_160    => Axi_WDATA_191_160,
           Axi_WDATA_223_192    => Axi_WDATA_223_192,
           Axi_WDATA_255_224    => Axi_WDATA_255_224,
           Axi_WLAST    => Axi_WLAST,
           Axi_WrAddr   => Axi_WrAddr,
           Axi_WrDataMode   => Axi_WrDataMode,
           Axi_WREADY   => Axi_WREADY,
           Axi_WrEn => Axi_WrEn,
           Axi_WrStartA => Axi_WrStartA,
           Axi_WVALID   => Axi_WVALID,
           DdrTest_clk   => #INSERT_YOUR_CLOCK_NAME,
           DdrTest_TestBusy => DdrTest_TestBusy,
           DdrTest_TestRight => DdrTest_TestRight,
           DdrTest_TestErrCnt => DdrTest_TestErrCnt,
           DdrTest_Operate_Total_Cycle => DdrTest_Operate_Total_Cycle,
           DdrTest_Operate_Actual_Cycle => DdrTest_Operate_Actual_Cycle,
           DdrTest_Operate_Efficiency_ppt => DdrTest_Operate_Efficiency_ppt,
           DdrTest_BandWidth_Mbps => DdrTest_BandWidth_Mbps,
           DdrTest_Test_Time_second => DdrTest_Test_Time_second,
           DdrTest_WrPeriod_minimun_Cycle => DdrTest_WrPeriod_minimun_Cycle,
           DdrTest_WrPeriod_Average_Cycle => DdrTest_WrPeriod_Average_Cycle,
           DdrTest_WrPeriod_Maximum_Cycle => DdrTest_WrPeriod_Maximum_Cycle,
           DdrTest_RdPeriod_minimun_Cycle => DdrTest_RdPeriod_minimun_Cycle,
           DdrTest_RdPeriod_Average_Cycle => DdrTest_RdPeriod_Average_Cycle,
           DdrTest_RdPeriod_Maximum_Cycle => DdrTest_RdPeriod_Maximum_Cycle,
           DdrTest_mux_reg_data => DdrTest_mux_reg_data,
           DdrTest_data_load => DdrTest_data_load,
           DdrTest_DdrReset => DdrTest_DdrReset,
           DdrTest_TestStart => DdrTest_TestStart,
           DdrTest_CfgDataMode => DdrTest_CfgDataMode,
           DdrTest_CfgTestMode => DdrTest_CfgTestMode,
           DdrTest_CfgBurstLen => DdrTest_CfgBurstLen,
           DdrTest_CfgTestLen => DdrTest_CfgTestLen,
           DdrTest_CfgStartAddr => DdrTest_CfgStartAddr,
           DdrTest_CfgEndAddr => DdrTest_CfgEndAddr,
           DdrTest_t_rst_in => DdrTest_t_rst_in
         );
------------------------ End INSTANTIATION Template ---------

--------------------------------------------------------------------------------
-- Copyright (C) 2013-2021 Efinix Inc. All rights reserved.              
--
-- This   document  contains  proprietary information  which   is        
-- protected by  copyright. All rights  are reserved.  This notice       
-- refers to original work by Efinix, Inc. which may be derivitive       
-- of other work distributed under license of the authors.  In the       
-- case of derivative work, nothing in this notice overrides the         
-- original author's license agreement.  Where applicable, the           
-- original license agreement is included in it's original               
-- unmodified form immediately below this header.                        
--                                                                       
-- WARRANTY DISCLAIMER.                                                  
--     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
--     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
--     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
--     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
--     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
--     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
--     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
--                                                                       
-- LIMITATION OF LIABILITY.                                              
--     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
--     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
--     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
--     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
--     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
--     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
--     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
--     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
--     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
--     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
--     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
--     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
--     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
--     APPLY TO LICENSEE.                                                
--
--------------------------------------------------------------------------------
