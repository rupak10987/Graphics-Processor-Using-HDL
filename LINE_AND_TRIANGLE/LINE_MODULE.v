module B_Line(
    input wire clk,start,
    input wire[31:0] x1,y1,x2,y2,
    output wire [9:0]X,
    output wire [8:0]Y,
    output reg finish
);

// Line coordinates
reg signed [31:0]X1,Y1,X2,Y2;
always @(*) begin
  X1 <= x1;  
  Y1 <= y1;  
  X2 <= x2;  
  Y2 <= y2;  
end
reg is_paused;
reg signed[31:0]x,x_next,y,y_next,dx,dy,dt,ds,d,d_next;
reg[2:0]state_reg,state_next;
//mem_of_state
  always @(posedge clk)begin
    if(start )
    begin
        state_reg<=2'b00;
        state_next<=2'b00;
        finish=1'b0;
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
    
    //finish=1'b0;
    state_next=state_reg;
    x_next=x;
    y_next=y;
    d_next=d;
    case (state_reg)
        3'b000:
        begin
            x_next=X1;
            y_next=Y1;
            dx=X2-X1;
            dy=Y2-Y1;
            state_next=3'b001;
        end 
        3'b001:
        begin
            if(dx>=dy)
            begin
            dt=2*(dy-dx);
            ds=2*dy;
            d_next=(2*dy)-dx;
            state_next=3'b010;
            end
            else
            begin
            dt=2*(dx-dy);
            ds=2*dx;
            d_next=(2*dx)-dy;
            state_next=3'b011;
            end
        end 
        3'b010://horizontal_line
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
            state_next=3'b100;
        end
        3'b011://vertical line
        begin
            if(y<=Y2) 
        begin
        y_next=y+1;
        if(d<0)
        begin
            d_next=d+ds;
        end
        else
        begin
            x_next=x+1;
            d_next=d+dt;
        end            
        end  
        else
            state_next=3'b100;
        end
        3'b100:
        begin
            finish=1'b1;
        end
        
    endcase
end

assign X=x[9:0];
assign Y=y[8:0];

endmodule

//testbench
// `timescale 1ns/1ps
// module brsn_line_tb ();
// reg clk;
// reg start;
// wire finish;
// wire[9:0]X;
// wire[8:0]Y;
// reg[31:0] x1,x2,y1,y2;
// B_Line circ1(
//     .clk(clk),
//     .start(start),
//     .X(X),
//     .Y(Y),
//     .finish(finish),
//     .x1(x1),
//     .y1(y1),
//     .x2(x2),
//     .y2(y2)
// );

// always
// begin
//     clk=~clk;
//     #1;
// end
// initial
// begin
//     x1=10;
//     y1=20;
//     x2=20;
//     y2=20;
//     clk<=1'b0;
//     start<=1'b1;
//     #2;
//     start<=1'b0;
//     #4000;
//     $finish;
// end

// initial
// begin
//     $monitor("x=%d, y=%d |finish=%b",X,Y,finish);
// end
// endmodule