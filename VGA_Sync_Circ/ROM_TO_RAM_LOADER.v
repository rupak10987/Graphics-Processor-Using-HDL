module rom_to_ram_load 
#(parameter addr_width =8, data_width=32)
(
    input wire clk,
    input wire complete,
    output wire [addr_width-1:0]addr
);
    
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


//tst bench
module tb();
reg clk;
reg complete;
wire [7:0]out_addr;

rom_to_ram_load cic1(
    .clk(clk),
    .complete(complete),
    .addr(out_addr));

always begin
clk=~clk;
#20;    
end

initial begin
    clk=0;
    complete=0;
    #400;
    complete=1;
    #40;
    $finish;
end

initial begin
    $monitor("complete = %b\n clk=%b \n out_addr=%b\n",complete,clk,out_addr);
end
endmodule