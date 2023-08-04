module filled_tris (
    input wire signed[31:0]x1,y1,x2,y2,x3,y3,
    output wire [9:0]OX1,
    output wire [8:0]OY1,
    output wire finish,
    input wire reset,
    input wire clk
);
    
    reg signed[31:0] X0,X1,X2;
    reg signed[31:0] Y0,Y1,Y2;
    reg signed[31:0] temp;
    reg signed [31:0]Y_itr;
    reg signed [31:0]Y_itr_next;
    reg [31:0] size;
    reg [3:0] state_reg;
    reg[3:0] state_next;
    reg LR;
    reg finish_reg;
    reg signed[31:0] X_left[640:0];//initialize to max size vertical height of display
    reg signed[31:0] X_right[640:0];
    reg signed[31:0] X_01[640:0];
    reg signed[31:0] X_12[640:0];
    reg signed[31:0] X_02[640:0];
    reg signed[31:0]lnX1,lnY1,lnX2,lnY2;


    //for line
    reg line_start;
    wire line_finish;
    wire[9:0]LX;
    wire[8:0]LY;
    reg[31:0] lx1,lx2,ly1,ly2;
    B_Line ln(
     .clk(clk),
     .start(line_start),
     .X(LX),
     .Y(LY),
     .finish(line_finish),
     .x1(lx1),
     .y1(ly1),
     .x2(lx2),
     .y2(ly2)
    );





    always @(posedge clk) begin
        if(reset)
        begin
            state_reg=0;
            state_next=0;
            finish_reg=0;
            Y_itr=0;
            Y_itr_next=0;
        end
        else
        begin
        state_reg=state_next;  
        Y_itr=Y_itr_next;
        end
        
    end


    //THE STATE MACHINE
    always @(posedge clk)
    begin
        state_next=state_reg;
        if(~finish_reg)
        begin
          case (state_reg)
            4'b0000: //initialize all reg
            begin
            X0=x1;
            Y0=y1;  
            X1=x2;
            Y1=y2;
            X2=x3;
            Y2=y3;
            state_next=4'b0001;
            end
            4'b0001://sort in order such that y2 top, y1 mid and y0 bottom vertecies
            begin
            if(Y1<Y0)
            begin
                temp=Y0;
                Y0=Y1;
                Y1=temp;
                temp=X0;
                X0=X1;
                X1=temp;
            end
            if(Y2<Y0)
            begin
                temp=Y0;
                Y0=Y2;
                Y2=temp;
                temp=X0;
                X0=X2;
                X2=temp;
            end
            if(Y2<Y1)
            begin
                temp=Y1;
                Y1=Y2;
                Y2=temp;
                temp=X1;
                X1=X2;
                X2=temp;
            end
            state_next=4'b0010;
            end
            4'b0010: //calculate size
            begin
                size=Y2-Y0+1;
                state_next=4'b0011;
            end
            4'b0011: //set y_itr to Y0
            begin
             Y_itr_next=Y0;
             state_next=4'b0100;
            end
            4'b0100: //calculate x01
            begin
               if(Y_itr<=Y1)
               begin
                temp=(Y_itr-Y0)*(X1-X0);
                X_01[Y_itr-Y0]=X0+(temp/(Y1-Y0));//eqn
                //$display("xo1[%d]=%d",Y_itr-Y0,X_01[Y_itr-Y0]);
                Y_itr_next<=Y_itr+1;
               end
               else
               begin
                Y_itr_next=Y0;
                state_next=4'b0101;
               end
            end
            4'b0101: //calculate x02
            begin
               if(Y_itr<=Y2)
               begin
                temp=(Y_itr-Y0)*(X2-X0);
                X_02[Y_itr-Y0]=X0+(temp/(Y2-Y0));//eqn
                //$display("xo2[%d]=%d",Y_itr-Y0,X_02[Y_itr-Y0]);
                Y_itr_next<=Y_itr+1;
               end
               else
               begin
                Y_itr_next=Y1;
                state_next=4'b0110;
               end
            end
             4'b0110: //calculate x12
            begin
               if(Y_itr<=Y2)
               begin
                temp=(Y_itr-Y1)*(X2-X1);
                X_12[Y_itr-Y1]=X1+(temp/(Y2-Y1));//eqn
                //$display("x12[%d]=%d",Y_itr-Y1,X_12[Y_itr-Y1]);
                Y_itr_next<=Y_itr+1;
               end
               else
               begin
                Y_itr_next=0;
                state_next=4'b0111;
               end
            end
            4'b0111: //determine left and right and 
            begin
                if(X_12[0]>X_02[size/2])
                begin
                //$display("X02 is left");
                LR=1'b1;
                end
                else
                begin
                //$display("X012 is left");
                LR=1'b0;
                end
                Y_itr_next=Y0;
                state_next=4'b1000;  
            end
            4'b1000:  //iterate through y0->y1->y2
            begin
                if(Y_itr>=Y0 & Y_itr<=Y1 )
                begin
                    //$display("line between %d,%d",X_02[Y_itr-Y0],X_01[Y_itr-Y0]);
                    if(LR)
                    begin
                    lnX1=X_02[Y_itr-Y0];
                    lnX2=X_01[Y_itr-Y0];    
                    end
                    else
                    begin
                    lnX2=X_02[Y_itr-Y0];
                    lnX1=X_01[Y_itr-Y0];
                    end
                    lnY1=Y_itr;
                    lnY2=Y_itr;
                    Y_itr_next=Y_itr+1;   
                    //ebar line draw kore asbe
                    state_next=4'b1001;
                    line_start=1'b1;
                end
                else if(Y_itr>Y1 & Y_itr<=Y2)
                begin
                    //$display("line between %d,%d",X_02[Y_itr-Y0],X_12[Y_itr-Y1]);
                    if(LR)
                    begin
                    lnX1=X_02[Y_itr-Y0];
                    lnX2=X_12[Y_itr-Y1];    
                    end
                    else
                    begin
                    lnX2=X_02[Y_itr-Y0];
                    lnX1=X_12[Y_itr-Y1]; 
                    end
                    lnY1=Y_itr;
                    lnY2=Y_itr;
                    Y_itr_next=Y_itr+1;    
                    //ebar line draw kore asbe 
                    state_next=4'b1001; 
                    line_start=1'b1;       
                end
                else
                  finish_reg=1'b1;
            end
            4'b1001://fill the triangles
            begin
                line_start=1'b0;//start doing line operation

                if(line_finish)
                begin
                state_next=4'b1000;  
                line_start=1'b1;  
                end
                
            end
        endcase  
        end  
    end

    always @(*) begin
        lx1<=(state_reg==4'b1001)?lnX1:0;
        ly1<=(state_reg==4'b1001)?lnY1:0;
        lx2<=(state_reg==4'b1001)?lnX2:0;
        ly2<=(state_reg==4'b1001)?lnY2:0;
    end
    
    assign OX1=(state_reg==4'b1001)?LX:0;
    assign OY1=(state_reg==4'b1001)?LY:0;
    assign finish=finish_reg;
endmodule


//tb
// `timescale 1ns/1ps
// module tb (
// );
//     reg signed[31:0] x1,y1,x2,y2,x3,y3;
//     wire [9:0] OX1;
//     wire [8:0] OY1;
//     wire finish;
//     reg clk;
//     reg reset;
//     reg pause_sig;
//     filled_tris uut(.x1(x1),
//                     .y1(y1),
//                     .x2(x2),
//                     .y2(y2),
//                     .x3(x3),
//                     .y3(y3),
//                     .OX1(OX1),
//                     .OY1(OY1),
//                     .clk(clk),
//                     .finish(finish),
//                     .reset(reset));
//     always
//     begin
//     clk=~clk;
//     #1;    
//     end
//     initial begin
//         clk=0;
//         reset=1;
//         x1=35;
//         y1=40;
//         x2=10;
//         y2=20;
//         x3=30;
//         y3=60;
//         #2;
//         reset=0;
//         #366;
//         #30000;
//         $finish;
//     end
//     initial begin
//         $monitor("filled-%d,%d",OX1,OY1);//filled pixels
//     end
// endmodule
