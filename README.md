
# DDR README

This README provides detailed information about the DDR design and how to debug it.
In this design Manual debugger is used for debugging this design.

## Manual Debugger Features

I. **Logic Analyzer:**
   - The manual debugger enables debugging through a logic analyzer, allowing modification of input parameters such as ALEN, burst counter, test start enable, start address, end address, and reset.

II. **Virtual I/O:**
   - Virtual I/O is used to define the input as a source and output as a probe. The design generates a debug file (edb_top) where input values are converted into output and vice versa. 
   - Instantiate debugger file's input and output in the top design file.

III. **DDR3 Configuration:**
   - DDR3 is used as per the VAAMAN board, with the memory chip being K4B4G1646D-BYK0.
   - DDR operates at 533.33 MHz, while the AXI clock runs at 100 MHz.

## Design Architecture

- **Top Module: DdrControllerDebug**
  - Includes sub-modules: ddr_reset_sequencer, DdrTest (DdrWrCtrl, DdrData, DdrRdCtrl, AxiFullDuplex), DdrTestStatic, and edb_top.
  - Ram2Axi module contains DdrWrCtrl, DdrRdCtrl, and AxiFullDuplex.

- **DdrData Module:**
  - Generates data and addresses using the generate block and data generation is dependent on the address.

- **DdrTest Module:**
  - Contains sub-modules DdrWrCtrl for controlling write addresses, testing some write signals, DdrRdCtrl for controlling read addresses, AxiFullDuplex. The address incrementation is based on the test length; address control is done through cfg_test_mode as well as RdBurstEn.

- **Ram2Axi Module:**
  - This module contains DdrWrCtrl, DdrRdCtrl, and AxiFullDuplex modules, in which AxiFullDuplex converts the full duplex into half duplex at the DDR Phy side.

````
Note : DDR3 Phy supports maximun 533.33MHz.
````
## Address Generation

- In the final design, a random address module LFSR( Linear Feedback Shift Register) is used. After generating a 32-bit random address, ensure proper alignment.
- If random addresses are not required, the DDR_data module can be utilized in order to generate the address. 

## Observation

  - Default parameters on the logic analyzer: `burstcnt = 80000000`, `ALEN = 1F`, `start address = 1000`, `end address = ffffff`.
  - Use `testmode = 3` in the logic analyzer for `simultaneous read and write operations`.
  - Upon receiving the read and write requests, the initial step involves completing the write operation before initiating the read operation. To commence the read operation, the RREADY and RVALID signals are enabled, and the ATYPE is set to zero. This results in an approximate initial read latency of 17 clock cycles.
  - After the first write, the next write and read address becomes valid. Basically, Concurrent read and write operation (first address of read data and next write data) is generated.
  - Changes in Bank address and Row address can impact latency on read and write operaton as compare to change in only column address or bank address.
  - Particularly greater number of ALEN and the bundle of changes in burst addresses which is inclining the latency.

  - `testmode = 1`, use for `continuous read operation`.
  - In the burst read operation, for new read request, latency of 2 cycles is observed between `RREADY` and `RVALID`.

  - `testmode = 2`, use for `continuous write operation`.
  - In the burst write operation, for new write request, latency of 4 to 5 cycles observed between `AVALID` and `WREADY`.

## Testing

- The design has been tested using two different address mapping, including BA - Row - Col, Row - Col-High - BA - Col-Low, ALEN, burstcnt, and random addresses starting from `0131BC00` and seed address is also same.

## Clock Cycle Calculation for Read Data

- For counting the clock cycle for read data:
  - Axi0 transfers 256 bits per cycle, thereby achieves `3200MB/sec` at `100MHz`.
  - DDR3 transfers `800 Mb per pin`, thereby achieves `12800 Mb/sec (1600 MB/sec)` at `400MHz`. 
  - The ratio of throughput between Axi and DDR data is `2 `.
  - Number of clock cycles to read in burst mode is `ratio * burst length`.

  -  Axi0 clock is `100 MHz` and DDR3 clock is `533.33 MHz` achieves throughput of `3200MB/sec` and `2132MB/sec` resulting in a throughput ratio of `1.5 `.
  - Opting for this configuration minimizes number of cycles in read burst.

## Additional Testing

- Tested the design at different settings:
  - ALEN = 3, Axi clock = 100 MHz, DDR clock = 533.33 MHz, address mapping: `BA - Row - Col`, read operation takes `6` clock cycles.
 -image
  - ALEN = 3, Axi clock = 100 MHz, DDR clock = 533.33 MHz, address mapping: `BA - Row - Col` (write operation only), write latency is `4-5` clock cycles.
 -image
  - ALEN = 3, Axi clock = 100 MHz, DDR clock = 533.33 MHz, address mapping: `BA - Row - Col` (read operation only), read data takes `6` clock cycles, with additional latency of `14-15` cycles for the next read address.
  -image

| Parameter              | ALEN = 7                     | ALEN = F                     |
|------------------------|------------------------------|------------------------------|
| Axi Clock              | 100 MHz                      | 100 MHz                      |
| DDR Clock              | 533.33 MHz                   | 533.33 MHz                   |
| Address mapping        | BA - Row - Col               | BA - Row - Col               |
| Latency (Read)         | 16 to 17 cycles              | 15 cycles                    |
| read data clock cycle        | 12 cycles (per burst)        | 23 to 25 cycles (per burst)              |

## Key findings
 - When DDR3 is operated at 533.33 MHz, number of read cycles in the burst poperation is decreased as compare to 400MHz clock cycle.
 - Less delay cycles is observed between the burst transfers for smaller burst length.
 - For continuous write burst ALEN = 7 is the optimum choice.



