module ROM2RAM
#(parameter addr_width = 8,data_width=32) 
(
    input wire start,clk,reset,
    output reg finish
);
localparam [1:0] suru = 2'b00,
                 rom_theke_ram = 2'b01,
                 sesh = 2'b10,
                 vul = 2'b11;
reg[1:0] state_reg,state_next;
reg[addr_width-1:0] addr_counter_reg,addr_counter_next;

//module instantiation
//ram signals
wire ram_we;
wire[addr_width-1:0]ram_read_addr,ram_wr_addr;
wire[data_width-1:0]ram_read_data,ram_write_data;
RAM circ1(
    .clk(clk),
    .we(ram_we),
    .read_addr(ram_read_addr),
    .wr_addr(ram_wr_addr),
    .wr_data(ram_write_data),
    .read_data(ram_read_data)
);

wire[addr_width-1:0]rom_read_addr;
wire[data_width-1:0]rom_data;
ROM circ2(
    .read_addr(rom_read_addr),
    .read_data(rom_data)
);


//memory
always @(posedge clk, reset)
begin
if(reset)
begin
    state_reg<=suru;
    addr_counter_reg<=0;
end
else
    state_reg<=state_next;
    addr_counter_reg<=addr_counter_next;
end

//next
always @(*) 
begin
state_next=state_reg;
addr_counter_next=addr_counter_reg;
finish=1'b0;
case (state_reg)
    suru:
    begin
    if(start)
    begin
        state_next=rom_theke_ram;
        addr_counter_next=0;         
    end
    end
    rom_theke_ram:
    begin
        if(addr_counter_reg<=2**addr_width-1)
        begin
            addr_counter_next=addr_counter_reg+1;
        end
        else
        begin
            state_next=sesh;
        end
    end
    sesh:
    begin
        finish=1'b1;
        state_next=suru;
    end
    vul:
    begin
        
    end  
endcase
end

assign ram_we=(state_reg==rom_theke_ram)?1'b1:0;
assign ram_wr_addr=(state_reg==rom_theke_ram)?addr_counter_reg:0;
assign ram_write_data=(state_reg==rom_theke_ram)?rom_data:0;
assign ram_read_addr=0;
assign rom_read_addr=(state_reg==rom_theke_ram)?addr_counter_reg:0;
endmodule


//tbfor rom_to_ram
`timescale 1ns/1ps
module tb_r2r();
reg clk;
reg reset;
reg start;
wire finish;


ROM2RAM circ3(.clk(clk),.reset(reset),.start(start),.finish(finish));


always begin
    clk=~clk;
    #10;
end

initial begin
    clk=0;
    reset=1;
    start=1;
    #40;
    reset=0;
    start=0;
    #4000;
    $finish;

end
endmodule