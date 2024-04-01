# ULX3S board

compiling

    make clean
    make

error will appear, currently it is normal until
makefile rules are properly fixed
just run another make

    make

full compilation takes few minutes.

To upload to board and print debug messages on
terminal

    make run

# firmware development

If only firmware "ukp.s" is changed, new bitstream
will be generated almost immediately.

For new ROM, Compilation will not run full synthesis,
but only firmware ROM will be compiled and replaced
in already build bitstream.

    make run

ROM compilation takes only a second.
