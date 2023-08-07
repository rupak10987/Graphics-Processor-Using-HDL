module MASTER(input wire clk,
             input wire Mreset,
             input wire Mstart,
             output wire[11:0]RGBA,
             output wire h_sync,
             output wire v_sync,
             output wire[9:0] OX,
             output wire[8:0] OY);


// rom_to_ram
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

//triangle
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

//assigning rom outputs into triangle inputs
always @(*) begin
    tx1=ram_read_data1;
    ty1=ram_read_data2;
    tx2=ram_read_data4;
    ty2=ram_read_data5;
    tx3=ram_read_data7;
    ty3=ram_read_data8;
    // if projectrion
    // tx1=(ram_read_data1*D)/ram_read_data3;
    // ty1=(ram_read_data2*D)/ram_read_data3;
    // tx2=(ram_read_data4*D)/ram_read_data6;
    // ty2=(ram_read_data5*D)/ram_read_data6; 
    // tx3=(ram_read_data7*D)/ram_read_data9;
    // ty3=(ram_read_data8*D)/ram_read_data9; 
end

//video buffer
wire[9:0] p_x,p_y;//need to declare here
reg [9:0] rp_x,rp_y;
reg [9:0]rOX1;
reg[8:0] rOY1;
always @(*) begin
    rp_x=p_x;
    rp_y=p_y;
    rOX1=OX1;
    rOY1=OY1;
end



reg vid_buff_we;
wire stat;//status of the buffer address
reg [18:0]_buff_add;
always @(*) 
begin
if(vid_buff_we)
    _buff_add={rOX1[9:0],rOY1[8:0]};
else
    _buff_add={rp_x[9:0],rp_y[8:0]}; 
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
wire monitor_h_sync,monitor_v_sync;
reg r_monitor_h_sync,r_monitor_v_sync;
always @(*) begin
    r_monitor_h_sync=monitor_h_sync;
    r_monitor_v_sync=monitor_v_sync;
end
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
reg [11:0]RGB;
// output 
always @(*)
begin
RGB <= (monitor_video_on) ? {11{stat}}: 0;   
end


//for iterating through triangles in a model
reg[1:0] tiny_state,tiny_state_next;
always @(*) begin
    tiny_state_next=tiny_state;
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
        tiny_state_next=2'b01;
        end
        2'b01: 
        begin
        treset=1'b0;
        //limbo
        end 
        default:
        begin
        //do nothing
        end
    endcase
end


//master memory
reg [3:0] MASTER_STATE,MASTER_STATE_NEXT;
always @(posedge clk, posedge Mreset) begin
if(Mreset)//master reset
begin
MASTER_STATE<=0;
MASTER_STATE_NEXT<=0;   
tiny_state<=2'b11;
tiny_state_next<=2'b11;
end
else
begin
    tiny_state<=tiny_state_next;
    MASTER_STATE<=MASTER_STATE_NEXT;
    ram_read_addr<=ram_read_addr_next;
end
end

//fsmd
always @(*) begin
    MASTER_STATE_NEXT=MASTER_STATE;
case (MASTER_STATE)
    4'b0000: 
    begin
    if(Mstart)
    begin
    monitor_rest=1'b1;
    Rstart=1'b0;
    Rreset=1'b0;
    vid_buff_we=1'b0; 
    MASTER_STATE_NEXT=4'b0001;   
    end

    end
    4'b0001: 
    begin
    Rreset=1'b1;
    MASTER_STATE_NEXT=4'b0010;
    end
    4'b0010: 
    begin
    Rreset=1'b0;
    MASTER_STATE_NEXT=4'b0011;
    end
    4'b0011: 
    begin
    Rstart=1'b1;//no need to set it to zero in next state
    MASTER_STATE_NEXT=4'b0100;
    end
    4'b0100: 
    begin
    if(Rfinish==1'b1)//loading done
    begin
    ram_read_addr=0;//1st triangle is feed
    ram_read_addr_next=0; 
    MASTER_STATE_NEXT=4'b0101;
    end
    //limbo
    end
    4'b0101: 
    begin
    vid_buff_we=1'b1;
    treset=1'b1;  
    MASTER_STATE_NEXT=4'b0110; 
    end
    4'b0110: 
    begin
    treset=1'b0;  
    MASTER_STATE_NEXT=4'b0111; 
    end
    4'b0111: 
    begin
    if(ram_read_addr>=18)//triangle drawn done
    begin
    vid_buff_we=1'b0;//draw kora sesh so ekhon screen e render kora jabe 
    monitor_rest=1'b0;   
    end
    end
endcase
end



assign RGBA=RGB;
assign h_sync=r_monitor_h_sync;
assign v_sync=r_monitor_v_sync;
assign OX=rOX1;
assign OY=rOY1;
endmodule
