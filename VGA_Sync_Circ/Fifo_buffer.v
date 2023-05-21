module buffer
#(parameter B = 4, W=4) (
    input wire clk,reset,wr,rd,
    input wire [B-1:0] w_data,
    output wire[B-1:0] r_data,
    output wire full,empty
);
reg[B-1:0] _Buffer [2**W-1:0];//main buffer
reg[W-1:0] rd_reg_ptr,rd_reg_next,rd_reg_succ;
reg[W-1:0] wr_reg_ptr,wr_reg_next,wr_reg_succ; 
reg full_reg, empty_reg, full_next, empty_next; 
wire wr_en;

//write
assign wr_en=~full_reg & wr;
always @(posedge clk)
    if(wr_en)
        _Buffer[wr_reg_ptr]<=w_data;
//read
assign r_data =_Buffer[rd_reg_ptr];
//mmem
always @(posedge clk,posedge reset) begin
    if(reset)
    begin
        rd_reg_ptr<=0;
        rd_reg_next<=0;
        rd_reg_succ<=1;
        wr_reg_ptr<=0;
        wr_reg_next<=0;
        wr_reg_succ<=1;
        full_reg<=1'b0;
        empty_reg<=1'b1;
    end
    else 
    begin
        rd_reg_ptr<=rd_reg_next;
        wr_reg_ptr<=wr_reg_next;
        empty_reg<=empty_next;
        full_reg<=full_next;
    end
end
//next
always @* begin
    wr_reg_succ=wr_reg_ptr+1;
    rd_reg_succ=rd_reg_ptr+1;
    //defaults
    wr_reg_next=wr_reg_ptr;
    rd_reg_next=rd_reg_next;
    full_next=full_reg;
    empty_next=empty_reg;
    case ({wr,rd})
        //2'b00:do nothing
        2'b01:
        if(~empty_reg)
            begin
            rd_reg_next=rd_reg_succ;
            full_next=1'b0;
            if(rd_reg_succ==wr_reg_ptr)
                empty_next=1'b1;  
            end 
        2'b10:
        if(~full_reg)
        begin
         wr_reg_next=wr_reg_succ;
         empty_next=1'b0;
         if (wr_reg_succ==rd_reg_ptr)
         full_next=1'b1;
        end
        2'b11:
        begin
            wr_reg_next=wr_reg_succ;
            rd_reg_next=rd_reg_succ;
        end
    endcase
end
assign full=full_reg;
assign empty=empty_reg;
endmodule

//tb
`timescale 1ns/10ps
module tb ();
localparam B = 8;
localparam W = 4;
reg clk,reset,wr,rd;
reg [B-1:0] w_data;
wire[B-1:0] r_data;
wire full,empty;   
buffer #(.B(B),.W(W))uut(
    .clk(clk),
    .reset(reset),
    .wr(wr),
    .rd(rd),
    .w_data(w_data),
    .r_data(r_data),
    .full(full),
    .empty(empty)
);
always
begin
clk=~clk;
#20;    
end

initial begin
    clk=0;
    reset=1'b1;
    #20;
    reset=1'b0;
    #20;
    wr=1'b1;
    rd=1'b0;
    w_data=8'b0000_0000;
    #40;
    w_data=4'b0000_0001;
    #40;
    w_data=4'b0000_0010;
    #40;
    w_data=4'b0000_0011;
    #40;
    w_data=4'b0000_0100;
    #40;
    wr=1'b0;
    rd=1'b1;
    #120;
    $finish;
end

initial begin
$monitor("clk=%b|reset=%b|wr=%b|rd=%b|full=%b|empty=%b || w_data=%b || rd_data=%b",clk,reset,wr,rd,full,empty,w_data,r_data);    
end
endmodule