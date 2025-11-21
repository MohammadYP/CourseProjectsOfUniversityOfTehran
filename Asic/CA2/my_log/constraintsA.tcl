gui_start
analyze -library WORK -format verilog {/home/CAD_Lab009/Desktop/counter/front_end/counter/source/counter.v}
elaborate counter -architecture verilog -library WORK
create_clock -name "clk" -period 0.2 -waveform { 0.1 0.2  }  { clk  }
set_dont_touch_network reset
write -hier -format verilog -out ./out/counterNetlist.v
compile -exact_map
report_timing
report_area
report_power
report_cell