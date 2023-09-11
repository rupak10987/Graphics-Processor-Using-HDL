module MASTER_TB (
);
wire[9:0] p_x,p_y;
reg mclk;
reg Mreset;
reg Mstart;
wire[11:0]RGBA;
wire h_sync;
wire v_sync;
wire[9:0] OX;
wire[8:0] OY;
wire von;
MASTER uut(.clk(mclk),
           .Mreset(Mreset),
           .Mstart(Mstart),
           .RGBA(RGBA),
           .h_sync(h_sync),
           .v_sync(v_sync),
           .OX(OX),
           .OY(OY),
           .PX(p_x),
           .PY(p_y),
           .vidwe(von)
           );
           
always
begin
    mclk=~mclk;
    #1;
end

initial begin
$dumpfile("test.vcd");
$dumpvars(0,MASTER_TB);
mclk=0;
Mreset=1;
Mstart=0;
#2;
Mreset=0;
Mstart=1;
#2;
#100000;
$finish;
end
initial begin
    //$monitor("X=%d, Y=%d",OX,OY);//filled x and y
     //$monitor("RGB=%b%b%b|X=%d, Y=%d",RGBA[0],RGBA[4],RGBA[8],OX,OY);//filled x and y
     $monitor("RGB=%b%b%b at px=%d, py=%d",RGBA[0],RGBA[4],RGBA[8],p_x,p_y);
end
endmodule