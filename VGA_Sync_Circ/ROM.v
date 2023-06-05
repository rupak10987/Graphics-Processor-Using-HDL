module ROM 
#(parameter addr_width = 8,data_width=32)
(
    input wire [addr_width-1:0]read_addr,
    output wire [data_width-1:0]read_data
);
reg [data_width-1:0]data;
always@(*)
begin
case (read_addr)
    8'b0000_0000:data=1;
    8'b0000_0001:data=2;
    8'b0000_0010:data=30;
    8'b0000_0011:data=40;
    default:data=0; 
endcase    
end
assign read_data=data;
endmodule

