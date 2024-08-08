
# Efinity Interface Designer SDC
# Version: 2019.3.253
# Date: 2019-12-04 02:24

# Copyright (C) 2017 - 2019 Efinix Inc. All rights reserved.

# Device: T120F484
# Project: DdrControllerDebug
# Timing Model: C4 (preliminary)
#               NOTE: The timing data is not final

# PLL Constraints
#################
create_clock -period 2.5000 DdrClk
create_clock -period 10.000 Axi0Clk
create_clock -period 10.000 Axi1Clk
create_clock -period 10.000 SysClk
create_clock -period 10.000 i_clk
create_clock -period 10.000 axi_clk
create_clock -period 14.280 uart_clk

# GPIO Constraints
####################
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[0]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[0]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[1]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[1]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[2]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[2]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[3]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[3]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[4]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[4]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[5]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[5]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[6]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[6]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[7]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[7]}]



# DDR Constraints
#####################
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_AADDR_0[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_AADDR_0[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ABURST_0[1] DdrCtrl_ABURST_0[0]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ABURST_0[1] DdrCtrl_ABURST_0[0]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_AID_0[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_AID_0[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ALEN_0[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ALEN_0[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ALOCK_0[1] DdrCtrl_ALOCK_0[0]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ALOCK_0[1] DdrCtrl_ALOCK_0[0]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ASIZE_0[2] DdrCtrl_ASIZE_0[1] DdrCtrl_ASIZE_0[0]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ASIZE_0[2] DdrCtrl_ASIZE_0[1] DdrCtrl_ASIZE_0[0]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ATYPE_0}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ATYPE_0}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_AVALID_0}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_AVALID_0}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_BREADY_0}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_BREADY_0}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_RREADY_0}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_RREADY_0}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WDATA_0[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WDATA_0[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WID_0[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WID_0[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WLAST_0}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WLAST_0}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WSTRB_0[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WSTRB_0[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WVALID_0}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WVALID_0}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_AREADY_0}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_AREADY_0}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_BID_0[*]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_BID_0[*]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_BVALID_0}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_BVALID_0}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RDATA_0[*]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RDATA_0[*]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RID_0[*]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RID_0[*]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RLAST_0}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RLAST_0}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RRESP_0[1] DdrCtrl_RRESP_0[0]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RRESP_0[1] DdrCtrl_RRESP_0[0]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RVALID_0}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RVALID_0}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_WREADY_0}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_WREADY_0}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_AADDR_1[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_AADDR_1[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ABURST_1[1] DdrCtrl_ABURST_1[0]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ABURST_1[1] DdrCtrl_ABURST_1[0]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_AID_1[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_AID_1[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ALEN_1[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ALEN_1[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ALOCK_1[1] DdrCtrl_ALOCK_1[0]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ALOCK_1[1] DdrCtrl_ALOCK_1[0]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ASIZE_1[2] DdrCtrl_ASIZE_1[1] DdrCtrl_ASIZE_1[0]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ASIZE_1[2] DdrCtrl_ASIZE_1[1] DdrCtrl_ASIZE_1[0]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_ATYPE_1}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_ATYPE_1}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_AVALID_1}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_AVALID_1}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_BREADY_1}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_BREADY_1}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_RREADY_1}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_RREADY_1}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WDATA_1[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WDATA_1[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WID_1[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WID_1[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WLAST_1}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WLAST_1}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WSTRB_1[*]}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WSTRB_1[*]}]
set_output_delay -clock SysClk -max -2.810 [get_ports {DdrCtrl_WVALID_1}]
set_output_delay -clock SysClk -min -2.155 [get_ports {DdrCtrl_WVALID_1}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_AREADY_1}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_AREADY_1}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_BID_1[*]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_BID_1[*]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_BVALID_1}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_BVALID_1}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RDATA_1[*]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RDATA_1[*]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RID_1[*]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RID_1[*]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RLAST_1}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RLAST_1}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RRESP_1[1] DdrCtrl_RRESP_1[0]}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RRESP_1[1] DdrCtrl_RRESP_1[0]}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_RVALID_1}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_RVALID_1}]
set_input_delay -clock SysClk -max 8.310 [get_ports {DdrCtrl_WREADY_1}]
set_input_delay -clock SysClk -min 4.155 [get_ports {DdrCtrl_WREADY_1}]
