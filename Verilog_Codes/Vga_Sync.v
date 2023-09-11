module Vga_Sync(
    input wire clk,reset,
    output wire [9:0] pixel_x,pixel_y,
    output wire h_sync,v_sync,video_on
    //output wire P_tick,
);

 //monitor specific constants
 localparam HD = 640 ;//display area
 localparam HF = 48 ;// h back porch
 localparam HB = 16 ;// h front porch
 localparam HR = 96 ;//h retrace
 localparam VD = 480 ;//display area
 localparam VF = 10 ; //v backporch
 localparam VB = 33 ; //v frontporch
 localparam VR = 2 ; //v retrace
//mod 2 reg for generating 25Mhz half of original clock freq
 reg Mod2_reg;
 wire Mod2_next;
//sync counters
reg[9:0] h_count_reg,h_count_next;
reg[9:0] v_count_reg,v_count_next;

//buffer for non display region
reg v_sync_reg, h_sync_reg;
wire v_sync_next,h_sync_next;

//status
wire h_end, v_end, pixel_tick;


//synchronous design method
//reg part
always @(posedge clk,posedge reset) begin
    if(reset)
    begin
        Mod2_reg<=0;
        h_count_reg<=0;
        v_count_reg<=0;
        v_sync_reg<=0;
        h_sync_reg<=0;
    end
    else
    begin
        Mod2_reg<=Mod2_next;
        h_count_reg<=h_count_next;
        v_count_reg<=v_count_next;
        v_sync_reg<=v_sync_next;
        h_sync_reg<=h_sync_next; 
    end
end

//mod2 circ logic
assign Mod2_next=~Mod2_reg;
assign pixel_tick=Mod2_reg;

//status
//horizontal counter end
assign h_end=(h_count_reg==(HD+HF+HB+HR-1));
//vertical counter end
assign v_end=(v_count_reg==(VD+VB+VF+VR-1));

//synchronus design methodology 
//Next state part
//next state logic for mod 800 counter
always @(*) begin
    if(pixel_tick)
        if(h_end)
            h_count_next=0;
        else
            h_count_next=h_count_reg+1;
    else
        h_count_next=h_count_reg;
end

//next state logic for mod 525 counter
always @(*) begin
    if(pixel_tick & h_end)
        if(v_end)
            v_count_next=0;
        else
            v_count_next=v_count_reg+1;
    else
        v_count_next=v_count_reg;
end


// horizontal and vertical sync, buffered to avoid glitch 
// h_svnc_next asserted between 656 and 751 
assign h_sync_next = (h_count_reg>=(HD+HB) && 
h_count_reg<=(HD+HB+HR-1)); 
// vh-sync-next asserted between 490 and 491 
assign v_sync_next = (v_count_reg>=(VD+VB) && 
v_count_reg<=(VD+VB+VR-1)); 

//video on and off if i want to reduce the disply area over here.. minus amount from vd and hd
assign video_on=(h_count_reg>=HD) && (v_count_reg>=VD);

//output
assign h_sync=h_sync_reg;
assign v_sync=v_sync_reg;
assign pixel_x=h_count_reg;
//assign p_tick=pixel_tick;
assign pixel_y=v_count_reg;

endmodule