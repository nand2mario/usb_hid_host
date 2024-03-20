// USB clock
create_clock -name clk_usb -period 83.33 [get_nets {clk_usb}]       // 12 Mhz

report_timing -hold -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
report_timing -setup -from_clock [get_clocks {clk*}] -to_clock [get_clocks {clk*}] -max_paths 25 -max_common_paths 1
