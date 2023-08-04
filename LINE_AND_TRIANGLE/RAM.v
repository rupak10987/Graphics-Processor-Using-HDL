module RAM 
#(parameter addr_width = 8, data_width=32)
(
    input wire clk,we,
    input wire [addr_width-1:0] read_addr,wr_addr,
    input wire[data_width-1:0] wr_data,
    output wire [data_width-1:0] read_data1,read_data2,read_data3,read_data4,read_data5,read_data6,read_data7,read_data8,read_data9

);
reg [data_width-1:0] ram [2**(addr_width-1):0];

always @(posedge clk) begin
    if(we)
    begin
    ram[wr_addr]=wr_data;
    end

end
assign read_data1=ram[read_addr];
assign read_data2=ram[read_addr+1];
assign read_data3=ram[read_addr+2];
assign read_data4=ram[read_addr+3];
assign read_data5=ram[read_addr+4];
assign read_data6=ram[read_addr+5];
assign read_data7=ram[read_addr+6];
assign read_data8=ram[read_addr+7];
assign read_data9=ram[read_addr+8];
endmodule

