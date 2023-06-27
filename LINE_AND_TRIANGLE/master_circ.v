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
reg [18:0]_buff_add;
always @(*) 
begin
if(vid_buff_we)
    _buff_add={X[9:0],Y[8:0]};
else
    _buff_add={p_x[9:0],p_y[8:0]}; 
end
video_buffer c1(
    .clk(clk),
    .we(vid_buff_we),
    .read_addr(_buff_add),
    .wr_addr(_buff_add),
    .wr_data(vid_buff_we),
    .read_data1(stat)
    );


//monitor
reg monitor_rest;
wire[9:0] p_x,p_y;
wire monitor_h_sync,monitor_v_sync;
wire monitor_video_on;

 Vga_Sync circ6(
    .clk(clk),
    .reset(monitor_rest),
    .pixel_x(p_x),
    .pixel_y(p_y),
    .h_sync(monitor_h_sync),
    .v_sync(monitor_v_sync),
    .P_tick(),
    .video_on(monitor_video_on)
);


// rgb buffer 
reg [2:0]RGB;
// output 
always @(*)
begin
RGB <= (monitor_video_on) ? {stat,stat,stat}: 3'b000;   
end


always begin
    clk=~clk;
    #1;
end

always @(*) begin
    x1<=ram_read_data1;
    y1<=ram_read_data2;
    x2<=ram_read_data3;
    y2<=ram_read_data4;
end

initial begin
    monitor_rest=1;
    clk=0;
    reset=1;
    start=1;
    vid_buff_we=1'b0;
    #2;
    reset=0;
    start=0;
    #14;//load done
    ram_read_addr=8'b0000_0000;
    #2;
    vid_buff_we=1'b1;
    line_start=1'b1;
    #2;
    line_start=1'b0;
    #40;
    vid_buff_we=1'b0;
    monitor_rest=0;
    #200000000;
    $finish;
end

initial begin
//$monitor("x=%d | y=%d",X,Y);
$monitor("stat=%b at x=%d | y=%d\n",stat,p_x,p_y);
end
endmodule