module hp_class (
    input wire [15:0] f,
    output wire inf,zero,snan,qnan,normal,subnormal
);
wire expone,expzero,sigone,sigzero;
assign expone=&f[14:10];
assign expzero=~|f[14:10];
assign sigone=&f[9:0];
assign sigzero=~|f[9:0];

assign snan=expone & ~sigzero & ~f[9];
assign qnan=expone & f[9];
assign inf=expone & sigzero;
assign zero=expzero & sigzero;
assign normal=~expone & ~expzero;
assign subnormal=expzero & ~sigzero;
endmodule

//testbench
`timescale 1ns/1ps
module tb();
    reg [15:0]f;
    wire [5:0] f_status;

hp_class uut(
.f(f),
.snan(f_status[0]),
.qnan(f_status[1]),
.inf(f_status[2]),
.zero(f_status[3]),
.normal(f_status[4]),
.subnormal(f_status[5])
);

initial begin
    f=16'b0_11111_0000010000;//snan
    #20;
    f=16'b0_11111_1000000000;//qnan
    #20;
    f=16'b0_11111_0000000000;//inf
    #20;
    f=16'b0_00000_0000000000;//zero
    #20;
    f=16'b0_00110_1010010000;//normal
    #20;
    f=16'b0_00000_0010011000;//zero
    #20;
    $finish;
end
initial begin
    $monitor("f=%b\nstatus=%b\n\n",f,f_status);
end


endmodule