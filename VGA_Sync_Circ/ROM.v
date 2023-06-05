module ROM 
#(parameter addr_width = 8,data_width=32)
(
    input wire [addr_width-1:0]read_addr,
    output wire [data_width-1:0]read_data
);
reg [data_width-1:0]data;
always@(*)
begin
case (read_addr)
    8'b0000_0000:data=1;
    8'b0000_0001:data=2;
    8'b0000_0010:data=30;
    8'b0000_0011:data=40; 
endcase    
end
assign read_data=data;
endmodule

/*
//test bench
`timescale 1ns/10ps
module ram_tb();
reg [7:0] read_addr;
wire [31:0] read_data;
ROM circ1(.read_data(read_data),.read_addr(read_addr));

initial begin
    read_addr=0;
    #40;
    read_addr=1;
    #40;
    read_addr=2;
    #40;
    read_addr=3;
    #40;
    $finish;
end
initial begin
    $monitor("rd_ad=%b \nrd_data=%b DONE_PULSE",read_addr,read_data);
end
endmodule
*/