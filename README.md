# DDR Test Example Description

## Clocks Used in the Design
- **DDR_Clk**: 533.33 MHz
- **Sys_clk**: 100 MHz
- **AXI0_Clk/AXI1_Clk**: 100 MHz

## DDR Clock and Speed Grade Configuration
- Set the DDR_Clk and speed grade in the INTERFACE DESIGN block:
  - If DDR_Clk = 400 MHz, Speed grade = 800D / 800E
  - If DDR_Clk = 533.33 MHz, Speed grade = 1066E
- Set other parameters in the DDR block as per the speed grade, referring to below provided document:
[Industrial_1.35V_x16 only_4G_D_DDR3_Samsung_Spec_Rev1.02_Aug.14.book - DS_K4B4G1646D_BY_M_Rev1_02-0.pdf](DDR3_memory_uart/blob/Random_addr_LFSR_Incremental_addr/Industrial_1.35V_x16%20only_4G_D_DDR3_Samsung_Spec_Rev1.02_Aug.14.book%20-%20DS_K4B4G1646D_BY_M_Rev1_02-0.pdf)

## Manual Debugger
- Used for debugging the design.
- Note: DDR3 PHY supports a maximum of 533.33 MHz.

## Testing Process

1. **Setup**:
   - Synthesize the design.
   - No trigger pin required.

2. **Debugging**:
   - Use manual debugger for debugging.
   - DDR3 PHY supports a maximum of 533.33 MHz.

3. **Testing Steps**:
   - Three logic options available for write and read operation delay measurement.
   - For random address testing, uncomment the logic and place the .mem file alongside .v files.
   - Run synthesis design flow.
   - Add any additional signals for debugging in manual debugger ILA window and save.
   - Upload the bitstream (.bit) file on the debugger.
   - Set AVALID of Axi4FullDuplex signal as a trigger with a trigger value of 1.
   - Run the debugger flow and open GTKwave terminal to view the waveform.
   - Repeat steps for other two logics: LFSR logic and Continuous address generation.

## Design Description

### DdrControllerDebug
- **Top module of the design**.
- Use `define Test_AXI0` to activate AXI0 signals.
- Use `define Test_AXI1` to activate AXI1 signals.
- Use `define Efinity_Debug` to enable manual JTAG signal, as defined in the INTERFACE design for the manual debugger.

### DdrReset
- Logic for resetting the DDR.

### DDRTest
- Tests additional signals of DdrWrCtrl, DdrRdCtrl, and AXI4FullDuplex module.
- Uses DdrData - DdrWriteData generation module for sending write data and DdrRdCheck for checking read data.

#### Tested Methods for Measuring Delay:
1. Sending random address through a `.mem` file.
2. Using LFSR logic.
3. Generating address using a start address and incrementing it according to burst length.

#### Test Modes:
- **TestMode 3**: For simultaneous read and write operations.
  - Completes the write operation before initiating the read operation.
  - Initial read latency of ~17 clock cycles.
- **TestMode 1**: Continuous read operation.
  - Latency of 2 cycles between `RREADY` and `RVALID`.
- **TestMode 2**: Continuous write operation.
  - Latency of 4 to 5 cycles between `AVALID` and `WREADY`.

#### Observations:
- **Address Mapping**: BA-Row-Col.
- Delay results for Random address logic, LFSR logic, and generated address logic are similar.
  - ALEN = 3: Read operation takes 6 clock cycles, Write operation takes 4-5 clock cycles.
  - ALEN = 7: Read operation takes 12 clock cycles, Write operation takes 7 clock cycles.
  - ALEN = F: Read operation takes 23 clock cycles, Write operation takes 16 clock cycles.

### Ram2Axi
- Modules: DdrWrCtrl, DdrRdCtrl, Axi4FullDuplex.
- DdrWrCtrl: Converts write command into AXI4 write operation.
- DdrRdCtrl: Converts read signals into AXI4 read operation.
- Axi4FullDuplex: Converts full duplex into two half duplex.

### DdrStatistics
- Counts number of reads and writes, bit errors, bandwidth, and calculates read/write efficiency.

### Debug Module (edb_top)
- Contains VIO (Virtual Input/Output) and ILA (Logic Analyzer) signals.

#### VIO Interface Test Signals:
- **DdrReset**: Resets DDR controller, Test module, and statistics module.
- **TestStart**: Starts the test and latches the parameters of CfgTestMode, CfgBurstLen, CfgStartAddr, CfgEndAddr; stops testing when set to 0.
- **CfgDataMode**: Test data mode, default is 3.
  - 0: Data is positive.
  - 1: Data is reverse logic.
  - 2: Data is forward/reverse alternating, starting with forward logic.
  - 3: Data is reverse/forward alternating, starting with reverse logic.
- **CfgTestMode**: Default is 3.
  - 0: Spare.
  - 1: Only for read operation.
  - 2: Only for write operation.
  - 3: Read and write operation alternate.
- **CfgBurstLen**: AXI4 default burst length is 0xF.
  - Plus 1 value for setting burst length.
  - Automatically reduces to 4k if the number of bytes is greater than 4k.
  - Maximum value of 0x7F for 256 bits.
- **CfgTestLen**: Indicates how many need to be tested; test stops automatically after this.
- **CfgStartAddr/CfgEndAddr**: Starting and ending addresses for testing, ensuring limits are not exceeded.
- **TestBusy**: Indicates ongoing testing.
- **TestRight**: 1 indicates multiple consecutive correct data.
- **TestErrCnt**: Test error counter.
- **Operate_Total_Cycle**: Total number of clocks used in the test.
- **Operate_Actual_Cycle**: Number of valid clocks for reading/writing data.
- **Operate_Efficiency_ppt**: Operating efficiency of the controller.
- **BandWidth_Mbps**: DDR controller bandwidth in Mbps.
- **Test_Time_Second**: Current test time in seconds.

#### Read and Write Cycle Statistics:
- **WrPeriod_Minimum_Cycle**: Minimum write cycle in clock cycles.
- **WrPeriod_Average_Cycle**: Average write clock cycle.
- **WrPeriod_Maximum_Cycle**: Maximum write clock cycle.
- **RdPeriod_Minimum_Cycle**: Minimum read clock cycle in clock cycles.
- **RdPeriod_Average_Cycle**: Average read clock cycle.
- **RdPeriod_Maximum_Cycle**: Maximum read clock cycle.

#### ILA Interface:
- Logic Analyzer for checking input and output signals on GTKWave.
- AXI bus signals, write data signals, and read data signals are tested.
- Additional or testing signals can be added after synthesis, then generate the debug file and run the rest of the flow.

## Conclusion
- The design undergoes thorough testing using different test modes and logic options.
- Observations regarding latency and performance are documented for various test scenarios.
- Detailed configurations and parameters provide insights into the testing process.