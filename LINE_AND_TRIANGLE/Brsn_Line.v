module B_Line(
    input wire clk,start,
    output wire [31:0]X,Y,
    output reg finish
);
// Line coordinates
  parameter X1 = 1;  
  parameter Y1 = 2;  
  parameter X2 = 20;  
  parameter Y2 = 21;      

reg signed[31:0]x,x_next,y,y_next,dx,dy,dt,ds,d,d_next;
reg[1:0]state_reg,state_next;

//mem_of_state
  always @(posedge clk)begin
    if(start)
    begin
        state_reg<=2'b00;
        state_next<=2'b00;
    end
    else
    begin
        state_reg=state_next;
        x=x_next;
        y=y_next;
        d=d_next;
    end
  end

//state_next logic
always @(*) begin
    finish=1'b0;
    state_next=state_reg;
    x_next=x;
    y_next=y;
    d_next=d;
    case (state_reg)
        2'b00:
        begin
            x_next=X1;
            y_next=Y1;
            dx=X2-X1;
            dy=Y2-Y1;
            state_next=2'b01;
        end 
        2'b01:
        begin

            dt=2*(dy-dx);
            ds=2*dy;
            d_next=(2*dy)-dx;
            state_next=2'b10;
        end 
        2'b10:
        begin
 
        if(x<=X2) 
        begin
        x_next=x+1;
        if(d<0)
        begin
            d_next=d+ds;
        end
        else
        begin
            y_next=y+1;
            d_next=d+dt;
        end            
        end  
        else
            state_next=2'b11;
        end
        2'b11:
        begin

            finish=1'b1;
        end
    endcase
end

assign X=x;
assign Y=y;
endmodule




////testbench
`timescale 1ns/1ps
module brsn_line_tb ();
reg clk;
reg start;
wire finish;
wire[31:0]X,Y;

B_Line circ1(
    .clk(clk),
    .start(start),
    .X(X),
    .Y(Y),
    .finish(finish)
);

always
begin
    clk=~clk;
    #20;
end
initial
begin
    clk<=1'b0;
    start<=1'b1;
    #40;
    start<=1'b0;
    #4000;
end

initial
begin
    $monitor("x=%d, y=%d |finish=%b",X,Y,finish);
end
endmodule