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
    begin
    // $display("==>ram_addr=%b\nram_data=%b\n",wr_addr,wr_data);
    ram[wr_addr]=wr_data;
    end

end
assign read_data=ram[read_addr];
endmodule

