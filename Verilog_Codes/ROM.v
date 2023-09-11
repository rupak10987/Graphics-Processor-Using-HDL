module ROM 
#(parameter addr_width = 8,data_width=32)
(
    input wire [addr_width-1:0]read_addr,
    output wire [data_width-1:0]read_data
);
reg [data_width-1:0]data;
always@(*)
begin
case (read_addr)//model
    8'b0000_0000:data=10;//triangle 1
    8'b0000_0001:data=20;
    8'b0000_0010:data=800;
    8'b0000_0011:data=35;
    8'b0000_0100:data=40;
    8'b0000_0101:data=660;
    8'b0000_0110:data=30;
    8'b0000_0111:data=60;
    8'b0000_1000:data=700;
    8'b0000_1001:data=36;//triangle 2
    8'b0000_1010:data=41;
    8'b0000_1011:data=660;
    8'b0000_1100:data=31;
    8'b0000_1101:data=61;
    8'b0000_1110:data=700;
    8'b0000_1111:data=45;
    8'b0001_0000:data=50;
    8'b0001_0001:data=750;
    default:data=0; 
endcase    
end
assign read_data=data;
endmodule

