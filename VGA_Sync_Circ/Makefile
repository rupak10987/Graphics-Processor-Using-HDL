main:
	iverilog -o out.vpp ROM.v RAM.v ROM_TO_RAM_LOADER.v
	vvp out.vpp
	#gtkwave test.vcd