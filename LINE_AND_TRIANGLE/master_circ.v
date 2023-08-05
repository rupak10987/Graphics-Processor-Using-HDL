//tbfor rom_to_ram
`timescale 1ns/1ps
module tb_r2r();
reg clk;
reg Rreset;
reg Rstart;
wire Rfinish;
reg [7:0]ram_read_addr;
reg [7:0]ram_read_addr_next;
wire [31:0]ram_read_data1,ram_read_data2,ram_read_data3,ram_read_data4,ram_read_data5,ram_read_data6,ram_read_data7,ram_read_data8,ram_read_data9;



ROM2RAM circ3(
    .clk(clk),
    .reset(Rreset),
    .start(Rstart),
    .finish(Rfinish),
    .ram_read_addr(ram_read_addr),
    .ram_read_data1(ram_read_data1),
    .ram_read_data2(ram_read_data2),
    .ram_read_data3(ram_read_data3),
    .ram_read_data4(ram_read_data4),
    .ram_read_data5(ram_read_data5),
    .ram_read_data6(ram_read_data6),
    .ram_read_data7(ram_read_data7),
    .ram_read_data8(ram_read_data8),
    .ram_read_data9(ram_read_data9));


reg signed[31:0] tx1,ty1,tx2,ty2,tx3,ty3;
wire [9:0] OX1;
wire [8:0] OY1;
wire tfinish;
reg treset;
filled_tris uut(    .x1(tx1),
                    .y1(ty1),
                    .x2(tx2),
                    .y2(ty2),
                    .x3(tx3),
                    .y3(ty3),
                    .OX1(OX1),
                    .OY1(OY1),
                    .clk(clk),
                    .finish(tfinish),
                    .reset(treset)
                    );
reg signed [31:0]D=300;                    

always @(*) begin
    tx1<=ram_read_data1;
    ty1<=ram_read_data2;
    tx2<=ram_read_data4;
    ty2<=ram_read_data5;
    tx3<=ram_read_data7;
    ty3<=ram_read_data8;
    // if projectrion
    // tx1<=(ram_read_data1*D)/ram_read_data3;
    // ty1<=(ram_read_data2*D)/ram_read_data3;
    // tx2<=(ram_read_data4*D)/ram_read_data6;
    // ty2<=(ram_read_data5*D)/ram_read_data6; 
    // tx3<=(ram_read_data7*D)/ram_read_data9;
    // ty3<=(ram_read_data8*D)/ram_read_data9; 
end

reg vid_buff_we;
wire stat;
reg [18:0]_buff_add;
always @(*) 
begin
if(vid_buff_we)
    _buff_add={OX1[9:0],OY1[8:0]};
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

//for iterating through triangles in a model
reg[1:0] tiny_state;
always @(posedge clk) begin
    ram_read_addr<=ram_read_addr_next;
end

always @(posedge clk) begin
    if(tfinish & ram_read_addr<9)
    begin
        //$display("triangle done");
        treset=1'b1;
        tiny_state=2'b00;
    end
    case (tiny_state)
        2'b00: 
        begin
        ram_read_addr_next=ram_read_addr+9;  
        tiny_state=2'b01;
        end
        2'b01: 
        begin
        treset=1'b0;
        //limbo
        end 
    endcase
end


initial begin
    clk<=0;
    monitor_rest<=1;
    Rstart<=1;
    vid_buff_we<=1'b0;
    #2;
    Rstart<=0;
    #36;//load done
    ram_read_addr<=0;//1st triangle is feed
    ram_read_addr_next<=0;
    #2;
    vid_buff_we<=1'b1;
    treset<=1'b1;
    #2;
    treset<=1'b0;
    #4000;//onek gula clk pulse dite hbe
    vid_buff_we<=1'b0;//draw kora sesh so ekhon screen e render kora jabe
    monitor_rest<=0;
    #200000000;
    $finish;
end

initial begin
$monitor("x=%d,y=%d",OX1,OY1);//for showing only the filled pixels
//$monitor("stat=%b at x=%d | y=%d\n",stat,p_x,p_y);//for showing all pixels and its corresponding bw value
end
endmodule