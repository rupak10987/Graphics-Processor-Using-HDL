main:
	iverilog -o out.vpp RAM.v ROM.v ROM_TO_RAM_LOADER.v rom_to_ram_tb.v
	vvp out.vpp
	#gtkwave test.vcd