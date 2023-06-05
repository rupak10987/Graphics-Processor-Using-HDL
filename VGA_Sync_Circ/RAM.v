module RAM 
#(parameter addr_width = 8, data_width=32)
(
    input wire clk,we,
    input wire [addr_width-1:0] read_addr,wr_addr,
    input wire[data_width-1:0] wr_data,
    output wire [data_width-1:0] read_data

);
reg [data_width-1:0] ram [2*addr_width-1:0];

always @(posedge clk) begin
    if(we)
    ram[wr_addr]=wr_data;
end

assign read_data=ram[read_addr];
endmodule
/*
//test bench
`timescale 1ns/10ps
module ram_tb();
reg clk,we;
reg [7:0] read_addr,wr_addr;
reg [31:0] wr_data;
wire [31:0] read_data;
RAM circ1(.clk(clk),
          .we(we),
          .read_addr(read_addr),
          .wr_addr(wr_addr),
          .wr_data(wr_data),
          .read_data(read_data));

always
begin
clk=~clk;
#20;    
end
initial begin
    clk<=0;
    we=0;
    #40;
    we=1;
    wr_addr=0;
    wr_data=1;
    read_addr=1;
    #40;
    read_addr=0;
    #40;
    $finish;
end
initial begin
    $monitor("rd_ad=%b \n rd_data=%b \n wr_adr=%b \n wr_data=%b \n we=%b \n clk=%b \n DONE_PULSE",read_addr,read_data,wr_addr,wr_data,we,clk);
end
endmodule
*/