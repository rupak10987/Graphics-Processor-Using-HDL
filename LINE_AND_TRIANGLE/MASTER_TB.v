module MASTER_TB (
);

reg mclk;
reg Mreset;
reg Mstart;
wire[11:0]RGBA;
wire h_sync;
wire v_sync;
wire[9:0] OX;
wire[8:0] OY;

MASTER uut(.clk(mclk),
           .Mreset(Mreset),
           .Mstart(Mstart),
           .RGBA(RGBA),
           .h_sync(h_sync),
           .v_sync(v_sync),
           .OX(OX),
           .OY(OY));
           
always
begin
    mclk=~mclk;
    #1;
end

initial begin
mclk=0;
Mreset=1;
Mstart=0;
#2;
Mreset=0;
Mstart=1;
#2;
#30000;
$finish;
end
initial begin
    $monitor("X=%d, Y=%d",OX,OY);//filled x and y
end
endmodule