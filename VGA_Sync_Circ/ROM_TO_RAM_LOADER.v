module rom_to_ram_load 
#(parameter addr_width =8, data_width=32)
(
    input wire clk,
    input wire complete,
    output wire [addr_width-1:0]addr

);
wire [data_width-1:0] fetched_data;
ROM circ1(.read_addr(addr),.read_data(fetched_data));
RAM circ2(.clk(clk),.we(1'b0),.wr_addr(addr),.wr_data(fetched_data));
//counter
reg[addr_width-1:0] counter_reg,counter_reg_next;
initial begin
counter_reg=0;
counter_reg_next=0;
end
//memory unit of counter
always@(posedge clk)
begin
if(~complete)
    counter_reg=counter_reg_next;
else
    counter_reg=0;
end
//next state of counter
always @(*) begin
counter_reg_next=counter_reg+1;
end 
assign addr=counter_reg;
endmodule


//TEST BENCH
module tb();
reg clk;
reg complete;
wire [7:0]out_addr;
wire [31:0]ram_out;

rom_to_ram_load cic1(
    .clk(clk),
    .complete(complete),
    .addr(out_addr));

RAM circ2(
    .read_addr(out_addr),
    .read_data(ram_out)
);

always begin
clk=~clk;
#20;    
end

initial begin
    clk=0;
    complete=0;
    #400;
    complete=1;
    #4000;
    $finish;
end

initial begin
    $monitor("complete = %b\n clk=%b \n out_addr=%b\n",complete,clk,out_addr);
    $monitor("ram_read_addr = %b\n ram_data=%b\n",out_addr,ram_out);
end
endmodule




//testing to check if things oke or not
