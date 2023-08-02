module fp_div(a, b, q);
  parameter NEXP = 5;
  parameter NSIG = 10;
  parameter BIAS=15;
  input [NEXP+NSIG:0] a, b;   // Operands
  output [NEXP+NSIG:0] q;     // Quotient 
  
  wire signed [NEXP+1:0] aExp, bExp, expOut;
  // qExp is the quotient for the exponent portion of our result.
  reg signed [NEXP+1:0] normExp, expIn, qExp;
  wire [NSIG:0] aSigWire, bSigWire, sigOut;
  // aSig is the portion of the dividend which hasn't yet been processed.
  // bSig is the zero-extended divisor
  reg signed [NSIG+2:0] aSig, bSig,rSig;
  // qSig is the temporary value used to calculate qSig in the always
  // block.
  reg [NSIG+2:0] qSig;
  wire qSign = a[NEXP+NSIG]^b[NEXP+NSIG];
  wire inexact;
  
  reg [NEXP+NSIG:0] alwaysQ; // Quotient generated inside the
                             // always block.
  integer i;

  always @(*)
    begin
        qSig = 0;
        aSig = {2'b00, aSigWire};
        bSig = {2'b00, bSigWire};
        normExp = 0;
        for (i = 0; i < NSIG+3; i = i + 1)
          begin
            rSig = aSig - bSig;
            qSig = {qSig[NSIG+1:0], ~rSig[NSIG+2]};
            aSig = {(rSig[NSIG+2] ? aSig[NSIG+1:0] : rSig[NSIG+1:0]), 1'b0};
          end
    
        // Renormalize if the MSB of the significand quotient is zero.
        normExp[0] = ~qSig[NSIG+2];
        expIn = aExp - bExp - normExp;
        qSig = qSig << ~qSig[NSIG+2];
        qExp = expOut + 15;
        alwaysQ = {qSign, qExp[NEXP-1:0], qSig[NSIG-1:0]};
    end      
  assign q = alwaysQ;
  
endmodule



`timescale 1ns/1ps
module div_tb (
);
reg[15:0] A,B;
wire [15:0] Q; 
fp_div uut(.a(A),.b(B),.q(Q));

initial begin
    A=16'b1_10010_0100000000;
    B=16'b0_10001_0100000000;
    #4000;
    $finish;
end

initial begin
    $monitor("A=%b / B=%b =\nQ=%b",A,B,Q);
end
endmodule