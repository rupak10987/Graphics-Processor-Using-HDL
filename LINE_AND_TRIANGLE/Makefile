main:
	iverilog -o out.vpp Projection.v
	#filled_tris.v 
	#ROM.v RAM.v ROM_TO_RAM_LOADER.v LINE_MODULE.v Vga_Sync.v master_circ.v video_buffer.v
	vvp out.vpp
	#gtkwave test.vcd