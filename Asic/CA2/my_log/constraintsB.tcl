gui_start
analyze -library WORK -format verilog {/home/CAD_Lab009/Desktop/counter/front_end/counter/source/counter.v}
elaborate counter -architecture verilog -library WORK
create_clock -name "clk" -period 5 -waveform { 2.5 5  }  { clk  }
set_dont_touch_network reset
set_input_delay 0.2 [all_inputs] -clock clk
set_output_delay 0.2 [all_outputs] -clock clk
write -hier -format verilog -out ./out/counterNetlist.v
compile -exact_map
report_timing
report_area
report_power
report_cell