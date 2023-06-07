module video_buffer(
    input wire[9:0]x,
    input wire[8:0]y,
    input wire vid_we,
    input wire clk,
    output wire stat
);
reg [0:0] vid_buff[18:0];
wire [18:0]address={x,y};
always @(posedge clk) begin
if(vid_we==1'b1)
vid_buff[address]=1'b1;
end
assign stat=(vid_buff[address]==1)?1:0;
endmodule