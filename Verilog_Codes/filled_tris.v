module filled_tris (
    input wire signed[31:0]x1,y1,x2,y2,x3,y3,
    output wire [9:0]OX1,
    output wire [8:0]OY1,
    output wire finish,
    input wire reset,
    input wire clk
);
    
    reg signed[31:0] X0,X1,X2,X0_next,X1_next,X2_next;
    reg signed[31:0] Y0,Y1,Y2,Y0_next,Y1_next,Y2_next;
    reg signed [31:0]Y_itr;
    reg signed [31:0]Y_itr_next;
    reg [31:0] size,size_next;
    reg [3:0] state_reg;
    reg[3:0] state_next;
    reg LR,LR_next;
    reg finish_reg;
    reg signed[31:0] X_left[64:0];//initialize to max size vertical height of display
    reg signed[31:0] X_right[64:0];
    reg signed[31:0] X_01[64:0];
    reg signed[31:0] X_12[64:0];
    reg signed[31:0] X_02[64:0];
    reg signed[31:0]lnX1,lnY1,lnX2,lnY2,lnX1_next,lnY1_next,lnX2_next,lnY2_next;


    //for line
    reg line_start,line_start_next;
    wire line_finish;
    reg r_line_finish;
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

always @(*) begin
    r_line_finish=line_finish;
end



    always @(posedge clk) begin
        if(reset)
        begin
            line_start=1'b0;
            state_reg<=4'b0000;
            Y_itr<=0;
        end
        else
        begin
        line_start<=line_start_next;
        state_reg<=state_next;  
        Y_itr<=Y_itr_next;
        X0<=X0_next;
        X1<=X1_next;
        X2<=X2_next;
        Y0<=Y0_next;
        Y1<=Y1_next;
        Y2<=Y2_next;
        size<=size_next;
        LR<=LR_next;
        lnX1<=lnX1_next;
        lnX2<=lnX2_next;
        lnY1<=lnY1_next;
        lnY2<=lnY2_next;
        
        end
        
    end


    //THE STATE MACHINE
    always @(*)
    begin
        line_start_next=line_start;
        state_next=state_reg;
        Y_itr_next=Y_itr;
        finish_reg=1'b0;
        X0_next=X0;
        X1_next=X1;
        X2_next=X2;
        Y0_next=Y0;
        Y1_next=Y1;
        Y2_next=Y2;
        size_next=size;
        LR_next=LR;
        lnX1_next=lnX1;
        lnX2_next=lnX2;
        lnY1_next=lnY1;
        lnY2_next=lnY2;

          case (state_reg)
            4'b0000: //initialize all reg
            begin
            X0_next=x1;
            Y0_next=y1;  
            X1_next=x2;
            Y1_next=y2;
            X2_next=x3;
            Y2_next=y3;
            state_next=4'b0001;
            end
            4'b0001://sort in order such that y2 top, y1 mid and y0 bottom vertecies
            begin
            if(Y1<Y0)
            begin
                Y0_next=Y1;
                Y1_next=Y0;
                X0_next=X1;
                X1_next=X0;
            end
            if(Y2<Y0)
            begin
                Y0_next=Y2;
                Y2_next=Y0;
                X0_next=X2;
                X2_next=X0;
            end
            if(Y2<Y1)
            begin
                Y1_next=Y2;
                Y2_next=Y1;
                X1_next=X2;
                X2_next=X1;
            end
            state_next=4'b0010;
            end
            4'b0010: //calculate size
            begin
                size_next=Y2-Y0+1;
                state_next=4'b0011;
            end
            4'b0011: //set y_itr to Y0
            begin
             Y_itr_next=Y0;
             state_next=4'b0100;
            end
            4'b0100: //calculate x01
            begin
                
               if(Y_itr<=Y1 & Y_itr>=Y0)
               begin
                X_01[Y_itr-Y0]=X0+(((Y_itr-Y0)*(X1-X0))/(Y1-Y0));
                Y_itr_next=Y_itr+1;
               end
               else
               begin
                X_01[Y_itr-Y0]=0;
                Y_itr_next=Y0;
                state_next=4'b0101;
               end

            end
            4'b0101: //calculate x02
            begin
               if(Y_itr<=Y2 & Y_itr>=Y0)
               begin
                X_02[Y_itr-Y0]=X0+(((Y_itr-Y0)*(X2-X0))/(Y2-Y0));
                Y_itr_next=Y_itr+1;
               end
               else
               begin
                X_02[Y_itr-Y0]=0;
                Y_itr_next=Y1;
                state_next=4'b0110;
               end

            end
             4'b0110: //calculate x12
            begin
               if(Y_itr<=Y2 & Y_itr>=Y1)
               begin
                X_12[Y_itr-Y1]=X1+(((Y_itr-Y1)*(X2-X1))/(Y2-Y1));
                Y_itr_next=Y_itr+1;
               end
               else
               begin
                X_12[Y_itr-Y1]=0;
                Y_itr_next=0;
                state_next=4'b0111;
               end
            end
            4'b0111: //determine left and right and 
            begin
                if(X_12[0]>X_02[size/2])
                begin
                //$display("X02 is left");
                LR_next=1'b1;
                end
                else
                begin
                //$display("X012 is left");
                LR_next=1'b0;
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
                    lnX1_next=X_02[Y_itr-Y0];
                    lnX2_next=X_01[Y_itr-Y0];    
                    end
                    else
                    begin
                    lnX2_next=X_02[Y_itr-Y0];
                    lnX1_next=X_01[Y_itr-Y0];
                    end
                    lnY1_next=Y_itr;
                    lnY2_next=Y_itr;
                    Y_itr_next=Y_itr+1;   
                    //ebar line draw kore asbe
                    state_next=4'b1001;
                    line_start_next=1'b1;
                end
                else if(Y_itr>Y1 & Y_itr<=Y2)
                begin
                    //$display("line between %d,%d",X_02[Y_itr-Y0],X_12[Y_itr-Y1]);
                    if(LR)
                    begin
                    lnX1_next=X_02[Y_itr-Y0];
                    lnX2_next=X_12[Y_itr-Y1];    
                    end
                    else
                    begin
                    lnX2_next=X_02[Y_itr-Y0];
                    lnX1_next=X_12[Y_itr-Y1]; 
                    end
                    lnY1_next=Y_itr;
                    lnY2_next=Y_itr;
                    Y_itr_next=Y_itr+1;    
                    //ebar line draw kore asbe 
                    state_next=4'b1001; 
                    line_start_next=1'b1;       
                end
                else
                  finish_reg=1'b1;
            end
            4'b1001://fill the triangles
            begin
                line_start_next=1'b0;//start doing line operation

                if(r_line_finish)
                begin
                state_next=4'b1000;  
                line_start_next=1'b1;  
                end
                
            end
            default:
            begin
               X_01[Y_itr-Y0]=0;
               X_02[Y_itr-Y0]=0;
               X_12[Y_itr-Y1]=0;
               state_next=4'b0000; 
            end
            
        endcase  
        end  

    always @(*) begin
        lx1=(state_reg==4'b1001)?lnX1:0;
        ly1=(state_reg==4'b1001)?lnY1:0;
        lx2=(state_reg==4'b1001)?lnX2:0;
        ly2=(state_reg==4'b1001)?lnY2:0;
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
