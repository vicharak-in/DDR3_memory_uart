# DDR Test with UART 

This README provides detailed information about the DDR design and debugging procedures. In this design, data passes through UART Rx to the DDR debug controller and then to UART Tx. A manual debugger is used to debug the entire design.

## Testing Setup

- **UART Rx Baudrate**: 115200, UART Rx clock: 100MHz.
- **AXI0 clock**: 100MHz.
- **DDR clock**: 400MHz.
- **UART Tx Baudrate**: 115200, UART Tx Clock: 70MHz.

- No need for any external trigger when the testing whole design.
- UART Rx data pin connected with GPIOL_73(H13) pin, the 7th pin of GPIO on Vaaman.
- UART Tx data pin connected with GPIOR_187 (T8) pin, the 30th pin of GPIO on Vaaman.

- Additional pin for testing data coming from DDR to UART Tx: check_pin = GPIOT_RXP24, USER_LED0 (only for testing); no external connection needed.

- For testing only the write part of this design, set a trigger pin (`rst` signal) before the DDR_Wr_Ctrl. Connect this pin's wire to GND when the design is waiting for trigger stage. The pin is connected with GPIOL_72(H14), the 10th pin of GPIO on the Vaaman board.

**Data Transfer**
- Data is passed through UART at 115200 baudrate.
- Address is generated on the DDR side.
- Ensure data received on the UART Rx side is transmitted to the DDR at 115200 baudrate.
  
## Design Architecture

### Modules Description

#### UART RX to DDR Write

- **Clock Operation:** The entire write operation runs at a 100 MHz clock, denoted as `i_clk`.
- **UART Reception and Data Conversion:**
  - Bytes received through UART Rx are converted into 8-bit data and stored in an 8-bit asynchronous FIFO.
  - The output from the FIFO is passed to the Write FSM module, which generates the read enable signal and converts the 8-bit data to 32-bit data.
  - A Multiplexer 8x1 module is used to store the 32-bit data into one register and make it 256 bits. When 256 bits of data are received, a flag enables the AXI module of the DDR.

#### DDR Write Controller to DDR Read Controller (Address and Data Description)

- **Clock Operation:**
  - Axi0 clock is 100 MHz for writing and reading data.
  - DDR clock is 400 MHz, extendable up to 533.33 MHz. Speed grade is 1066E, with adjustments in AXI PHY settings.

- **Write Data Handling:**
  - In the DDR write controller, the data is connected to the Mux_8x1 register, which is 256 bits.
  - For addresses, the DDR_Data module is used. It starts at address 2100 and increments according to the burst length.
  - If only one address is used for writing data, the NextWrAddr in the DDR_Test module is not incremented; only the start address is used.
  - Other test methods include using a .mem file for random addresses or using an LFSR (Linear Feedback Shift Register).
  - In both DDR write and read controller modules, the address comes from the DDR_Data module.
  - The DDR write controller’s AXI signals are connected to the AXI4FullDuplex module.

- **Read Operation:**
  - The DDR read controller is used for reading data from the DDR.
  - The DdrRdDataChk module generates the read address, which is connected to the DDR read controller’s read address port.
  - The AXI4FullDuplex module connects both the DDR write and read controller modules to the AXI PHY module, configured using the Efinix Interface design.

#### Interface Design Connections

- **Configuration:**
  - In the Interface Design, go to the DDR block, create a block, and set all parameters according to the clock. For a 400 MHz DDR clock, use speed grade 800D. For a 533.33 MHz DDR clock, use speed grade 1066E. Set memory write and read channel timing parameters according to the datasheet.

  - AXI4FullDuplex signal names for write and read controllers of the AXI ports should match those set in the AXI PHY.
  - Set the Axi0 and Axi1 clocks to 100 MHz in the DDR block interface design.
  - AXI0 works on a 256-bit data width, while AXI1 works on a 128-bit data width.
  - Use two different clocks in the DDR block for AXI0 and AXI1, set from the PLL.
  - Modify parameters in the DDR block:

    | Parameter                       | Value                          |
    |---------------------------------|--------------------------------|
    | Axi0 clock                      | 100 MHz                        |
    | DDR Clock                       | 400 MHz                        |
    | **Base**                        |                                |
    | DDR Resources                   | DDR_0                          |
    | Memory Type                     | DDR3                           |
    | **Configuration**               |                                |
    | DQ Width                        | 16                             |
    | Speed Grade                     | 800D                           |
    | Width                           | x16                            |
    | Density                         | 4G                             |
    | **Advanced Options**            |                                |
    | FPGA Input Termination (ohm)    | 60                             |
    | FPGA Output Termination (ohm)   | 34                             |
    | **Memory Mode Register Settings** |                              |
    | Burst Length                    | 8                              |
    | DLL Precharge Power Down        | off                            |
    | Memory Auto Self-Refresh        | Auto                           |
    | Memory CAS Latency (CL)         | 6                              |
    | Memory Cas Write Latency (CWL)  | 5                              |
    | Memory Dynamic ODT (Rtt_WR)     | RZQ/2                          |
    | Memory Input Termination (Rtt_nom) | RZQ/12                        |
    | Memory output Termination       | RZQ/7                          |
    | Read Burst Type                 | Sequencial                     |
    | Self-Refresh Temperature        | Normal                         |
    | **Memory Timing Settings**      |                                |
    | tFAW(ns)                        | 20.000                         |
    | tRAS (ns)                       | 37.500                         |
    | tRC (ns)                        | 52.500                         |
    | tRCD (ns)                       | 15.000                         |
    | tREFI(us)                       | 3.9000                         |
    | tRFC (ns)                       | 350.000                        |
    | tRP (ns)                        | 15.000                         |
    | tRRD (ns)                       | 4.000                          |
    | tRTP (ns)                       | 7.5000                         |
    | tWTR (ns)                       | 7.5000                         |
    | **Controller Settings**         |                                |
    | Address Mapping                 | ROW-COL_HIGH-BANK-COL_LOW      |
    | Enable Auto Power Down          | off                            |
    | Enable Sel-Refresh Controls     | No                             |

#### DDR to UART TX Modules Description

- **Clock Configuration:**
  - AXI0 clock is set to 100 MHz, and UART Tx clock is set to 70 MHz.
- **Data Transmission:**
  - Data written in the DDR at a specific address is read from the DDR Read controller.
  - Data is then passed through the read_test module, used for testing data. If data is read successfully, an LED is activated.
  - The Convert_data module converts the data from 256 bits to 8 bits using 32 registers of bits.
  - These 8 bits of data are connected to a 32x1 MUX, resulting in 1 output of 8 bits selected according to the select line.
  - All 8 bits of data are stored in an Asynchronous FIFO, controlled by the FSM for generating write enable for FIFO, while read enable comes from the UART_TX_FSM.
  - Finally, the data is transmitted through UART_TX as an output. Use a terminal for checking the data.
