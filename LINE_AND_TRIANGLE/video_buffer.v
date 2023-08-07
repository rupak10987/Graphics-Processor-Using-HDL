module video_buffer 
#(parameter addr_width = 19, data_width=1)
(
    input wire clk,we,
    input wire [addr_width-1:0] read_addr,wr_addr,
    input wire[data_width-1:0] wr_data,
    output wire [data_width-1:0] read_data1
);
reg [data_width-1:0] buffer [2**addr_width-1:0];

always @(posedge clk) begin
    if(we)
    begin
    buffer[wr_addr]=wr_data;
    end
end
assign read_data1=(buffer[read_addr]==1'b1)?1:0;
endmodule


// module tb (
// );
//     reg [9:0]x;
//     reg [8:0]y;
//     reg vid_we;
//     reg clk;
//     wire stat;

//     video_buffer c1(
//     .clk(clk),
//     .we(vid_we),
//     .read_addr({x[9:0],y[8:0]}),
//     .wr_addr({x[9:0],y[8:0]}),
//     .wr_data(1),
//     .read_data1(stat)
//     );

// always  begin
//     clk=~clk;
//     #10;
// end

// initial begin
//     x<=0;
//     y<=0;
//     vid_we<=1;
//     clk<=0;
//     #20;
//     x<=1;
//     y<=2;
//     #20;
//     x<=2;
//     y<=3;
//     #20;
//     x<=4;
//     y<=5;
//     #20;
//     vid_we<=0;
//     #20;
//     x=100;
//     y=0;
//     #20;
//     $finish;
// end

// initial begin
//     $monitor("x=%d y=%d  st=%b clk=%b vid_we=%b",x,y,stat,clk,vid_we);
// end

// endmodule