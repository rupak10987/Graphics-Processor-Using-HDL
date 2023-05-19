module Vga_Test(
    input wire clk,reset,
    input wire [2:0] B_color,
    output wire [2:0]RGB,
    output wire h_sync,v_sync
);


//signal declaration 
reg [2:0] rgb_reg; 
wire video_on;

// instantiate vga sync circuit 
Vga_Sync INS(.clk(clk) , .reset(reset), .h_sync(h_sync), .v_sync(v_sync), 
.video_on(video_on), .P_tick(), .pixel_x(), .pixel_y()) ; 
// rgb buffer 
always @(posedge clk , posedge reset )
if (reset) 
rgb_reg <= 0; 
else 
rgb_reg <= B_color; 
// output 
assign RGB = (video_on) ? rgb_reg : 3'b0;


endmodule