#!/usr/bin/python3

# usage: ecppll.py <in_freq> <out_freq>
# example: ecppll.py 25 12

# f_pfd = f_in / refclk_div
# f_vco = f_pfd * feedback_div * output_div
# f_out = f_vco / output_div
# refclk_div:      1..128
# feedback_div:    1..80
# output_div:      1..128
# f_pfd:           3.125..400
# f_vco:           400..800

import sys
import math

if len(sys.argv) < 3:
    print('usage: ecpppll.py <in_freq> <out_freq>')
    exit(1)

IN=float(sys.argv[1])
OUT=float(sys.argv[2])

OFF_BEST = 1.0

# for CLKI_DIV in range(25,26):
for CLKI_DIV in range(1,129):
    f_pfd = IN / CLKI_DIV
    if f_pfd < 3.125 or f_pfd > 400:
        continue
    # for CLKFB_DIV in range(3,4):
    for CLKFB_DIV in range(1,81):
        f_out = f_pfd * CLKFB_DIV
        CLKOP_DIV = math.floor(800 / f_out) 
        if CLKOP_DIV > 128:
            CLKOP_DIV = 128
        f_vco = f_out * CLKOP_DIV
        if f_vco < 400 or f_vco > 800:
            continue
        off = abs(f_out / OUT - 1.0)
        if off < OFF_BEST:      # found a good value
            OFF_BEST = off
            CLKI_DIV_BEST = CLKI_DIV
            CLKFB_DIV_BEST = CLKFB_DIV
            CLKOP_DIV_BEST = CLKOP_DIV
            f_out_best = f_out

print("CLKI_DIV={}, CLKFB_DIV={}, CLKOP_DIV={}, OUT={:.5}Mhz, off by {:.3}%".format(CLKI_DIV_BEST, CLKFB_DIV_BEST, CLKOP_DIV_BEST, f_out_best, abs((f_out_best/OUT-1)*100)))

