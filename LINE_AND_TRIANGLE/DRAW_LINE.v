module DRAW_LINE(
    input wire[31:0]X1,Y1,X2,Y2,
    input wire clk,
    output wire[31:0]X,
    output wire [31:0]Y
    //output wire[17:0]buffer_addr
);
reg valid;
reg [31:0] x_counter_reg,x_counter_next;
reg [31:0] y_counter_reg,y_counter_next;    
reg signed [31:0] dx, dy;
reg signed [31:0] x, y;
reg signed [31:0] p, inc1, inc2;
reg [31:0] count_x;
reg [31:0] count_y;
reg[1:0] state;
//initialization
initial begin
    valid=1'b0;
    x_counter_reg=X1;
    y_counter_reg=Y1;
    dx = X2 - X1;
    dy = Y2 - Y1;
    inc1 = (dx < 0) ? -1 : 1;
    inc2 = (dy < 0) ? -1 : 1;
    x = X1;
    y = Y1;
    p = 2 * dy - dx;
end

//memory
always @(posedge clk) 
begin
x_counter_reg<=x_counter_next ;
y_counter_reg<=y_counter_next;
end

//counter next state
always @(posedge clk) begin
    if(x_counter_reg<X2)
    x_counter_next<=x_counter_reg+1;
    else
    x_counter_next<=x_counter_reg;

    if(y_counter_reg<Y2)
    y_counter_next<=y_counter_reg+1;
     else
    y_counter_next<=y_counter_reg;
end


// Bresenham's line algorithm
 always @(*) begin
   if (x_counter_reg == X1 && y_counter_reg == Y1)
      begin
        state <= 2'b00;
      end
      if (state == 2'b00) begin
        if (x == X2 && y == Y2)
          state <= 2'b10;

        if (p >= 0) 
        begin
          x = x + inc1;
          p = p + inc2;
          $display("x=%d, y=%d",x,y);
        end
        else
        begin
          x = x;
          p = p + dx;
          $display("x=%d, y=%d",x,y);
        end
      end

      if (state == 2'b10) begin
        count_x = count_x + 1;
        if (count_x >= dx)
        begin
          count_x = 0;
          count_y = count_y + 1;
          x = X1;
          y = Y1 + count_y;
          p = p - dx * dy;
          $display("x=%d, y=%d",x,y);
        end
        else 
        begin
          x = x + 1;
          p = p + 2 * dy;
          $display("x=%d, y=%d",x,y);
        end
      end  
end

assign X=x;
assign Y=y;
endmodule



`timescale 1ns/1ps
module tb_line (
);

reg[31:0] X1=10;
reg[31:0] Y1=20;
reg[31:0] X2=30;
reg[31:0] Y2=40;
reg clk;
wire[31:0] X;
wire[31:0] Y;

DRAW_LINE line_circ(
    .clk(clk),
    .X1(X1),
    .Y1(Y1),
    .X2(X2),
    .Y2(Y2),
    .X(X),
    .Y(Y)
);

always 
begin
    clk=~clk;
    #10;
end
initial
begin
  $monitor("%d, %d",X,Y);
end
endmodule