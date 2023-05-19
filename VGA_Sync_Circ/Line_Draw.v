module Line_Draw(
    input wire clk,
    output wire[31:0]X,Y

);

    reg signed [31:0] dx, dy;
    reg signed [31:0] x, y;
    reg signed [31:0] p, inc1, inc2;
    reg[31:0] h_counter,v_counter;
    reg[31:0]h_count_next,v_count_next;
    reg [1:0] state;
    reg [9:0] count_x, count_y;

// Line coordinates
  parameter X1 = 1;  // X coordinate of the first point
  parameter Y1 = 2;  // Y coordinate of the first point
  parameter X2 = 40;  // X coordinate of the second point
  parameter Y2 = 30;  // Y coordinate of the second point

//initialization
initial begin
    h_counter<=X1;
    v_counter<=Y1;
    dx = X2 - X1;
    dy = Y2 - Y1;
    inc1 = (dx < 0) ? -1 : 1;
    inc2 = (dy < 0) ? -1 : 1;
    x = X1;
    y = Y1;
    p = 2 * dy - dx;
end

//counter reg
always @(posedge clk) 
begin
h_counter<=h_count_next ;
v_counter<=v_count_next;
end
//counter next state
always @(posedge clk) begin
    if(h_counter>=X2)
    begin
        h_count_next=X1;
    end
    else
    begin
        h_count_next=h_counter+1;
    end

    if(v_counter>=Y2)
    begin
        v_count_next=Y1;
    end
    else
    begin
        v_count_next=v_counter+1;
    end
end

 // Bresenham's line algorithm
 always @(*) begin
   if (h_counter == X1 && v_counter == Y1)
      begin
        state <= 2'b00;
      end
      if (state == 2'b00) begin
        if (x == X2 && y == Y2)
          state <= 2'b10;

        if (p >= 0) 
        begin
          x <= x + inc1;
          p <= p + inc2;
        end
        else
        begin
          x <= x;
          p <= p + dx;
        end
      end

      if (state == 2'b10) begin
        count_x <= count_x + 1;
        if (count_x >= dx)
        begin
          count_x <= 0;
          count_y <= count_y + 1;
          x <= X1;
          y <= Y1 + count_y;
          p <= p - dx * dy;
        end
        else 
        begin
          x <= x + 1;
          p <= p + 2 * dy;
        end
      end  
 end
      
  assign X=x;
  assign Y=y;
endmodule