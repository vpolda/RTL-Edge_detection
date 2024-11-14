#Input clocks
create_clock -period 13.468 -waveform {0.000 5.000} [get_ports hdmi_in_clk_p]
create_clock -period 8.000 -waveform {0.000 5.000} [get_ports sys_clock]

#for crawl
#create_clock -period 5.000 -waveform {0.000 5} [get_ports pix_clk]
#create_clock -period 2.500 -waveform {0.000 5} [get_ports fast_clk]

# Set max path delay from input to output (max delay should not exceed 16.67 ms)

#Max/Min delay constraints 16.67 ms
#set_input_delay -max 16670000 [get_ports hdmi_in] -clock [get_clocks hdmi_in_clk_p]

# Add output delay constraints (for the output DVI signal) 16.67 ms
#set_output_delay -max 16670000 [get_ports hdmi_out] -clock [get_clocks hdmi_in_clk_p]

