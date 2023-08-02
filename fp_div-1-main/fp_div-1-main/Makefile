main:
	iverilog -o out.vpp fp_class.sv fp_div_tb.v fp_div.v padder11.v padder24.v padder53.v padder113.v PijGij.v round.v 
	vvp out.vpp
	#gtkwave test.vcd