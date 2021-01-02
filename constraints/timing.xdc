# clock
create_clock -period 5.000 -name clk -waveform {0.000 2.500} [get_ports clk]

# input false path
set_false_path -from [get_ports reset]
set_false_path -from [get_ports rx]
set_false_path -to [get_ports tx]

# output false path
set_false_path -to [get_ports {leds[*]}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
