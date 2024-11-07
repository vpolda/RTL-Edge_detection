## HDMI signals
## HDMI RX
set_property -dict {PACKAGE_PIN P19 IOSTANDARD TMDS_33} [get_ports hdmi_in_clk_n]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD TMDS_33} [get_ports hdmi_in_clk_p]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD TMDS_33} [get_ports {hdmi_in_data_n[0]}]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD TMDS_33} [get_ports {hdmi_in_data_p[0]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD TMDS_33} [get_ports {hdmi_in_data_n[1]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD TMDS_33} [get_ports {hdmi_in_data_p[1]}]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD TMDS_33} [get_ports {hdmi_in_data_n[2]}]
set_property -dict {PACKAGE_PIN N20 IOSTANDARD TMDS_33} [get_ports {hdmi_in_data_p[2]}]
##set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports {hdmi_in_hpd[0]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports hdmi_in_ddc_scl_io]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports hdmi_in_ddc_sda_io]

## HDMI TX
set_property -dict {PACKAGE_PIN L17 IOSTANDARD TMDS_33} [get_ports hdmi_out_clk_n]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD TMDS_33} [get_ports hdmi_out_clk_p]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_n[0]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_p[0]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_n[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_p[1]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_n[2]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD TMDS_33} [get_ports {hdmi_out_data_p[2]}]

#Output HDMI HPD, is an input alerting FPGA the sink is there to connect
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports hdmi_out_hpd]

#Input HDMI HPD detection, is an ouput to the HDMI Source to alert it there is a sink available
set_property PACKAGE_PIN T19 [get_ports {hdmi_in_hpd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hdmi_in_hpd[0]}]

#125MHz clock
set_property IOSTANDARD LVCMOS33 [get_ports sys_clock]
set_property PACKAGE_PIN H16 [get_ports sys_clock]

#LED
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led0}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led1}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led2}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led3}]

#RGB LED
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { led4_b }];
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { led4_g }];
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { led4_r }];
#set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led5_b }];
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { led5_g }];
#set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { led5_r }];

set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io0  }]; 
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io1  }]; 
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io2 }]; 
set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io3 }]; 
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io4 }]; 
set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io5 }]; 
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[6] }]; 
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[7] }]; 
set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[8] }]; 
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[9] }]; 
set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[10] }]; 
set_property -dict { PACKAGE_PIN Y8    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[11] }]; 
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[12] }]; 
set_property -dict { PACKAGE_PIN Y9    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[13] }]; 
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[14] }]; 
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[15] }]; 
set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[16] }]; 
set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[17] }]; 
set_property -dict { PACKAGE_PIN W9    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[18] }]; 
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports { rpi_gpio_tri_io[19] }];
