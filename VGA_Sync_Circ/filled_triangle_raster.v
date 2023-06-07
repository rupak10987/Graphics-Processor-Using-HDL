module FilledTriangle (
  input wire clk,
  input wire rst,
  output reg [9:0] vga_x,
  output reg [8:0] vga_y,
  output reg vga_h,
  output reg vga_v
);

wire vga_hsync,vga_vsync;
always@(*)
begin
vga_h<=vga_hsync;
vga_v<=vga_vsync;
end

  // Triangle vertex coordinates
  parameter [9:0] X1 = 200;  // X coordinate of vertex 1
  parameter [8:0]Y1 = 100;  // Y coordinate of vertex 1
  parameter [9:0] X2 = 400;  // X coordinate of vertex 2
  parameter [8:0]Y2 = 300;  // Y coordinate of vertex 2
  parameter [9:0] X3 = 100;  // X coordinate of vertex 3
  parameter [8:0] Y3 = 300;  // Y coordinate of vertex 3

  // Instantiate the LineDrawing module
  LineDrawing line_drawing(
    .clk(clk),
    .rst(rst),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .x1(X1),
    .y1(Y1),
    .x2(X2),
    .y2(Y2)
  );

  reg [9:0] min_x, max_x, min_y, max_y;
  reg [1:0] state;
  reg [9:0] count_x, count_y;

  always @(posedge clk) begin
     $display("x_pixel=%b, ypixel=%b",vga_x,vga_y);
    if (rst) begin
      vga_hsync <= 0;
      vga_vsync <= 0;
      state <= 2'b00;
      count_x <= 0;
      count_y <= 0;
    end
    else begin
      case (state)
        2'b00:
          begin
            // Calculate minimum and maximum x, y coordinates
            min_x <= X1 < X2 ? (X1 < X3 ? X1 : X3) : (X2 < X3 ? X2 : X3);
            max_x <= X1 > X2 ? (X1 > X3 ? X1 : X3) : (X2 > X3 ? X2 : X3);
            min_y <= Y1 < Y2 ? (Y1 < Y3 ? Y1 : Y3) : (Y2 < Y3 ? Y2 : Y3);
            max_y <= Y1 > Y2 ? (Y1 > Y3 ? Y1 : Y3) : (Y2 > Y3 ? Y2 : Y3);
            if (count_y >= max_y - min_y + 1)
              state <= 2'b00;
            else if (count_x >= max_x - min_x + 1)
              state <= 2'b10;
            else if (count_x >= X1 - min_x && count_x <= X2 - min_x)
              state <= 2'b01;
            else
              state <= 2'b00;
          end
        2'b01:
          begin
            // Inside the triangle
            vga_x <= min_x + count_x;
            vga_y <= min_y + count_y;
            count_x <= count_x + 1;
            if (count_x >= X2 - min_x + 1)
              state <= 2'b11;
          end
        2'b10:
          begin
            // Between two lines of the triangle
            count_x <= 0;
            count_y <= count_y + 1;
            if (count_y >= max_y - min_y + 1)
              state <= 2'b00;
            else if (count_y >= Y2 - min_y && count_y <= Y3 - min_y)
              state <= 2'b01;
            else
              state <= 2'b00;
          end
        2'b11:
          begin
            // Inside the triangle
            vga_x <= X3 + count_x;
            vga_y <= min_y + count_y;
           
            count_x <= count_x + 1;
            if (count_x >= max_x - X3 + 1)
              state <= 2'b00;
          end
      endcase
    end
  end

endmodule

module LineDrawing (
  input wire clk,
  input wire rst,

  output reg vga_hsync,
  output reg vga_vsync,
  input wire [9:0] x1,
  input wire [8:0] y1,
  input wire [9:0] x2,
  input wire [8:0] y2
);

  reg [9:0] dx, dy, dx_abs, dy_abs;
  reg [9:0] slope_error, x, y;
  reg [0:1] quadrant;
  reg [0:1] state;
  reg [9:0] count;
  reg line_done;

  always @(posedge clk) begin
    if (rst) begin
      vga_hsync <= 0;
      vga_vsync <= 0;
      state <= 2'b00;
      count <= 0;
      line_done <= 0;
    end
    else begin
      case (state)
        2'b00:
          begin
            dx <= x2 - x1;
            dy <= y2 - y1;
            dx_abs <= dx > 0 ? dx : -dx;
            dy_abs <= dy > 0 ? dy : -dy;
            slope_error <= dx_abs >> 1;
            x <= x1;
            y <= y1;
            quadrant <= dx >= 0 ? (dy >= 0 ? 2'b00 : 2'b11) : (dy >= 0 ? 2'b01 : 2'b10);
            state <= 2'b01;
          end
        2'b01:
          begin
            if (count >= dx_abs + 1) begin
              state <= 2'b10;
              line_done <= 1;
            end
            else begin
              case (quadrant)
                2'b00:
                  begin
                    x <= x + 1;
                    slope_error <= slope_error - dy_abs;
                    if (slope_error < 0) begin
                      y <= y + 1;
                      slope_error <= slope_error + dx_abs;
                    end
                  end
                2'b01:
                  begin
                    y <= y + 1;
                    slope_error <= slope_error - dx_abs;
                    if (slope_error < 0) begin
                      x <= x - 1;
                      slope_error <= slope_error + dy_abs;
                    end
                  end
                2'b10:
                  begin
                    y <= y - 1;
                    slope_error <= slope_error - dx_abs;
                    if (slope_error < 0) begin
                      x <= x + 1;
                      slope_error <= slope_error + dy_abs;
                    end
                  end
                2'b11:
                  begin
                    x <= x - 1;
                    slope_error <= slope_error - dy_abs;
                    if (slope_error < 0) begin
                      y <= y - 1;
                      slope_error <= slope_error + dx_abs;
                    end
                  end
              endcase
              count <= count + 1;
            end
          end
        2'b10:
          begin
            if (line_done) begin
              vga_hsync <= 1;
              vga_vsync <= 1;
            end
            else begin
              vga_hsync <= 0;
              vga_vsync <= 0;
            end
            state <= 2'b00;
          end
      endcase
    end
  end

endmodule


//testbench
`timescale 1ns/1ps
module tr_tb (
);
  reg clk;
  reg rst;
  wire [9:0] vga_x;
  wire [8:0] vga_y;
  wire vga_hs;
  wire vga_vs;
FilledTriangle circ3 (
  .clk(clk),
  .rst(clk),
  .vga_x(vga_x),
  .vga_y(vga_y),
  .vga_h(vga_hs),
  .vga_v(vga_vs)
);

always 
begin
  clk=~clk;
  #10;
end
initial begin
  clk<=1'b0;
  rst<=1'b1;
  #40;
  rst<=0;
  #4000;
  $finish;
end
endmodule