module hp_div(
    input [15:0] dividend,
    input [15:0] divisor,
    input wire clk,
    output wire [15:0] quotient
);

    // Extracting sign, exponent, and fraction parts of the two numbers
    wire s_dividend = dividend[15];
    wire s_divisor = divisor[15];
    wire q_sign; 
    assign q_sign=s_dividend^s_divisor;

    wire [4:0] exp_dividend = dividend[14:10];
    wire [4:0] exp_divisor = divisor[14:10];
    wire [10:0] frac_dividend ={1'b1,dividend[9:0]} ;
    wire [10:0] frac_divisor = {1'b1,divisor[9:0]};
    reg [12:0] Asig,Bsig,Qsig;
    integer iterator=0;
    integer iterator_next=0;
    initial begin
        iterator=0;
        iterator_next=0;
        Asig={2'b00,frac_dividend};
        Bsig={2'b00,frac_divisor};
        Qsig=0;
    end

    always @(posedge clk) begin
        if(iterator<=13)
        iterator_next=iterator+1;
        iterator=iterator_next; 
        $display("%d",iterator);
    end
    // Determine the exponents' difference
    wire [6:0] exp_difference;
    assign exp_difference = (exp_dividend-15) - (exp_divisor-15)+15;


    always @(posedge clk) begin
            //division algo goes here
            if((Asig-Bsig)<0)
            begin
                Asig=Asig<<1;
                Qsig=Qsig<<1;
            end
            else
            begin
                Asig=(Asig-Bsig)<<1;
                Qsig={Qsig[11:0],1'b1};
            end
    end

    assign quotient={q_sign,exp_difference[4:0],Qsig[9:0]};

endmodule

`timescale 1ns/1ps
module div_tb (
);
reg[15:0] A,B;
wire [15:0] Q; 
reg clk;
hp_div uut(.dividend(A),.divisor(B),.quotient(Q),.clk(clk));
always 
begin
clk=~clk;
#20;    
end
initial begin
    clk=0;
    A=16'b0_10010_0100000000;
    B=16'b0_10001_0100000000;
    #4000;
    $finish;
end

initial begin
    $monitor("A=%b / B=%b =\nQ=%b",A,B,Q);
end
endmodule