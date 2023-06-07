module FilledTriangle (
  input wire clk,
  input wire rst,
  output reg [9:0] vga_x,
  output reg [8:0] vga_y,
  output reg vga_hsync,
  output reg vga_vsync
);

  // Triangle vertex coordinates
  parameter X1 = 20;  // X coordinate of vertex 1
  parameter Y1 = 10;  // Y coordinate of vertex 1
  parameter X2 = 40;  // X coordinate of vertex 2
  parameter Y2 = 30;  // Y coordinate of vertex 2
  parameter X3 = 10;  // X coordinate of vertex 3
  parameter Y3 = 30;  // Y coordinate of vertex 3

  reg [9:0] min_x, max_x, min_y, max_y;
  reg [31:0] a1, a2, a3, b1, b2, b3;
  reg [31:0] w1, w2, w3;
  reg [1:0] state;
  reg [9:0] count_x, count_y;

  // VGA timing parameters
  parameter H_DISPLAY = 640;  // Horizontal display resolution
  parameter V_DISPLAY = 480;  // Vertical display resolution
  parameter H_FRONT_PORCH = 16;  // Horizontal front porch
  parameter H_SYNC_PULSE = 96;   // Horizontal sync pulse
  parameter H_BACK_PORCH = 48;   // Horizontal back porch
  parameter V_FRONT_PORCH = 10;  // Vertical front porch
  parameter V_SYNC_PULSE = 2;    // Vertical sync pulse
  parameter V_BACK_PORCH = 33;   // Vertical back porch

  // VGA horizontal counter
  reg [9:0] h_counter;
  // VGA vertical counter
  reg [8:0] v_counter;

  always @(posedge clk) begin
    if (rst) begin
      h_counter <= 0;
      v_counter <= 0;
      vga_hsync <= 0;
      vga_vsync <= 0;
      vga_x <= 0;
      vga_y <= 0;
      state <= 2'b00;
      count_x <= 0;
      count_y <= 0;
    end
    else begin
      case (state)
        2'b00:
          begin
            // Horizontal sync pulse
            if (h_counter >= H_SYNC_PULSE) begin
              h_counter <= 0;
              state <= 2'b01;
            end
            else begin
              h_counter <= h_counter + 1;
              vga_hsync <= 1;
            end
          end
        2'b01:
          begin
            // Horizontal back porch
            if (h_counter >= H_BACK_PORCH) begin
              h_counter <= 0;
              state <= 2'b10;
            end
            else begin
              h_counter <= h_counter + 1;
              vga_hsync <= 0;
            end
          end
        2'b10:
          begin
            // Horizontal display
            if (h_counter >= H_DISPLAY) begin
              h_counter <= 0;
              state <= 2'b11;
            end
            else begin
              h_counter <= h_counter + 1;
              vga_hsync <= 0;
              vga_x <= h_counter;
             
            end
          end
        2'b11:
          begin
            // Horizontal front porch
            if (h_counter >= H_FRONT_PORCH) begin
              h_counter <= 0;
              state <= 2'b00;
            end
            else begin
              h_counter <= h_counter + 1;
              vga_hsync <= 0;
            end
          end
      endcase

      // Vertical timing
      if (h_counter == 0) begin
        case (state)
          2'b00, 2'b01, 2'b11:
            begin
              // Vertical sync pulse
              if (v_counter >= V_SYNC_PULSE) begin
                v_counter <= 0;
                vga_vsync <= 1;
              end
              else begin
                v_counter <= v_counter + 1;
                vga_vsync <= 0;
              end
            end
          2'b10:
            begin
              // Vertical back porch
              if (v_counter >= V_BACK_PORCH) begin
                v_counter <= 0;
                state <= 2'b00;
              end
              else begin
                v_counter <= v_counter + 1;
                vga_vsync <= 0;
                vga_y <= v_counter;
                
              end
            end
        endcase
      end

      // Calculate minimum and maximum x,y coordinates
      if (state == 2'b00) begin
        min_x <= X1 < X2 ? (X1 < X3 ? X1 : X3) : (X2 < X3 ? X2 : X3);
        max_x <= X1 > X2 ? (X1 > X3 ? X1 : X3) : (X2 > X3 ? X2 : X3);
        min_y <= Y1 < Y2 ? (Y1 < Y3 ? Y1 : Y3) : (Y2 < Y3 ? Y2 : Y3);
        max_y <= Y1 > Y2 ? (Y1 > Y3 ? Y1 : Y3) : (Y2 > Y3 ? Y2 : Y3);
      end

      // Check if current pixel is inside the triangle
      if (state == 2'b10 && v_counter >= min_y && v_counter <= max_y &&
          h_counter >= min_x && h_counter <= max_x) begin
        a1 <= Y2 - Y1;
        b1 <= X1 - X2;
        a2 <= Y3 - Y2;
        b2 <= X2 - X3;
        a3 <= Y1 - Y3;
        b3 <= X3 - X1;
        w1 <= (a1 * (h_counter - X2) + b1 * (v_counter - Y2)) >> 1;
        w2 <= (a2 * (h_counter - X3) + b2 * (v_counter - Y3)) >> 1;
        w3 <= (a3 * (h_counter - X1) + b3 * (v_counter - Y1)) >> 1;
        if (w1 >= 0 && w2 >= 0 && w3 >= 0)
          state <= 2'b11;
      end

      // Draw filled triangle
      if (state == 2'b11) begin
        count_x <= count_x + 1;
        if (count_x >= max_x - min_x + 1) begin
          count_x <= 0;
          count_y <= count_y + 1;
          if (count_y >= max_y - min_y + 1)
            state <= 2'b00;
        end
        else begin
          vga_x <= h_counter;//
          vga_y <= v_counter;
        end
      end
    end
  end

endmodule



`timescale 1ns/1ps
module tb (
);
reg clk;
reg rst;
wire [9:0] vga_x;
wire [8:0] vga_y;
wire vga_hsync;
wire vga_vsync;
FilledTriangle circt(
.clk(clk),
.rst(rst),
.vga_x(vga_x),
.vga_y(vga_y),
.vga_hsync(vga_hsync),
.vga_vsync(vga_vsync)
);

always
begin
  clk=~clk;
  #10;
end
initial begin
  clk<=0;
  rst=1;
  #40;
  rst=0;
  #400000;
  $finish;
end
always@(*)
begin
  $monitor("x=%d,y=%d\n",vga_x,vga_y);
end

endmodule