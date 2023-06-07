//tbfor rom_to_ram
`timescale 1ns/1ps
module tb_r2r();
reg clk;
reg reset;
reg start;
wire finish;
reg [7:0]ram_read_addr;
wire [31:0]ram_read_data1,ram_read_data2,ram_read_data3,ram_read_data4;


ROM2RAM circ3(
    .clk(clk),
    .reset(reset),
    .start(start),
    .finish(finish),
    .ram_read_addr(ram_read_addr),
    .ram_read_data1(ram_read_data1),
    .ram_read_data2(ram_read_data2),
    .ram_read_data3(ram_read_data3),
    .ram_read_data4(ram_read_data4));

reg line_start;
wire line_finish;
wire[9:0]X;
wire[8:0]Y;
reg[31:0] x1,x2,y1,y2;
B_Line circ4(
     .clk(clk),
     .start(line_start),
     .X(X),
     .Y(Y),
     .finish(line_finish),
     .x1(x1),
     .y1(y1),
     .x2(x2),
     .y2(y2)
    ) ;


reg vid_buff_we;
wire stat;
video_buffer circ5(
.x(X),
.y(Y),
.vid_we(vid_buff_we),
.clk(clk),
.stat(stat)
);


always begin
    clk=~clk;
    #10;
end

always @(*) begin
    x1<=ram_read_data1;
    y1<=ram_read_data2;
    x2<=ram_read_data3;
    y2<=ram_read_data4;
end

initial begin
    clk=0;
    reset=1;
    start=1;
    vid_buff_we=1'b0;
    #20;
    reset=0;
    start=0;
    #140;//load done
    ram_read_addr=8'b0000_0000;
    #20;
    vid_buff_we=1'b1;
    line_start=1'b1;
    #20;
    line_start=1'b0;
    #40000
    $finish;
end

initial begin
$monitor("x=%d | y=%d",X,Y);
end
endmodule