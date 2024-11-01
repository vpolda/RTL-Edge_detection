#Input clocks
create_clock -period 13.468 -waveform {0.000 5} [get_ports hdmi_in_clk_p]

#Max delay constraints