module projection (
    input wire signed [31:0] x1,y1,z1,x2,y2,z2,x3,y3,z3,
    input wire start,
    input wire clk,
    output wire finish,
    output wire signed [31:0]ox1,oy1,ox2,oy2,ox3,oy3
);
reg signed[31:0] D=600; 
reg signed[31:0]X1;
reg signed[31:0]Y1,Z1;
reg signed[31:0]X2;
reg signed[31:0]Y2,Z2;
reg signed[31:0]X3;
reg signed[31:0]Y3,Z3;
reg signed[31:0]temp;
reg [1:0] state_reg,state_next;
reg finish_reg;
always @(posedge clk) 
begin
if(start)
begin
    finish_reg=0;
    state_reg=2'b00;
    state_next=2'b00;
    X1=x1;
    Y1=y1;
    Z1=z1;
    X2=x2;
    Y2=y2;
    Z2=z2;
    X3=x3;
    Y3=y3;
    Z3=z3;
end    
else
begin
state_reg=state_next;

end
end

always @(posedge clk) 
begin
    if(~finish_reg)
    begin
    case (state_reg)
            2'b00: 
            begin
            temp=X1*D;
            X1=temp/Z1;
            temp=Y1*D;
            Y1=temp/Z1;

            temp=X2*D;
            X2=temp/Z2;
            temp=Y2*D;
            Y2=temp/Z2;

            temp=X3*D;
            X3=temp/Z3;
            temp=Y3*D;
            Y3=temp/Z3;
            state_next=2'b01;   
            end

             2'b01:
             begin
                finish_reg=1'b1;
             end 
endcase            
    end
end
assign finish=finish_reg;
assign ox1=X1;
assign oy1=Y1;
assign ox2=X2;
assign oy2=Y2;
assign ox3=X3;
assign oy3=Y3;
endmodule

`timescale 1ns/1ps
module tb ();
  reg signed [31:0] x1,y1,z1,x2,y2,z2,x3,y3,z3;
  wire signed [31:0]ox1,oy1,ox2,oy2,ox3,oy3;
  reg clk;
  wire finish;
  reg start;

projection uut(.x1(x1), .y1(y1), .z1(z1), .x2(x2), .y2(y2), .z2(z2), .x3(x3), .y3(y3), .z3(z3),
                .ox1(ox1), .oy1(oy1), .ox2(ox2), .oy2(oy2), .ox3(ox3), .oy3(oy3),
                .clk(clk), .start(start), .finish(finish));
always
begin
    clk=~clk;
    #1;
end
initial begin
   clk=0;
   start=1'b1;
    x1=35;
    y1=40;
    z1=800;
    x2=10;
    y2=20;
    z2=650;
    x3=30;
    y3=60;
    z3=1000;
    #2;
    start=1'b0;
    #20;
    $finish;
end
initial begin
   $monitor("x1,y1=[%d,%d]\nx2,y2=[%d,%d]\nx3,y3=[%d,%d]",ox1,oy1,ox2,oy2,ox3,oy3); 
end
endmodule