**DDR TEST EXAMPLE DESCRIPTION**
- In this design there are 4 clock used.
    - DDR_Clk = 533.33 MHz 
    - Sys_clk = 100 MHz
    - AXI0_Clk/ AXI1_Clk = 100MHz

- As per the requirement set DDR_clk , set the speed grade in the INTERFACE DESIGN block.
    - i.e. If DDR_Clk = 400 MHz , Speed grade = 800D / 800E. and If DDR_clk = 533.33MHz, Speed grade = 1066E .
    - As per the speed grade set the other parameter in the DDR block, refer the below document:


- Mannual debugger is used for debugging the design. 
    Note : DDR3 PHY supports maximum 533.33 MHz.

    **How to test design Steps** 
    - in the test design there is three logic for write and read operation for messuring the delay so if the random address testing you want then uncommented that logic and you must put the .mem file at the same place of .v files. 
    - run the synthesis design flow, there is no trigger pin so no external wires are needed for enable the trigger pin. 
    - After completion of synthesis, if you want add any additional signals to debug then add it in mannual debugger ILA window and save it; run remaining flow.
    - After completion whole flow run, then upload the bitstream (.bit) file on the debugger. 
    - AVALID of Axi4FullDuplex signal set as a trigger and give trigger value 1. 
    - run the debugger flow, after that open GTKwave terminal so you can see the waveform. 

    - follow the same steps for other two that is LFSR logic and Continuous generating address using the burst length in the DDR_Data module. 

    **Design Description**
    **DdrControllerDebug**
    - Top module of the design .
    - If add `define Test_AXI0 for activate the AXI0 signals in the design and 
    - Add `define Test_AXI1 for activate the AXI1 signals.
    - Add `define Efinity_Debug for enable the manual jtag signal and that signal name same define in INTERFACE design, manual jtag is used in mannual debugger. 

    **DdrReset**
    - This logic is use for reseting the DDR.

    **DDRTest**
    - In this module testing some addition signal of DdrWrCtrl, DdrRdCtrl and AXI4FullDuplex module
    - For sending the write data use the DdrData - DdrWriteData generation module, which is generating the data using the write address. DdrRdCheck in which it is checking the read data. 
    - I have tested 3 different type of test for measuring the delay : 
        1. sending random address through .mem file. 
        2. using the LFSR logic.
        3. generating address using one start address and increment it according to burst length.
        
    - There is 3 TestMode (Only for Write, Only for Read, Write and Read simultaneous), That is modify from debugger window in Logic Analyzer. 
    - Use `testmode = 3` in the logic analyzer of mannual debugger for `simultaneous read and write operations`.
    - Upon receiving the read and write requests, the initial step involves completing the write operation before       initiating the read operation. To commence the read operation, the RREADY and RVALID signals are enabled, and the ATYPE is set to zero. This results in an approximate initial read latency of 17 clock cycles.
    - After the first write, the next write and read address becomes valid. Basically, Concurrent read and write operation (first address of read data and next write data) is generated.
    - Changes in Bank address and Row address can impact latency on read and write operaton as compare to change in only column address or bank address.
    - Particularly greater number of ALEN and the bundle of changes in burst addresses which is inclining the latency.

    - `testmode = 1`, use for `continuous read operation`.
    - In the burst read operation, for new read request, latency of 2 cycles is observed between `RREADY` and `RVALID`.

    - `testmode = 2`, use for `continuous write operation`.
    - In the burst write operation, for new write request, latency of 4 to 5 cycles observed between `AVALID` and `WREADY`.

        **Observation**
        - Address Mapping : BA-Row-Col.
        - When using the Random address logic, LFSR logic and generating address using start address to increment it logic the delay result is same. ALEN = 3, Only for read operation takes 6 clock cycles (but with additional latency of 14-15 clock cycle for waiting to next read address), only for Write operation takes 4-5 clock cycles, and Read and Write operation read takes 6 clock cycles.

        - ALEN = 7, Only for read operation takes 12 clock cycle (16-17 clock cycle is waiting for the next read address), only for write operation takes 7 clock cycle.

        - ALEN = F, Only for read operation takes 23 clock cycles (15 clock cycles waiting for the next read address), only for Write operation takes 16 clock cycles.

        - Note : When Write and Read operation simultaneously at that time there may be clock cycles varies in write side if read request is comes when the write operation continue. 
        For fixing this issue change the read address request when the RLAST & RVALID comes at that time takes/generates new address.

        **Ram2Axi** 
        - In this DdrWrCtrl, DdrRdCtrl, Axi4FullDuplex modules, in which DdrWrCtrl contains write commnad which is converted into AXI4 write operation, DdrRdCtrl contains read signals which is converted into AXI4 Read operation related to AXI and that is connect with AXI module, Axi4FullDuplex converts full duplex into two half duplex.

    **DdrStatistics**
    - It is count number of read and writes, bit error, bandwidth, and calculate the sum of read and write efficiency.

    **Debug Module(edb_top)**
    - It contains VIO (Virtual Input/Output) and ILA (Logic Analyzer) signals.
        **VIO Interface test Signals Description**
        - DdrReset : When it takes 1 position at that time DDR controller, Test module and statistics module becomes reset.

        - TestStart : When TestStart = 1 , start the test and latch the parameters of CfgTestMode, CfgBurstLen, CfgStartAddr, CfgEndAddr, while zero then stop testing.

        - CfgDataMode : Test data mode default is 3. In that 
            - CfgDataMode 0 : data is positive.
            - CfgDataMode 1 : Data is reverse logic.
            - CfgDataMode 2 : Data is Forward/reverse alternating, but starting withForward logic.
            - CfgDataMode 3 : Data is Reverse/Forward alternating, but data starting is reverse logic.

        - CfgTestMode : Default test mode 3. 
            - CfgTestmode 0 : Spare .
            - CfgTestMode 1 : only for read operation.
            - CfgTestMode 2 : only for Write Operation.
            - CfgTestMode 3 : Read and Write operation Alternate.
        
        - CfgBurstLen : Axi4 default burst length is 0xF. Whatever burst length value is setting up that gives the plus 1 value i.e. if setting up the CfgBurstLen = 7 then gives 8. 
            - If number of bytes is grater than 4k, then this value is automatically reduce to 4k; for 256 bits this value is maximum 0x7F. 

        - CfgTestLen (Test length configuration) : It is indicate how many need to be tested, after that test will be automatically stopped.

        - CfgStartAddr/CfgEndAddr : The starting address and ending address which limit allowed for testing, the logic will ensure that this limit will not be exceeded, corresponding to AXI of ALEN.

        - TestBusy : this indicate that testing is in underway.

        - TestRight : 1 indicates that multiple consecutive data are correct. 

        - TestErrCnt : test error counter.

        - Operate_Total_Cycle : this indicates total number of clocks used in the test.

        - Operate_Actual_Cycle : This indicates that the number of valid clock for reading/writing data.

        - Operate_Efficiency_ppt : This indicates that operating efficiency of the controller.

        - BandWidth_Mbps : DDR controller bandwidth in units of Mbps.

        - Test_Time_Second : Current test time in unit seconds. 

            **Read and Write Cycle Statistics**
        - WrPeriod_Minimum_Cycle : Minimum write cycle, Unit in number of clocks.

        - WrPeriod_Average_Cycle : Average write clock cyle for write operation. 

        - WrPeriod_Maximum_Cycle : Maximum write clock cycle for write the data. 

        - RdPeriod_Minimum_Cycle : Minimum read clock cycle unit in number of clocks. 

        - RdPeriod_Average_Cycle : Average clock cycle for read operation. 

        - RdPeriod_Maximum_Cycle : Maximum nuber of clock cycles for reading the data. 

        **ILA Interface** 
        - Logic Analyzer is used for whatever input and output signals want to check on the GTKWave that signals are define on that window. 

        - In this design AXI bus signals, Write data signals and read data signals are testing. 
        - If any additional or testing signals want to check then after the synthesis firstly add the signal on the logic analyzer , according to that generate the debug file then run the rest of the flow. 

    ## Conclusion
    - The design undergoes thorough testing using different test modes and logic options.
    - Observations regarding latency and performance are documented for various test scenarios.
    - Detailed configurations and parameters provide insights into the testing process.
