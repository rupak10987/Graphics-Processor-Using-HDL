//tbfor rom_to_ram
`timescale 1ns/1ps
module tb_r2r();
reg clk;
reg reset;
reg start;
wire finish;
reg [7:0]ram_read_addr;
wire [31:0]ram_read_data;


ROM2RAM circ3(
    .clk(clk),
    .reset(reset),
    .start(start),
    .finish(finish),
    .ram_read_addr(ram_read_addr),
    .ram_read_data(ram_read_data));


always begin
    clk=~clk;
    #10;
end

initial begin
    clk=0;
    reset=1;
    start=1;
    #20;
    reset=0;
    start=0;
    #140;//load done
    ram_read_addr=8'b0000_0001;
    #20;
    ram_read_addr=8'b0000_0010;
    #20;
    ram_read_addr=8'b0000_0011;
    $finish;
end

initial begin
$monitor("done_loading=%b\nram_read_addr_after_load=%d\n data_on_above_address=%d\n",finish,ram_read_addr,ram_read_data);
end
endmodule